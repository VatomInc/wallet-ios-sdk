import WebKit

struct PendingRequest {
    var resolve: (Any) -> Void // Assuming your resolution doesn't need to return a value
    var reject: (Error) -> Void // Reject should accept an 'Error' to pass to the 'throw'
    var timer: DispatchSourceTimer?
}

struct BaseVatomMessage: Codable {
    let id: String
    let name: String?
    let request: Bool
    let error: String?
}

struct VatomMessage<Payload: Codable> {
    let id: String
    let name: String?
    let request: Bool
    let payload: Payload
    let error: String?
}

enum MessageError: Error {
    case handlerNotFound(String)
    case errorFromMessage(String)
    case timeout(String)
}

extension VatomMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, request, payload, error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        request = try container.decode(Bool.self, forKey: .request)
        error = try container.decodeIfPresent(String.self, forKey: .error)

        let payloadString = try container.decode(String.self, forKey: .payload)
        if let data = payloadString.data(using: .utf8) {
            payload = try JSONDecoder().decode(Payload.self, from: data)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .payload,
                                                   in: container,
                                                   debugDescription: "Payload string could not be converted to Data")
        }
    }
}

public class VatomMessageHandler: NSObject, WKScriptMessageHandler {
    var pending: [String: PendingRequest] = [:]
    var handlers: [String: (Any) throws -> Any] = [:]
    private var asyncHandlers = [String: (Any) async -> Any]()

    var webview: WKWebView
    var userContentController: WKUserContentController

    init(userContentController: WKUserContentController, webview: WKWebView) {
        self.webview = webview
        self.userContentController = userContentController
        super.init()
        webview.configuration.userContentController.add(self, name: "vatomMessageHandler")
    }

    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Received message:", message.body, type(of: message.body))

        // Convert message.body to Data if it's a string
        guard let jsonString = message.body as? String,
              let jsonData = jsonString.data(using: .utf8)
        else {
            print("The message body is not a valid JSON string.")
            return
        }

        let decoder = JSONDecoder()

        switch message.body {
        case let bodyString as String:
            print("message.body is a String")
            let jsonData = Data(bodyString.utf8)
            do {
                // TODO: Remove this as all responses are properly typed
                let message = try decoder.decode(VatomMessage<VatomUser>.self, from: jsonData)
                let baseMessage = try decoder.decode(BaseVatomMessage.self, from: jsonData)

                guard let pendingPromise = pending[baseMessage.id] else {
                    print("[Vatom VatomWallet] No pending request for ID \(baseMessage.id)")
                    return
                }

                if let error = baseMessage.error {
                    pendingPromise.reject(MessageError.errorFromMessage(error))
                } else {
                    pendingPromise.resolve(jsonData)
                }

                pending.removeValue(forKey: baseMessage.id)
                return
            } catch {
                print("Error decoding JSON: \(error)")
                print("JSONData", jsonData)
            }
        // Handle the String case
        case is Data:
            print("message.body is Data")
        // Handle the Data case
        default:
            print("message.body is of an unknown type")
        }

        // Now deserialize the JSON data into a dictionary
        Task.detached {
            do {
                if var messageDictionary = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    print("Incoming payload", messageDictionary)
                    if let payloadBool = messageDictionary["payload"] as? Bool {
                        print("Payload is a boolean:", payloadBool) // This should print true or false
                        messageDictionary["payload"] = payloadBool
                        try await self.onMessage(messageDictionary)

                    } else if let payloadData = (messageDictionary["payload"] as? String)?.data(using: .utf8) {
                        // Try to deserialize the payload string into a dictionary or an array
                        do {
                            if let payloadDictionary = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any] {
                                // Handle payload as a dictionary
                                print("Incoming payload dictionary", payloadDictionary)
                                messageDictionary["payload"] = payloadDictionary
                            } else if let payloadArray = try JSONSerialization.jsonObject(with: payloadData) as? [[String: Any]] {
                                // Handle payload as an array
                                print("Incoming payload array", payloadArray)
                                messageDictionary["payload"] = payloadArray
                            } else {
                                print("Warning: Payload is neither a dictionary nor an array.")
                            }
                        } catch {
                            print("Warning: Failed to parse payload. Using original payload string.")
                        }
                    } else {
                        print("Could not get payload data.")
                    }
                    print("Received message dictionary:", messageDictionary)
                    try await self.onMessage(messageDictionary)
                } else {
                    print("Could not interpret the message body as a dictionary.")
                }
            } catch {
                print("Error deserializing JSON data:", error)
            }
        }
    }

    func onMessage(_ e: Any) async throws {
        guard let data = e as? [String: Any] else { return }
        guard let id = data["id"] as? String else { return }
        guard let request = data["request"] as? Bool else { return }
        let name = data["name"] as? String ?? "no name"

        let payload = data["payload"]

        guard let error = data["error"] as? String? else { return }
        if !id.isEmpty {
            if request {
                do {
                    let result = try await executeCallback(name: name, value: payload)
                    sendPayload(["id": id, "payload": result, "request": false])
                } catch {
                    sendPayload(["id": id, "error": error.localizedDescription, "request": false])
                }
            } else {
                guard let pendingPromise = pending[id] else {
                    print("[Vatom VatomWallet] No pending request for ID \(id)")
                    return
                }

                if let error = error {
                    pendingPromise.reject(MessageError.errorFromMessage(error))
                } else {
                    pendingPromise.resolve(payload as Any)
                }

                pending.removeValue(forKey: id)
            }
        }
    }

    func sendPayload(_ payload: [String: Any]) {
        do {
            // Serialize the valid payload to JSON string
            let jsonString = try validateAndSerializeJSON(payload: payload)

            // Inject the JSON directly, without escaping quotes
            let javascriptCommand = "window.postMessage(\(jsonString));"
            print("Sending json", jsonString)
            // Use the JSON string in the JavaScript code
            try webview.evaluateJavaScript(javascriptCommand)
        } catch {
            print("Error sending message: \(error)")
        }
    }

    func validateAndSerializeJSON(payload: [String: Any]) throws -> String {
        var validPayload = [String: Any]()

        for (key, value) in payload {
            // Unwrap the optional values
            let unwrappedValue = unwrapOptional(value)

            // Skip non-serializable values like functions
            if !(unwrappedValue is () -> Void) && JSONSerialization.isValidJSONObject([unwrappedValue]) {
                validPayload[key] = unwrappedValue
            } else {
                print("Warning: The value for key '\(key)' fis not a valid JSON object. The value is '\(unwrappedValue)'. It will be skipped.")
            }
        }

        let jsonData = try JSONSerialization.data(withJSONObject: validPayload)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "JSONError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create a JSON string from the payload."])
        }
        return jsonString
    }

    private func unwrapOptional(_ value: Any) -> Any {
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle != .optional {
            return value
        }

        if mirror.children.isEmpty {
            return NSNull()
        }

        let (_, some) = mirror.children.first!
        return some
    }

    func deserializeAndValidateJSON(jsonString: String) throws -> [String: Any] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "JSONError", code: 1, userInfo: [NSLocalizedDescriptionKey: "The JSON string cannot be converted to Data."])
        }

        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
        guard let payload = jsonObject as? [String: Any] else {
            throw NSError(domain: "JSONError", code: 2, userInfo: [NSLocalizedDescriptionKey: "The JSON data cannot be converted to a dictionary."])
        }

        for (key, value) in payload {
            if !JSONSerialization.isValidJSONObject([value]) {
                throw NSError(domain: "JSONError", code: 3, userInfo: [NSLocalizedDescriptionKey: "The value for key '\(key)' is not a valid JSON object."])
            }
        }

        return payload
    }

    func sendMsg(name: String, payload: Any? = nil) async throws -> Any {
        // Create unique ID for this request
        let id = UUID().uuidString
        // Send payload
        print("[Vatom VatomWallet] Sending request to other side: id=\(id), name=\(name)")
        sendPayload(["id": id, "name": name, "payload": payload, "request": true])
        // Create pending promise
        let response = await try withUnsafeThrowingContinuation { continuation in
            // Create timeout timer
            let timer = DispatchSource.makeTimerSource()
            timer.schedule(deadline: .now() + 15)
            timer.setEventHandler {
                // Fail it
                self.pending[id]?.reject(MessageError.timeout("Timed out waiting for response."))
                self.pending[id] = nil
            }
            timer.resume()
            // Store pending promise
            self.pending[id] = PendingRequest(
                resolve: continuation.resume, reject: { _ in
                    print("MessageError.errorFromMessage(error.localizedDescription)")
                }
            )
        }

        print("Message response", response)
        return response
    }

    // Once we type all payloads we can remove the other one
    func sendMsg2<PayloadType: Codable>(name: String, payload: Any? = nil) async throws -> PayloadType {
        let id = UUID().uuidString
        // Send payload
        print("[Vatom VatomWallet] Sending request to other side: id=\(id), name=\(name)")
        sendPayload(["id": id, "name": name, "payload": payload, "request": true])
        // Create pending promise
        let thing = await try withUnsafeThrowingContinuation { continuation in
            // Create timeout timer
            let timer = DispatchSource.makeTimerSource()
            timer.schedule(deadline: .now() + 15)
            timer.setEventHandler {
                // Fail it
                self.pending[id]?.reject(MessageError.timeout("Timed out waiting for response."))
                self.pending[id] = nil
            }
            timer.resume()
            // Store pending promise
            self.pending[id] = PendingRequest(
                resolve: { result in
                    continuation.resume(returning: result as! Data)
                }, reject: { _ in
                    print("MessageError.errorFromMessage(error.localizedDescription)")
                }
            )
        }

        let decodedPayload = try JSONDecoder().decode(VatomMessage<PayloadType>.self, from: thing)
        return decodedPayload.payload
    }

    func handle(name: String, callback: @escaping (Any) -> Any) {
        handlers[name] = callback
    }

    func handle(name: String, callback: @escaping (Any) async -> Any) {
        asyncHandlers[name] = callback
    }

    func executeCallback(name: String, value: Any) async -> Any {
        // Try to execute the synchronous handler if it exists
        if let syncCallback = handlers[name] {
            do {
                return try syncCallback(value)
            } catch {
                return "Error occurred: \(error)"
            }
        }
        // Try to execute the asynchronous handler if it exists
        if let asyncCallback = asyncHandlers[name] {
            print("Doing async call back for ", name)
            return await asyncCallback(value)
        }
        // Handle the case where there's no callback registered
        // Return a default value or an error indication as appropriate
        return "No handler registered for \(name)"
    }
}

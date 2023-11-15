import Foundation
import WebKit

public class VatomWallet: WKWebView, WKNavigationDelegate, WKUIDelegate {
    var businessId: String?
    var accessToken: String?
    var view: UIView?
    let webConfig = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    var config: [String: Any?]?
    

    private lazy var vatomMessageHandler: VatomMessageHandler = {
        let handler = VatomMessageHandler(userContentController: contentController, webview: self)
        return handler
    }()

    private lazy var locationHandler: VatomLocationHandler = {
        let handler = VatomLocationHandler()
        return handler
    }()

    private lazy var cameraHandler: VatomCameraAccessHandler = {
        let handler = VatomCameraAccessHandler()
        return handler
    }()

    public init(businessId: String = "", accessToken: String, view: UIView, config: [String: Any?]?) {
        webConfig.userContentController = contentController
        webConfig.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfig.allowsInlineMediaPlayback = true
        self.config = config
        let scriptSource = """
        sessionStorage.setItem('isIosEmbedded','true');
        localStorage.setItem("VATOM_ACCESS_TOKEN","\(accessToken)");
        sessionStorage.setItem('isEmbedded','true');
        sessionStorage.setItem('embeddedType','ios');
        """

        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webConfig.userContentController.addUserScript(script)
        super.init(frame: view.bounds, configuration: webConfig)
        vatomMessageHandler.handle(name: "vatomwallet:pre-init", callback: initSDK)
        vatomMessageHandler.handle(name: "vatomwallet:getCurrentPosition", callback: getCurrentPosition)
        self.businessId = businessId
        self.accessToken = accessToken
        self.view = view
        super.navigationDelegate = self
        super.uiDelegate = self
        if #available(iOS 16.4, *) {
            self.isInspectable = true
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @discardableResult
    public func load() -> WKNavigation? {
        var url = "https://wallet.localhost:3000"
        if businessId != "" {
            url = url + "/b/" + businessId!
        }
        if let url = URL(string: url) {
            let req = URLRequest(url: url)
            return super.load(req)
        } else {
            return nil
        }
        return nil
    }

    public func getCameraPermission() async -> Bool? {
        let permission = await cameraHandler.requestCameraAccess()

        return permission
    }

    @available(iOS 15.0, *)
    public func webView(_: WKWebView, requestMediaCapturePermissionFor _: WKSecurityOrigin, initiatedByFrame _: WKFrameInfo, type _: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }

    public func getCurrentPosition(data _: Any) async -> Any? {
        let location = await locationHandler.getCurrentPosition()
        if let coords = location?.coordinate {
            return [
                "coords": [
                    "latitude": coords.latitude,
                    "longitude": coords.longitude
                ]
            ]
        }

        return nil
    }

    public func initSDK(data _: Any) async {
        do {
            try await vatomMessageHandler.sendMsg(name: "wallet-sdk-init", payload:
                [
                    "accessToken": accessToken,
                    "embeddedType": "ios",
                    "businessId": businessId,
                    "config": self.config
                ])
        } catch {
            print("init sdk error", error)
        }
    }

    public func getTabs() async -> Any? {
        do {
            let tabs = try await vatomMessageHandler.sendMsg(name: "walletsdk:getBusinessTabs", payload: [])
            return tabs
        } catch {
            print("Error getting tabs")
        }
        return nil
    }

    public func isLoggedIn() async -> Bool? {
        do {
            let loggedIn = try await vatomMessageHandler.sendMsg(name: "walletsdk:isLoggedIn", payload: [])
            return loggedIn as! Bool
        } catch {
            print("Error checking login status")
        }
        return nil
    }

    public func performAction(tokenId: String, actionName: String, payload: Any?) async -> Any? {
        do {
            let result = try await vatomMessageHandler.sendMsg(name: "walletsdk:performAction", payload: ["tokenId": tokenId, "actionName": actionName, "actionPayload": payload ?? []])
            return result
        } catch {
            print("Error performing action")
        }
        return nil
    }

    public func combineTokens(thisTokenId: String, otherTokenId: String) async -> Any? {
        do {
            let result = try await vatomMessageHandler.sendMsg(name: "walletsdk:combineToken", payload: ["thisTokenId": thisTokenId, "otherTokenId": otherTokenId])
            return result
        } catch {
            print("Error combining tokens")
        }
        return nil
    }

    public func trashToken(tokenId: String) async -> Any? {
        do {
            let result = try await vatomMessageHandler.sendMsg(name: "walletsdk:trashToken", payload: ["tokenId": tokenId])
            return result
        } catch {
            print("Error trashing token")
        }
        return nil
    }

    public func getToken(tokenId: String) async -> Any? {
        do {
            let token = try await vatomMessageHandler.sendMsg(name: "walletsdk:getToken", payload: ["tokenId": tokenId])
            return token
        } catch {
            print("Error getting token")
        }
        return nil
    }

    public func getPublicToken(tokenId: String) async -> Any? {
        do {
            let token = try await vatomMessageHandler.sendMsg(name: "walletsdk:getPublicToken", payload: ["tokenId": tokenId])
            return token
        } catch {
            print("Error getting public token")
        }
        return nil
    }

    public func getPublicProfile(userId: String?) async -> Any? {
        do {
            let profile = try await vatomMessageHandler.sendMsg(name: "walletsdk:getPublicProfile", payload: ["userId": userId ?? ""])
            return profile
        } catch {
            print("Error getting public profile")
        }
        return nil
    }

    public func getUser() async -> VatomUser? {
        do {
            let user: VatomUser = try await vatomMessageHandler.sendMsg2(name: "walletsdk:getCurrentUser", payload: [])
            print("AQUI GET USER ", user)
            return user
        } catch {
            print("error getting user")
        }
        return nil
    }

    public func listTokens() async -> [Any]? {
        do {
            let tokens: [Any] = try await vatomMessageHandler.sendMsg(name: "walletsdk:listTokens") as! [Any]
            return tokens
        } catch {
            print("error getting user")
        }
        return nil
    }

    public func webView(_: WKWebView,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Check the type of challenge
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            print("Server trust challenge requested")

            if let serverTrust = challenge.protectionSpace.serverTrust {
                // Create a credential from the server trust
                let credential = URLCredential(trust: serverTrust)
                // Pass the credential back to the completion handler
                completionHandler(.useCredential, credential)
                print("Server trust challenge handled with credential")
            } else {
                // For some reason, the server trust couldn't be obtained, so we cancel the authentication challenge
                completionHandler(.cancelAuthenticationChallenge, nil)
                print("Server trust challenge cancelled - serverTrust is nil")
            }
        } else {
            // If this isn't a server trust challenge, we tell the web view to perform the default handling
            completionHandler(.performDefaultHandling, nil)
            print("Performed default handling for non-server trust challenge")
        }
    }

    public func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation: \(error.localizedDescription)")
    }

    let tabsRoutesAllowed = ["Home", "Wallet", "Map", "MapAr", "Connect"] // Allowed routes
    public func navigateToTab(_ tabRoute: String, params: [String: Any]? = nil) async throws {
        let tabsRoutesAllowed = ["Home", "Wallet", "Map", "MapAr", "Connect"] // Allowed routes

        guard tabsRoutesAllowed.contains(tabRoute) else {
            throw NSError(domain: "InvalidRouteError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Route not allowed \(tabRoute), allowed \(tabsRoutesAllowed)"])
        }

        var parameters: [String: Any] = ["route": tabRoute]
        parameters["params"] = ["businessId": businessId] // Assuming businessId is a property of this class
        if let params = params {
            parameters.merge(params) { _, new in new }
        }

        try await vatomMessageHandler.sendMsg(name: "walletsdk:navigateToTab", payload: parameters)
    }
}

//
//  File.swift
//
//
//  Created by Luis Palacios on 10/11/2023.
//

import Foundation

public struct Location: Codable {
    let country: String
    let latitude: Double
    let locality: String?
    let longitude: Double
    let postalCode: String?
    let region: String?
}

public struct UserData: Codable {
    let bio: String?
    let defaultBusinessId: String?
    let defaultSpaceId: String?
    let email: String?
    let emailVerified: Bool?
    let location: Location?
    let name: String?
    let phoneNumber: String?
    let phoneNumberVerified: Bool?
    let picture: String?
    let sub: String?
    let expiresAt: Int?
    let updatedAt: Int?
    let walletAddress: String?
    let website: String?
    let guest: Bool?
    let deferredDeeplink: String?
}


public struct VatomConfig: Codable {
    public var hideNavigation: Bool
    public var hideTokenActions: Bool
    public var disableNewTokenToast: Bool
    public var scanner: ScannerConfig
    public var pageConfig: PageConfig
    public var mapStyle: [MapStyleElement]?
    public var baseUrl: String?
    public var hideDrawer: Bool
    public var language: String?


    public init( baseUrl: String? = nil, hideNavigation: Bool = false,hideDrawer: Bool = false,  hideTokenActions: Bool = false, language: String? = "en", disableNewTokenToast: Bool, scanner: ScannerConfig, pageConfig: PageConfig, mapStyle: [MapStyleElement]? = nil) {
        self.hideNavigation = hideNavigation
        self.hideDrawer = hideDrawer
        self.language = language
        self.hideTokenActions = hideTokenActions
        self.disableNewTokenToast = disableNewTokenToast
        self.scanner = scanner
        self.pageConfig = pageConfig
        self.mapStyle = mapStyle
        self.baseUrl = baseUrl
    }

    public struct ScannerConfig: Codable {
        public var enabled: Bool

        public init(enabled: Bool) {
            self.enabled = enabled
        }
    }

    public struct PageConfig: Codable {
        public var theme: Theme
        public var text: [String: String]
        public var features: Features

        public init(theme: Theme, text: [String: String], features: Features) {
            self.theme = theme
            self.text = text
            self.features = features
        }

        public struct Theme: Codable {
            public var header: [String: String]
            public var iconTitle: [String: String]
            public var icon: [String: String]
            public var main: [String: String]
            public var emptyState: [String: String]
            public var mode: String
            public var pageTheme: String

            public init(header: [String: String], iconTitle: [String: String], icon: [String: String], main: [String: String], emptyState: [String: String], mode: String, pageTheme: String) {
                self.header = header
                self.iconTitle = iconTitle
                self.icon = icon
                self.main = main
                self.emptyState = emptyState
                self.mode = mode
                self.pageTheme = pageTheme
            }
        }

        public struct Features: Codable {
            public var notifications: [String: String]
            public var card: [String: String]
            public var footer: Footer

            public init(notifications: [String: String], card: [String: String], footer: Footer) {
                self.notifications = notifications
                self.card = card
                self.footer = footer
            }

            public struct Footer: Codable {
                public var enabled: Bool
                public var icons: [Icon]

                public init(enabled: Bool, icons: [Icon]) {
                    self.enabled = enabled
                    self.icons = icons
                }

                public struct Icon: Codable {
                    public var link: String?
                    public var src: String?

                    public var title: String
                    public var id: String

                    public init(src: String? = nil,link: String? = nil,  title: String, id: String) {
                        self.link = link
                        self.src = src
                        self.title = title
                        self.id = id
                    }
                }
            }
        }
    }

    public struct MapStyleElement: Codable {
        public var elementType: String?
        public var featureType: String?
        public var stylers: [[String: String]]

        public init(elementType: String?, featureType: String?, stylers: [[String: String]]) {
            self.elementType = elementType
            self.featureType = featureType
            self.stylers = stylers
        }
    }
}


extension VatomConfig {
    func toDictionary() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            return dictionary as? [String: Any]
        } catch {
            print("Error converting VatomConfig to dictionary: \(error)")
            return nil
        }
    }
}

extension VatomConfig {
    public static func loadMapStyles(from url: URL) throws -> [MapStyleElement] {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let mapStyles = try decoder.decode([MapStyleElement].self, from: data)
        return mapStyles
    }
}

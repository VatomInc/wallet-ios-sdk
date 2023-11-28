# Vatom™ Swift SDK

Welcome to the Vatom™ Swift SDK, a robust tool designed for seamless integration of the Vatom™ Wallet into iOS applications. This SDK enables swift and efficient digital asset management in your Swift applications, enhancing the user experience with comprehensive wallet functionalities.

## Installation

Add the Vatom™ Wallet SDK to your iOS project using CocoaPods:

```bash
pod install vatom-wallet-sdk
```

## iOS Permissions and Configuration

### Info.plist Configuration

Update your `Info.plist` file with the following entries to ensure proper functionality:

```xml
<key>NSCameraUsageDescription</key>
<string>Allow $(PRODUCT_NAME) to access your camera</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>App requires geolocation to improve the quality of the service</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location when in the background.</string>
```


## Usage

Swift integration of the Vatom™ Wallet SDK is straightforward. Initialize the wallet and utilize its features in your iOS application.

### Example

```swift
import UIKit
import VatomWalletSwiftSDK

class ViewController: UIViewController, UIScrollViewDelegate {
    var vatom: VatomWallet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        Get the access token & refresh token after the token-exchange and pass it to the VatomWallet
        let vatomAccessToken = ""
        let refreshToken = ""
        let businessId = ""
        
        
        let vatomConfigFeatures: [String: Any] = [
            "hideNavigation": false,
            "hideTokenActions": true,
            "disableNewTokenToast": true,
            "scanner": ["enabled": false],
            "pageConfig": [
                "theme": [
                    "header": ["logo": "https://resources.vatom.com/a8BxS4bNj9/UR_Logo.png"],
                    "iconTitle": [:],
                    "icon": [:],
                    "main": [:],
                    "emptyState": [:],
                    "mode": "dark",
                    "pageTheme": "dark",
                ],
                "text": ["emptyState": ""],
                "features": [
                    "notifications": [:],
                    "card": [:],
                    "footer": [
                        "enabled": true,
                        "icons": [
                            [
                                "src": "https:sites.vatom.com/a8BxS4bNj9",
                                "title": "Home",
                                "id": "home",
                            ],
                            [
                                "title": "Connect",
                                "id": "connect",
                            ],
                            [
                                "title": "Map",
                                "id": "map",
                            ],
                        ],
                    ],
                    "vatom": [:],
                ],
            ],
        ]
         
        self.vatom = VatomWallet(businessId: businessId, accessToken:vatomAccessToken,view: self.view, config: vatomConfigFeatures, refreshToken: refreshToken)
        view.addSubview(vatom!)
        
        vatom?.scrollView.delegate = self
        vatom?.scrollView.bounces = false
        vatom?.scrollView.bouncesZoom = false
        
        vatom?.load()
    }
    
```

### VatomWalletConfig Properties

- `scannerEnabled`: Boolean value to enable or disable the scanner feature.
- `tokenActionsHidden`: Boolean value to show or hide token actions.
- `newTokenToastDisabled`: Boolean value to enable or disable new token toast notifications.

## SDK Functions

- `navigateToTab(tabName:parameters:)`: Navigate to a specific tab within the app.
- `getCurrentUser()`: Retrieve the current user's information.
- `performAction(tokenId:actionName:payload:)`: Perform a specific action on a token.
- `trashToken(tokenId:)`: Remove or delete a token.
- `getToken(tokenId:)`: Retrieve information about a specific token.
- `getPublicToken(tokenId:)`: Retrieve public information about a token.
- `listTokens()`: Get a list of tokens owned by the user.
- `isLoggedIn()`: Check if the user is logged in.
- `logOut()`: Initiate the log-out process.
- `openCommunity(communityId:roomId:)`: Open a community or a specific room within a community.
- `openNFTDetail(tokenId:)`: Open the NFT detail screen for a specific token.

---


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
import vatom_wallet_sdk

class ViewController: UIViewController, UIScrollViewDelegate {
    var wallet: VatomWallet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vatomAccessToken = ""
        let refreshToken = ""
        let businessId = "nQwtevgfOa"
        let experienceUrl = "https://vatom.com"
        let mapStyles = self.loadMapStyles()

        
        let config = VatomConfig(
            baseUrl: "https://wallet.localhost:3000",
            hideNavigation: false,
            hideDrawer: false,
            hideTokenActions: true,
            disableNewTokenToast: true,
            scanner: .init(enabled: false),
            pageConfig: .init(
                theme: .init(
                    header: ["logo": "https://resources.vatom.com/a8BxS4bNj9/UR_Logo.png"],
                    iconTitle: [:],
                    icon: [:],
                    main: [:],
                    emptyState: [:],
                    mode: "dark",
                    pageTheme: "dark"
                ),
                text: ["emptyState": ""],
                features: .init(
                    notifications: [:],
                    card: [:],
                    footer: .init(
                        enabled: true,
                        icons: [
                            .init(link: experienceUrl, title: "Home", id: "home"),
                            .init(title: "Connect", id: "connect"),
                            .init(title: "Map", id: "map")
                        ]
                    )
                )
            ),
            mapStyle: mapStyles
        )
        
        
        
        self.wallet = VatomWallet(businessId: businessId, accessToken:vatomAccessToken,view: self.view, config: config, refreshToken: refreshToken)
        view.addSubview(wallet!)
        
        wallet?.scrollView.delegate = self
        
        wallet?.load()

    }

    private func loadMapStyles () ->  [VatomConfig.MapStyleElement]? {
        var mapStyles: [VatomConfig.MapStyleElement]?

         if let mapStylesUrl = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
            do {
                mapStyles = try VatomConfig.loadMapStyles(from: mapStylesUrl)
            } catch {
                print("Error loading map styles: \(error)")
            }
            
        }
        
        return mapStyles
    }
}
    
```







## VatomConfig Properties

- **language**: The "language" field is used to specify the language setting for an application. The default language is English ("en"). This field allows users to customize the language in which the app's content is displayed, providing a localized and personalized experience. (e.g., "es" for Spanish)

- **hideNavigation**: Set this property to `false` if you want to show the wallet navigation. The default value is `true`.

- **hideDrawer**: Set to `false` by default, deactivates the drawer, rendering it inaccessible. Developers can customize this option to control the initial availability of the drawer, ensuring its activation or deactivation based on specific app requirements.

- **scanner**: Configure the scanner feature with the following options:

  - **enabled**: Set to `false` to hide the scanner icon on the home page; The default value is `true`.

- **disableNewTokenToast**: Disables the toast notification for new tokens. Default is false.

- **hideTokenActions**: Hides token actions UI. Default is `false`.

- **pageConfig**: Configuration for the page layout, including features like icons and footer.
  - **features**: Specifies the features for the page.
    - **icon**: Configuration for icons on the page.
      - **badges**: Enables or disables badges. Default is `true`.
      - **editions**: Enables or disables editions. Default is `true`.
      - **titles**: Enables or disables titles. Default is `true`.
    - **footer**: Configuration for the footer on the page.
      - **enabled**: Enables or disables the footer. Default is `true`.
      - **icons**: List of footer icons, each having an ID, source, and title.

These properties allow you to customize the behavior of the wallet according to your preferences.

## navigateToTab()

The `navigateToTab` function allows navigation to a specific tab in the application, providing a tab route and optional parameters.

```swift
  await wallet.navigateToTab("Map");
```

### Parameters

- tabRoute (String): The route of the tab to navigate to.
- params (optional): Additional navigation parameters that can be passed to the tab.

### Example

```swift
  await wallet.navigateToTab("Connect", ["paramKey": "paramValue"]);

```
## navigate()

The `navigate` function facilitates navigation within the wallet SDK by sending a message to trigger a specific route.

### Parameters:

- **`route` (String)**: The route to navigate to within the wallet SDK.
- **`params` [String: Any]? (optional)**: Additional parameters to be passed along with the navigation request.

### Usage:

```swift
// Example 1: Navigate to a route without additional parameters.
wallet.navigate("home");

// Example 2: Navigate to a route with additional parameters.
wallet.navigate("profile", ["any": "..."]);
```

## openCommunity()

The `openCommunity` function facilitates the opening of a community within the wallet SDK. It sends a message to the wallet SDK to navigate to a specific community, and optionally to a specific room within that community.

### Parameters:

- **`communityId` (String)**: The unique identifier of the community to be opened.
- **`roomId` (String)?**: The unique identifier of the room within the community to navigate to.

### Usage:

```swift
// Example: Open a community without specifying a room.
await wallet.openCommunity(communityId: "communityId");

// Example: Open a specific room within a community.
await wallet.openCommunity(communityId: "communityId", roomId: "roomId");
```

## listTokens()

The `listTokens` function is intended to be called by the host application to retrieve a list of tokens owned by the user within the wallet SDK.

### Usage:

```swift
var userTokens = await wallet.listTokens();
```

## getToken()

The `getToken` function is intended to be called by the host application to retrieve information about a specific token in the user's wallet inventory.

### Parameters:

- **`tokenId`** (`String`): The unique identifier of the token for which information is requested.

### Returns:

```swift
[
  "id":"320ca...",
  "type":"vatom",
  "parentId":".",
  "owner":"b02...",
  "author":"739f...",
  "lastOwner":"739f..."
  "modified":1697142415000,
  "shouldShowNotification":true,
  "created":1695758987000,
  ...
]
```

### Usage:

```swift
var tokenInfo = await wallet.getToken(tokenId: "id");
```

## getPublicToken()

The `getPublicToken` function is designed to be called by the host application to retrieve information about a public token that is not neccessarily in the user's wallet inventory (e.g. dropped on the map)


### Parameters:

- **`tokenId`** (`String`): The unique identifier of the token for which public information is requested.

### Returns:

```swift
{
  "id":"320ca...",
  "type":"vatom",
  "parentId":".",
  "owner":"b02...",
  "author":"739f...",
  "lastOwner":"739f..."
  "modified":1697142415000,
  "shouldShowNotification":true,
  "created":1695758987000,
  ...
}
```

### Usage:

```swift
var publicTokenInfo = await wallet.getPublicToken('tokenId123');
```

## openToken()

The `openToken` function facilitates the navigation to the NFT detail screen within the wallet SDK.

### Parameters:

- **`tokenId` (String)**: The unique identifier of the NFT for which the detail screen should be opened.

### Usage:

```swift
// Example: Open the NFT detail screen for a specific token.
await wallet.openToken("abc123");
```

## trashToken()

The `trashToken` function is designed to be called by the host application to initiate the removal or deletion of a specific token within the wallet SDK.

### Parameters:

- **`tokenId`** (`String`): The unique identifier of the token to be trashed or deleted.

### Usage:

```swift
await wallet.trashToken(tokenId: "id")
```


## performAction()

The `performAction` function is intended to be called by the host application to initiate a specific action on a token within the wallet SDK.

### Parameters:

- **`tokenId`** (`String`): The unique identifier of the token on which the action will be performed.
- **`actionName`** (`String`): The name of the action to be executed on the token.
- **`payload`** (`Object?`): An optional payload containing additional data required for the specified action. It can be `null` if no additional data is needed.


### Usage:

```swift
await wallet.performAction("tokenId123", "activate", ["foo": "bar"]);
```

## isLoggedIn()

The `isLoggedIn` function allows the host application to check whether the user is currently logged in to the wallet SDK.

### Usage:

```swift
var userLoggedIn = await wallet.isLoggedIn();
if (userLoggedIn) {
  // User is logged in, perform actions accordingly.
} else {
  // User is not logged in, handle the scenario appropriately.
}
```

## getCurrentUser()

The `getCurrentUser` function is used to retrieve the current user's data from the wallet SDK. It sends a message to the wallet SDK to fetch the user data and returns a `Future` containing a `UserData` object.

### Returns:

an instance of the following struct
```swift

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

public struct Location: Codable {
    let country: String
    let latitude: Double
    let locality: String?
    let longitude: Double
    let postalCode: String?
    let region: String?
}

```

### Usage:

```swift
var currentUser = await wallet.getCurrentUser();
if (currentUser != null) {
  // Use the user data for various purposes.
  print("User Name: ", user.name);
} else {
  // Handle the scenario where user data retrieval fails.
  print("Error fetching user data.");
}
```

## logOut()

The `logOut` function initiates the log-out process in the wallet SDK by sending a message to trigger the log-out action.

### Usage:

```swift
// Example: Initiate the log-out process.
await wallet.logOut();
```

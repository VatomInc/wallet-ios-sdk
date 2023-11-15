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

struct ScannerFeatures: Codable {
    let enabled: Bool?
}

struct PageThemeHeader: Codable {
    let logo: String
}

struct PageThemeIconTitle: Codable {
    // Define properties if needed
}

struct PageThemeIcon: Codable {
    // Define properties if needed
}

struct PageThemeMain: Codable {
    // Define properties if needed
}

struct PageThemeEmptyState: Codable {
    // Define properties if needed
}

struct PageTheme: Codable {
    let header: PageThemeHeader
    let iconTitle: PageThemeIconTitle
    let icon: PageThemeIcon
    let main: PageThemeMain
    let emptyState: PageThemeEmptyState
    let mode: String
    let pageTheme: String
}

struct PageText: Codable {
    let emptyState: String
}

struct PageFeaturesNotifications: Codable {
    // Define properties if needed
}

struct PageFeaturesCard: Codable {
    // Define properties if needed
}

struct PageFeaturesFooterIcon: Codable {
    let id: String
    let src: String
    let title: String
}

struct PageFeaturesFooter: Codable {
    let enabled: Bool
    let icons: [PageFeaturesFooterIcon]
}

struct PageFeaturesVatom: Codable {
    // Define properties if needed
}

struct PageFeatures: Codable {
    let notifications: PageFeaturesNotifications
    let card: PageFeaturesCard
    let footer: PageFeaturesFooter
    let vatom: PageFeaturesVatom
}

struct PageConfig: Codable {
    let theme: PageTheme
    let text: PageText
    let features: PageFeatures
}

struct VatomConfigFeatures: Codable {
    let pageConfig: PageConfig?
    let baseUrl: String?
    let language: String?
    let scanner: ScannerFeatures?
    let visibleTabs: [String]?
    let hideNavigation: Bool?
    let hideTokenActions: Bool?
    let disableNewTokenToast: Bool?
}





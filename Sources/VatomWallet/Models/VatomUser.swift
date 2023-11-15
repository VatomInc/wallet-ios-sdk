//
//  File.swift
//  
//
//  Created by Luis Palacios on 15/11/2023.
//

import Foundation


public struct VatomUser: Codable {
    public var bio: String?
    public var defaultBusinessID: String
    public var defaultSpaceID: String?
    public var email: String
    public var emailVerified: Bool
    public var location: Location
    public var name: String
    public var phoneNumber: String?
    public var phoneNumberVerified: Bool
    public var picture: String?
    public var sub: String
    public var expiresAt: Int64
    public var updatedAt: Int
    public var walletAddress: String?
    public var website: String?
    public var guest: Bool
    public var deferredDeeplink: String?

    public enum CodingKeys: String, CodingKey {
        case bio, email, location, name, picture, sub, guest
        case defaultBusinessID = "default_business_id"
        case defaultSpaceID = "default_space_id"
        case emailVerified = "email_verified"
        case phoneNumber = "phone_number"
        case phoneNumberVerified = "phone_number_verified"
        case expiresAt = "expires_at"
        case updatedAt = "updated_at"
        case walletAddress = "wallet_address"
        case deferredDeeplink = "deferred_deeplink"
    }
}

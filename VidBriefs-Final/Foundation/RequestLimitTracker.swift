//
//  RequestLimitTracker.swift
//  VidBriefs-Final
//
//  Created by Alfie Nurse on 18/11/2023.
//

import Foundation
import UIKit
import Security
/*
    Imports essential libraries:
    - Foundation: Provides fundamental utilities.
    - UIKit: Used for accessing device-specific information.
    - Security: Used for secure storage in the keychain.
*/

class KeychainHelper {
    /*
        Provides helper methods for saving and loading data securely using the keychain.
    */

    static func save(_ data: Data, service: String, account: String) {
        // Saves data securely to the keychain
        let query = [
            kSecClass as String: kSecClassGenericPassword, // Specifies the item class
            kSecAttrService as String: service, // Service identifier
            kSecAttrAccount as String: account, // Account identifier
            kSecValueData as String: data // Data to save
        ] as [String: Any] // Constructs a dictionary with keychain attributes and values

        SecItemDelete(query as CFDictionary) // Deletes existing item if it exists
        SecItemAdd(query as CFDictionary, nil) // Adds the new item to the keychain
    }

    static func load(service: String, account: String) -> Data? {
        // Loads data securely from the keychain
        let query = [
            kSecClass as String: kSecClassGenericPassword, // Specifies the item class
            kSecAttrService as String: service, // Service identifier
            kSecAttrAccount as String: account, // Account identifier
            kSecReturnData as String: kCFBooleanTrue!, // Specifies that the data should be returned
            kSecMatchLimit as String: kSecMatchLimitOne // Limits the search to one item
        ] as [String: Any]

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        // Copies the matching keychain item if it exists

        if status == noErr { // If the item is found
            return dataTypeRef as? Data // Returns the data
        } else {
            return nil // Returns nil if the item is not found
        }
    }
}

struct RequestLimitTracker {
    /*
        Tracks the number of requests made by the user and limits the frequency
        to prevent abuse. Records are stored securely in the keychain.
    */

    static let service = "YourAppRequestTracker" // Service identifier for keychain
    static let account = "RequestRecords" // Account identifier for keychain

    static func addTimestamp() {
        // Adds the current timestamp to the request records for the device
        guard let deviceId = getDeviceIdentifier() else { return }

        var requestRecords = getRequestRecords() // Retrieves existing request records
        var timestamps = requestRecords[deviceId.uuidString, default: []] // Retrieves timestamps for the device
        timestamps.append(Date()) // Appends the current date and time
        requestRecords[deviceId.uuidString] = timestamps // Updates the records

        saveRequestRecords(requestRecords) // Saves updated records to the keychain
    }

    static func getDeviceIdentifier() -> UUID? {
        // Retrieves a unique identifier for the device
        return UIDevice.current.identifierForVendor
    }

    static func isRequestAllowed() -> Bool {
        // Checks if the number of requests within the last week is within the allowed limit
        guard let deviceId = getDeviceIdentifier() else { return false }

        let requestRecords = getRequestRecords() // Retrieves existing request records
        let timestamps = requestRecords[deviceId.uuidString, default: []] // Retrieves timestamps for the device
        let oneWeekAgo = Date().addingTimeInterval(-604800) // Calculates the date one week ago

        let recentTimestamps = timestamps.filter { $0 > oneWeekAgo } // Filters timestamps from the last week
        return recentTimestamps.count < 3 // Allows if less than 3 requests in the last week
    }

    private static func getRequestRecords() -> [String: [Date]] {
        // Retrieves request records from the keychain
        if let data = KeychainHelper.load(service: service, account: account),
           let records = try? JSONDecoder().decode([String: [Date]].self, from: data) {
            return records // Returns decoded records
        }
        return [:] // Returns empty records if decoding fails or no data exists
    }

    private static func saveRequestRecords(_ records: [String: [Date]]) {
        // Saves request records to the keychain
        if let data = try? JSONEncoder().encode(records) {
            KeychainHelper.save(data, service: service, account: account)
        }
    }
}
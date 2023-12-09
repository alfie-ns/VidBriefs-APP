//
//  RequestLimitTracker.swift
//  VidBriefs-Final
//
//  Created by Alfie Nurse  on 18/11/2023.
//

import Foundation
import UIKit
import Security

class KeychainHelper {
    
    static func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ] as [String: Any]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(service: String, account: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == noErr {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
}


struct RequestLimitTracker {
    static let service = "YourAppRequestTracker"
    static let account = "RequestRecords"

    static func addTimestamp() {
        guard let deviceId = getDeviceIdentifier() else { return }

        var requestRecords = getRequestRecords()
        var timestamps = requestRecords[deviceId.uuidString, default: []]
        timestamps.append(Date())
        requestRecords[deviceId.uuidString] = timestamps

        saveRequestRecords(requestRecords)
    }
    
    static func getDeviceIdentifier() -> UUID? {
            return UIDevice.current.identifierForVendor
        }

    static func isRequestAllowed() -> Bool {
        guard let deviceId = getDeviceIdentifier() else { return false }

        let requestRecords = getRequestRecords()
        let timestamps = requestRecords[deviceId.uuidString, default: []]
        let oneWeekAgo = Date().addingTimeInterval(-604800)

        let recentTimestamps = timestamps.filter { $0 > oneWeekAgo }
        return recentTimestamps.count < 3
    }

    private static func getRequestRecords() -> [String: [Date]] {
        if let data = KeychainHelper.load(service: service, account: account),
           let records = try? JSONDecoder().decode([String: [Date]].self, from: data) {
            return records
        }
        return [:]
    }

    private static func saveRequestRecords(_ records: [String: [Date]]) {
        if let data = try? JSONEncoder().encode(records) {
            KeychainHelper.save(data, service: service, account: account)
        }
    }
}


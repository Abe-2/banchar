

import Foundation

struct Keychain {
    // Constant Identifiers
    static let userAccount = Bundle.main.bundleIdentifier! + ".keychainAccount" // or anything else
    static let accessGroup = "com.alnajat.keychainGroup" // or anything else
    
    // Arguments for the keychain queries
    static let kSecClassValue = NSString(format: kSecClass)
    static let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
    static let kSecValueDataValue = NSString(format: kSecValueData)
    static let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
    static let kSecAttrServiceValue = NSString(format: kSecAttrService)
    static let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
    static let kSecReturnDataValue = NSString(format: kSecReturnData)
    static let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
    
    static func has(_ service: String) -> Bool {
        let value = get(service)
        return !(value == nil || value == "")
    }
    
    static func set(_ data: String, for service: String) {
        guard let dataFromString: Data = data.data(using: String.Encoding.utf8, allowLossyConversion: false) else { return }
        
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [Keychain.kSecClassGenericPasswordValue, service, Keychain.userAccount, dataFromString], forKeys: [Keychain.kSecClassValue, Keychain.kSecAttrServiceValue, Keychain.kSecAttrAccountValue, Keychain.kSecValueDataValue])
        
        SecItemDelete(keychainQuery as CFDictionary)
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    static func get(_ service: String) -> String? {
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [Keychain.kSecClassGenericPasswordValue, service, Keychain.userAccount, kCFBooleanTrue ?? true, Keychain.kSecMatchLimitOneValue], forKeys: [Keychain.kSecClassValue, Keychain.kSecAttrServiceValue, Keychain.kSecAttrAccountValue, Keychain.kSecReturnDataValue, Keychain.kSecMatchLimitValue])
        
        var dataTypeRef :AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: NSString? = nil
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
            }
        }
        
        if let resault = contentsOfKeychain {
            return String(describing: resault)
        } else {
            return nil
        }
    }
}

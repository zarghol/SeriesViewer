//
//  Extensions.swift
//  SeriesViewer
//
//  Created by Clément NONN on 28/10/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

extension String {
    var MD5String: String {
        if let str = self.cStringUsingEncoding(NSUTF8StringEncoding) {
            let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
            let digestLen = Int(CC_MD5_DIGEST_LENGTH)
            let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
            
            CC_MD5(str, strLen, result)
            
            var hash = NSMutableString()
            for i in 0..<digestLen {
                hash.appendFormat("%02x", result[i])
            }
            
            result.destroy()
            return String(hash)
            
        }
        return self
    }
    
    var intValue: Int {
        let nsself = self as NSString
        return nsself.integerValue ?? 0
    }
    
    var floatValue: Float {
        let nsself = self as NSString
        return nsself.floatValue ?? 0.0
    }
}

//extension Array {
//    func contains<U>(element: U) -> Bool {
//        return contains(self, x:element)
//    }
//}

extension Dictionary {
    
    func mapKeys<U> (transform: Key -> U) -> [U] {
        var results: [U] = []
        for k in self.keys {
            results.append(transform(k))
        }
        return results
    }
    
    func mapValues<U> (transform: Value -> U) -> [U] {
        var results: [U] = []
        for v in self.values {
            results.append(transform(v))
        }
        return results
    }
    
    func map<U> (transform: Value -> U) -> [U] {
        return self.mapValues(transform)
    }
    
    func map<U> (transform: (Key, Value) -> U) -> [U] {
        var results: [U] = [U]()
        for k in self.keys {
            results.append(transform(k as Key, self[k]! as Value))
        }
        return results
    }
    
    func map<K: Hashable, V> (transform: (Key, Value) -> (K, V)) -> [K: V] {
        var results: [K: V] = [:]
        for k in self.keys {
            if let value = self[ k ] {
                let (u, w) = transform(k, value)
                results.updateValue(w, forKey: u)
            }
        }
        return results
    }
}
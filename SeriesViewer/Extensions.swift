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
            
            return String(format: hash)
            
        }
        return self
    }
}


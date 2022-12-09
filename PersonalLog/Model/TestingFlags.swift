//
//  TestingFlags.swift
//  PersonalLog
//
//  Created by Joseph Wardell on 12/9/22.
//

import Foundation

struct TestingFlags {
    
    static var `default`: TestingFlags { TestingFlags() }
    
    var offsetDateForNewEntries: Bool {
#if DOIT // negate this to get the behavior
#warning("Date offset for new entries is turned on. DO NOT COMMIT!!!!")
        return true
#else
        return false
#endif
    }
}

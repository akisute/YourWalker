//
//  SwiftASL.swift
//  YourWalker
//
//  Created by Ono Masashi on 2014/12/15.
//  Copyright (c) 2014年 akisute. All rights reserved.
//
//  Heavily inspired from nloko/NLOSyslog
//  (https://github.com/nloko/NLOSyslog)
//

import Foundation

/// A private struct that provides constant values.
private struct ASLKeys {
    private static let pid = String(format: "%s", ASL_KEY_PID)
    private static let timestamp = String(format: "%s", ASL_KEY_TIME)
    private static let sender = String(format: "%s", ASL_KEY_SENDER)
    private static let message = String(format: "%s", ASL_KEY_MSG)
}

/// A struct that represents a line of Apple Simple Logger (ASL).
public struct ASLLine {
    public var pid: Int
    public var timestamp: NSDate
    public var sender: String
    public var message: String
    
    private init(pid: Int, timestamp: NSDate, sender: String, message: String) {
        self.pid = pid
        self.timestamp = timestamp
        self.sender = sender
        self.message = message
    }
    
    private init(entry: Dictionary<String, String>) {
        let pidString = entry[ASLKeys.pid]! as NSString
        self.pid = pidString.integerValue
        let timestampString = entry[ASLKeys.timestamp]! as NSString
        self.timestamp = NSDate(timeIntervalSince1970: timestampString.doubleValue)
        self.sender = entry[ASLKeys.sender]!
        self.message = entry[ASLKeys.message]!
    }
}

/// Apple Simple Logger (ASL) client. ASL is also known as NSLog.
/// 
/// Requires `#include <asl.h>` to be bridged in "Objective-C Bridging Header".
public class ASL {
    
    private var queue: dispatch_queue_t = dispatch_queue_create("com.akisute.SwiftASL.ASL.queue", DISPATCH_QUEUE_CONCURRENT)
    private var filterSeconds: Int? = nil
    private var filterSender: String? = nil
    private var filterMessage: String? = nil
    
    /// Adds a filter by seconds from now.
    /// If multiple filters of a same kind is set, the previous filter is overridden.
    public func filter(seconds _: Int64) -> ASL {
        return self
    }
    
    /// Adds a filter by sender that only passes when a line contains the given `sender`.
    /// If multiple filters of a same kind is set, the previous filter is overridden.
    public func filter(sender _: String) -> ASL {
        return self
    }
    
    /// Adds a filter by message that only passes when a line contains the given `message`.
    /// If multiple filters of a same kind is set, the previous filter is overridden.
    public func filter(message _: String) -> ASL {
        return self
    }
    
    /// Synchronously reads multiple lines that matches a given filter.
    /// If nothing matches, return a blank Array.
    public func readlines() -> [ASLLine] {
        
        let query = asl_new(UInt32(ASL_TYPE_QUERY))
        
        if let value = self.filterSeconds {
            let seconds = NSString(format: "%.0f", NSDate(timeIntervalSinceNow: NSTimeInterval(-value)).timeIntervalSince1970).cStringUsingEncoding(NSUTF8StringEncoding)
            asl_set_query(query, ASL_KEY_TIME, seconds, UInt32(ASL_QUERY_OP_GREATER))
        }
        if let value: NSString = self.filterSender {
            let sender = value.cStringUsingEncoding(NSUTF8StringEncoding)
            asl_set_query(query, ASL_KEY_SENDER, sender, UInt32(ASL_QUERY_OP_EQUAL | ASL_QUERY_OP_SUBSTRING))
        }
        if let value: NSString = self.filterMessage {
            let message = value.cStringUsingEncoding(NSUTF8StringEncoding)
            asl_set_query(query, ASL_KEY_MSG, message, UInt32(ASL_QUERY_OP_EQUAL | ASL_QUERY_OP_SUBSTRING))
        }
        
        let response = asl_search(COpaquePointer.null(), query)
        
        var results = Array<ASLLine>()
        var msg: aslmsg = asl_next(response)
        while (COpaquePointer.null() != msg) {
            var entry = Dictionary<String, String>()
            var n: UInt32 = 0
            var key = asl_key(msg, n)
            while (key != nil) {
                let value = asl_get(msg, key)
                let k = String(UTF8String: key)
                let v = String(UTF8String: value)
                if k != nil && v != nil {
                    entry[k!] = v!
                }
                n++
                key = asl_key(msg, n)
            }
            let line = ASLLine(entry: entry)
            results.append(line)
            msg = asl_next(response)
        }
        
        asl_release(response)
        asl_release(query)
        
        return results
    }
    
    /// Asynchronously reads a line, then dispatch a callback handler to the given queue.
    /// 
    /// @param queue - a dispatch queue that calls the given handler. Default is the main queue.
    /// @param handler - a callback handler.
    public func readlineAsync(queue: dispatch_queue_t? = dispatch_get_main_queue(), handler: (ASLLine) -> (Void)) {
        handler(ASLLine(pid: 1, timestamp: NSDate(), sender: "", message: ""))
    }
}


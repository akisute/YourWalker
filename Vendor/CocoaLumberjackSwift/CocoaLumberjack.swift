//  Created by Ullrich Schäfer on 16/08/14.
//  Updated by Masashi Ono (akisute) on 26/12/14.
//  
//  Tested on CocoaLumberjack 2.0.0 rc

// Bitmasks are a bit tricky in swift
// See http://natecook.com/blog/2014/07/swift-options-bitmask-generator/

// Refer DDLog.h
/*
typedef NS_OPTIONS(NSUInteger, DDLogFlag) {
DDLogFlagError      = (1 << 0), // 0...00001
DDLogFlagWarning    = (1 << 1), // 0...00010
DDLogFlagInfo       = (1 << 2), // 0...00100
DDLogFlagDebug      = (1 << 3), // 0...01000
DDLogFlagVerbose    = (1 << 4)  // 0...10000
};
*/
struct LogFlag : RawOptionSetType {
    private var value: Int32 = 0
    init(nilLiteral: ()) {}
    init(rawValue: Int32) { self.value = rawValue }
    var boolValue: Bool { return self.value != 0 }
    var rawValue: Int32 { return self.value }
    var DDLogFlagValue: DDLogFlag {
        switch self.value {
        case LogFlag.allZeros.rawValue:
            return DDLogFlag.allZeros
        case LogFlag.Error.rawValue:
            return DDLogFlag.Error
        case LogFlag.Warn.rawValue:
            return DDLogFlag.Warning
        case LogFlag.Info.rawValue:
            return DDLogFlag.Info
        case LogFlag.Debug.rawValue:
            return DDLogFlag.Debug
        case LogFlag.Verbose.rawValue:
            return DDLogFlag.Verbose
        default:
            return DDLogFlag.allZeros
        }
    }
    static var allZeros: LogFlag { return self(rawValue: 0) }
    static var Error:    LogFlag { return self(rawValue: 1 << 0) }
    static var Warn:     LogFlag { return self(rawValue: 1 << 1) }
    static var Info:     LogFlag { return self(rawValue: 1 << 2) }
    static var Debug:    LogFlag { return self(rawValue: 1 << 3) }
    static var Verbose:  LogFlag { return self(rawValue: 1 << 4) }
}
func == (lhs: LogFlag, rhs: LogFlag) -> Bool { return lhs.value == rhs.value }
func & (lhs: LogFlag, rhs: LogFlag) -> LogFlag { return LogFlag(rawValue: lhs.value & rhs.value) }
func | (lhs: LogFlag, rhs: LogFlag) -> LogFlag { return LogFlag(rawValue: lhs.value | rhs.value) }
func ^ (lhs: LogFlag, rhs: LogFlag) -> LogFlag { return LogFlag(rawValue: lhs.value ^ rhs.value) }
prefix func ~(x: LogFlag) -> LogFlag { return LogFlag(rawValue: ~x.value) }

// Refer DDLog.h
/*
typedef NS_ENUM(NSUInteger, DDLogLevel) {
DDLogLevelOff       = 0,
DDLogLevelError     = (DDLogFlagError),                       // 0...00001
DDLogLevelWarning   = (DDLogLevelError   | DDLogFlagWarning), // 0...00011
DDLogLevelInfo      = (DDLogLevelWarning | DDLogFlagInfo),    // 0...00111
DDLogLevelDebug     = (DDLogLevelInfo    | DDLogFlagDebug),   // 0...01111
DDLogLevelVerbose   = (DDLogLevelDebug   | DDLogFlagVerbose), // 0...11111
DDLogLevelAll       = NSUIntegerMax                           // 1111....11111 (DDLogLevelVerbose plus any other flags)
};
*/
struct LogLevel : RawOptionSetType {
    private var value: Int32 = 0
    init(nilLiteral: ()) {}
    init(rawValue: Int32) { self.value = rawValue }
    var boolValue: Bool { return self.value != 0 }
    var rawValue: Int32 { return self.value }
    var DDLogLevelValue: DDLogLevel { return DDLogLevel(rawValue: UInt(self.rawValue))! }
    static var allZeros: LogLevel { return self(rawValue: 0) }
    static var Off:      LogLevel { return self(rawValue: 0b0) }
    static var Error:    LogLevel { return self(rawValue: LogFlag.Error.rawValue) }
    static var Warn:     LogLevel { return self(rawValue: LogLevel.Error.rawValue | LogFlag.Warn.rawValue) }
    static var Info:     LogLevel { return self(rawValue: LogLevel.Warn.rawValue  | LogFlag.Info.rawValue) }
    static var Debug:    LogLevel { return self(rawValue: LogLevel.Info.rawValue  | LogFlag.Debug.rawValue) }
    static var Verbose:  LogLevel { return self(rawValue: LogLevel.Debug.rawValue | LogFlag.Verbose.rawValue) }
    static var All:      LogLevel { return self(rawValue: Int32.max) }
}
func == (lhs: LogLevel, rhs: LogLevel) -> Bool { return lhs.value == rhs.value }
func & (lhs: LogLevel, rhs: LogLevel) -> LogLevel { return LogLevel(rawValue: lhs.value & rhs.value) }
func | (lhs: LogLevel, rhs: LogLevel) -> LogLevel { return LogLevel(rawValue: lhs.value | rhs.value) }
func ^ (lhs: LogLevel, rhs: LogLevel) -> LogLevel { return LogLevel(rawValue: lhs.value ^ rhs.value) }
prefix func ~(x: LogLevel) -> LogLevel { return LogLevel(rawValue: ~x.value) }


// what's a better way than poluting the global scope?
var __logLevel: LogLevel?
var __logAsync: Bool?


// Use those class properties insted of `#define LOG_LEVEL_DEF` and `LOG_ASYNC_ENABLED`
extension DDLog {
    class var logLevel: LogLevel {
        get {
        return __logLevel ?? LogLevel.Error
        }
        set(logLevel) {
            __logLevel = logLevel
        }
    }
    
    class var logAsync: Bool {
        get {
        return (self.logLevel != LogLevel.Error) && (__logAsync ?? true)
        }
        set(logAsync) {
            __logAsync = logAsync
        }
    }
    
    class func logError (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) { log(.Error, message: message, function: function, file: file, line: line) }
    class func logWarn  (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) { log(.Warn,  message: message, function: function, file: file, line: line) }
    class func logInfo  (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) { log(.Info,  message: message, function: function, file: file, line: line) }
    class func logDebug (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) { log(.Debug, message: message, function: function, file: file, line: line) }
    
    private class func log (
        flag: LogFlag,
        message: String,
        // No need to pass those in. the defaults will do just fine
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int32 = __LINE__
        )
    {
        let level:LogLevel = DDLog.logLevel
        let async:Bool = (level != LogLevel.Error) && DDLog.logAsync
        
        if flag.rawValue & level.rawValue != 0 {
            let msg: DDLogMessage = DDLogMessage(
                message: message,
                level: level.DDLogLevelValue,
                flag: flag.DDLogFlagValue,
                context: UInt(0),
                file: file,
                function: function,
                line: UInt(line),
                tag: nil,
                options: DDLogMessageOptions.allZeros,
                timestamp: NSDate())
            DDLog.log(async, message: msg)
        }
    }
}

// Shorthands, what you'd expect
/* //Not possible due to http://openradar.appspot.com/radar?id=5773154781757440
let logError = DDLog.logError
let logWarn  = DDLog.logWarn
let logInfo  = DDLog.logInfo
let logDebug = DDLog.logDebug
*/
func logError (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) { DDLog.logError(message, function: function, file: file, line: line) }
func logWarn  (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) { DDLog.logWarn(message, function: function, file: file, line: line) }
func logInfo  (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) { DDLog.logInfo(message, function: function, file: file, line: line) }
func logDebug (message: String, function: String = __FUNCTION__, file: String = __FILE__, line: Int32 = __LINE__) { DDLog.logDebug(message, function: function, file: file, line: line) }
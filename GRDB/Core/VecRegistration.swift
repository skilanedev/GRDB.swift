import GRDBSQLite

struct VecRegistration {
    static let once: Void = {
        var pErrMsg: UnsafeMutablePointer<CChar>? = nil
        let rc = sqlite3_vec_init(nil, &pErrMsg, nil)
        if rc != 0 {
            let msg = pErrMsg != nil ? String(cString: pErrMsg!) : "Unknown error"
            if pErrMsg != nil {
                sqlite3_free(pErrMsg)
            }
            fatalError("sqlite-vec registration failed: \(msg) (code \(rc))")
        }
    }()
    
    static func register() {
        _ = once
    }
}
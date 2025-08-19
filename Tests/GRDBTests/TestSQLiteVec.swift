import XCTest
import GRDB

class TestSQLiteVec: XCTestCase {
    func testVecTableCreation() throws {
        let dbQueue = try DatabaseQueue()
        try dbQueue.write { db in
            try db.execute(sql: "CREATE VIRTUAL TABLE vec_test USING vec0(embedding float[384])")
            // Insert a dummy vector
            let embeddingBlob = Data((0..<384).map { _ in Float(0.0) }.withUnsafeBytes { Data($0) })
            try db.execute(sql: "INSERT INTO vec_test(rowid, embedding) VALUES (1, vec_f32(?))", arguments: [embeddingBlob])
            // Query
            let row = try Row.fetchOne(db, sql: "SELECT * FROM vec_test")
            XCTAssertNotNil(row)
        }
    }
}
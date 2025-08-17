// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "GRDB",
    platforms: [.macOS(.v11)],
    products: [
        .library(name: "GRDB", targets: ["GRDB"]),
    ],
    targets: [
        .binaryTarget(
            name: "SQLiteVec",
            path: "SQLiteVec.xcframework"
        ),
        .target(
            name: "GRDB",
            dependencies: ["SQLiteVec"],
            path: "Sources/GRDB"
        ),
        .testTarget(
            name: "GRDBTests",
            dependencies: ["GRDB"],
            path: "Tests/GRDBTests"
        )
    ]
)
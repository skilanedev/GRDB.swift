// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var swiftSettings: [SwiftSetting] = [
    .define("SQLITE_ENABLE_FTS5"),
    .define("SQLITE_ENABLE_LOAD_EXTENSION"),  // Optional, but harmless for Swift conditional compilation
]

var cSettings: [CSetting] = [
    .define("SQLITE_ENABLE_LOAD_EXTENSION"),  // Enables dynamic extension loading
    .define("SQLITE_ENABLE_FTS5"),  // For hybrid search
    .define("SQLITE_THREADSAFE", to: "1"),  // Multi-thread mode (GRDB default)
    .define("SQLITE_TEMP_STORE", to: "2"),  // Temp files in memory
    .define("SQLITE_DQS", to: "0"),  // Disable double-quoted strings as identifiers
    .define("SQLITE_OMIT_LOAD_EXTENSION", to: "0"),  // Explicitly include load extension (default, but safe)
    .define("SQLITE_OMIT_SHARED_CACHE", to: "1"),  // Disable shared cache for safety
    .define("SQLITE_OMIT_DEPRECATED", to: "1"),  // Omit deprecated features
    .define("SQLITE_OMIT_PROGRESS_CALLBACK", to: "1"),  // Omit progress callbacks
    .define("SQLITE_OMIT_DECLTYPE", to: "1"),  // Omit declared types
    .define("SQLITE_OMIT_AUTOINIT", to: "1"),  // Omit auto-init
    .define("SQLITE_USE_ALLOCA", to: "1"),  // Use alloca for memory
    .define("SQLITE_ENABLE_RTREE", to: "1"),  // Enable R*Tree (optional, but useful)
    .define("SQLITE_ENABLE_JSON1", to: "1"),  // Enable JSON functions (optional)
    .define("SQLITE_ENABLE_STAT4", to: "1"),  // Enable advanced stats
    .define("SQLITE_MAX_EXPR_DEPTH", to: "0"),  // No max expression depth
    .define("SQLITE_DEFAULT_MMAP_SIZE", to: "268435456"),  // 256MB mmap
    .define("NDEBUG", .when(configuration: .release))  // No debug in release
]

var dependencies: [PackageDescription.Package.Dependency] = []

// Don't rely on those environment variables. They are ONLY testing conveniences:
// $ SQLITE_ENABLE_PREUPDATE_HOOK=1 make test_SPM
if ProcessInfo.processInfo.environment["SQLITE_ENABLE_PREUPDATE_HOOK"] == "1" {
    swiftSettings.append(.define("SQLITE_ENABLE_PREUPDATE_HOOK"))
    cSettings.append(.define("GRDB_SQLITE_ENABLE_PREUPDATE_HOOK"))
}

// The SPI_BUILDER environment variable enables documentation building
// on <https://swiftpackageindex.com/groue/GRDB.swift>. See
// <https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/2122>
// for more information.
//
// SPI_BUILDER also enables the `make docs-localhost` command.
if ProcessInfo.processInfo.environment["SPI_BUILDER"] == "1" {
    dependencies.append(.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"))
}

let package = Package(
    name: "GRDB",
    defaultLocalization: "en", // for tests
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v7),
    ],
    products: [
        .library(name: "CSQLite", targets: ["CSQLite"]),
        .library(name: "GRDB", targets: ["GRDB"]),
        .library(name: "GRDB-dynamic", type: .dynamic, targets: ["GRDB"]),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "CSQLite",
            path: "Sources/CSQLite",  // Explicit path to sources
        ),  // Now a custom target compiling sqlite3.c with enables; no providers needed
        .target(
            name: "GRDB",
            dependencies: ["CSQLite"],
            path: "GRDB",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            cSettings: cSettings,
            swiftSettings: swiftSettings),
        .testTarget(
            name: "GRDBTests",
            dependencies: ["GRDB"],
            path: "Tests",
            exclude: [
                "CocoaPods",
                "Crash",
                "CustomSQLite",
                "GRDBManualInstall",
                "GRDBTests/getThreadsCount.c",
                "Info.plist",
                "Performance",
                "SPM",
                "Swift6Migration",
                "generatePerformanceReport.rb",
                "parsePerformanceTests.rb",
            ],
            resources: [
                .copy("GRDBTests/Betty.jpeg"),
                .copy("GRDBTests/InflectionsTests.json"),
                .copy("GRDBTests/Issue1383.sqlite"),
            ],
            cSettings: cSettings,
            swiftSettings: swiftSettings + [
                // Tests still use the Swift 5 language mode.
                .swiftLanguageMode(.v5),
                .enableUpcomingFeature("InferSendableFromCaptures"),
                .enableUpcomingFeature("GlobalActorIsolatedTypesUsability"),
            ])
    ],
    swiftLanguageModes: [.v6]
)
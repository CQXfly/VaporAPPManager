// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "AppManagerServer",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.5"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
//        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc.2"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0-rc.4.0.1"),
        .package(url: "https://github.com/CQXfly/QXTCPServer_Vapor", from: "0.3.1"),
    ],
    targets: [
        .target(name: "App", dependencies: [ "Vapor","FluentMySQL","QXTCPServer"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)


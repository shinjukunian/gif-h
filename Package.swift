// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gif-h",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "gif-h",
            targets: ["gif-h"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
    
        .target(name: "gif-h", dependencies: [], path: nil, exclude: [], sources: nil, publicHeadersPath: ".", cSettings: [.headerSearchPath("../c_gif-h/")], cxxSettings: nil, swiftSettings: nil, linkerSettings: nil ),
        
        .testTarget(
            name: "gif-hTests",
            dependencies: ["gif-h"]),
    ]
)

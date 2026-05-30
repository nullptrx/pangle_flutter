// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BUAdTestMeasurementPackage",
    platforms: [.iOS("13.0")],
    products: [
        .library(name: "BUAdTestMeasurement", targets: ["BUAdTestMeasurement"]),
    ],
    targets: [
        .binaryTarget(
            name: "BUAdTestMeasurement",
            url: "https://sf3-fe-tos.pglstatp-toutiao.com/obj/csj-sdk-static/Public/BUAdTestMeasurement/6.8.0.6/BUAdTestMeasurement.zip",
            checksum: "3f1220f99120ba247927ec0026ceb3a0d219e49db58212b4ceadb77a372453d4"
        ),
    ]
)

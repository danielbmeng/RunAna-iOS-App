import AppKit

let sourceURL = URL(fileURLWithPath: "RunAna/Tools/RunAnaIconSource.png")
let outputURL = URL(fileURLWithPath: "RunAna/RunAna/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
let pixelSize = 1024

guard let sourceImage = NSImage(contentsOf: sourceURL) else {
    fatalError("Missing source icon at \(sourceURL.path)")
}

let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: pixelSize,
    pixelsHigh: pixelSize,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)!

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
NSColor.white.setFill()
NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize).fill()
sourceImage.draw(
    in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize),
    from: NSRect(x: 0, y: 0, width: sourceImage.size.width, height: sourceImage.size.height),
    operation: .copy,
    fraction: 1
)
NSGraphicsContext.restoreGraphicsState()

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not render app icon.")
}

try png.write(to: outputURL)

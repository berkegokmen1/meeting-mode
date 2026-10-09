import AppKit
let root = CommandLine.arguments[1]
for size in [16, 32, 64, 128, 256, 512, 1024] {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let scale = CGFloat(size) / 1024
    let transform = NSAffineTransform(); transform.scale(by: scale); transform.concat()
    NSColor(calibratedRed: 0.08, green: 0.12, blue: 0.18, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 48, y: 48, width: 928, height: 928), xRadius: 210, yRadius: 210).fill()
    NSColor.white.setFill()
    NSBezierPath(roundedRect: NSRect(x: 230, y: 335, width: 390, height: 354), xRadius: 65, yRadius: 65).fill()
    let lens = NSBezierPath(); lens.move(to: NSPoint(x: 654, y: 435)); lens.line(to: NSPoint(x: 794, y: 355)); lens.line(to: NSPoint(x: 794, y: 669)); lens.line(to: NSPoint(x: 654, y: 589)); lens.close(); lens.fill()
    NSColor(calibratedRed: 0.20, green: 0.85, blue: 0.60, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(x: 274, y: 579, width: 60, height: 60)).fill()
    NSGraphicsContext.restoreGraphicsState()
    let data = bitmap.representation(using: .png, properties: [:])!
    let names: [Int: [String]] = [16:["icon_16x16"],32:["icon_16x16@2x","icon_32x32"],64:["icon_32x32@2x"],128:["icon_128x128"],256:["icon_128x128@2x","icon_256x256"],512:["icon_256x256@2x","icon_512x512"],1024:["icon_512x512@2x"]]
    for name in names[size]! { try data.write(to: URL(fileURLWithPath: root).appendingPathComponent(name + ".png")) }
}

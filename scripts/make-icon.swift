import AppKit

let outDir = CommandLine.arguments[1]
let space = CGColorSpace(name: CGColorSpace.sRGB)!

func render(size: Int) -> Data {
    let ctx = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: space,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    let s = CGFloat(size)
    ctx.translateBy(x: 0, y: s)
    ctx.scaleBy(x: 1, y: -1)

    let inset = s * 100 / 1024
    let body = s - inset * 2
    let u = body / 64
    ctx.translateBy(x: inset, y: inset)

    let tile = CGPath(roundedRect: CGRect(x: 0, y: 0, width: body, height: body), cornerWidth: u * 14.4, cornerHeight: u * 14.4, transform: nil)
    ctx.addPath(tile)
    ctx.setFillColor(CGColor(gray: 1, alpha: 1))
    ctx.fillPath()

    ctx.addPath(tile)
    ctx.clip()

    let notch = CGMutablePath()
    let r = u * 10
    notch.move(to: CGPoint(x: u * 16, y: -1))
    notch.addLine(to: CGPoint(x: u * 48, y: -1))
    notch.addArc(tangent1End: CGPoint(x: u * 48, y: u * 24), tangent2End: CGPoint(x: u * 38, y: u * 24), radius: r)
    notch.addArc(tangent1End: CGPoint(x: u * 16, y: u * 24), tangent2End: CGPoint(x: u * 16, y: u * 14), radius: r)
    notch.closeSubpath()
    ctx.addPath(notch)
    ctx.setFillColor(CGColor(gray: 0.07, alpha: 1))
    ctx.fillPath()

    ctx.addPath(tile)
    ctx.setStrokeColor(CGColor(gray: 0.07, alpha: 1))
    ctx.setLineWidth(max(2, u * 5))
    ctx.strokePath()

    let image = ctx.makeImage()!
    return NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])!
}

let specs: [(String, Int)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024),
]
for (name, size) in specs {
    try! render(size: size).write(to: URL(fileURLWithPath: "\(outDir)/\(name).png"))
}

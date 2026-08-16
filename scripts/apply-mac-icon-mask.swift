import AppKit
import CoreGraphics

guard CommandLine.arguments.count >= 3 else {
    fputs("Usage: apply-mac-icon-mask <input.png> <output.png>\n", stderr)
    exit(1)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
let dimension = 1024

guard let source = NSImage(contentsOf: inputURL) else {
    fputs("Could not read \(inputURL.path)\n", stderr)
    exit(1)
}

var drawRect = NSRect(x: 0, y: 0, width: dimension, height: dimension)
guard let cgImage = source.cgImage(forProposedRect: &drawRect, context: nil, hints: nil) else {
    fputs("Could not create CGImage\n", stderr)
    exit(1)
}

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let context = CGContext(
    data: nil,
    width: dimension,
    height: dimension,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fputs("Could not create bitmap context\n", stderr)
    exit(1)
}

let rect = CGRect(x: 0, y: 0, width: dimension, height: dimension)
context.clear(rect)

// macOS app-icon squircle (superellipse), matching Big Sur+ Dock icons.
let exponent: CGFloat = 5.0
let steps = 720
let a = rect.width / 2
let b = rect.height / 2
let cx = rect.midX
let cy = rect.midY
context.beginPath()
for i in 0...steps {
    let theta = (CGFloat(i) / CGFloat(steps)) * 2 * .pi
    let cosT = cos(theta)
    let sinT = sin(theta)
    let x = cx + copysign(pow(abs(cosT), 2 / exponent), cosT) * a
    let y = cy + copysign(pow(abs(sinT), 2 / exponent), sinT) * b
    if i == 0 {
        context.move(to: CGPoint(x: x, y: y))
    } else {
        context.addLine(to: CGPoint(x: x, y: y))
    }
}
context.closePath()
context.clip()
context.interpolationQuality = .high
context.draw(cgImage, in: rect)

guard let masked = context.makeImage() else {
    fputs("Could not export masked image\n", stderr)
    exit(1)
}

let rep = NSBitmapImageRep(cgImage: masked)
rep.size = NSSize(width: dimension, height: dimension)
guard let png = rep.representation(using: .png, properties: [:]) else {
    fputs("Could not encode PNG\n", stderr)
    exit(1)
}

try png.write(to: outputURL)
print("Wrote \(outputURL.path)")

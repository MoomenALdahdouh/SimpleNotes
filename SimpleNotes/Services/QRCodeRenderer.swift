import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum QRCodeRenderer {
    static func image(from payload: Data, dimension: CGFloat) -> NSImage? {
        image(from: payload, dimension: dimension, correction: "M")
            ?? image(from: payload, dimension: dimension, correction: "L")
    }

    private static func image(from payload: Data, dimension: CGFloat, correction: String) -> NSImage? {
        let generator = CIFilter.qrCodeGenerator()
        generator.message = payload
        generator.correctionLevel = correction
        guard let qr = generator.outputImage else { return nil }

        let color = CIFilter.falseColor()
        color.inputImage = qr
        color.color0 = CIColor(color: .black) ?? .black
        color.color1 = CIColor(color: .white) ?? .white
        guard let colored = color.outputImage else { return nil }

        let moduleSize = max(colored.extent.width, 1)
        let scale = max(dimension / moduleSize, 1)
        let scaled = colored.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let rect = scaled.extent.integral

        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let cgImage = context.createCGImage(scaled, from: rect) else { return nil }

        let image = NSImage(size: NSSize(width: dimension, height: dimension))
        image.addRepresentation(NSBitmapImageRep(cgImage: cgImage))
        return image
    }
}

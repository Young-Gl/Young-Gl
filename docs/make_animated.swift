import AppKit
import ImageIO
import UniformTypeIdentifiers

let W: CGFloat = 760, H: CGFloat = 190
let frames = 20
let fps = 10.0

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> NSColor {
    NSColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: a)
}

func drawFrame(_ t: Double) -> CGImage? {
    let img = NSImage(size: NSSize(width: W, height: H))
    img.lockFocus()

    // near-black base
    NSGradient(colors: [rgb(7,8,11,1), rgb(10,11,16,1)])!
        .draw(in: NSRect(x: 0, y: 0, width: W, height: H), angle: -90)

    let phase = t * 2 * .pi

    // single soft glow, drifting
    let gx = 200 + 140 * sin(phase)
    let gy = 70 + 30 * cos(phase * 0.7)
    NSGradient(colors: [rgb(20,110,255,0.22), rgb(20,110,255,0.0)])!
        .draw(in: NSBezierPath(ovalIn: NSRect(x: gx - 1400, y: gy - 1000, width: 2800, height: 2000)),
              relativeCenterPosition: .zero)

    // hairline top
    rgb(255,255,255,0.07).setFill()
    NSBezierPath(rect: NSRect(x: 0, y: H - 1, width: W, height: 1)).fill()

    // name
    NSAttributedString(string: "YOUNG", attributes: [
        .font: NSFont.systemFont(ofSize: 54, weight: .semibold),
        .foregroundColor: NSColor.white,
        .kern: 11
    ]).draw(at: NSPoint(x: 48, y: 82))

    // thin rule
    NSGradient(colors: [rgb(90,150,255,1), rgb(150,120,255,0.0)])!
        .draw(in: NSBezierPath(roundedRect: NSRect(x: 50, y: 66, width: 150, height: 1.5),
                               xRadius: 0.75, yRadius: 0.75), angle: 0)

    // role
    NSAttributedString(string: "MACOS  ·  SWIFTUI", attributes: [
        .font: NSFont.monospacedSystemFont(ofSize: 9.5, weight: .regular),
        .foregroundColor: rgb(125,132,148,1),
        .kern: 2.6
    ]).draw(at: NSPoint(x: 50, y: 40))

    img.unlockFocus()
    guard let tiff = img.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let cg = rep.cgImage else { return nil }
    return cg
}

let url = URL(fileURLWithPath: "assets/banner.gif")
guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, frames, nil) else {
    print("dest failed"); exit(1)
}
CGImageDestinationSetProperties(dest, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary)
let fp: [CFString: Any] = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1.0/fps]]
for i in 0..<frames {
    guard let cg = drawFrame(Double(i)/Double(frames)) else { continue }
    CGImageDestinationAddImage(dest, cg, fp as CFDictionary)
}
CGImageDestinationFinalize(dest)
print("ok")

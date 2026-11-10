import AppKit
import ImageIO
import UniformTypeIdentifiers

let W: CGFloat = 760, H: CGFloat = 190
let frames = 16
let fps = 12.0

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> NSColor {
    NSColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: a)
}

func drawFrame(_ t: Double) -> CGImage? {
    let img = NSImage(size: NSSize(width: W, height: H))
    img.lockFocus()

    NSGradient(colors: [rgb(6,7,11,1), rgb(12,14,22,1)])!
        .draw(in: NSRect(x: 0, y: 0, width: W, height: H), angle: -30)

    // drifting colour blobs
    let phase = t * 2 * .pi
    func blob(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, _ c: NSColor, _ alpha: CGFloat) {
        let rect = NSRect(x: cx - r, y: cy - r, width: r*2, height: r*2)
        NSGradient(colors: [c.withAlphaComponent(alpha), c.withAlphaComponent(0)])!
            .draw(in: NSBezierPath(ovalIn: rect), relativeCenterPosition: .zero)
    }

    let a: CGFloat = 0.62
    blob(150 + 70*sin(phase),            200 + 40*cos(phase),        300, rgb(10,132,255,1),  a)
    blob(400 + 90*cos(phase*0.8 + 1.1),  70  + 50*sin(phase*0.9),    330, rgb(110,91,255,1),  a*0.95)
    blob(650 + 80*sin(phase*0.7 + 2.0),  210 + 45*cos(phase*0.6),    300, rgb(255,55,95,1),   a*0.72)
    blob(850 + 70*cos(phase*0.5 + 0.4),  60  + 60*sin(phase*0.8+1.4),330, rgb(255,159,10,1),  a*0.66)
    blob(540 + 60*sin(phase*1.1 + 3.0),  240 + 30*cos(phase*0.8),    260, rgb(48,209,188,1),  a*0.50)

    NSGradient(colors: [rgb(0,0,0,0), rgb(0,0,0,0.42)])!
        .draw(in: NSRect(x: 0, y: 0, width: W, height: H), angle: -90)

    // accent line
    let lineRect = NSRect(x: 45, y: H - 60, width: 36, height: 2.5)
    NSGradient(colors: [rgb(10,132,255,1), rgb(191,90,242,1), rgb(255,55,95,1)])!
        .draw(in: NSBezierPath(roundedRect: lineRect, xRadius: 1.5, yRadius: 1.5), angle: 0)

    // name
    NSAttributedString(string: "YOUNG", attributes: [
        .font: NSFont.systemFont(ofSize: 62, weight: .bold),
        .foregroundColor: NSColor.white,
        .kern: 4.5
    ]).draw(at: NSPoint(x: 44, y: 47))

    // tagline
    NSAttributedString(string: "TURNING SUDO INTO BUTTONS, ONE SWIFTUI APP AT A TIME.", attributes: [
        .font: NSFont.monospacedSystemFont(ofSize: 10, weight: .regular),
        .foregroundColor: rgb(175,181,196,1),
        .kern: 1.1
    ]).draw(at: NSPoint(x: 45, y: 30))

    // right marks
    func right(_ s: String, _ y: CGFloat, _ size: CGFloat, _ color: NSColor, _ kern: CGFloat) {
        let a = NSAttributedString(string: s, attributes: [
            .font: NSFont.monospacedSystemFont(ofSize: size, weight: .regular),
            .foregroundColor: color, .kern: kern
        ])
        a.draw(at: NSPoint(x: W - 45 - a.size().width, y: y))
    }
    right("FLUXA", H - 70, 9, rgb(214,220,232,1), 2)
    right("POWER · BATTERIES", H - 84, 6.5, rgb(120,126,142,1), 1.6)
    right("BACKUP CONTROL", H - 104, 9, rgb(214,220,232,1), 2)
    right("RESTIC · ONEDRIVE", H - 118, 6.5, rgb(120,126,142,1), 1.6)

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
let props: [CFString: Any] = [
    kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]
]
CGImageDestinationSetProperties(dest, props as CFDictionary)
let frameProps: [CFString: Any] = [
    kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1.0/fps]
]
for i in 0..<frames {
    guard let cg = drawFrame(Double(i)/Double(frames)) else { continue }
    CGImageDestinationAddImage(dest, cg, frameProps as CFDictionary)
}
CGImageDestinationFinalize(dest)
print("ok")

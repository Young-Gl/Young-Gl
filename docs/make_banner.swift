import AppKit

let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "light"
let isDark = mode == "dark"
let NAME = CommandLine.arguments.count > 3 ? CommandLine.arguments[3] : "Lumen"

let W: CGFloat = 1200, H: CGFloat = 320
let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocus()

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor {
    NSColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: 1)
}

let paper = isDark ? rgb(14, 14, 15) : rgb(244, 243, 239)
let ink   = isDark ? rgb(239, 238, 233) : rgb(18, 18, 18)
let meta  = isDark ? rgb(128, 128, 124) : rgb(120, 118, 112)
let accent = isDark ? rgb(150, 168, 140) : rgb(86, 104, 76)

paper.setFill()
NSRect(x: 0, y: 0, width: W, height: H).fill()

// ---- portrait strip (left) ----
let stripW: CGFloat = 430
if let photo = NSImage(contentsOfFile: "assets/portrait.jpg") ?? NSImage(contentsOfFile: "assets/portrait.png") {
    let rect = NSRect(x: 0, y: 0, width: stripW, height: H)
    let iw = photo.size.width, ih = photo.size.height
    let scale = max(rect.width / iw, rect.height / ih)
    let dw = iw * scale, dh = ih * scale
    let drawRect = NSRect(x: rect.midX - dw/2, y: rect.midY - dh/2, width: dw, height: dh)
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(rect: rect).addClip()
    photo.draw(in: drawRect)
    // desaturate + tone
    (isDark ? rgb(10,12,10) : rgb(244,243,239)).withAlphaComponent(isDark ? 0.35 : 0.22).setFill()
    rect.fill()
    // fade into paper
    let fadeW: CGFloat = 110
    let g = NSGradient(colors: [paper.withAlphaComponent(0), paper.withAlphaComponent(1)])!
    g.draw(in: NSRect(x: stripW - fadeW, y: 0, width: fadeW, height: H), angle: 0)
    NSGraphicsContext.restoreGraphicsState()
}

// frame
meta.withAlphaComponent(0.28).setStroke()
let frame = NSBezierPath(rect: NSRect(x: 0.5, y: 0.5, width: W - 1, height: H - 1))
frame.lineWidth = 1
frame.stroke()

// ---- name ----
let nameFont = NSFont(name: "Georgia", size: 96) ?? NSFont.systemFont(ofSize: 96)
NSAttributedString(string: NAME, attributes: [
    .font: nameFont, .foregroundColor: ink, .kern: -1.5
]).draw(at: NSPoint(x: stripW + 46, y: 150))

// rule under name
accent.withAlphaComponent(0.9).setFill()
NSBezierPath(rect: NSRect(x: stripW + 48, y: 132, width: 92, height: 2)).fill()

// meta lines (monospace)
func mono(_ text: String, x: CGFloat, y: CGFloat, size: CGFloat, color: NSColor) {
    NSAttributedString(string: text, attributes: [
        .font: NSFont.monospacedSystemFont(ofSize: size, weight: .regular),
        .foregroundColor: color, .kern: 0.8
    ]).draw(at: NSPoint(x: x, y: y))
}

mono("FIELD NOTES / 2019 —", x: stripW + 48, y: 104, size: 11, color: meta)
mono("01  macOS TOOLS", x: stripW + 48, y: 84, size: 11, color: meta)
mono("02  ENCRYPTED BACKUP", x: stripW + 48, y: 64, size: 11, color: meta)

// right corner index
let idx = NSAttributedString(string: "LUMEN-001", attributes: [
    .font: NSFont.monospacedSystemFont(ofSize: 10, weight: .regular),
    .foregroundColor: meta.withAlphaComponent(0.75), .kern: 1.2
])
idx.draw(at: NSPoint(x: W - 40 - idx.size().width, y: H - 34))

img.unlockFocus()

if let tiff = img.tiffRepresentation,
   let rep = NSBitmapImageRep(data: tiff),
   let png = rep.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
    print("ok \(mode)")
}

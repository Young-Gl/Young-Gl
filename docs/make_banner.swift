import AppKit

let W: CGFloat = 1600, H: CGFloat = 400
let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocus()

// background
let bg = NSGradient(colors: [
    NSColor(srgbRed: 0.035, green: 0.039, blue: 0.055, alpha: 1),
    NSColor(srgbRed: 0.075, green: 0.082, blue: 0.110, alpha: 1)
])!
bg.draw(in: NSRect(x: 0, y: 0, width: W, height: H), angle: -35)

// soft glow
if let glow = NSGradient(colors: [
    NSColor(srgbRed: 0.04, green: 0.45, blue: 1.0, alpha: 0.16),
    NSColor(srgbRed: 0.04, green: 0.45, blue: 1.0, alpha: 0.0)
]) {
    glow.draw(in: NSBezierPath(ovalIn: NSRect(x: -900, y: -700, width: 2600, height: 1800)),
              relativeCenterPosition: NSPoint(x: 0, y: 0))
}

// bottom hairline
NSColor.white.withAlphaComponent(0.06).setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: W, height: 1)).fill()

// accent line
NSColor(srgbRed: 0.04, green: 0.52, blue: 1.0, alpha: 1).setFill()
NSBezierPath(rect: NSRect(x: 96, y: H - 150, width: 56, height: 4)).fill()

// name
let name = NSAttributedString(string: "YOUNG", attributes: [
    .font: NSFont.systemFont(ofSize: 132, weight: .bold),
    .foregroundColor: NSColor.white,
    .kern: 10
])
name.draw(at: NSPoint(x: 92, y: 108))

// tagline
let tag = NSAttributedString(string: "TURNING SUDO INTO BUTTONS, ONE SWIFTUI APP AT A TIME.", attributes: [
    .font: NSFont.monospacedSystemFont(ofSize: 21, weight: .regular),
    .foregroundColor: NSColor(srgbRed: 0.56, green: 0.60, blue: 0.68, alpha: 1),
    .kern: 2.2
])
tag.draw(at: NSPoint(x: 96, y: 72))

// right-side project marks
func rightText(_ text: String, y: CGFloat, size: CGFloat, color: NSColor, kern: CGFloat) {
    let a = NSAttributedString(string: text, attributes: [
        .font: NSFont.monospacedSystemFont(ofSize: size, weight: .regular),
        .foregroundColor: color,
        .kern: kern
    ])
    let w = a.size().width
    a.draw(at: NSPoint(x: W - 96 - w, y: y))
}

rightText("FLUXA", y: 148, size: 19, color: NSColor(srgbRed: 0.62, green: 0.66, blue: 0.74, alpha: 1), kern: 3)
rightText("POWER · BATTERIES", y: 120, size: 13, color: NSColor(srgbRed: 0.36, green: 0.39, blue: 0.46, alpha: 1), kern: 2.4)

rightText("BACKUP CONTROL", y: 78, size: 19, color: NSColor(srgbRed: 0.62, green: 0.66, blue: 0.74, alpha: 1), kern: 3)
rightText("RESTIC · ONEDRIVE", y: 50, size: 13, color: NSColor(srgbRed: 0.36, green: 0.39, blue: 0.46, alpha: 1), kern: 2.4)

img.unlockFocus()

if let tiff = img.tiffRepresentation,
   let rep = NSBitmapImageRep(data: tiff),
   let png = rep.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
    print("ok")
}

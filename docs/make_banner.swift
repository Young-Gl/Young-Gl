import AppKit

let W: CGFloat = 1600, H: CGFloat = 400
let isDark = CommandLine.arguments.count > 2 && CommandLine.arguments[2] == "dark"

let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocus()

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> NSColor {
    NSColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: a)
}

// base
let base = isDark
    ? NSGradient(colors: [rgb(6,7,11,1), rgb(11,13,20,1)])!
    : NSGradient(colors: [rgb(250,250,252,1), rgb(244,245,249,1)])!
base.draw(in: NSRect(x: 0, y: 0, width: W, height: H), angle: -30)

// colourful blobs
func blob(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, _ color: NSColor, _ alpha: CGFloat) {
    let rect = NSRect(x: cx - r, y: cy - r, width: r*2, height: r*2)
    let g = NSGradient(colors: [color.withAlphaComponent(alpha), color.withAlphaComponent(0)])!
    g.draw(in: NSBezierPath(ovalIn: rect), relativeCenterPosition: .zero)
}

let a: CGFloat = isDark ? 0.55 : 0.30

blob(240, 330, 460, rgb(10,132,255,1), a)        // blue
blob(640, 120, 520, rgb(110,91,255,1), a*0.95)   // violet
blob(1030, 300, 480, rgb(255,55,95,1), a*0.75)   // pink
blob(1360, 90, 520, rgb(255,159,10,1), a*0.68)   // amber
blob(880, 380, 420, rgb(48,209,188,1), a*0.55)   // teal

// subtle vignette for depth
if isDark {
    let v = NSGradient(colors: [rgb(0,0,0,0), rgb(0,0,0,0.45)])!
    v.draw(in: NSRect(x: 0, y: 0, width: W, height: H), angle: -90)
}

// accent line with gradient
let lineRect = NSRect(x: 96, y: H - 150, width: 72, height: 4)
let lineGrad = NSGradient(colors: [rgb(10,132,255,1), rgb(191,90,242,1), rgb(255,55,95,1)])!
let linePath = NSBezierPath(roundedRect: lineRect, xRadius: 2, yRadius: 2)
lineGrad.draw(in: linePath, angle: 0)

// name
let nameColor = isDark ? NSColor.white : rgb(8,8,12,1)
let name = NSAttributedString(string: "YOUNG", attributes: [
    .font: NSFont.systemFont(ofSize: 132, weight: .bold),
    .foregroundColor: nameColor,
    .kern: 10
])
name.draw(at: NSPoint(x: 92, y: 104))

// tagline
let tagColor = isDark ? rgb(170,176,190,1) : rgb(90,94,108,1)
let tag = NSAttributedString(string: "TURNING SUDO INTO BUTTONS, ONE SWIFTUI APP AT A TIME.", attributes: [
    .font: NSFont.monospacedSystemFont(ofSize: 21, weight: .regular),
    .foregroundColor: tagColor,
    .kern: 2.2
])
tag.draw(at: NSPoint(x: 96, y: 68))

// right-side marks
func rightText(_ text: String, y: CGFloat, size: CGFloat, color: NSColor, kern: CGFloat) {
    let a = NSAttributedString(string: text, attributes: [
        .font: NSFont.monospacedSystemFont(ofSize: size, weight: .regular),
        .foregroundColor: color,
        .kern: kern
    ])
    a.draw(at: NSPoint(x: W - 96 - a.size().width, y: y))
}

let markHi = isDark ? rgb(214,220,232,1) : rgb(40,42,52,1)
let markLo = isDark ? rgb(120,126,142,1) : rgb(120,124,136,1)

rightText("FLUXA", y: 148, size: 19, color: markHi, kern: 3)
rightText("POWER · BATTERIES", y: 120, size: 13, color: markLo, kern: 2.4)
rightText("BACKUP CONTROL", y: 78, size: 19, color: markHi, kern: 3)
rightText("RESTIC · ONEDRIVE", y: 50, size: 13, color: markLo, kern: 2.4)

img.unlockFocus()

if let tiff = img.tiffRepresentation,
   let rep = NSBitmapImageRep(data: tiff),
   let png = rep.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
    print("ok")
}

import AppKit

let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "light"
let isDark = mode == "dark"
let NAME = CommandLine.arguments.count > 3 ? CommandLine.arguments[3] : "Lumen"

let W: CGFloat = 1200, H: CGFloat = 300
let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocus()

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor {
    NSColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: 1)
}

let paper = isDark ? rgb(12, 12, 14) : rgb(247, 246, 243)
let ink   = isDark ? rgb(242, 241, 237) : rgb(17, 17, 17)
let faint = isDark ? rgb(110, 110, 116) : rgb(122, 120, 116)

paper.setFill()
NSRect(x: 0, y: 0, width: W, height: H).fill()

// hairline top + bottom
faint.withAlphaComponent(0.25).setFill()
NSBezierPath(rect: NSRect(x: 0, y: H - 1, width: W, height: 1)).fill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: W, height: 1)).fill()

// name — serif, tightly tracked
let nameFont = NSFont(name: "Georgia", size: 104) ?? NSFont.systemFont(ofSize: 104, weight: .regular)
NSAttributedString(string: NAME, attributes: [
    .font: nameFont,
    .foregroundColor: ink,
    .kern: -1.5
]).draw(at: NSPoint(x: 78, y: 108))

// small caps line
NSAttributedString(string: "M A C O S   T O O L S", attributes: [
    .font: NSFont.systemFont(ofSize: 10.5, weight: .regular),
    .foregroundColor: faint,
    .kern: 1.2
]).draw(at: NSPoint(x: 82, y: 70))

// right column: index + year
let right = [
    ("01 — FLUXA", 132.0),
    ("02 — BACKUP CONTROL", 108.0),
]
for (text, y) in right {
    let a = NSAttributedString(string: text, attributes: [
        .font: NSFont.systemFont(ofSize: 10, weight: .regular),
        .foregroundColor: faint,
        .kern: 1.4
    ])
    a.draw(at: NSPoint(x: W - 80 - a.size().width, y: y))
}

NSAttributedString(string: "EST. 2020", attributes: [
    .font: NSFont.systemFont(ofSize: 10, weight: .regular),
    .foregroundColor: faint.withAlphaComponent(0.8),
    .kern: 1.4
]).draw(at: NSPoint(x: W - 80 - NSAttributedString(string: "EST. 2020", attributes: [.font: NSFont.systemFont(ofSize: 10)]).size().width, y: 70))

img.unlockFocus()

if let tiff = img.tiffRepresentation,
   let rep = NSBitmapImageRep(data: tiff),
   let png = rep.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
    print("ok \(mode)")
}

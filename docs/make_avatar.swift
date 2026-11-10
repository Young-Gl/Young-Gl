import AppKit

let S: CGFloat = 460
let img = NSImage(size: NSSize(width: S, height: S))
img.lockFocus()

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor {
    NSColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: 1)
}

let paper = rgb(247, 246, 243)
let ink = rgb(17, 17, 17)
let faint = rgb(122, 120, 116)

paper.setFill()
NSRect(x: 0, y: 0, width: S, height: S).fill()

// thin inner frame
faint.withAlphaComponent(0.35).setStroke()
let frame = NSBezierPath(rect: NSRect(x: 22, y: 22, width: S - 44, height: S - 44))
frame.lineWidth = 1
frame.stroke()

// serif L
let font = NSFont(name: "Georgia", size: 260) ?? NSFont.systemFont(ofSize: 260)
let a = NSAttributedString(string: "L", attributes: [.font: font, .foregroundColor: ink])
let size = a.size()
a.draw(at: NSPoint(x: (S - size.width) / 2, y: (S - size.height) / 2 + 6))

img.unlockFocus()

if let tiff = img.tiffRepresentation,
   let rep = NSBitmapImageRep(data: tiff),
   let png = rep.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: "assets/avatar.png"))
    print("ok")
}

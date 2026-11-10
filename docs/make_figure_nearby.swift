import AppKit

let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "light"
let isDark = mode == "dark"

let W: CGFloat = 1200, H: CGFloat = 500
let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocus()

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor {
    NSColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: 1)
}
let paper = isDark ? rgb(14, 14, 15) : rgb(247, 246, 243)
let ink   = isDark ? rgb(238, 237, 232) : rgb(20, 20, 20)
let faint = isDark ? rgb(120, 120, 118) : rgb(140, 138, 132)

paper.setFill()
NSRect(x: 0, y: 0, width: W, height: H).fill()

let cx: CGFloat = 600, cy: CGFloat = 240

func ring(_ r: CGFloat, width: CGFloat, alpha: CGFloat, dashed: Bool = false) {
    let p = NSBezierPath(ovalIn: NSRect(x: cx - r, y: cy - r, width: r*2, height: r*2))
    p.lineWidth = width
    if dashed {
        var pattern: [CGFloat] = [3, 6]
        p.setLineDash(&pattern, count: 2, phase: 0)
    }
    ink.withAlphaComponent(alpha).setStroke()
    p.stroke()
}

// world / nearby / family
ring(190, width: 1.0, alpha: 0.75)
ring(120, width: 1.0, alpha: 0.30, dashed: true)
ring(55,  width: 1.2, alpha: 0.85)

// centre dot
ink.withAlphaComponent(0.9).setFill()
NSBezierPath(ovalIn: NSRect(x: cx - 3, y: cy - 3, width: 6, height: 6)).fill()

func mono(_ s: String, centeredAt x: CGFloat, _ y: CGFloat, _ size: CGFloat, _ color: NSColor) {
    let a = NSAttributedString(string: s, attributes: [
        .font: NSFont.monospacedSystemFont(ofSize: size, weight: .regular),
        .foregroundColor: color, .kern: 2.0
    ])
    a.draw(at: NSPoint(x: x - a.size().width/2, y: y))
}

mono("WORLD", centeredAt: cx, cy + 190 + 14, 9, ink.withAlphaComponent(0.6))
mono("NEARBY", centeredAt: cx, cy + 120 + 12, 9, faint)
mono("FAMILY", centeredAt: cx, cy - 16, 9, ink.withAlphaComponent(0.85))

// side note for the fading ring
mono("THINNING", centeredAt: cx + 330, cy + 40, 9, faint)

img.unlockFocus()

if let tiff = img.tiffRepresentation,
   let rep = NSBitmapImageRep(data: tiff),
   let png = rep.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
    print("ok \(mode)")
}

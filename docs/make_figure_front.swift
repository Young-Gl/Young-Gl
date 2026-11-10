import AppKit

let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "light"
let isDark = mode == "dark"

let W: CGFloat = 1200, H: CGFloat = 460
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

// back stage (dashed) and front stage (solid)
let back = NSRect(x: 150, y: 150, width: 360, height: 200)
let front = NSRect(x: 590, y: 150, width: 360, height: 200)

let bp = NSBezierPath(rect: back)
bp.lineWidth = 1
var dash: [CGFloat] = [4, 5]
bp.setLineDash(&dash, count: 2, phase: 0)
faint.withAlphaComponent(0.95).setStroke()
bp.stroke()

let fp = NSBezierPath(rect: front)
fp.lineWidth = 1.2
ink.withAlphaComponent(0.85).setStroke()
fp.stroke()

// divider
let div = NSBezierPath()
div.move(to: NSPoint(x: 550, y: 120))
div.line(to: NSPoint(x: 550, y: 380))
div.lineWidth = 0.8
div.setLineDash(&dash, count: 2, phase: 0)
faint.withAlphaComponent(0.7).setStroke()
div.stroke()

// audience dots below the front stage
for i in 0..<4 {
    let x = 660 + CGFloat(i) * 80
    ink.withAlphaComponent(0.75).setFill()
    NSBezierPath(ovalIn: NSRect(x: x - 4, y: 96, width: 8, height: 8)).fill()
}

func mono(_ s: String, centeredAt x: CGFloat, _ y: CGFloat, _ size: CGFloat, _ color: NSColor, kern: CGFloat = 2.0) {
    let a = NSAttributedString(string: s, attributes: [
        .font: NSFont.monospacedSystemFont(ofSize: size, weight: .regular),
        .foregroundColor: color, .kern: kern
    ])
    a.draw(at: NSPoint(x: x - a.size().width/2, y: y))
}

mono("BACK STAGE", centeredAt: 330, 240, 10, faint)
mono("FRONT STAGE", centeredAt: 770, 240, 10, ink.withAlphaComponent(0.8))
mono("AUDIENCE", centeredAt: 780, 62, 9, faint)

// crossing arrow
let arrow = NSBezierPath()
arrow.move(to: NSPoint(x: 480, y: 200))
arrow.line(to: NSPoint(x: 600, y: 200))
arrow.lineWidth = 1
ink.withAlphaComponent(0.55).setStroke()
arrow.stroke()

let head = NSBezierPath()
head.move(to: NSPoint(x: 600, y: 200))
head.line(to: NSPoint(x: 588, y: 205))
head.line(to: NSPoint(x: 588, y: 195))
head.close()
ink.withAlphaComponent(0.65).setFill()
head.fill()

img.unlockFocus()

if let tiff = img.tiffRepresentation,
   let rep = NSBitmapImageRep(data: tiff),
   let png = rep.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
    print("ok \(mode)")
}

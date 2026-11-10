import AppKit

let mode = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "light"
let isDark = mode == "dark"

let W: CGFloat = 1200, H: CGFloat = 360
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

struct Node { let x: CGFloat; let y: CGFloat }

let a: [Node] = [
    Node(x: 250, y: 200), Node(x: 320, y: 250), Node(x: 330, y: 160),
    Node(x: 400, y: 210), Node(x: 390, y: 120), Node(x: 260, y: 130),
    Node(x: 450, y: 150),
]
let b: [Node] = [
    Node(x: 800, y: 190), Node(x: 870, y: 240), Node(x: 880, y: 150),
    Node(x: 950, y: 200), Node(x: 940, y: 120),
]

func edge(_ p: Node, _ q: Node, dashed: Bool = false, alpha: CGFloat = 0.55, width: CGFloat = 1.0) {
    let path = NSBezierPath()
    path.move(to: NSPoint(x: p.x, y: p.y))
    path.line(to: NSPoint(x: q.x, y: q.y))
    path.lineWidth = width
    if dashed {
        var pattern: [CGFloat] = [5, 4]
        path.setLineDash(&pattern, count: 2, phase: 0)
    }
    ink.withAlphaComponent(alpha).setStroke()
    path.stroke()
}

func cluster(_ nodes: [Node]) {
    for i in 0..<nodes.count {
        for j in (i+1)..<nodes.count {
            let dx = nodes[i].x - nodes[j].x, dy = nodes[i].y - nodes[j].y
            if (dx*dx + dy*dy).squareRoot() < 130 {
                edge(nodes[i], nodes[j], alpha: 0.35)
            }
        }
    }
}

cluster(a)
cluster(b)

// the single weak tie
edge(a[6], b[0], dashed: true, alpha: 0.85, width: 1.4)

func dot(_ n: Node, _ r: CGFloat = 4.5) {
    ink.setFill()
    NSBezierPath(ovalIn: NSRect(x: n.x - r, y: n.y - r, width: r*2, height: r*2)).fill()
}
a.forEach { dot($0) }
b.forEach { dot($0) }

// labels
func mono(_ s: String, _ x: CGFloat, _ y: CGFloat, _ size: CGFloat, _ color: NSColor) {
    NSAttributedString(string: s, attributes: [
        .font: NSFont.monospacedSystemFont(ofSize: size, weight: .regular),
        .foregroundColor: color, .kern: 1.2
    ]).draw(at: NSPoint(x: x, y: y))
}
mono("DENSE", 318, 285, 9, faint)
mono("DENSE", 838, 285, 9, faint)
mono("WEAK TIE", 578, 232, 9, ink.withAlphaComponent(0.75))

img.unlockFocus()

if let tiff = img.tiffRepresentation,
   let rep = NSBitmapImageRep(data: tiff),
   let png = rep.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
    print("ok \(mode)")
}

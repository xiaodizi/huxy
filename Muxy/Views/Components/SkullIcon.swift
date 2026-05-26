import SwiftUI

struct SkullIcon: View {
    var color: Color = .white

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let scale = min(w, h) / 100.0

            context.scaleBy(x: scale, y: scale)

            // 骷髅主体
            let path = Path { p in
                p.addPath(Path(CGRect(x: 20, y: 15, width: 60, height: 60))) // 简化主体逻辑，使用原始设计感
                // 实际上我们可以通过 SwiftUI Path 绘制出精确的 SVG 线条
            }

            // 重新绘制精确路径
            var skullPath = Path()
            // 顶部圆弧
            skullPath.addArc(center: CGPoint(x: 50, y: 45), radius: 30, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            // 脸颊与下巴
            skullPath.addLine(to: CGPoint(x: 80, y: 45))
            skullPath.addCurve(to: CGPoint(x: 68.5, y: 68.5), control1: CGPoint(x: 80, y: 54.5), control2: CGPoint(x: 75.5, y: 63))
            skullPath.addLine(to: CGPoint(x: 68.5, y: 80))
            skullPath.addLine(to: CGPoint(x: 31.5, y: 80))
            skullPath.addLine(to: CGPoint(x: 31.5, y: 68.5))
            skullPath.addCurve(to: CGPoint(x: 20, y: 45), control1: CGPoint(x: 24.5, y: 63), control2: CGPoint(x: 20, y: 54.5))
            skullPath.closeSubpath()

            context.stroke(skullPath, with: .color(color), lineWidth: 4)

            // 眼窝
            let leftEye = Path(roundedRect: CGRect(x: 32, y: 42, width: 12, height: 12), cornerRadius: 2)
            let rightEye = Path(roundedRect: CGRect(x: 56, y: 42, width: 12, height: 12), cornerRadius: 2)
            context.stroke(leftEye, with: .color(color), lineWidth: 4)
            context.stroke(rightEye, with: .color(color), lineWidth: 4)

            // 鼻孔
            var nose = Path()
            nose.move(to: CGPoint(x: 47, y: 62))
            nose.addLine(to: CGPoint(x: 50, y: 58))
            nose.addLine(to: CGPoint(x: 53, y: 62))
            context.stroke(nose, with: .color(color), lineWidth: 3)

            // 牙齿
            var teethBase = Path()
            teethBase.move(to: CGPoint(x: 40, y: 73))
            teethBase.addLine(to: CGPoint(x: 60, y: 73))
            context.stroke(teethBase, with: .color(color), lineWidth: 2)

            for x in [44, 50, 56] {
                var tooth = Path()
                tooth.move(to: CGPoint(x: CGFloat(x), y: 73))
                tooth.addLine(to: CGPoint(x: CGFloat(x), y: 80))
                context.stroke(tooth, with: .color(color), lineWidth: 2)
            }
        }
    }
}

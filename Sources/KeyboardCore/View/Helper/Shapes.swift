//
//  Shapes.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-24.
//

import UIKit

public enum Shapes {
    
    static func getFactors(_ fromSize: CGSize, toRect: CGRect) -> (xScalingFactor: CGFloat, yScalingFactor: CGFloat, lineWidthScalingFactor: CGFloat, fillIsHorizontal: Bool, offset: CGFloat) {
        
        let xSize = { () -> CGFloat in
            let scaledSize = (fromSize.width / CGFloat(2))
            if scaledSize > toRect.width {
                return (toRect.width / scaledSize) / CGFloat(2)
            }
            else {
                return CGFloat(0.5)
            }
        }()
        
        let ySize = { () -> CGFloat in
            let scaledSize = (fromSize.height / CGFloat(2))
            if scaledSize > toRect.height {
                return (toRect.height / scaledSize) / CGFloat(2)
            }
            else {
                return CGFloat(0.5)
            }
        }()
        
        let actualSize = min(xSize, ySize)
        
        return (actualSize, actualSize, actualSize, false, 0)
    }
    
    @discardableResult
    static func centerShape(_ fromSize: CGSize, toRect: CGRect) -> CGContext? {
        let xOffset = (toRect.width - fromSize.width) / CGFloat(2)
        let yOffset = (toRect.height - fromSize.height) / CGFloat(2)
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        ctx?.translateBy(x: xOffset, y: yOffset)
        
        return ctx
    }
    
    static func endCenter() {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.restoreGState()
    }
    
}

extension Shapes {
    
    public static func drawBackspace(_ bounds: CGRect, color: UIColor, fill: Bool) {
        let factors = getFactors(CGSize(width: 44, height: 32), toRect: bounds)
        let xScalingFactor = factors.xScalingFactor
        let yScalingFactor = factors.yScalingFactor
        let lineWidthScalingFactor = factors.lineWidthScalingFactor
        
        let ctx = centerShape(CGSize(width: 44 * xScalingFactor, height: 32 * yScalingFactor), toRect: bounds)
        
        
        //// Color Declarations
        let color = color
        let color2 = color
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 16 * xScalingFactor, y: 32 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 38 * xScalingFactor, y: 32 * yScalingFactor))
        bezierPath.addCurve(to: CGPoint(x: 44 * xScalingFactor, y: 26 * yScalingFactor), controlPoint1: CGPoint(x: 38 * xScalingFactor, y: 32 * yScalingFactor), controlPoint2: CGPoint(x: 44 * xScalingFactor, y: 32 * yScalingFactor))
        bezierPath.addCurve(to: CGPoint(x: 44 * xScalingFactor, y: 6 * yScalingFactor), controlPoint1: CGPoint(x: 44 * xScalingFactor, y: 22 * yScalingFactor), controlPoint2: CGPoint(x: 44 * xScalingFactor, y: 6 * yScalingFactor))
        bezierPath.addCurve(to: CGPoint(x: 36 * xScalingFactor, y: 0 * yScalingFactor), controlPoint1: CGPoint(x: 44 * xScalingFactor, y: 6 * yScalingFactor), controlPoint2: CGPoint(x: 44 * xScalingFactor, y: 0 * yScalingFactor))
        bezierPath.addCurve(to: CGPoint(x: 16 * xScalingFactor, y: 0 * yScalingFactor), controlPoint1: CGPoint(x: 32 * xScalingFactor, y: 0 * yScalingFactor), controlPoint2: CGPoint(x: 16 * xScalingFactor, y: 0 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 0 * xScalingFactor, y: 18 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 16 * xScalingFactor, y: 32 * yScalingFactor))
        bezierPath.close()
        
        if fill {
            color.setFill()
            bezierPath.fill()
        }
        bezierPath.lineWidth = 2.8 * lineWidthScalingFactor
        color.setStroke()
        bezierPath.stroke()
        
        if fill {
            ctx?.setBlendMode(.clear)
        }
        color2.setFill()
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 20 * xScalingFactor, y: 10 * yScalingFactor))
        bezier2Path.addLine(to: CGPoint(x: 34 * xScalingFactor, y: 22 * yScalingFactor))
        bezier2Path.addLine(to: CGPoint(x: 20 * xScalingFactor, y: 10 * yScalingFactor))
        bezier2Path.close()
        
        color2.setStroke()
        bezier2Path.lineWidth = 2.5 * lineWidthScalingFactor
        bezier2Path.stroke()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 20 * xScalingFactor, y: 22 * yScalingFactor))
        bezier3Path.addLine(to: CGPoint(x: 34 * xScalingFactor, y: 10 * yScalingFactor))
        bezier3Path.addLine(to: CGPoint(x: 20 * xScalingFactor, y: 22 * yScalingFactor))
        
        bezier3Path.fill()
        color2.setStroke()
        bezier3Path.lineWidth = 2.5 * lineWidthScalingFactor
        bezier3Path.stroke()
        
        endCenter()
    }
    
    public static func drawShift(_ bounds: CGRect, color: UIColor, withRect: Bool, fill: Bool) {
        let factors = getFactors(CGSize(width: 38, height: (withRect ? 34 + 4 : 32)), toRect: bounds)
        let xScalingFactor = factors.xScalingFactor
        let yScalingFactor = factors.yScalingFactor
        _ = factors.lineWidthScalingFactor
        
        centerShape(CGSize(width: 38 * xScalingFactor, height: (withRect ? 34 + 4 : 32) * yScalingFactor), toRect: bounds)
        
        //// Color Declarations
        let color2 = color
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 28 * xScalingFactor, y: 18 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 38 * xScalingFactor, y: 18 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 38 * xScalingFactor, y: 18 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 19 * xScalingFactor, y: 0 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 0 * xScalingFactor, y: 18 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 0 * xScalingFactor, y: 18 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 10 * xScalingFactor, y: 18 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 10 * xScalingFactor, y: 28 * yScalingFactor))
        bezierPath.addCurve(to: CGPoint(x: 14 * xScalingFactor, y: 32 * yScalingFactor), controlPoint1: CGPoint(x: 10 * xScalingFactor, y: 28 * yScalingFactor), controlPoint2: CGPoint(x: 10 * xScalingFactor, y: 32 * yScalingFactor))
        bezierPath.addCurve(to: CGPoint(x: 24 * xScalingFactor, y: 32 * yScalingFactor), controlPoint1: CGPoint(x: 16 * xScalingFactor, y: 32 * yScalingFactor), controlPoint2: CGPoint(x: 24 * xScalingFactor, y: 32 * yScalingFactor))
        bezierPath.addCurve(to: CGPoint(x: 28 * xScalingFactor, y: 28 * yScalingFactor), controlPoint1: CGPoint(x: 24 * xScalingFactor, y: 32 * yScalingFactor), controlPoint2: CGPoint(x: 28 * xScalingFactor, y: 32 * yScalingFactor))
        bezierPath.addCurve(to: CGPoint(x: 28 * xScalingFactor, y: 18 * yScalingFactor), controlPoint1: CGPoint(x: 28 * xScalingFactor, y: 26 * yScalingFactor), controlPoint2: CGPoint(x: 28 * xScalingFactor, y: 18 * yScalingFactor))
        bezierPath.close()
        
        bezierPath.lineJoinStyle = .round
        
        if fill {
            color2.setFill()
            bezierPath.fill()
        } else {
            bezierPath.lineWidth = 1.25
            color2.setStroke()
            bezierPath.stroke()
        }
        
        if withRect {
            //// Rectangle Drawing
            let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 10 * xScalingFactor, y: 38 * yScalingFactor, width: 18 * xScalingFactor, height: 4 * yScalingFactor), cornerRadius: 1.0)
            color2.setFill()
            rectanglePath.fill()
        }
        
        endCenter()
    }
    
    public static func drawGlobe(_ bounds: CGRect, color: UIColor) {
        let factors = getFactors(CGSize(width: 41, height: 40), toRect: bounds)
        let xScalingFactor = factors.xScalingFactor
        let yScalingFactor = factors.yScalingFactor
        let lineWidthScalingFactor = factors.lineWidthScalingFactor
        
        centerShape(CGSize(width: 41 * xScalingFactor, height: 40 * yScalingFactor), toRect: bounds)
        
        
        //// Color Declarations
        let color = color
        
        let lineWidth: CGFloat = 2
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 0 * xScalingFactor, y: 0 * yScalingFactor, width: 40 * xScalingFactor, height: 40 * yScalingFactor))
        color.setStroke()
        ovalPath.lineWidth = lineWidth * lineWidthScalingFactor
        ovalPath.stroke()
        
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 20 * xScalingFactor, y: -0 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 20 * xScalingFactor, y: 40 * yScalingFactor))
        bezierPath.addLine(to: CGPoint(x: 20 * xScalingFactor, y: -0 * yScalingFactor))
        bezierPath.close()
        color.setStroke()
        bezierPath.lineWidth = lineWidth * lineWidthScalingFactor
        bezierPath.stroke()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 0.5 * xScalingFactor, y: 19.5 * yScalingFactor))
        bezier2Path.addLine(to: CGPoint(x: 39.5 * xScalingFactor, y: 19.5 * yScalingFactor))
        bezier2Path.addLine(to: CGPoint(x: 0.5 * xScalingFactor, y: 19.5 * yScalingFactor))
        bezier2Path.close()
        color.setStroke()
        bezier2Path.lineWidth = lineWidth * lineWidthScalingFactor
        bezier2Path.stroke()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 21.63 * xScalingFactor, y: 0.42 * yScalingFactor))
        bezier3Path.addCurve(to: CGPoint(x: 21.63 * xScalingFactor, y: 39.6 * yScalingFactor), controlPoint1: CGPoint(x: 21.63 * xScalingFactor, y: 0.42 * yScalingFactor), controlPoint2: CGPoint(x: 41 * xScalingFactor, y: 19 * yScalingFactor))
        bezier3Path.lineCapStyle = .round;
        
        color.setStroke()
        bezier3Path.lineWidth = lineWidth * lineWidthScalingFactor
        bezier3Path.stroke()
        
        
        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 17.76 * xScalingFactor, y: 0.74 * yScalingFactor))
        bezier4Path.addCurve(to: CGPoint(x: 18.72 * xScalingFactor, y: 39.6 * yScalingFactor), controlPoint1: CGPoint(x: 17.76 * xScalingFactor, y: 0.74 * yScalingFactor), controlPoint2: CGPoint(x: -2.5 * xScalingFactor, y: 19.04 * yScalingFactor))
        bezier4Path.lineCapStyle = .round;
        
        color.setStroke()
        bezier4Path.lineWidth = lineWidth * lineWidthScalingFactor
        bezier4Path.stroke()
        
        
        //// Bezier 5 Drawing
        let bezier5Path = UIBezierPath()
        bezier5Path.move(to: CGPoint(x: 6 * xScalingFactor, y: 7 * yScalingFactor))
        bezier5Path.addCurve(to: CGPoint(x: 34 * xScalingFactor, y: 7 * yScalingFactor), controlPoint1: CGPoint(x: 6 * xScalingFactor, y: 7 * yScalingFactor), controlPoint2: CGPoint(x: 19 * xScalingFactor, y: 21 * yScalingFactor))
        bezier5Path.lineCapStyle = .round;
        
        color.setStroke()
        bezier5Path.lineWidth = lineWidth * lineWidthScalingFactor
        bezier5Path.stroke()
        
        
        //// Bezier 6 Drawing
        let bezier6Path = UIBezierPath()
        bezier6Path.move(to: CGPoint(x: 6 * xScalingFactor, y: 33 * yScalingFactor))
        bezier6Path.addCurve(to: CGPoint(x: 34 * xScalingFactor, y: 33 * yScalingFactor), controlPoint1: CGPoint(x: 6 * xScalingFactor, y: 33 * yScalingFactor), controlPoint2: CGPoint(x: 19 * xScalingFactor, y: 22 * yScalingFactor))
        bezier6Path.lineCapStyle = .round;
        
        color.setStroke()
        bezier6Path.lineWidth = lineWidth * lineWidthScalingFactor
        bezier6Path.stroke()
        
        endCenter()
    }

}

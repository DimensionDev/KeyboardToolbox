//
//  KeyPopup.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-24.
//

import UIKit

public class KeyPopup: UIView {
    
    public static let popupWidthIncrement: CGFloat = 26
    public static let cornerRadius: CGFloat = 10
    
    var imageView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    private func _init() {
        isUserInteractionEnabled = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        // set conetentMode to center due to image render with padding
        imageView.contentMode = .center
        clipsToBounds = false
        
        // Debug
        // backgroundColor = .systemRed
    }
    
}

extension KeyPopup {
    
    public func render(for keyView: KeyView, in keyboardView: KeyboardView) {
        assert(superview == keyboardView)
        
        guard let layout = keyboardView.layout else {
            return
        }
        
        let offset: CGFloat = 5
        let paddingBounds = bounds.insetBy(dx: -2 * offset, dy: -2 * offset)
        let popupRect = CGRect(x: 0, y: 0, width: bounds.width, height: 48)
        let keyViewFrameInPopup = keyboardView.convert(keyView.frame, to: self)
        
        imageView.image = UIGraphicsImageRenderer(bounds: paddingBounds).image { context in
            guard let cgContext = UIGraphicsGetCurrentContext() else { return }
            
            KeyPopup.backgroundColor(for: keyboardView.traitCollection.userInterfaceStyle).setFill()
            KeyPopup.borderColor(for: keyboardView.traitCollection.userInterfaceStyle).setStroke()
            
            cgContext.saveGState()
            cgContext.setShadow(offset: CGSize(width: 0, height: 1), blur: 0, color: KeyView.shadowColor(for: keyboardView.traitCollection.userInterfaceStyle).cgColor)
            
            // create path for popup
            let path = UIBezierPath()
            // move to top-mid and draw clockwise
            path.move(to: CGPoint(x: popupRect.midX, y: popupRect.minY))
            path.addLine(to: CGPoint(x: popupRect.maxX - KeyPopup.cornerRadius, y: popupRect.minY))
            // top-right corner
            path.addArc(withCenter: CGPoint(x: popupRect.maxX - KeyPopup.cornerRadius, y: popupRect.minY + KeyPopup.cornerRadius),
                        radius: KeyPopup.cornerRadius,
                        startAngle: 3 * .pi / 2,
                        endAngle: 0,
                        clockwise: true)
            path.addLine(to: CGPoint(x: popupRect.maxX, y: popupRect.maxY))
            // right curve
            path.addCurve(to: CGPoint(x: keyViewFrameInPopup.maxX, y: keyViewFrameInPopup.minY),
                          controlPoint1: CGPoint(x: popupRect.maxX, y: 0.5 * (popupRect.maxY + keyViewFrameInPopup.minY)),
                          controlPoint2: CGPoint(x: keyViewFrameInPopup.maxX, y: 0.5 * (popupRect.maxY + keyViewFrameInPopup.minY)))
            path.addLine(to: CGPoint(x: keyViewFrameInPopup.maxX, y: keyViewFrameInPopup.maxY - layout.settings.keyCornerRadius))
            // bottom-right corner
            path.addArc(withCenter: CGPoint(x: keyViewFrameInPopup.maxX - layout.settings.keyCornerRadius, y: keyViewFrameInPopup.maxY - layout.settings.keyCornerRadius),
                        radius: layout.settings.keyCornerRadius,
                        startAngle: 0,
                        endAngle: .pi / 2,
                        clockwise: true)
            path.addLine(to: CGPoint(x: keyViewFrameInPopup.minX + layout.settings.keyCornerRadius, y: keyViewFrameInPopup.maxY))
            // bottom-left corner
            path.addArc(withCenter: CGPoint(x: keyViewFrameInPopup.minX + layout.settings.keyCornerRadius, y: keyViewFrameInPopup.maxY - layout.settings.keyCornerRadius),
                        radius: layout.settings.keyCornerRadius,
                        startAngle: .pi / 2,
                        endAngle: .pi,
                        clockwise: true)
            path.addLine(to: CGPoint(x: keyViewFrameInPopup.minX, y: keyViewFrameInPopup.minY))
            // left curve
            path.addCurve(to: CGPoint(x: popupRect.minX, y: popupRect.maxY),
                          controlPoint1: CGPoint(x: keyViewFrameInPopup.minX, y: 0.5 * (keyViewFrameInPopup.minY + popupRect.maxY)),
                          controlPoint2: CGPoint(x: popupRect.minX, y: 0.5 * (keyViewFrameInPopup.minY + popupRect.maxY)))
            path.addLine(to: CGPoint(x: popupRect.minX, y: popupRect.minY + KeyPopup.cornerRadius))
            // top-left corner
            path.addArc(withCenter: CGPoint(x: popupRect.minX + KeyPopup.cornerRadius, y: popupRect.minY + KeyPopup.cornerRadius),
                        radius: KeyPopup.cornerRadius,
                        startAngle: .pi,
                        endAngle: 3 * .pi / 2,
                        clockwise: true)
            path.close()
            
            // fill & stroke Path
            path.fill()
            path.lineWidth = 0.2
            path.stroke()
            
            // generate Shadow
            cgContext.restoreGState()
            
            cgContext.addPath(path.cgPath)
            cgContext.drawPath(using: .fill)
            
            // Draw popup cap
            
            let settings = layout.settings
            let key = keyView.key
            let shiftState = keyboardView.shiftState
            let size: CGFloat = shiftState == .disabled ? 38.0 : 35.0
            let keyCapFont = settings.keyCapFont(ofSize: size, weight: .thin)
            
            // Make popup key cap center to the underneath key cap
            let adjustOffsetY: CGFloat = shiftState == .disabled ? 5 : 8
            var adjustPopupKeyCapRect = popupRect
            adjustPopupKeyCapRect.origin.y += adjustOffsetY
            
            // debug
            // let popupRectPath = UIBezierPath(roundedRect: adjustPopupKeyCapRect, cornerRadius: KeyPopup.cornerRadius)
            // UIColor.systemBlue.setFill()
            // popupRectPath.fill()
            
            let capText: NSString = {
                if !settings.preferSmallLowercase {
                    return key.keyCode.shift as NSString
                } else {
                    return shiftState == .disabled ? key.keyCode.normal as NSString : key.keyCode.shift as NSString
                }
            }()
            let attributes: [NSAttributedString.Key: Any] = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                // adapt vertical center text for lowercase & uppercase
                if capText == key.keyCode.shift as NSString {
                    paragraphStyle.minimumLineHeight = key.backgroundRect.height / 2 + keyCapFont.lineHeight / 2
                } else {
                    paragraphStyle.minimumLineHeight = key.backgroundRect.height / 2 + keyCapFont.xHeight
                }
                
                // Stoke & Fill:
                // https://developer.apple.com/library/archive/qa/qa1531/_index.html
                return [
                    NSAttributedString.Key.strokeWidth: -3,     // tweak little bold than .thin
                    NSAttributedString.Key.strokeColor: KeyView.foregroundColor(for: keyboardView.traitCollection.userInterfaceStyle),
                    NSAttributedString.Key.foregroundColor: KeyView.foregroundColor(for: keyboardView.traitCollection.userInterfaceStyle),
                    NSAttributedString.Key.font: keyCapFont,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle
                ]
            }()
            capText.draw(in: adjustPopupKeyCapRect, withAttributes: attributes)
            
            // Debug
            // let keyViewPath = UIBezierPath(roundedRect: keyViewFrameInPopup, cornerRadius: layout.settings.keyCornerRadius)
            // UIColor.systemBlue.setFill()
            // keyViewPath.fill()
        }
    }
    
}

extension KeyPopup {
    
    public class func foregroundColor(for userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return userInterfaceStyle == .dark ? .white : .black
    }
    
    public class func backgroundColor(for userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        let grey = UIColor(red: 0.40, green: 0.40, blue: 0.40, alpha: 1.00)
        return userInterfaceStyle == .dark ? grey : .white
    }
    
    public class func borderColor(for userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return userInterfaceStyle == .dark ? .black : .systemGray
    }
    
    public class func shadowColor(for userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return userInterfaceStyle == .light ? .systemGray : .black
    }
    
}

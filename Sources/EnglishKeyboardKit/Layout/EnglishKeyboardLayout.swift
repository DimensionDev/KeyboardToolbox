//
//  EnglishKeyboardLayout.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import os
import UIKit
import CoreGraphics
import KeyboardCore

// QWERTY layout for English keyboard
public final class EnglishKeyboardLayout {
    
    public weak var keyboardView: KeyboardView?
    public var settings: KeyboardViewLayoutSettings = EnglishKeyboardViewLayoutSettings()
    
    private var functionKeyRectCache: [KeyboardFunctionKeyCode: CGRect] = [:]
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s: deinit", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

// MARK: - KeyboardViewLayout
extension EnglishKeyboardLayout: KeyboardViewLayout {
    
    public func invalidateLayout() {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
        
        guard let keyboardView = self.keyboardView, let page = keyboardView.currentPage else {
            return
        }
        
        // Set `needsInputModeSwitchKey` for page
        let needsInputModeSwitchKey = keyboardView.delegate?.needsInputModeSwitchKey(keyboardView) ?? true
        page.needsInputModeSwitchKey = needsInputModeSwitchKey
        
        settings.size = keyboardView.bounds.size
        layout(page: page, in: keyboardView)
        bind(page: page, to: keyboardView)
    }
    
    public func updateKeyCaps(shiftState: ShiftState) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
        guard let keyboardView = keyboardView, let page = keyboardView.currentPage else {
            return
        }
        
        keyboardView.keyCaps.image = EnglishKeyboardLayout.createKeyCapImage(for: page, in: keyboardView, with: settings, shiftState: shiftState)
        if let shiftKey = page.shiftKey {
            update(page: page, functionKey: shiftKey, in: keyboardView)
        }
    }
    
    public func update(page: Page, functionKey key: FunctionKey, in keyboardView: KeyboardView) {
        guard let keyCode = key.keyCode as? KeyboardFunctionKeyCode,
            let keyView = page.keyPlane[key] as? FunctionKeyView else {
                return
        }
        
        // Draw key
        keyView.imageView.image = UIGraphicsImageRenderer(size: keyView.bounds.size).image { context in
            guard let cgContext = UIGraphicsGetCurrentContext() else { return }
            
            // Set fill color
            let fillColor: UIColor = {
                // Note: could use UITextInputMode.keyboardAppearance instead
                let userInterfaceStyle = keyboardView.traitCollection.userInterfaceStyle
                switch keyCode {
                case .shift:
                    let highlight = keyboardView.shiftState != .disabled
                    return FunctionKeyView.backgroundColor(for: userInterfaceStyle, highlight: highlight)
                case .backspace:
                    let highlight = keyboardView.backspaceActiveSubject.value
                    return FunctionKeyView.backgroundColor(for: userInterfaceStyle, highlight: highlight)
                case .return:
                    let highlight = keyboardView.returnActiveSubject.value
                    return FunctionKeyView.backgroundColor(for: userInterfaceStyle, highlight: highlight)
                case .space:
                    return keyboardView.spaceActiveSubject.value ? FunctionKeyView.backgroundColor(for: userInterfaceStyle, highlight: false) : KeyView.backgroundColor(for: userInterfaceStyle)
                default:
                    return FunctionKeyView.backgroundColor(for: userInterfaceStyle, highlight: false)
                }
            }()
            fillColor.setFill()
            
            // prepare shadow
            cgContext.saveGState()
            cgContext.setShadow(offset: CGSize(width: 0, height: 1), blur: 0, color: KeyView.shadowColor(for: keyboardView.traitCollection.userInterfaceStyle).cgColor)
            
            // draw background
            let keyRect = CGRect(x: settings.minimumInteritemSpacing / 2,
                                 y: settings.minimumLineSpacing / 2,
                                 width: key.backgroundRect.width,
                                 height: key.backgroundRect.height)
            let bezierPath = UIBezierPath(roundedRect: keyRect, cornerRadius: settings.keyCornerRadius)
            bezierPath.fill()
            
            // finish shadow
            cgContext.restoreGState()
            
            cgContext.addPath(bezierPath.cgPath)
            cgContext.drawPath(using: .fill)
            
            let color = KeyView.foregroundColor(for: keyboardView.traitCollection.userInterfaceStyle)
            
            // draw key cap
            switch keyCode {
            case .shift:
                let withRect = keyboardView.shiftState == .locked
                let fill = keyboardView.shiftState != .disabled
                
                let color: UIColor = {
                    if keyboardView.traitCollection.userInterfaceStyle == .light {
                        return .black
                    } else {
                        return fill ? .black : .white
                    }
                }()
                
                Shapes.drawShift(CGRect(origin: .zero, size: keyView.bounds.size), color: color, withRect: withRect, fill: fill)
            case .shiftSymbol, .shiftNumber:
                let size: CGFloat = 15.0
                let capText = key.keyCode.normal as NSString
                let keyCapFont = EnglishKeyboardViewLayoutSettings.keyCapRegularFont(size: size)
                let attributes: [NSAttributedString.Key: Any] = {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center
                    paragraphStyle.minimumLineHeight = key.backgroundRect.height / 2 + keyCapFont.lineHeight / 2
                    return [
                        NSAttributedString.Key.foregroundColor: UIColor.label,
                        NSAttributedString.Key.font: keyCapFont,
                        NSAttributedString.Key.paragraphStyle: paragraphStyle
                    ]
                }()
                capText.draw(in: keyRect, withAttributes: attributes)
            case .backspace:
                let fill = keyboardView.backspaceActiveSubject.value
                Shapes.drawBackspace(CGRect(origin: .zero, size: keyView.bounds.size), color: color, fill: fill)
            case .globe:
                Shapes.drawGlobe(CGRect(origin: .zero, size: keyView.bounds.size), color: color)
                
            // key cap is text
            case .page, .space, .return:
                let size: CGFloat = 15.0
                let capText: NSString = {
                    if keyCode == .page {
                        if page is EnglishCharacterPage {
                            return "123"
                        } else {
                            return "ABC"
                        }
                    } else {
                        return key.keyCode.normal as NSString
                    }
                }()
                let keyCapFont = EnglishKeyboardViewLayoutSettings.keyCapRegularFont(size: size)
                let attributes: [NSAttributedString.Key: Any] = {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center
                    paragraphStyle.minimumLineHeight = key.backgroundRect.height / 2 + keyCapFont.lineHeight / 2
                    return [
                        NSAttributedString.Key.foregroundColor: UIColor.label,
                        NSAttributedString.Key.font: keyCapFont,
                        NSAttributedString.Key.paragraphStyle: paragraphStyle
                    ]
                }()
                capText.draw(in: keyRect, withAttributes: attributes)
                
            default:
                return
            }
            
        }   // end render image
    }
    
    public func popup(for keyView: KeyView, in keyboardView: KeyboardView) -> KeyPopup {
        let keyFrame = keyView.key.backgroundRect
        
        let offset = CGPoint(x: -0.5 * KeyPopup.popupWidthIncrement,
                             y: -keyFrame.height - 2 * settings.minimumLineSpacing)
        let popupOrigin = CGPoint(x: keyView.frame.origin.x + offset.x,
                                  y: keyView.frame.origin.y + offset.y)
        let popupSize = CGSize(width: keyFrame.width + KeyPopup.popupWidthIncrement,
                               height: 2 * keyFrame.height + 2 * settings.minimumLineSpacing)
        let popupFrame: CGRect = {
            var frame = CGRect(origin: popupOrigin, size: popupSize)
            if frame.minX < 0 {
                frame.origin.x = keyFrame.minX
            } else if frame.maxX > keyboardView.bounds.width {
                frame.origin.x = keyFrame.maxX - frame.width
            }
            return frame
        }()
        
        let popup = KeyPopup(frame: popupFrame)
        
        return popup
    }
    
}

// MARK: - private layout implementation
extension EnglishKeyboardLayout {
    
    /// Layout page in keyobard view
    /// - Parameters:
    ///   - page: the page waiting layout
    ///   - keyboardView: host keyboard view
    private func layout(page: Page, in keyboardView: KeyboardView) {
        os_log("%{public}s[%{public}ld], %{public}s: keyboardView bounds %s", ((#file as NSString).lastPathComponent), #line, #function, keyboardView.bounds.debugDescription)
        
        guard keyboardView.bounds.height != 0 || keyboardView.bounds.width != 0 else {
            return
        }
        
        // layout in portrait
        typesetKeys(for: page, with: settings)
        layoutInputKeys(for: page, in: keyboardView)
        layoutFunctionKeys(for: page, in: keyboardView)
        
        // update key cap for current shift state
        updateKeyCaps(shiftState: keyboardView.shiftState)
    }
    
    /// Setup keyboardView keyBackgorunds and keyCaps image for input keys
    /// Create keyView and insert into keyPlane
    /// - Parameters:
    ///   - page: page for setup
    ///   - keyboardView: host keyboard view for setup
    private func layoutInputKeys(for page: Page, in keyboardView: KeyboardView) {
        keyboardView.keyBackgrounds.image = EnglishKeyboardLayout.createKeyBackgroundImage(for: page, in: keyboardView, with: settings)
        keyboardView.keyCaps.image = EnglishKeyboardLayout.createKeyCapImage(for: page, in: keyboardView, with: settings)
        
        for row in page.keys {
            for key in row where !(key is FunctionKey) {
                let keyView = KeyView(frame: key.backgroundRect)    // TODO: add margin cut
                keyView.key = key
                page.keyPlane[key]?.removeFromSuperview()   // remove old keyView
                page.keyPlane[key] = keyView
                keyboardView.trackingView.addSubview(keyView)
            }
        }
    }
    
    /// Setup keyboardView keyPlane for function keys
    /// Create FunctionKeyView and insert into keyPlane
    /// - Parameters:
    ///   - page: page for setup
    ///   - keyboardView: host keyboard view for setup
    private func layoutFunctionKeys(for page: Page, in keyboardView: KeyboardView) {
        // setup keyView in keyPlane
        for row in page.keys {
            for key in row where key is FunctionKey {
                guard let key = key as? FunctionKey,
                    let _ = key.keyCode as? KeyboardFunctionKeyCode else {
                        continue
                }
                
                page.keyPlane[key]?.removeFromSuperview()   // remove old keyView
                
                // skip if rect is zero
                guard key.backgroundRect != .zero else {
                    continue
                }
                
                let keyViewFrame = key.backgroundRect.insetBy(dx: -1.0 * settings.minimumInteritemSpacing / 2, dy: -1.0 * settings.minimumLineSpacing / 2)
                let keyView = FunctionKeyView(frame: keyViewFrame)
                keyView.key = key
                page.keyPlane[key] = keyView                // prepare new keyView to layout
                
                update(page: page, functionKey: key, in: keyboardView)
                
                // add new keyView to tracking View
                keyboardView.trackingView.addSubview(keyView)
            }
        }
    }
    
}

extension EnglishKeyboardLayout {
    
    /// Setup key UIControl target & action in page to keyboard view
    /// - Parameters:
    ///   - page: keyboard page
    ///   - keyboardView: keyboard view for binding target & action
    private func bind(page: Page, to keyboardView: KeyboardView) {
        // remove keyView in page exclude current page to setup
        for allPages in keyboardView.pages.values {
            // Remove other pages
            for otherPage in allPages where otherPage != page {
                otherPage.keyPlane.values.forEach { keyView in
                    keyView.removeFromSuperview()
                }
            }
        }
        
        // bind target & action to key view
        for (key, keyView) in page.keyPlane {
            switch key {
            case _ where key.keyCode is KeyboardFunctionKeyCode:
                guard let keyCode = key.keyCode as? KeyboardFunctionKeyCode else {
                    continue
                }
                
                keyView.removeTarget(nil, action: nil, for: .allEvents)
                
                switch keyCode {
                case .shift:
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.shiftDown(_:)), for: .touchDown)
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.shiftUp(_:)), for: .touchUpInside)
                    
                    // use the ForwardingView dispatch .touchUpInside before .touchUpOutside property to implement drag input Caps key feature
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.shiftKeyDragExit(_:)), for: .touchDragExit)
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.shiftKeyDragExitOff(_:)), for: [.touchUpOutside, .touchCancel])
                case .backspace:
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.backspaceDown(_:)), for: .touchDown)
                    keyView.addTarget(keyboardView, action: #selector(keyboardView.backspaceUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchDragOutside, .touchCancel,])
                case .page, .shiftNumber, .shiftSymbol:
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.pageDown(_:)), for: .touchDown)
                    
                    // use the ForwardingView dispatch .touchUpInside before .touchUpOutside property to implement drag input Caps key feature
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.pageShiftKeyDragExit(_:)), for: .touchDragExit)
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.pageShiftKeyDragExitOff(_:)), for: [.touchDragEnter, .touchUpOutside, .touchUpInside, .touchCancel])
                case .globe:
                    keyboardView.delegate?.requestHandleInputModeList(keyboardView, keyView: keyView)
                case .space:
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.spaceDown(_:)), for: [.touchDown])
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.spaceDragEnter(_:)), for: [.touchDragEnter])
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.spaceUp(_:)), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside, .touchDragOutside])
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.spaceInput(_:)), for: [.touchUpInside])
                case .return:
                    keyView.addTarget(keyboardView, action: #selector(KeyboardView.returnDown(_:)), for: .touchDown)
                    keyView.addTarget(keyboardView, action: #selector(keyboardView.returnUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchDragOutside, .touchCancel,])
                default:
                    continue
                }
                
                os_log("%{public}s[%{public}ld], %{public}s: setup function key %{public}s", ((#file as NSString).lastPathComponent), #line, #function, keyCode.code)
                
            case _ where !(key.keyCode is KeyboardFunctionKeyCode):
                keyView.addTarget(keyboardView, action: #selector(KeyboardView.showPopup(_:)), for: [.touchDown, .touchDragInside, .touchDragEnter])
                keyView.addTarget(keyboardView, action: #selector(KeyboardView.hidePopup(_:)), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside, .touchDragOutside])
                
                keyView.addTarget(keyboardView, action: #selector(KeyboardView.inputKeyDown(_:)), for: [.touchDown])
                keyView.addTarget(keyboardView, action: #selector(KeyboardView.inputKeyUp(_:)), for: [.touchUpInside])
                
            default:
                continue
            }
        }   // end for … in
    }
    
}

extension EnglishKeyboardLayout {
    
    /// Typeset keys in page
    ///
    /// Calculate key frame and save that info into `Key`. Separate typeset the input key and function key.
    /// This layout is adapt for en_US QWERTY iOS standard English keyboard.
    ///
    /// - Parameter page: keyboard page
    /// - Parameter settings: keyboard view layout settings
    private func typesetKeys(for page: Page, with settings: KeyboardViewLayoutSettings) {
        os_log("%{public}s[%{public}ld], %{public}s: settings.size %s", ((#file as NSString).lastPathComponent), #line, #function, settings.size.debugDescription)
        
        guard let maxNumberOfKeysInRow = (page.keys.max { $0.count < $1.count }?.count) else {
            return
        }
        
        // PART A: input key
        // 1. Calculate key height
        let keyHeight: CGFloat = {
            let availableHeightForKeys = settings.size.height - settings.contentInsets.top - settings.contentInsets.bottom - settings.minimumLineSpacing * CGFloat(page.keys.count - 1)
            return floor(availableHeightForKeys / CGFloat(page.keys.count))
        }()
        
        // 2. Calculate input key width (on the first row)
        // Note: QWERTY portrait keyboard width layout guide:
        //  - space between key is 6pt
        //  - assert left margin + right margin = 6pt
        //  - key width is floor((size.width - space * keyCount - leftMargin - rightMargin) / keyCount)
        //  - calculate first key x position from center to left
        //  - layout latest key in row to align margin with not rounded width size
        
        let inputKeyWidth: CGFloat = {
            let inset = settings.contentInsets.left + settings.contentInsets.right      // for iPad
            let firstRowNumberOfKeys = page.keys[0].count
            let availableWidthForKeys = settings.size.width - inset - settings.minimumInteritemSpacing * CGFloat(firstRowNumberOfKeys - 1) - settings.minimumInteritemSpacing
            return floor(availableWidthForKeys / CGFloat(maxNumberOfKeysInRow))
        }()
        
        var QWERTYKeyCache: [QWERTYKeyCode : Key] = [:]
        
        // 3. Layout input key
        for row in 0..<page.keys.count {
            
            let firstInputKeyIndex = page.keys[row].firstIndex(where: { type(of: $0.keyCode) != KeyboardFunctionKeyCode.self }) ?? 0
            let firstInputKeyRectMinX = self.firstInputKeyRectMinX(forRow: row, in: page, width: inputKeyWidth, with: settings)
            
            for column in 0..<page.keys[row].count {
                let key = page.keys[row][column]
                guard type(of: key.keyCode) != KeyboardFunctionKeyCode.self else {
                    continue
                }
                os_log("%{public}s[%{public}ld], %{public}s: layout key %s…", ((#file as NSString).lastPathComponent), #line, #function, String(describing: key.keyCode))
                
                let rect: CGRect = {
                    let leftMargin = firstInputKeyIndex == 0 ? settings.contentInsets.left : 0
                    let x: CGFloat = column == firstInputKeyIndex ? leftMargin + firstInputKeyRectMinX : page.keys[row][column-1].backgroundRect.maxX + settings.minimumInteritemSpacing
                    let y: CGFloat = row == 0 ? settings.contentInsets.top : page.keys[row-1][0].backgroundRect.maxY + settings.minimumLineSpacing
                    return CGRect(x: x, y: y, width: inputKeyWidth, height: keyHeight)
                }()
                
                key.backgroundRect = rect
                os_log("%{public}s[%{public}ld], %{public}s: rect %s", ((#file as NSString).lastPathComponent), #line, #function, rect.debugDescription)
                
                if let keyCode = key.keyCode as? QWERTYKeyCode {
                    QWERTYKeyCache[keyCode] = key
                }
            }
        }
        
        // 3.1 tweak frame for number & symbol input key.
        // So the keys in that line could a little widther than normal input key
        let anchorKey = page.keys
            .flatMap { $0 }
            .filter { key in
                guard let keyCode = key.keyCode as? SymbolKeyCode else { return false }
                return keyCode == .euro_sign || keyCode == .dollar_sign
        }
        .first
        let tweakKeyCodes: [SymbolKeyCode] = [.full_stop, .comma, .question_mark, .exclamation_mark, .apostrophe]
        let tweakKeys = page.keys.flatMap { $0 }
            .filter { key in
                guard let keyCode = key.keyCode as? SymbolKeyCode else { return false }
                return tweakKeyCodes.contains(keyCode)
        }
        
        if let anchorKey = anchorKey, page.keys.count >= 3, !tweakKeys.isEmpty {
            let keyWidth = (anchorKey.backgroundRect.maxX - 0.5 * settings.size.width - settings.minimumInteritemSpacing) / 1.5
            let firstInputKeyIndex = page.keys[2].firstIndex(where: { type(of: $0.keyCode) != KeyboardFunctionKeyCode.self }) ?? 0
            let firstInputKeyX: CGFloat = 0.5 * settings.size.width - settings.minimumInteritemSpacing * CGFloat(tweakKeys.count / 2) - keyWidth * (CGFloat(tweakKeys.count / 2) + 0.5)
            
            for column in 0..<page.keys[2].count {
                let key = page.keys[2][column]
                guard let keyCode = key.keyCode as? SymbolKeyCode, tweakKeyCodes.contains(keyCode) else { continue }
                let rect: CGRect = {
                    let x: CGFloat = column == firstInputKeyIndex ? firstInputKeyX : page.keys[2][column-1].backgroundRect.maxX + settings.minimumInteritemSpacing
                    return CGRect(x: x, y: key.backgroundRect.minY, width: keyWidth, height: key.backgroundRect.height)
                }()
                key.backgroundRect = rect
            }
        }
        
        // PART B: function key
        
        // layout cache. Use this cache to align key. The order is important.
        var functionKeyCache: [KeyboardFunctionKeyCode: Key] = [:]
        
        for row in 0..<page.keys.count {
            for column in 0..<page.keys[row].count {
                let key = page.keys[row][column]
                guard let keyCode = key.keyCode as? KeyboardFunctionKeyCode else {
                    continue
                }
                os_log("%{public}s[%{public}ld], %{public}s: layout key %s…", ((#file as NSString).lastPathComponent), #line, #function, String(describing: keyCode))
                
                // Reuse function key layout
                if let rect = functionKeyRectCache[keyCode], type(of: page) != EnglishCharacterPage.self {
                    key.backgroundRect = rect
                    continue
                }
                
                if keyCode == .shiftNumber || keyCode == .shiftSymbol,
                    let rect = functionKeyRectCache[.shift] {
                    key.backgroundRect = rect
                    continue
                }
                
                let x: CGFloat
                let width: CGFloat
                switch keyCode {
                case .shift, .shiftSymbol, .shiftNumber:
                    guard let Q = QWERTYKeyCache[.q] else { continue }
                    x = Q.backgroundRect.minX
                    width = keyHeight
                case .backspace:
                    guard let P = QWERTYKeyCache[.p] else { continue }
                    width = keyHeight
                    x = P.backgroundRect.maxX - width
                case .page:
                    guard let Q = QWERTYKeyCache[.q] else { continue }
                    guard let X = QWERTYKeyCache[.x] else { continue }
                    
                    x = Q.backgroundRect.minX
                    
                    let minX = x
                    let maxX = X.backgroundRect.minX - settings.minimumInteritemSpacing
                    if page.needsInputModeSwitchKey {
                        width = (maxX - minX - settings.minimumInteritemSpacing) / 2
                    } else {
                        width = maxX - minX
                    }
                case .globe:   // assert layout .page before .global
                    guard page.needsInputModeSwitchKey else {
                        key.backgroundRect = .zero
                        continue
                    }
                    guard let pageKey = functionKeyCache[.page] else { continue }
                    x = pageKey.backgroundRect.maxX + settings.minimumInteritemSpacing
                    width = pageKey.backgroundRect.width
                case .space:
                    guard let X = QWERTYKeyCache[.x] else { continue }
                    guard let N = QWERTYKeyCache[.n] else { continue }
                    x = X.backgroundRect.minX
                    let maxX = N.backgroundRect.maxX
                    width = maxX - x
                case .return:
                    guard let M = QWERTYKeyCache[.m] else { continue }
                    guard let P = QWERTYKeyCache[.p] else { continue }
                    x = M.backgroundRect.minX
                    let maxX = P.backgroundRect.maxX
                    width = maxX - x
                default:
                    x = 0.0
                    width = 0.0
                    continue
                }
                
                let keyRectMinY: CGFloat = settings.contentInsets.top + CGFloat(row) * (keyHeight + settings.minimumLineSpacing)
                let rect = CGRect(x: x, y: keyRectMinY, width: width, height: keyHeight)
                key.backgroundRect = rect
                os_log("%{public}s[%{public}ld], %{public}s: rect %s", ((#file as NSString).lastPathComponent), #line, #function, rect.debugDescription)
                
                functionKeyCache[keyCode] = key
                functionKeyRectCache[keyCode] = key.backgroundRect
            }   // end for
        }   // end for
    }   // end EnglishKeyboardLayout.calculateKeyBackgroundRect(for:with:)
    
    
    /// Calculate the first input key (not function key) minX
    /// - Parameters:
    ///   - row: the row in page
    ///   - page: host page
    ///   - width: input key width
    ///   - settings: keyboard layout settings
    private func firstInputKeyRectMinX(forRow row: Int, in page: Page, width: CGFloat, with settings: KeyboardViewLayoutSettings) -> CGFloat {
        let keys = page.keys[row]
        let inputKeys = keys.filter { type(of: $0.keyCode) != KeyboardFunctionKeyCode.self }
        let centerX = floor(settings.size.width / 2)
        
        if inputKeys.count % 2 == 0 {
            let leftPartNumberOfKeys = inputKeys.count / 2
            return centerX - CGFloat(leftPartNumberOfKeys) * width - (CGFloat(leftPartNumberOfKeys) - 0.5) * settings.minimumInteritemSpacing
        } else {
            let centerKeyRectMinX = centerX - floor(width / 2)
            let leftPartNumberOfKeys = inputKeys.count / 2
            return centerKeyRectMinX - CGFloat(leftPartNumberOfKeys) * (settings.minimumInteritemSpacing + width)
        }
    }
    
}

extension EnglishKeyboardLayout {
    
    /// Create cap image for input keys (not function key)
    /// - Parameters:
    ///   - keyboardView: keyboard view
    ///   - page: keyboard page
    private static func createKeyCapImage(for page: Page, in keyboardView: KeyboardView, with settings: KeyboardViewLayoutSettings, shiftState: ShiftState = .disabled) -> UIImage {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
        
        let size: CGFloat = {
            switch page {
            case is EnglishCharacterPage:
                return keyboardView.shiftState == .disabled ? 25.0 : 22.0
            case is EnglishNumberPage, is EnglishSymbolPage:
                return 21.0
            default:
                return 21.0
            }
        }()
        let keyCapFont = EnglishKeyboardViewLayoutSettings.keyCapLightFont(size: size)
        
        return UIGraphicsImageRenderer(size: keyboardView.bounds.size).image { context in
            UIColor.clear.setFill()
            
            for row in page.keys {
                for key in row {
                    // Draw function key in FunctionKeyView
                    if key is FunctionKey {
                        continue
                    }
    
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
                        // tweak the little caps looks the same stroke as capital caps
                        // Ref: https://developer.apple.com/library/archive/qa/qa1531/_index.html
                        let strokeWidth = keyboardView.shiftState == .disabled ? -0.5: -1
                        return [
                            NSAttributedString.Key.strokeWidth: strokeWidth,
                            NSAttributedString.Key.strokeColor: KeyView.foregroundColor(for: keyboardView.traitCollection.userInterfaceStyle),
                            NSAttributedString.Key.foregroundColor: KeyView.foregroundColor(for: keyboardView.traitCollection.userInterfaceStyle),
                            NSAttributedString.Key.font: keyCapFont,
                            NSAttributedString.Key.paragraphStyle: paragraphStyle
                        ]
                    }()
                    capText.draw(in: key.backgroundRect, withAttributes: attributes)
                }
            }
        }   // end UIGraphicsImageRenderer
    }
    
    /// Create shadow & background key background image for input keys (without function key)
    /// - Parameters:
    ///   - keyboardView: keyboard view
    ///   - page: keyboard page
    ///   - settings: keyboard layout settings
    private static func createKeyBackgroundImage(for page: Page, in keyboardView: KeyboardView, with settings: KeyboardViewLayoutSettings) -> UIImage {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
        
        return UIGraphicsImageRenderer(size: keyboardView.bounds.size).image { context in
            // Draw shaow in CGContext
            // Ref:
            // https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_shadows/dq_shadows.html
            // https://stackoverflow.com/questions/6709064/coregraphics-quartz-drawing-shadow-on-transparent-alpha-path
            guard let cgContext = UIGraphicsGetCurrentContext() else { return }
            
            KeyView.backgroundColor(for: keyboardView.traitCollection.userInterfaceStyle).setFill()
            
            for row in page.keys {
                for key in row {
                    // Draw function key in FunctionKeyView
                    if key is FunctionKey {
                        continue
                    }
                    
                    cgContext.saveGState()
                    cgContext.setShadow(offset: CGSize(width: 0, height: 1), blur: 0, color: KeyView.shadowColor(for: keyboardView.traitCollection.userInterfaceStyle).cgColor)
                    
                    let bezierPath = UIBezierPath(roundedRect: key.backgroundRect, cornerRadius: settings.keyCornerRadius)
                    bezierPath.fill()
                    
                    cgContext.restoreGState()
                    
                    cgContext.addPath(bezierPath.cgPath)
                    cgContext.drawPath(using: .fill)
                }
            }
        }   // end UIGraphicsImageRenderer
    }
    
}

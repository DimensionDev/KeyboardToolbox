//
//  KeyboardView+Action.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-24.
//

import os
import Foundation

// MARK: - shift
extension KeyboardView {
    
    @objc public func shiftDown(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        shiftStateWhenShiftDown = shiftState
        
        let now = Date()
        defer {
            lastShiftDownTime = now
        }
        
        if shiftState != .locked, now.timeIntervalSince(lastShiftDownTime) < shiftLockThrottle {
            shiftStateMachine.enter(ShiftState.Locked.self)
        } else {
            switch shiftState {
            case .disabled:
                shiftStateMachine.enter(ShiftState.Enabled.self)
            case .enabled:
                // delay to mouseUp
                break
            case .locked:
                shiftStateMachine.enter(ShiftState.Enabled.self)
            }
        }
        
        os_log("%{public}s[%{public}ld], %{public}s: shiftState %{public}s", ((#file as NSString).lastPathComponent), #line, #function, shiftState.description)
        
        playSystemSound(.modifier)
    }
    
    @objc public func shiftUp(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        switch shiftState {
        case .disabled:
            // invalid route
            break
        case .enabled:
            shiftStateMachine.enter(ShiftState.Disabled.self)
        case .locked:
            // invalid route
            break
        }
        
        os_log("%{public}s[%{public}ld], %{public}s: shiftState %{public}s", ((#file as NSString).lastPathComponent), #line, #function, shiftState.description)
    }
    
    @objc public func shiftKeyDragExit(_ sender: KeyView) {
        guard shiftState == .enabled else {
            return
        }
        
        isShiftDragExit = true
    }
    
    @objc public func shiftKeyDragExitOff(_ sender: KeyView) {
        if isShiftDragExit {
            resetShift()
        }
        
        isShiftDragExit = false
    }
    
}

// MAKR: - backspace
extension KeyboardView {
    
    @objc public func backspaceDown(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        deleteBackward()
        backspaceActiveSubject.send(true)
    }
    
    @objc public func backspaceUp(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        backspaceActiveSubject.send(false)
    }
    
}

// MARK: - page
extension KeyboardView {
    
    @objc public func pageDown(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        guard let page = currentPage,
            let keyCode = sender.key.keyCode as? KeyboardFunctionKeyCode else {
                assertionFailure()
                return
        }
        
        guard let nextPage = currentKeyboard?.dataSource?.nextPage(for: keyCode, from: page) else {
            assertionFailure()
            return
        }
        
        previousPage = page
        resetShift()
        load(page: nextPage)
        
        playSystemSound(.modifier)
    }
    
    @objc public func pageShiftKeyDragExit(_ sender: KeyView) {
        isPageDragExit = true
    }
    
    @objc public func pageShiftKeyDragExitOff(_ sender: KeyView) {
        isPageDragExit = false
    }
    
}

// MARK: - space
extension KeyboardView {
    
    @objc public func spaceDown(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        spaceActiveSubject.send(true)
        
        playSystemSound(.modifier)
    }
    
    @objc public func spaceDragEnter(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        spaceActiveSubject.send(true)
    }
    
    @objc public func spaceUp(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        spaceActiveSubject.send(false)
    }
    
    @objc public func spaceInput(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        input(sender, text: " ")
    }
    
}

// MARK: - return
extension KeyboardView {
    
    @objc public func returnDown(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        returnActiveSubject.send(true)
        
        playSystemSound(.modifier)
    }
    
    @objc public func returnUp(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        returnActiveSubject.send(false)
        self.return(sender)
    }
    
}

// MARK: - popup
extension KeyboardView {
    
    @objc public func showPopup(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        guard let layout = layout else { return }
        
        sender.popup?.removeFromSuperview()
        let popup = layout.popup(for: sender, in: self)
        sender.popup = popup
        
        addSubview(popup)
        popup.render(for: sender, in: self)
        
        os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, popup.frame.debugDescription)
    }
    
    @objc public func hidePopup(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        sender.popup?.removeFromSuperview()
        sender.popup = nil
    }
    
    @objc public func hidePopupDelay(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
    }
    
}

extension KeyboardView {
    
    @objc public func inputKeyDown(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        playSystemSound(.click)
    }
    
    @objc public func inputKeyUp(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: [keyCode:%{public}s] %s", ((#file as NSString).lastPathComponent), #line, #function, sender.key.keyCode.code, sender.description)
        
        let text = isShiftDragExit || shiftState.uppercase ? sender.key.keyCode.shift : sender.key.keyCode.normal
        input(sender, text: text)
    }
    
}


extension KeyboardView {
    
    private func input(_ sender: KeyView, text: String) {
        // Restore previous page when drag input
        if isPageDragExit, let previousPage = previousPage {
            resetShift()
            load(page: previousPage)
        }
        
        // Restore default page not default page and just type space
        if text == " ",
            let currentKeyboard = self.currentKeyboard, let currentPage = self.currentPage,
            let defaultPage = self.pages[currentKeyboard]?.first,
            currentPage !== defaultPage {
            os_log("%{public}s[%{public}ld], %{public}s: request inputDelegate restore default page", ((#file as NSString).lastPathComponent), #line, #function)
            guard inputDelegate?.canRestorePage(self, page: defaultPage) ?? false else {
                return
            }
            
            load(page: defaultPage)
        }
        
        // Restore to previous page if type single quote
        if text == "'", let previousPage = previousPage {
            load(page: previousPage)
        }
        
        // Always reset shift when input
        if shiftState == .enabled {
            resetShift()
        }
        
        os_log("%{public}s[%{public}ld], %{public}s: input '%s' from %s", ((#file as NSString).lastPathComponent), #line, #function, text, sender.description)
        inputDelegate?.keyboardView(self, didInputText: text, sender: sender)
        
    }
    
    func deleteBackward() {
        os_log("%{public}s[%{public}ld], %{public}s: deleteBackward", ((#file as NSString).lastPathComponent), #line, #function)
        
        inputDelegate?.deleteBackward(self)
        playSystemSound(.modifier)
    }
    
    func `return`(_ sender: KeyView) {
        os_log("%{public}s[%{public}ld], %{public}s: return", ((#file as NSString).lastPathComponent), #line, #function)
        
        inputDelegate?.keyboardView(self, didInputText: "\n", sender: sender)
    }
    
}

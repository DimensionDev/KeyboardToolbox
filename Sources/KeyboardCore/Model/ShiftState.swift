//
//  ShiftState.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-25.
//

import Foundation
import GameplayKit

public enum ShiftState: String, CaseIterable {
    case disabled
    case enabled
    case locked
}

extension ShiftState {
    
    public var uppercase: Bool {
        return self == .disabled ? false : true
    }
    
}

extension ShiftState {
    
    public class State: GKState {
        unowned let keyboardView: KeyboardView
        
        public init(keyboardView: KeyboardView) {
            self.keyboardView = keyboardView
        }
    }
    
    public class Disabled: State {
        public override func didEnter(from previousState: GKState?) {
            keyboardView.shiftState = .disabled
        }
        
        public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass == Enabled.self || stateClass == Locked.self
        }
    }
    
    public class Enabled: State {
        public override func didEnter(from previousState: GKState?) {
            keyboardView.shiftState = .enabled
        }
        
        public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            if stateClass == Disabled.self && keyboardView.shiftStateWhenShiftDown != .disabled {
                return true
            }
            
            return stateClass == Locked.self
        }
    }
    
    public class Locked: State {
        public override func didEnter(from previousState: GKState?) {
            keyboardView.shiftState = .locked
        }
        
        public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass == Enabled.self
        }
    }
    
}

extension ShiftState: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
    
}

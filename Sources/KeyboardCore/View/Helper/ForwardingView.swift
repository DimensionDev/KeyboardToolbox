//
//  File.swift
//  
//
//  Created by Cirno MainasuK on 2020-3-24.
//

import UIKit

//   1. .touchDown -> [.touchDragInside] -> .touchUpInside
//    +-----+
//    |     |
//    | +-> |
//    |     |
//    +-----+
//
//   2. touchDown -> [.touchDragInside] -> .touchDragExit -> [.touchDragOutside] -> .touchUpOutside
//    +-----+
//    |     |
//    |  +--------->
//    |     |
//    +-----+
//
//   3. .touchDown -> [.touchDragInside] -> .touchDragExit -> [.touchDragOutside] -> .touchDragEnter -> [.touchDragInside] -> .touchUpInside
//    +-----+
//    |  +---------+
//    |     |      |
//    |  <---------+
//    +-----+
//
//   4. .touchDragEnter -> [.touchDragInside] -> .touchUpInside
//    +-----+
//    |     |
//    |  <---------+
//    |     |
//    +-----+
//
//   5. .touchDragEnter -> [.touchDragInside] -> .touchDragExit -> [.touchDragOutside] -> .touchUpOutside
//    +-----+
//    |  +---------+
//    |  |  |
//    |  +--------->
//    +-----+
//
//
//
// .touchDown: the view under touch position when touch began
// .touchDragEnter: trigger when from outside to inside
//      the new view drag inside (case 4)
//      the view touch move outside then move inside (case 3)
// .touchDragExit: trigger when from inside to outside
//      the view touch move outside (case 2, 3, 5)
// .touchDragInside: trigger every touch event when touch inside
// .touchDragOutside: trigger every touch event when touch outside

public class ForwardingView: UIView {
    
    var currentTouch: UITouch?
    var passThroughViews: Set<UIView> = []
    var viewInside: [UIView: Bool] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentMode = .redraw
        isMultipleTouchEnabled = true
        isUserInteractionEnabled = true
        isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // Why have this useless drawRect? Well, if we just set the backgroundColor to clearColor,
    // then some weird optimization happens on UIKit's side where tapping down on a transparent pixel will
    // not actually recognize the touch. Having a manual drawRect fixes this behavior, even though it doesn't
    // actually do anything.
    public override func draw(_ rect: CGRect) { }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent!) -> UIView? {
        if self.isHidden || self.alpha == 0 || !self.isUserInteractionEnabled {
            return nil
        } else {
            let view = findNearestView(point)
            
            if let keyView = view as? FunctionKeyView,
                let keyCode = keyView.key.keyCode as? KeyboardFunctionKeyCode, keyCode == .globe {
                return view
            }
            
            return (self.bounds.contains(point) ? self : nil)
        }
    }
    
    func handleControl(_ view: UIView?, controlEvent: UIControl.Event, uiEvent: UIEvent?) {
        guard let control = view as? UIControl else {
            return
        }
        
        let targets = control.allTargets
        for target in targets {
            if let actions = control.actions(forTarget: target, forControlEvent: controlEvent) {
                for action in actions {
                    let selectorString = action
                    let selector = Selector(selectorString)
                    control.sendAction(selector, to: target, for: uiEvent)
                }
                
            }
        }
    }
    
    func findNearestView(_ position: CGPoint) -> UIView? {
        if !bounds.contains(position) {
            return nil
        }
        
        var closest: (UIView, CGFloat)? = nil
        
        for anyView in subviews {
            if anyView.isHidden {
                continue
            }
            
            let distance = distanceBetween(anyView.frame, point: position)
            
            if closest != nil {
                if distance < closest!.1 {
                    closest = (anyView, distance)
                }
            } else {
                closest = (anyView, distance)
            }
        }
        
        return closest?.0
    }
    
    // http://stackoverflow.com/questions/3552108/finding-closest-object-to-cgpoint
    func distanceBetween(_ rect: CGRect, point: CGPoint) -> CGFloat {
        if rect.contains(point) {
            return 0
        }
        
        var closest = rect.origin
        
        if (rect.origin.x + rect.size.width < point.x) {
            closest.x += rect.size.width
        }
        else if (point.x > rect.origin.x) {
            closest.x = point.x
        }
        if (rect.origin.y + rect.size.height < point.y) {
            closest.y += rect.size.height
        }
        else if (point.y > rect.origin.y) {
            closest.y = point.y
        }
        
        let a = pow(Double(closest.y - point.y), 2)
        let b = pow(Double(closest.x - point.x), 2)
        return CGFloat(sqrt(a + b));
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let sortedTouches = touches.sorted(by: { $0.timestamp > $1.timestamp })
        let droppedTouches = touches.dropFirst()
        
        // Send instant .touchDown & .cancel event to the all touches except the latest touch
        for touch in droppedTouches {
            let position = touch.location(in: self)
            
            guard let view = findNearestView(position) else {
                continue
            }
            
            // .touchDown to trigger event
            handleControl(view, controlEvent: .touchDown, uiEvent: event)
            if touch.tapCount > 1 {
                handleControl(view, controlEvent: .touchDownRepeat, uiEvent: event)
            }
            
            // .cancel to finish event
            handleControl(view, controlEvent: .touchCancel, uiEvent: event)
        }
        
        // Cancel touch on previous touch views
        for view in passThroughViews {
            handleControl(view, controlEvent: .touchCancel, uiEvent: event)
        }
        
        // Reset touch views
        passThroughViews = []
        viewInside = [:]
        
        // Reset current touch
        currentTouch = sortedTouches.first
        
        // Set touchDown views
        passThroughViews = {
            guard let position = currentTouch?.location(in: self),
                let view = findNearestView(position) else {
                    return []
            }
            
            viewInside[view] = true
            handleControl(view, controlEvent: .touchDown, uiEvent: event)
            
            return [view]
        }()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentTouch = currentTouch, touches.contains(currentTouch) else {
            return
        }
        
        let position = currentTouch.location(in: self)
        var theNearestView: UIView?
        if let view = findNearestView(position) {
            // touch pass through a new view
            if !passThroughViews.contains(view) {
                passThroughViews.insert(view)
                viewInside[view] = true
                handleControl(view, controlEvent: .touchDragEnter, uiEvent: event)
            } else {
                theNearestView = view
            }
        } else {
            // no new view under touch
        }
        
        let touchInsideViews = passThroughViews.filter { view in
            return view.bounds.contains(currentTouch.location(in: view))
        }
        let touchOutsideViews = passThroughViews.subtracting(touchInsideViews)
        
        for view in touchInsideViews {
            let controlEvent: UIControl.Event = viewInside[view] == true ? .touchDragInside : .touchDragEnter
            handleControl(view, controlEvent: controlEvent, uiEvent: event)
            viewInside[view] = true
        }
        
        for view in touchOutsideViews {
            if view == theNearestView {
                // make the nearest view keep the touch focues
                let controlEvent: UIControl.Event = viewInside[view] == false  ? .touchDragEnter : .touchDragInside
                handleControl(view, controlEvent: controlEvent, uiEvent: event)
                viewInside[view] = true
            } else {
                let controlEvent: UIControl.Event = viewInside[view] == false  ? .touchDragOutside : .touchDragExit
                handleControl(view, controlEvent: controlEvent, uiEvent: event)
                viewInside[view] = false
            }
        }
        
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentTouch = currentTouch, touches.contains(currentTouch) else {
            return
        }
        
        let position = currentTouch.location(in: self)
        var theNearestView: UIView?
        if let view = findNearestView(position) {
            // touch pass through a new view
            if !passThroughViews.contains(view) {
                passThroughViews.insert(view)
                viewInside[view] = true
                handleControl(view, controlEvent: .touchUpInside, uiEvent: event)
            } else {
                theNearestView = view
            }
        } else {
            // no new view under touch
        }
        
        let touchInsideViews = passThroughViews.filter { view in
            return view.bounds.contains(currentTouch.location(in: view))
        }
        let touchOutsideViews = passThroughViews.subtracting(touchInsideViews)
        
        // trigger .touchUpInside first
        for view in touchInsideViews {
            handleControl(view, controlEvent: .touchUpInside, uiEvent: event)
        }
        
        if let theNearestView = theNearestView, touchOutsideViews.contains(theNearestView) {
            handleControl(theNearestView, controlEvent: .touchUpInside, uiEvent: event)
            
            for view in touchOutsideViews.drop(while: { $0 != theNearestView }) {
                handleControl(view, controlEvent: .touchUpOutside, uiEvent: event)
            }
            
        } else {
            for view in touchOutsideViews {
                handleControl(view, controlEvent: .touchUpOutside, uiEvent: event)
            }
        }
        
        passThroughViews = []
        viewInside = [:]
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentTouch = currentTouch, touches.contains(currentTouch) else {
            return
        }
        
        for view in passThroughViews {
            handleControl(view, controlEvent: .touchCancel, uiEvent: event)
        }
        
        passThroughViews = []
        viewInside = [:]
        
        self.currentTouch = nil
    }
    
}

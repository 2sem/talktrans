//
//  UIView+.swift
//  ShowNote
//
//  Created by 영준 이 on 2015. 12. 21..
//  Copyright © 2015년 leesam. All rights reserved.
//

import UIKit

extension UIView {

    func clearSubViews(){
        let views = self.subviews;
        for v in views{
            v.removeFromSuperview();
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable
    var tintGrayPopover : Bool{
        get{
            return self.tintAdjustmentMode == .automatic;
        }
        
        set(value){
            self.tintAdjustmentMode = value ? .dimmed : .normal;
        }
    }

    var viewController : UIViewController?{
        get{
            var value : UIViewController?;
            
            let next = self.next;
            guard next != nil else{
                return value;
            }
            
//            if let n = next as? UIViewController {
            if next is UIViewController{
                value = next as? UIViewController;
                return value;
            } else{
                value = (next as? UIView)?.viewController;
            }
            
            return value;
        }
    }
    
    func getConstraint(identifier: String?) -> NSLayoutConstraint?{
        //var value : NSLayoutConstraint?;
        //var filter = NSPredicate.predicateWithSubstitutionVariables(<#T##NSPredicate#>)
        
        return self.constraints.filter({ (cst) -> Bool in
            return cst.identifier == identifier;
        }).first;
    }
    
    func hasView<T : UIView>(type: T.Type) -> Bool{
        return !self.subviews.filter({ (view) -> Bool in
            return view is T || view.hasView(type: type);
        }).isEmpty;
    }
    
    /*func getView<T : UIView>(type: T.Type) -> T?{
        var value = self.subviews.filter({ (view) -> Bool in
            LS.debug("check subview \(LS.getClassName(view.classForCoder)) == \(LS.getClassName(T.self)) in \(LSUIUtil.getClassName(self.classForCoder))");
//            print("check subview %@ == %@ in %@", LSUIUtil.getClassName(view.classForCoder), LSUIUtil.getClassName(self.classForCoder));
            return view is T;
        }).first as? T;
        
        guard value == nil else {
            return value;
        }
        
        for view in self.subviews{
            value = view.getView(T);
            guard value == nil else {
                break;
            }
        }
        
        return value;
    }*/
    
    /*func printViewTree() -> Void{
        for view in self.subviews{
            print("print subview %@ in %@", LSUIUtil.getClassName(view.classForCoder), LSUIUtil.getClassName(self.classForCoder));
            view._printViewTree();
        }
    }*/
    
    /*private func _printViewTree(depth : Int = 0) -> Void{
        for view in self.subviews{
            //"".stringByPaddingToLength(depth, withString: " ", startingAtIndex: 0)
            print("print subview[%d] view[%@] super[%@]", depth, LSUIUtil.getClassName(view.classForCoder), LSUIUtil.getClassName(self.classForCoder));
            view._printViewTree(depth + 1);
        }
    }*/
    
    /*public func printSuperTree() -> Void{
        var currClass : AnyClass? = self.classForCoder;
        
        
        while currClass != nil {
            var superName = "";
            if currClass?.superclass() != nil{
                superName = LSUIUtil.getClassName(currClass!.superclass()!);
            }
            
            print("%@ - super[%@]", LSUIUtil.getClassName(currClass!), superName);
            currClass = currClass?.superclass();
        }
    }*/
    
    class LSGradientBackgroundLayer : CAGradientLayer{
        
    }
    
    @IBInspectable
    var GradientBackgroundStartColor : UIColor{
        get{
            let color_obj = self.GradientBackgroundLayer?.colors?.first;
            var color = UIColor.clear.cgColor;
            if color_obj != nil{
                color = color_obj as! CGColor;
            }
            
            return UIColor(cgColor: color);
        }
        
        set(value){
            let layer = self.GradientBackgroundLayer;
            guard layer != nil else{
                return;
            }
            
            layer?.colors = [value.cgColor, self.GradientBackgroundEndColor.cgColor];
            
//            layer?.removeFromSuperlayer();
//            self.layer.insertSublayer(layer!, atIndex: 0);
        }
    }
    
    @IBInspectable
    var GradientBackgroundEndColor : UIColor{
        get{
            let color_obj = self.GradientBackgroundLayer?.colors?.last;
            var color = UIColor.clear.cgColor;
            if color_obj != nil{
                color = color_obj as! CGColor;
            }
            
            return UIColor(cgColor: color);
        }
        
        set(value){
            let layer = self.GradientBackgroundLayer;
            
            guard layer != nil else{
                return;
            }
            
            layer?.colors = [self.GradientBackgroundStartColor.cgColor, value.cgColor];
            
//            layer?.removeFromSuperlayer();
//            self.layer.insertSublayer(layer!, atIndex: 0);
        }
    }
    
    private var GradientBackgroundLayer : LSGradientBackgroundLayer?{
        get{
            var layer = self.layer.sublayers?.filter({ (layer) -> Bool in
                return layer is LSGradientBackgroundLayer;
            }).first as? LSGradientBackgroundLayer;
            
            guard layer == nil else{
                return layer;
            }
            
            let gd_layer = LSGradientBackgroundLayer();
            gd_layer.frame = self.bounds;

//            gd_layer.colors = [self.GradientBackgroundStartColor.CGColor, self.GradientBackgroundEndColor.CGColor];
            gd_layer.colors = [UIColor.black.cgColor, UIColor.white.cgColor];
            gd_layer.startPoint = CGPoint(x: 0, y: 0.5);
            gd_layer.endPoint = CGPoint(x: 1, y: 0.5);
            
            self.layer.insertSublayer(gd_layer, at: 0);
            layer = gd_layer;
            
            return layer;
        }
    }
    
    func fitGradientBackground(){
        let layer = self.layer.sublayers?.filter({ (layer) -> Bool in
            return layer is LSGradientBackgroundLayer;
        }).first as? LSGradientBackgroundLayer;
        
        guard layer != nil else{
            return;
        }
        
        layer?.frame = self.bounds;
    }
    
    func rotate(angle: CGFloat){
        self.transform = self.transform.rotated(by: CGFloat.pi/180.0 * angle);
    }
}

//
//  UIViewController+.swift
//  ShowNote
//
//  Created by 영준 이 on 2015. 12. 15..
//  Copyright © 2015년 leesam. All rights reserved.
//

import UIKit

extension UIViewController {
    var window : UIWindow?{
        get{
            return UIApplication.shared.keyWindow;
        }
    }
    
    var mostTopViewController : UIViewController?{
        get{
            var value : UIViewController?;
            if let nav = self as? UINavigationController{
                value = nav.visibleViewController;
            }else if let tab = self as? UITabBarController{
                value = tab.selectedViewController;
            }else if value?.presentedViewController != nil{
                if value?.presentedViewController is UIAlertController{
                }else{
                    value = value?.presentedViewController;
                }
            }
            
            let top = value?.mostTopViewController;
            return top != nil ? top : value;
        }
    }
    
    @discardableResult
    func showAlert(title: String, msg: String, actions : [UIAlertAction], style: UIAlertControllerStyle, sourceView: UIView? = nil, sourceRect: CGRect? = nil, popoverDelegate: UIPopoverPresentationControllerDelegate? = nil, completion: (() -> Void)? = nil) -> UIAlertController{
        let alert = UIAlertController(title: title, message: msg, preferredStyle: style);
        for act in actions{
            alert.addAction(act);
        };
        
        if style == .actionSheet && alert.modalPresentationStyle == .popover{
            
            alert.popoverPresentationController?.sourceView = sourceView;
            if sourceRect != nil{
                alert.popoverPresentationController?.sourceRect = sourceRect!;
            }
            
            alert.popoverPresentationController?.delegate = popoverDelegate;
            //UIModalPresentationPopover
            //sourceView and sourceRect or a barButtonItem
        }
        
        self.present(alert, animated: false, completion: completion);
        return alert;
    }
    
    func showIndicator(title: String?, msg: String = "\n\n\n", completion: (() -> Void)? = nil) -> UIAlertController{
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert);
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge);
        indicator.center = CGPoint(x: 130, y: 65);
        indicator.color = UIColor.black;
        indicator.startAnimating();
        
        alert.view.addSubview(indicator);
        self.present(alert, animated: true, completion: completion);
        
        return alert;
    }
    
    @discardableResult
    func showPasscode(title: String?, msg: String, buttonTitle: String? = "OK", request: ((String) -> Bool)? = nil, completion: (() -> Void)? = nil) -> UIAlertController{
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert);
        
        alert.addTextField { (txt) -> Void in
            txt.placeholder = "Input password";
            txt.isSecureTextEntry = true;
        };
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (act) -> Void in
        }));
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (act) -> Void in
            let txt = alert.textFields?.first;
            
            guard txt?.text != nil else{
                return;
            }
            
            if request?(txt!.text!) == false {
                self.showPasscode(title: title, msg: msg, buttonTitle: buttonTitle, request: request, completion: completion);
            }
        }));
        
        self.present(alert, animated: true, completion: completion);
        
        return alert;
    }
    
    /// < 8.0
//    func popOverFromButton(buttonToShow: UIBarButtonItem, permittedArrowDirections : UIPopoverArrowDirection, animated : Bool) -> UIPopoverController{
//        var pop = UIPopoverController(contentViewController: self);
//        pop.presentPopoverFromBarButtonItem(buttonToShow, permittedArrowDirections: .Any, animated: true);
//        
////        (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
//        
//        return pop;
//    }
    
    func popOverFromButton(inView: UIViewController, buttonToShow: UIBarButtonItem, permittedArrowDirections : UIPopoverArrowDirection, animated : Bool=true, color: UIColor? = nil) -> UIPopoverPresentationController?{
        var pop = self.popoverPresentationController;
//        pop = LSPopoverPresentationController(presentedViewController: self, presentingViewController: inView);
        self.modalPresentationStyle = .popover;
        pop = self.popoverPresentationController;

//        var alreadyPoped = pop != nil;
        
        if inView.presentedViewController === self {
            return inView.presentedViewController?.popoverPresentationController;
        }
        else if inView.presentedViewController != nil {
            inView.presentedViewController?.dismiss(animated: false, completion: nil);
//            pop = self.popoverPresentationController;
        }
        pop?.permittedArrowDirections = .any;
        pop?.barButtonItem = buttonToShow;
        pop?.permittedArrowDirections = permittedArrowDirections;
        pop?.backgroundColor = color;
        if inView is UIPopoverPresentationControllerDelegate{
            pop?.delegate = inView as? UIPopoverPresentationControllerDelegate;
        }
        print("pop delegate \(pop?.delegate?.description ?? "")");
        
        inView.present(self, animated: animated, completion: nil);

//        pop?.presentationStyle = .FormSheet;
        
        
//        pop.presentPopoverFromBarButtonItem(buttonToShow, permittedArrowDirections: .Any, animated: true);
        
        //        (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
        
        return pop;
    }
    
    func popOver(inView: UIViewController, popOverDelegate delegate: UIPopoverPresentationControllerDelegate? = nil, viewToShow view: UIView, rectToShow rect: CGRect, permittedArrowDirections : UIPopoverArrowDirection, animated : Bool, color: UIColor? = nil, completion: (() -> Void)? = nil) -> UIPopoverPresentationController?{
        var pop = self.popoverPresentationController;
        self.modalPresentationStyle = .popover;
        
        pop = self.popoverPresentationController;
        
        if inView.presentedViewController === self {
            return inView.presentedViewController?.popoverPresentationController;
        }
        else if inView.presentedViewController != nil {
            inView.presentedViewController?.dismiss(animated: false, completion: nil);
            //            pop = self.popoverPresentationController;
        }
        
//        pop?.permittedArrowDirections = .Any;
//        pop?.barButtonItem = buttonToShow;
        pop?.permittedArrowDirections = permittedArrowDirections;
        pop?.sourceView = view;
        pop?.sourceRect = rect;
        pop?.backgroundColor = color;
//        self.modalInPopover = true;
        
        if delegate != nil{
            pop?.delegate = delegate;
        }
//        pop?.preferredContentSize = CGSizeMake(300, 200);
//        self.preferredContentSize = CGRectZero;
        
        if inView is UIPopoverPresentationControllerDelegate{
            pop?.delegate = inView as? UIPopoverPresentationControllerDelegate;
        }
        print("pop delegate \(pop?.delegate?.description ?? "")");
        
        inView.present(self, animated: true, completion: completion);
        
        
        //        pop?.presentationStyle = .FormSheet;
        
        
        //        pop.presentPopoverFromBarButtonItem(buttonToShow, permittedArrowDirections: .Any, animated: true);
        
        //        (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
        
        return pop;
    }
    
    var isPopover : Bool{
        get{
            var value = self.popoverPresentationController != nil;
            
            guard !value else{
                return value;
            }
            
            value = self.parent?.isPopover ?? false;
//            value = self.presentingViewController?.isPopover ?? false;
            
            return value;
        }
    }
    
    func childViewController<T : UIViewController>(type: T.Type) -> T?{
//        print("childViewController filter count[\(self.childViewControllers.count)]");
        return self.childViewControllers.filter({ (view) -> Bool in
//            print("childViewController filter \(view) == \(type)");

            return view.isKind(of: type);
        }).first as? T;
    }
    
    func backupNavigationBarHidden( hidden : inout Bool){
        hidden = (self.navigationController?.isNavigationBarHidden ?? false);
    }
    
    func restoreNavigationBarHidden( hidden: inout Bool){
        self.navigationController?.isNavigationBarHidden = hidden;
    }
    
    func backupNavigationBarTranslucent( translucent : inout Bool){
        translucent = (self.navigationController?.navigationBar.isTranslucent ?? false);
    }
    
    func restoreNavigationBarTranslucent( translucent: inout Bool){
        self.navigationController?.navigationBar.isTranslucent = translucent;
    }
    
    func backupTabBarTranslucent( translucent : inout Bool){
        translucent = (self.tabBarController?.tabBar.isTranslucent ?? false);
    }
    
    func restoreTabBarTranslucent( translucent: inout Bool){
        self.tabBarController?.tabBar.isTranslucent = translucent;
    }
    
    func openSettings(completionHandler completion: ((Bool) -> Swift.Void)? = nil){
        let url_settings = URL(string:UIApplicationOpenSettingsURLString);
        print("open settings - \(url_settings?.description ?? "")");
        UIApplication.shared.open(url_settings!, options: [:], completionHandler: { (result) in
            
        })
    }
    
    func openSettingsOrCancel(title: String = "Something is disabled", msg: String = "Please enable to do something", style: UIAlertControllerStyle = .alert, titleForOK: String = "OK", titleForSettings: String = "Settings"){
        let acts = [UIAlertAction(title: titleForSettings, style: .default, handler: { (act) in
            self.openSettings();
        }), UIAlertAction(title: titleForOK, style: .default, handler: nil)];
        self.showAlert(title: title, msg: msg, actions: acts, style: style);
    }
    
    func showCellularAlert(title: String, okHandler : ((UIAlertAction) -> Void)? = nil, cancelHandler : ((UIAlertAction) -> Void)? = nil){
        self.showAlert(title: title, msg: "Turn on cellular data or use Wi-Fi to access data".localized(), actions: [UIAlertAction(title: "Cancel".localized(), style: .default, handler: cancelHandler), UIAlertAction(title: "OK".localized(), style: .default, handler: okHandler)], style: .alert);
    }
    
    func share(_ activityItems: [Any], applicationActivities: [UIActivity]? = nil, completion: (() -> Void)? = nil){
        let controller = UIActivityViewController.init(activityItems: activityItems, applicationActivities: applicationActivities);
        controller.popoverPresentationController?.sourceView = self.view;
        //        controller.excludedActivityTypes = [.mail, .message, .postToFacebook, .postToTwitter];
        self.present(controller, animated: true, completion: completion);
    }
    
    func shareOrReview(cancelation: ((UIAlertAction) -> Void)? = nil){
        let name : String = self.nibBundle?.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? "";
        let acts = [UIAlertAction(title: String(format: "Review '%@'".localized(), name), style: .default) { (act) in
            
            UIApplication.shared.openReview();
            },
                    UIAlertAction(title: String(format: "Recommend '%@'".localized(), name), style: .default) { (act) in
                        self.share(["\(UIApplication.shared.urlForItunes.absoluteString)"]);
            },
                    UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: cancelation)]
        self.showAlert(title: "App rating and recommendation".localized(), msg: String(format: "Please rate '%@' or recommend it to your friends.".localized(), name), actions: acts, style: .alert);
    }
}

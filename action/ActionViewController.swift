//
//  ActionViewController.swift
//  action
//
//  Created by 영준 이 on 2017. 1. 23..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import MobileCoreServices
import Material
import LSExtensions
import NaverPapago

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var nativeLabel: UILabel!
    @IBOutlet weak var transLabel: UILabel!
    @IBOutlet weak var transButton: RaisedButton!
    
    var nativeText = "";
    
    var needFix = true;
    var nativeLocale = Locale.current{
        didSet{
            let lang = self.supportedLangs[self.nativeLocale.identifier];
            //            self.selectNativeLangButton.setTitle(lang?.localized(), for: .normal);
            self.nativeLabel.text = "";
            self.nativeLabel.layoutIfNeeded();
            self.nativeLabel.text = lang?.localized();
//            self.nativeLabel.text = "siba"
            if self.needFix{
                self.fixTransLang();
            }
        }
    }
    var transLocale = Locale(identifier: "en"){
        didSet{
            let lang = self.supportedLangs[self.transLocale.identifier];
            //            self.selectTransLangButton.setTitle(lang?.localized(), for: .normal);
            self.transLabel.text = "";
            self.transLabel.layoutIfNeeded();
            self.transLabel.text = lang?.localized();
//            self.transLabel.text = "siho"
            if self.needFix{
                self.fixNativeLang();
            }
        }
    }
    
    var isIPhone : Bool{
        get{
            return !UIDevice.current.model.hasPrefix("iPad");
        }
    }
    var supportedLangs = ["ko-Kore" : "Korean", "en" : "English", "ja" : "Japanese", "zh-Hans" : "Chinese", "zh-Hant" : "Taiwanese", "es" : "Spanish", "fr" : "French", "vi" : "Vietnamese", "id" : "Indonesian", "Thai" : "th"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        self.present(interstitial, animated: true, completion: nil);
        
//        self.extensionContext!.open(URL(string: "http://www.daum.net")!, completionHandler: { (result) in
//            print("open url => \(result)");
//        })
        
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        var textFound = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                    // This is an image. We'll load it, then place it in our image view.
//                    weak var weakImageView = self.imageView
                    provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { (text, error) in
                        
                        self.nativeText = text as? String ?? "";
                        print("load from host app - \(self.nativeText)")
                        let current = self.supportedLangs.first { (key: String, value: String) -> Bool in
                            return self.nativeLocale.identifier.hasPrefix(key);
                        }
                        let lang = self.supportedLangs[self.transLocale.identifier];
                        
                        DispatchQueue.main.sync {
                            self.transLabel.text = lang?.localized();
                            self.nativeLocale = Locale(identifier: current?.key ?? "ko");
                        }
                        
//                        OperationQueue.main.addOperation {
//                            if let strongImageView = weakImageView {
//                                if let imageURL = imageURL as? URL {
//                                    strongImageView.image = UIImage(data: try! Data(contentsOf: imageURL))
//                                }
//                            }
//                        }
                    })
                    
                    textFound = true
                    break
                }
            }
            
            if textFound {
                // We only handle one image, so stop looking for more.
                break
            }
        }
        
        if !textFound{
            print("no text to translate")
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.onTransLang(self.transButton);
    }

    func fixTransLang(){
        guard !NaverPapago.canSupportTranslate(source: self.nativeLocale, target: self.transLocale) else{
            return;
        }
        
        let target = self.supportedLangs.first { (key: String, value: String) -> Bool in
            return (self.nativeLocale.languageCode != "ko") ? key == "ko-Kore" : key == "en";
        }
        self.transLocale = Locale(identifier: target?.key ?? "en");
    }
    
    func fixNativeLang(){
        guard !NaverPapago.canSupportTranslate(source: self.nativeLocale, target: self.transLocale) else{
            //            self.updateTransMessage();
            return;
        }

        let source = self.supportedLangs.first { (key: String, value: String) -> Bool in
            return (self.transLocale.languageCode != "ko") ? key == "ko-Kore" : key == "en";
        }
        self.nativeLocale = Locale(identifier: source?.key ?? "ko");
    }
    
    func translate(_ text: String){
        NaverPapago.shared.requestTranslateByNMT(text: text, source: self.nativeLocale, target: self.transLocale, completionHandler: { (result) in
            
            switch result{
            case .success(let translated):
                print("translate result - \(translated)");
                OperationQueue.main.addOperation {
                    self.resultTextView.text = translated;
                }
                break;
            case .error:
                self.showCellularAlert(title: "Could not connect to Translator".localized(), okHandler: { (act) in
                    self.translate(text);
                }, cancelHandler: { (act) in
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil);
                })
                break;
            }
        });
    }
    
    func returnResult(result : String){
        let item = NSExtensionItem();
        let provider = NSItemProvider(item: result as NSSecureCoding?, typeIdentifier: kUTTypeText as String);
        item.attachments = [provider];
        
        //        result.attributedContentText = NSAttributedString(string: "dlkqweljqw");
        self.extensionContext!.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onNativeLang(_ button: UIButton) {
        //        AppDelegate.test = .portraitUpsideDown;
        var acts : [UIAlertAction] = [];
        var langs = self.supportedLangs;
        
        print("except \(self.nativeLocale.identifier) from lang list");
        let current = langs.first { (key: String, value: String) -> Bool in
            return self.nativeLocale.identifier.hasPrefix(key);
        }
        langs.removeValue(forKey: current?.key ?? "");
        for lang in langs{
            acts.append(UIAlertAction(title: lang.value.localized(), style: .default, handler: {(act) -> Void in
                //                self.selectNativeLangButton.setTitle("\(lang.value)".localized(), for: .normal);
                self.nativeLocale = Locale(identifier: lang.key);
                self.translate(self.nativeText);
                //                self.fixTransLang();
            }));
        }
        acts.append(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {(act) -> Void in
        }));
        self.showAlert(title: "Select Native Language".localized(), msg: String(format: "Current: %@".localized(), (self.supportedLangs[self.nativeLocale.languageCode ?? "ko"] ?? "Korean").localized()), actions: acts, style: .actionSheet, sourceView: button, sourceRect: button.bounds);
    }
    
    @IBAction func onTransLang(_ button: UIButton) {
        var acts : [UIAlertAction] = [];
        var langs = self.supportedLangs;
        let current = langs.first { (key: String, value: String) -> Bool in
            return self.transLocale.identifier.hasPrefix(key);
        }
        langs.removeValue(forKey: current?.key ?? "");
        //        langs.removeValue(forKey: self.transLocale.languageCode!);
        for lang in langs{
            acts.append(UIAlertAction(title: lang.value.localized(), style: .default, handler: {(act) -> Void in
                //                self.selectTransLangButton.setTitle(lang.value.localized(), for: .normal);
                self.transLocale = Locale(identifier: lang.key);
                self.translate(self.nativeText);
            }));
        }
        acts.append(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {(act) -> Void in
        }));
        self.showAlert(title: "Select Language to Translate".localized(), msg: String(format: "Current: %@".localized(), (self.supportedLangs[self.transLocale.languageCode ?? "en"] ?? "English").localized()), actions: acts, style: .actionSheet, sourceView: button, sourceRect: button.bounds);
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
//        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
        self.returnResult(result: self.resultTextView.text);
    }
    
    @IBAction func onShare(_ sender: UIBarButtonItem) {
        self.share([self.resultTextView.text], excludedActivities: [UIActivityType(rawValue: "com.credif.talktrans.action"),
                                                                    UIActivityType(rawValue: "com.credif.talktrans")]);
    }
    
    @discardableResult
    func showAlert(title: String, msg: String, actions : [UIAlertAction], style: UIAlertControllerStyle, sourceView: UIView? = nil, sourceRect: CGRect? = nil, completion: (() -> Void)? = nil) -> UIAlertController{
        let alert = UIAlertController(title: title, message: msg, preferredStyle: style);
        for act in actions{
            alert.addAction(act);
        };

        if style == .actionSheet && alert.modalPresentationStyle == .popover{
            alert.popoverPresentationController?.sourceView = sourceView;
            if sourceRect != nil{
                alert.popoverPresentationController?.sourceRect = sourceRect!;
            }

            //UIModalPresentationPopover
            //sourceView and sourceRect or a barButtonItem
        }
        self.present(alert, animated: false, completion: completion);
        return alert;
    }
    
//    func openSettings(completionHandler completion: ((Bool) -> Swift.Void)? = nil){
//        var url_settings = URL(string:UIApplicationOpenSettingsURLString);
//        print("open settings - \(url_settings)");
//        self.extensionContext?.open(url_settings!, completionHandler: { (result) in
//            
//        });
//    }
}

//
//  ViewController.swift
//  talktrans
//
//  Created by 영준 이 on 2016. 12. 2..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Speech
import AVKit
import Material

class MainViewController: UIViewController, UITextViewDelegate, GADBannerViewDelegate, UIPopoverPresentationControllerDelegate {
    static let MaxNativeTextLength = 100;
    class ConstraintID{
        static let TopBanner_BOTTOM = "TopBanner_BOTTOM";
        static let BottomBanner_TOP = "BottomBanner_TOP";
        static let ViewContainerBottom = "ViewContainerBottom";
    }
    
    var needFix = true;
    var nativeLocale = Locale.current{
        didSet{
            var lang = self.supportedLangs[self.nativeLocale.identifier];
//            self.selectNativeLangButton.setTitle(lang?.localized(), for: .normal);
            self.nativeLabel.text = lang?.localized();
            if self.needFix{
                self.fixTransLang();
            }
        }
    }
    var transLocale = Locale(identifier: "en"){
        didSet{
            var lang = self.supportedLangs[self.transLocale.identifier];
//            self.selectTransLangButton.setTitle(lang?.localized(), for: .normal);
            self.transLabel.text = lang?.localized();
            self.updateNativeInputMessage();
            self.updateTransMessage();
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
    var supportedLangs = ["ko-Kore" : "Korean", "en" : "English", "ja" : "Japanese", "zh-Hans" : "Chinese", "zh-Hant" : "Taiwanese", "es" : "Spanish", "fr" : "French", "vi" : "Vietnamese", "id" : "Indonesian"];
    
    var constraint_topBanner_top : NSLayoutConstraint!;
    var constraint_topBanner_bottom : NSLayoutConstraint!;
    var constraint_bottomBanner_top : NSLayoutConstraint!;
    var constraint_bottomBanner_bottom : NSLayoutConstraint!;

//    var constraint_viewContainer_bottom : NSLayoutConstraint!;
    
    @IBOutlet weak var topBannerView: GADBannerView!
    @IBOutlet weak var bottomBannerView: GADBannerView!
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var transView: UIView!
    @IBOutlet weak var transTextView: UITextView!
    @IBOutlet weak var transPlaceHolderLabel: UILabel!
    @IBOutlet weak var transLabel: UILabel!
    
    @IBOutlet weak var nativeView: UIView!
    @IBOutlet weak var nativeTextView: UITextView!
    @IBOutlet weak var nativePlaceHolderLabel: UILabel!
    @IBOutlet weak var nativeLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBAction func onAction(_ sender: UIButton) {
        self.share([self.transTextView.text ?? ""]);
    }
    
    @IBOutlet weak var fixButton: UIButton!
    @IBAction func onToggleFix(_ button: UIButton) {
        button.isSelected = !button.isSelected;
        
        if button.isSelected{
            
        }else{
            self.isUpSideDown = self.nativeTextView.isFirstResponder;
        }
        
        TTDefaults.isRotateFixed = button.isSelected;
    }
    
    @IBOutlet weak var selectNativeLangButton: UIButton!
    @IBAction func onNativeLang(_ button: UIButton) {
//        AppDelegate.test = .portraitUpsideDown;
        var acts : [UIAlertAction] = [];
        var langs = self.supportedLangs;
        
        print("except \(self.nativeLocale.identifier) from lang list");
        var current = langs.first { (key: String, value: String) -> Bool in
            return self.nativeLocale.identifier.hasPrefix(key);
        }
        langs.removeValue(forKey: current?.key ?? "");
        for lang in langs{
            acts.append(UIAlertAction(title: lang.value.localized(), style: .default, handler: {(act) -> Void in
//                self.selectNativeLangButton.setTitle("\(lang.value)".localized(), for: .normal);
                self.nativeLocale = Locale(identifier: lang.key);
//                self.fixTransLang();
            }));
        }
        acts.append(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {(act) -> Void in
        }));
        self.showAlert(title: "Select Native Language".localized(), msg: String(format: "Current: %@".localized(), (self.supportedLangs[self.nativeLocale.languageCode ?? "ko"] ?? "Korean").localized()), actions: acts, style: .actionSheet, sourceView: button, sourceRect: button.bounds, popoverDelegate: self);
        
        /*
         actions: [UIAlertAction(title: "Korean", style: .default, handler: {(act) -> Void in
         }),UIAlertAction(title: "English", style: .default, handler: {(act) -> Void in
         }),UIAlertAction(title: "Japanease", style: .default, handler: {(act) -> Void in
         }),UIAlertAction(title: "Chinease", style: .default, handler: {(act) -> Void in
         }),UIAlertAction(title: "Cancel", style: .cancel, handler: {(act) -> Void in
         })]
         */
    }
    
    @IBOutlet weak var selectTransLangButton: UIButton!
    @IBAction func onTransLang(_ button: UIButton) {
        var acts : [UIAlertAction] = [];
        var langs = self.supportedLangs;
        var current = langs.first { (key: String, value: String) -> Bool in
            return self.transLocale.identifier.hasPrefix(key);
        }
        langs.removeValue(forKey: current?.key ?? "");
//        langs.removeValue(forKey: self.transLocale.languageCode!);
        for lang in langs{
            acts.append(UIAlertAction(title: lang.value.localized(), style: .default, handler: {(act) -> Void in
//                self.selectTransLangButton.setTitle(lang.value.localized(), for: .normal);
                self.transLocale = Locale(identifier: lang.key);
            }));
        }
        acts.append(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {(act) -> Void in
        }));
        self.showAlert(title: "Select Language to Translate".localized(), msg: String(format: "Current: %@".localized(), (self.supportedLangs[self.transLocale.languageCode ?? "en"] ?? "English").localized()), actions: acts, style: .actionSheet, sourceView: button, sourceRect: button.bounds, popoverDelegate: self);
    }
    
    var av : AVAudioEngine = AVAudioEngine();
    var av_req = SFSpeechAudioBufferRecognitionRequest();
    var av_task : SFSpeechRecognitionTask?;
    var alert : UIAlertController?;

    @IBAction func onRegnizeSpeech(_ button: UIButton) {
        var recognizer = SFSpeechRecognizer(locale: self.nativeLocale);
        guard recognizer != nil else{
            print("device/locale does not support speech");
            return;
        }
        
        self.nativeTextView.resignFirstResponder();
        DispatchQueue.main.syncInMain {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        }
        SFSpeechRecognizer.requestAuthorization { (status) in
            defer{
                DispatchQueue.main.syncInMain {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                }
            }
            
            var str = "";
            
            switch(status){
            case .authorized:
                str = "authorized";
                
                AVAudioSession.sharedInstance().requestRecordPermission({ (recording_enabled) in
                    print("recording permission => \(recording_enabled)");
                    guard recording_enabled else{
                        self.openSettingsOrCancel(title: "Please allow Recording".localized(), msg: "Enable Microphone to input your sentence from your voice".localized(), style: .alert, titleForOK: "OK", titleForSettings: "Settings".localized());
                        return;
                    }
                    
                    guard !self.av.isRunning else{
                        return;
                    }
                    
                    self.av.inputNode.installTap(onBus: 0, bufferSize: 1024, format: self.av.inputNode.outputFormat(forBus: 0), block: { (buffer, time) in
                        self.av_req.append(buffer);
                    })
                    self.av.prepare();
                    
                    DispatchQueue.main.async {
                        self.alert = self.showAlert(title: "Recognizing...".localized(), msg: "Please say sentence to be recognized".localized(), actions: [UIAlertAction(title: "Translate".localized(), style: .default, handler: { (act) in
                            self.doneRecognition();
                            self.onTranslate(self.translateButton);
                        }), UIAlertAction(title: "Done".localized(), style: .default, handler: { (act) in
                            self.doneRecognition();
                        })], style: .actionSheet, sourceView: button, sourceRect: button.bounds, popoverDelegate: self);
                    }
                    
                    do{
                        try self.av.start();
                    }catch let error {
                        print("recording has been failed. error[\(error)]");
                    }
//                    self.av_req.shouldReportPartialResults = true;
                    self.av_task = recognizer?.recognitionTask(with: self.av_req, resultHandler: { (result, error) in
                        print("recognition has been completed. result[\(result)] error[\(error)]");
                        
                        guard error == nil else{
                            self.av.inputNode.removeTap(onBus: 0);
                            self.av.stop();
                            self.av_req.endAudio();
                            self.av_req = SFSpeechAudioBufferRecognitionRequest();
                            print("recording and recognition has been stopped");
                            var errorHandler = {(_ err : NSError) -> Void in
                                //show settings for cellular
                                if err.isSiriConnectionError(){
                                    self.showCellularAlert(title: "Could not connect to Siri".localized(), okHandler: { (act) in
                                        self.onRegnizeSpeech(self.translateButton);
                                    }, cancelHandler: { (act) in
                                        
                                    })
                                }
                            };
                            if self.alert?.presentingViewController != nil{
                                self.alert?.dismiss(animated: false, completion: {
                                    errorHandler(error as! NSError);
                                });
                                return;
                            }
                            
//                            if error is
                            return;
                        }
                        
                        self.nativeTextView.text = result?.bestTranscription.formattedString;
                        self.nativePlaceHolderLabel.isHidden = !self.nativeTextView.text.isEmpty;
//                        result?.bestTranscription.formattedString
                    })
                })
                break;

            case .denied:
                str = "denied";
//                var url = URL(string: "prefs:root=\(Bundle.main.infoDictionary!["CFBundleName"]!)");
                
//                var acts = [UIAlertAction(title: "Settings", style: .default, handler: { (act) in
//                    var url_settings = URL(string:UIApplicationOpenSettingsURLString);
//                    print("open settings - \(url_settings)");
//                    UIApplication.shared.open(url_settings!, options: [:], completionHandler: { (result) in
//                        
//                    })
//                }), UIAlertAction(title: "OK", style: .default, handler: nil)];
//                self.showAlert(title: "Please allow Speech Recognition", msg: "Turn on Speech Recognition to input your sentence from your voice", actions: acts, style: .alert);
                self.openSettingsOrCancel(title: "Please allow Speech Recognition", msg: "Turn on Speech Recognition to input your sentence from your voice", style: .alert, titleForOK: "OK", titleForSettings: "Settings");
                break;
            case .notDetermined:
                str = "notDetermined";
                break;
            case .restricted:
                str = "restricted";
                break;
            }
            
            print("\(#function) - requestAuthorization => \(str)");
        }
        //recognizer
    }
    
    func doneRecognition(){
        self.av_req.endAudio();
        self.av.stop();
        self.av.inputNode.removeTap(onBus: 0);
        self.av_req = SFSpeechAudioBufferRecognitionRequest();
    }
    
    @IBOutlet weak var translateButton: UIButton!
    @IBAction func onTranslate(_ sender: UIButton) {
        guard !self.nativeTextView.text.isEmpty else{
            return;
        }
        
        self.nativeTextView.resignFirstResponder();
        guard NVAPIManager.canSupportTranslate(source: self.nativeLocale, target: self.transLocale) else{
                var nativeTitle = self.nativeLabel.text ?? "";
                var transTitle = self.transLabel.text ?? "";
            self.showAlert(title: "Error".localized(), msg: String(format: "It is not supported to translate %@ to %@".localized(), nativeTitle, transTitle), actions: [UIAlertAction(title: "OK".localized(), style: .default, handler: nil)], style: .alert);
                return;
        }
        
//        NVAPIManager().requestTranslate(source: self.nativeTextView.text);
        NVAPIManager().requestTranslateByNMT(text: self.nativeTextView.text,
                                        source: self.nativeLocale,
                                        target: self.transLocale,
                                        completionHandler: {(status, result, error) -> Void in
            guard error == nil else {
                if result == nil{
                    self.showCellularAlert(title: "Could not connect to Translator".localized(), okHandler: { (act) in
                        self.onTranslate(self.translateButton);
                    }, cancelHandler: { (act) in
                        
                    })
                }
                return;
            }
            
            DispatchQueue.main.async {
                self.transTextView.text = result;
                self.transPlaceHolderLabel.isHidden = !self.transTextView.text.isEmpty;
            }
        });
    }
    
    @IBOutlet weak var reviewButton: IconButton!
    @IBAction func onReviewButton(_ sender: UIButton) {
        var name : String = self.nibBundle?.localizedInfoDictionary?["CFBundleDisplayName"] as? String ?? "";
        var acts = [UIAlertAction(title: String(format: "Review '%@'".localized(), name), style: .default) { (act) in
            
                UIApplication.shared.openReview();
            },
                    UIAlertAction(title: String(format: "Recommend '%@'".localized(), name), style: .default) { (act) in
                        self.share(["\(UIApplication.shared.urlForItunes.absoluteString)"]);
            },
                UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)]
        self.showAlert(title: "App rating and recommendation".localized(), msg: String(format: "Please rate '%@' or recommend it to your friends.".localized(), name), actions: acts, style: .alert);
    }
    
    var isUpSideDown = false{
        didSet{
            if self.isUpSideDown{
                UIView.animate(withDuration: 0.5, animations: {
                    self.transView.rotate(angle: 180);
                })
            }else{
                UIView.animate(withDuration: 0.5, animations: {
                    self.transView.rotate(angle: -180);
                })
            }
            
            TTDefaults.isUpsideDown = self.isUpSideDown;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*NMT 언어 코드.
         1.ko : 한국어
         2.en : 영어
         3.zh-CN : 중국어 간체
         4.zh-TW : 중국어 번체
         5.es : 스페인어
         6.fr : 프랑스어
         7.vi : 베트남어
         8.th : 태국어
         9.id : 인도네시아어
         10. ja : japan
         */
        
        UIApplication.shared.statusBarStyle = .lightContent;
        print("current locale[\(self.nativeLocale.identifier)] lang[\(self.nativeLocale.languageCode)] region[\(self.nativeLocale.regionCode)]");
        var current = self.supportedLangs.first { (key: String, value: String) -> Bool in
            return self.nativeLocale.identifier.hasPrefix(key);
        }
        self.nativeLocale = Locale(identifier: current?.key ?? "ko");
        
        self.constraint_topBanner_top = self.topBannerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20);
        self.constraint_topBanner_bottom = self.view.getConstraint(identifier: ConstraintID.TopBanner_BOTTOM);
        
        self.constraint_bottomBanner_top = self.view.getConstraint(identifier: ConstraintID.BottomBanner_TOP);
        self.constraint_bottomBanner_bottom = self.bottomBannerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor);
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: .UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: .UIKeyboardWillHide, object: nil);
        
        self.topBannerView.loadUnitId(name: "TopBanner");
//        self.topBannerView.adUnitID = "ca-app-pub-9684378399371172/8037065649";
        self.topBannerView.rootViewController = self;
        var req = GADRequest();
//        req.testDevices = ["5fb1f297b8eafe217348a756bdb2de56"];
        self.topBannerView.load(req);
        
//        self.topBannerView.layer.transform = CATransform3DMakeRotation(180, 0, 0, 0);
//        self.topBannerView.layer.transform = CGAffineTransform(rotationAngle: 180);
        self.topBannerView.transform = self.topBannerView.transform.rotated(by: CGFloat.pi/180.0 * 180.0);
//        self.topBannerView.rotate(angle: 180);
//        self.topBannerView.transform = CGAffineTransform(rotationAngle: 0);
        
        self.bottomBannerView.loadUnitId(name: "BottomBanner");
//        self.bottomBannerView.adUnitID = "ca-app-pub-9684378399371172/9513798848";
        self.bottomBannerView.rootViewController = self;
        req = GADRequest();
//        req.testDevices = ["5fb1f297b8eafe217348a756bdb2de56"];
        self.bottomBannerView.load(req);
        
        self.transView.rotate(angle: 180);
        
        if TTDefaults.isRotateFixed ?? false{
            if TTDefaults.isUpsideDown ?? false{
                self.isUpSideDown = TTDefaults.isUpsideDown ?? true;
            }
            
            self.fixButton.isSelected = TTDefaults.isRotateFixed ?? false;
        }else{
            TTDefaults.isUpsideDown = true;
        }
        // Do any additional setup after loading the view, typically from a nib.
        
//        self.reviewButton.image = Icon.cm.star;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSwapLang(_ sender: UIButton) {
        print("swap lang");
        self.nativeTextView.resignFirstResponder();
        var tempLocale = self.nativeLocale;
        var tempText = self.nativeTextView.text;
        var tempTitle = self.nativeLabel.text;
        
        self.needFix = false;
        self.nativeLocale = self.transLocale;
        self.nativeTextView.text = self.transTextView.text;
//        self.selectNativeLangButton.setTitle(self.transLabel.text, for: .normal);
        self.nativeLabel.text = self.transLabel.text;
        
        self.transLocale = tempLocale;
        self.transTextView.text = tempText;
//        self.selectTransLangButton.setTitle(tempTitle, for: .normal);
        self.transLabel.text = tempTitle;
        
        self.nativePlaceHolderLabel.isHidden = !self.nativeTextView.text.isEmpty;
        self.transPlaceHolderLabel.isHidden = !self.transTextView.text.isEmpty;
        
        self.needFix = true;
    }
    
    /// MARK: keyboard notification
    var keyboardEnabled = false;
    @objc func keyboardWillShow(noti: Notification){
        print("keyboard will show move view to upper -- \(noti.object)");
//        if self.nativeTextView.isFirstResponder {
        if !keyboardEnabled {
            keyboardEnabled = true;
//            self.viewContainer.frame.origin.y -= 180;
            var frame = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect;
            
            // - self.bottomBannerView.frame.height
            if false && !self.isIPhone{
//                var remainHeight = self.view.frame.height - (frame?.height ?? 0);
                var remainHeight : CGFloat = 100.0;
                self.constraint_topBanner_top.constant = -remainHeight;
                self.constraint_topBanner_bottom.constant = -remainHeight;
            }
            
            //hide while user is typing
            self.toggleContraint(value: true, constraintOn: self.constraint_topBanner_bottom, constarintOff: self.constraint_topBanner_top);
            self.topBannerView.isHidden = true;
            self.constraint_bottomBanner_top.constant = -((frame?.height ?? 180));
            self.constraint_bottomBanner_bottom.constant = -((frame?.height ?? 180));
//            self.viewContainer.layoutIfNeeded();
            if !self.fixButton.isSelected{
                self.isUpSideDown = true;
            }
            self.topBannerView.rotate(angle: -180);
        };
        //native y -= (keyboard height - bottom banner height)
        // keyboard top == native bottom
//        }
    }
    
    @objc func keyboardWillHide(noti: Notification){
        print("keyboard will hide move view to lower  -- \(noti.object)");
//        if self.nativeTextView.isFirstResponder{
        
//        }
        //&&
        if keyboardEnabled {
            keyboardEnabled = false;
//            self.viewContainer.frame.origin.y += 180;
            self.constraint_topBanner_top.constant = 20;
            self.constraint_topBanner_bottom.constant = 0;
            
            self.constraint_bottomBanner_top.constant = 0;
            self.constraint_bottomBanner_bottom.constant = 0;
//            self.viewContainer.layoutIfNeeded();
            
            //show while user is not typing
            self.toggleContraint(value: false, constraintOn: self.constraint_topBanner_bottom, constarintOff: self.constraint_topBanner_top);
            self.topBannerView.isHidden = false;
            
            if !self.fixButton.isSelected{
                self.isUpSideDown = false;
            }
            self.topBannerView.rotate(angle: 180);
        };
    }
    
    func updateNativeInputMessage(){
        self.nativePlaceHolderLabel.text = String(format: "Please input your message to be translated as %@".localized(), self.transLabel.text?.localized() ?? "English");
//        print("set native input usage. format[\("Please input your message to be translated as %@".localized())] locale[\(self.transLabel.text?.localized() ?? "English")] ");
//        print("chinese[\(String(format: "sibal moay? %@ sibal", "???"))]");
//        print("chinese[\(String(format: "sibal moay? %@ sibal Please input your %@ message to be translated as ", "English"))]");
        //請輸入您要翻譯為 ％s 的郵件
    }
    
    func updateTransMessage(){
        self.transPlaceHolderLabel.text = "Translated message will appear here".localized(locale: self.transLocale);
    }
    
    func fixTransLang(){
        guard !NVAPIManager.canSupportTranslate(source: self.nativeLocale, target: self.transLocale) else{
            self.updateNativeInputMessage();
            return;
        }
        
        var target = self.supportedLangs.first { (key: String, value: String) -> Bool in
            return (self.nativeLocale.languageCode != "ko") ? key == "ko-Kore" : key == "en";
        }
        self.transLocale = Locale(identifier: target?.key ?? "en");
    }
    
    func fixNativeLang(){
        guard !NVAPIManager.canSupportTranslate(source: self.nativeLocale, target: self.transLocale) else{
//            self.updateTransMessage();
            return;
        }
        
        var source = self.supportedLangs.first { (key: String, value: String) -> Bool in
            return (self.transLocale.languageCode != "ko") ? key == "ko-Kore" : key == "en";
        }
        self.nativeLocale = Locale(identifier: source?.key ?? "ko");
    }
    
    func toggleContraint(value : Bool, constraintOn : NSLayoutConstraint, constarintOff : NSLayoutConstraint){
        if constraintOn.isActive{
            constraintOn.isActive = value;
            constarintOff.isActive = !value;
        }else{
            constarintOff.isActive = !value;
            constraintOn.isActive = value;
        }
    }
    
    // MARK: GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if bannerView === self.topBannerView && !self.keyboardEnabled{
            // && self.isIPhone
            self.toggleContraint(value: true, constraintOn: self.constraint_topBanner_top, constarintOff: self.constraint_topBanner_bottom);
            self.topBannerView.isHidden = false;
        }else if bannerView === self.bottomBannerView{
            self.toggleContraint(value: true, constraintOn: self.constraint_bottomBanner_bottom, constarintOff: self.constraint_bottomBanner_top);
            self.bottomBannerView.isHidden = false;
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        if bannerView === self.topBannerView{
            self.toggleContraint(value: false, constraintOn: self.constraint_topBanner_top, constarintOff: self.constraint_topBanner_bottom);
            self.topBannerView.isHidden = true;
        }else if bannerView === self.bottomBannerView{
            self.toggleContraint(value: false, constraintOn: self.constraint_bottomBanner_bottom, constarintOff: self.constraint_bottomBanner_top);
            self.bottomBannerView.isHidden = true;
        }
    }
    
    /// MARK: UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var textLength = textView.text.lengthOfBytes(using: .utf8);
//        var textLength = textView.text.lengthOfBytes(using: .utf8);
        var textNewLength = text.lengthOfBytes(using: .utf8);
        
        return (textLength - range.length + textNewLength) <= MainViewController.MaxNativeTextLength
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.nativePlaceHolderLabel.isHidden = true;
//        UIView.animate(withDuration: 0.5, animations: {
//            self.transView.layoutIfNeeded();
//        }, completion: {(result) -> Void in
////            self.transView.rotate(angle: 180);
//        })
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView === self.nativeTextView else{
            return;
        }
        
        self.nativePlaceHolderLabel.isHidden = !textView.text.isEmpty;
//        UIView.animate(withDuration: 0.5, animations: {
//            self.transView.rotate(angle: 180);
//            self.transView.layoutIfNeeded();
//        }, completion: {(result) -> Void in
////            self.transView.rotate(angle: 180);
//        })
    }
//    override var shouldAutorotate: Bool{
//        get{
//            return false;
//        }
//    }
    
    //UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        guard self.av.isRunning else{
            return;
        }
        
        self.doneRecognition();
    }
}

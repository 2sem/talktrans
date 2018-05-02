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
import LSExtensions
import NaverPapago

class MainViewController: UIViewController, UITextViewDelegate, GADBannerViewDelegate, UIPopoverPresentationControllerDelegate, LSLanguagePickerButtonDelegate {
    
    /// Limits length of native text
    static let MaxNativeTextLength = 100;
    
    /// need fix language
    var needFix = true;
    
    ///Locale(Lang) of Native Text
    var nativeLocale = Locale.current{
        didSet{
            self.nativeButton.language = self.supportedLangs[self.nativeLocale.identifier];
            if self.needFix{
                self.fixTransLang();
            }
        }
    }
    
    ///Locale(Lang) of Translated Text
    var transLocale = Locale.current{
        didSet{
            let lang = self.supportedLangs[self.transLocale.identifier];
            self.transButton.language = lang;
            self.updateNativeInputMessage();
            self.updateTransMessage();
            if self.needFix{
                self.fixNativeLang();
            }
        }
    }
    
    var supportedLangs = ["ko-Kore" : "Korean", "en" : "English", "ja" : "Japanese", "zh-Hans" : "Chinese", "zh-Hant" : "Taiwanese", "es" : "Spanish", "fr" : "French", "vi" : "Vietnamese", "id" : "Indonesian"];
    
    // MARK: Layout Constraints to toggle Admob Banner
    var constraint_topBanner_top : NSLayoutConstraint!;
    @IBOutlet var constraint_topBanner_bottom: NSLayoutConstraint!
    @IBOutlet var constraint_bottomBanner_top : NSLayoutConstraint!;
    var constraint_bottomBanner_bottom : NSLayoutConstraint!;

    @IBOutlet weak var topBannerView: GADBannerView!
    @IBOutlet weak var bottomBannerView: GADBannerView!
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var transView: UIView!
    @IBOutlet weak var transTextView: UITextView!
    @IBOutlet weak var transPlaceHolderLabel: UILabel!
    @IBOutlet weak var transButton: LSLanguagePickerButton!
    
    @IBOutlet weak var nativeView: UIView!
    @IBOutlet weak var nativeTextView: UITextView!
    @IBOutlet weak var nativePlaceHolderLabel: UILabel!
    @IBOutlet var nativeButton: LSLanguagePickerButton!
    
    @IBOutlet weak var actionButton: UIButton!
    
    /// Shares translated text
    @IBAction func onAction(_ button: UIButton) {
        self.share([self.transTextView.text ?? ""]);
    }
    
    //Fix rotation of translated view
    @IBOutlet weak var fixButton: UIButton!
    @IBAction func onToggleFix(_ button: UIButton) {
        button.isSelected = !button.isSelected;
        
        if !button.isSelected{
            self.isUpSideDown = self.nativeTextView.isFirstResponder;
        }
        
        //Stores state of rotation of translated view
        TTDefaults.isRotateFixed = button.isSelected;
    }
    
    var languagePicker: LSLanguagePicker!;
    @IBOutlet weak var langTextField : UITextField!;
    
    @IBOutlet weak var selectNativeLangButton: UIButton!
    @IBAction func onNativeLang(_ button: UIButton) {
        self.nativeButton.languages = [String].init(self.supportedLangs.values);
        self.nativeButton.showPicker();
    }
    
    @IBOutlet weak var selectTransLangButton: UIButton!
    @IBAction func onTransLang(_ button: UIButton) {
        self.transButton.languages = [String].init(self.supportedLangs.values);
        self.transButton.showPicker();
    }
    
    var av : AVAudioEngine = AVAudioEngine();
    var av_req = SFSpeechAudioBufferRecognitionRequest();
    var av_task : SFSpeechRecognitionTask?;
    var alert : UIAlertController?;

    @IBAction func onRegnizeSpeech(_ button: UIButton) {
        
        guard let recognizer = SFSpeechRecognizer(locale: self.nativeLocale) else{
            print("device/locale does not support speech");
            return;
        }
        
        self.nativeTextView.resignFirstResponder();
        UIApplication.onNetworking();
        SFSpeechRecognizer.requestAuthorization { (status) in
            defer{
                UIApplication.offNetworking();
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
                    self.av_task = recognizer.recognitionTask(with: self.av_req, resultHandler: { (result, error) in
                        print("recognition has been completed. result[\(result?.description ?? "")] error[\(error.debugDescription)]");
                        
                        guard error == nil else{
                            self.av.inputNode.removeTap(onBus: 0);
                            self.av.stop();
                            self.av_req.endAudio();
                            self.av_req = SFSpeechAudioBufferRecognitionRequest();
                            print("recording and recognition has been stopped");
                            let errorHandler = {(_ err : NSError) -> Void in
                                //show settings for cellular
                                if err.isSiriConnectionError{
                                    self.showCellularAlert(title: "Could not connect to Siri".localized(), okHandler: { (act) in
                                        self.onRegnizeSpeech(self.translateButton);
                                    }, cancelHandler: { (act) in
                                        
                                    })
                                }
                            };
                            if self.alert?.presentingViewController != nil{
                                self.alert?.dismiss(animated: false, completion: {
                                    errorHandler(error! as NSError);
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
        
        //Stop typing
        self.nativeTextView.resignFirstResponder();
        
        //Checks if native locale can be translated to the translated locale
        guard NaverPapago.canSupportTranslate(source: self.nativeLocale, target: self.transLocale) else{
                let nativeTitle = self.nativeButton.language ?? "";
                let transTitle = self.transButton.language ?? "";
            self.showAlert(title: "Error".localized(), msg: String(format: "It is not supported to translate %@ to %@".localized(), nativeTitle, transTitle), actions: [UIAlertAction(title: "OK".localized(), style: .default, handler: nil)], style: .alert);
                return;
        }

        //Translates native text
        NaverPapago.shared.requestTranslateByNMT(text: self.nativeTextView.text,
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
    
    // MARK: Shows alert to open review
    @IBAction func onReviewButton(_ sender: UIButton) {
        let name : String = UIApplication.shared.displayName ?? "";
        let acts = [UIAlertAction(title: String(format: "Review '%@'".localized(), name), style: .default) { (act) in
            
                UIApplication.shared.openReview();
            },
                    UIAlertAction(title: String(format: "Recommend '%@'".localized(), name), style: .default) { (act) in
                        self.share(["\(UIApplication.shared.urlForItunes.absoluteString)"]);
            },
                UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)]
        self.showAlert(title: "App rating and recommendation".localized(), msg: String(format: "Please rate '%@' or recommend it to your friends.".localized(), name), actions: acts, style: .alert);
    }
    
    /**
        Indication to reverse translated view
    */
    var isUpSideDown = false{
        didSet{
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                let angle : CGFloat = 180.0;
                self?.transView.rotate(self?.isUpSideDown ?? false ? angle : -angle);
            })
            
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
        
        // Sets white status bar because app's theme is dark
        UIApplication.shared.statusBarStyle = .lightContent;
        print("current locale[\(self.nativeLocale.identifier)] lang[\(self.nativeLocale.languageCode?.description ?? "")] region[\(self.nativeLocale.regionCode?.description ?? "")]");
        let current = self.supportedLangs.first { (key: String, value: String) -> Bool in
            return self.nativeLocale.identifier.hasPrefix(key);
        }
        self.nativeButton.delegate = self;
        self.nativeLocale = Locale(identifier: current?.key ?? "ko");
        
        self.transButton.delegate = self;
        
        // Treats iPhone X
        if #available(iOS 11.0, *) {
            self.constraint_topBanner_top = self.topBannerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor);
            self.constraint_bottomBanner_bottom = self.bottomBannerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor);
        } else {
            self.constraint_topBanner_top = self.topBannerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20);
            self.constraint_bottomBanner_bottom = self.bottomBannerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor);
        };
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: .UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: .UIKeyboardWillHide, object: nil);
        
        self.topBannerView.loadUnitId(name: "TopBanner");
        self.topBannerView.rootViewController = self;
        
        var req = GADRequest();
        self.topBannerView.load(req);
        
        self.topBannerView.rotate(180);
        self.transView.rotate(180);
        
        self.bottomBannerView.loadUnitId(name: "BottomBanner");
        self.bottomBannerView.rootViewController = self;
        req = GADRequest();
        self.bottomBannerView.load(req);
        
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
    
    //Gets Locale by identifier
    func getLang(byLocale locale : Locale) -> (key: String, value: String)?{
        return self.supportedLangs.first { (key: String, value: String) -> Bool in
            return locale.identifier.hasPrefix(key);
        }
    }
    
    //Gets Lang by lang name
    func getLang(byLangName lang : String) -> (key: String, value: String)?{
        return self.supportedLangs.first { (key: String, value: String) -> Bool in
            return lang == value;
        }
    }
    
    @IBAction func onSwapLang(_ button: UIButton) {
        print("swap lang");
        
        //Stops input native text
        self.nativeTextView.resignFirstResponder();
        let tempLocale = self.nativeLocale;
        let tempText = self.nativeTextView.text;
        let tempTitle = self.nativeButton.language ?? "";
        
        //Prevents to fix language
        self.needFix = false;
        self.nativeLocale = self.transLocale;
        self.nativeTextView.text = self.transTextView.text;
        self.nativeButton.language = self.transButton.language;
        
        //Swaps locale of native and translated
        self.transLocale = tempLocale;
        self.transTextView.text = tempText;
        self.transButton.language = tempTitle;
        
        self.nativePlaceHolderLabel.isHidden = self.nativeTextView.text.any;
        self.transPlaceHolderLabel.isHidden = self.transTextView.text.any;
        
        //Releases preventing to fix language
        self.needFix = true;
    }
    
    /// MARK: keyboard notification
    var keyboardEnabled = false;
    @objc func keyboardWillShow(noti: Notification){
        print("keyboard will show move view to upper -- \(noti.object.debugDescription)");
        if !keyboardEnabled {
            keyboardEnabled = true;
            let frame = noti.keyboardFrame;
            
            //Hides while user is typing native text
            self.toggleContraint(value: true, constraintOn: self.constraint_topBanner_bottom, constarintOff: self.constraint_topBanner_top);
            self.topBannerView.isHidden = true;
            self.constraint_bottomBanner_top.constant = -(frame.height);
            self.constraint_bottomBanner_bottom.constant = -(frame.height);

            if !self.fixButton.isSelected{
                self.isUpSideDown = true;
            }
            self.topBannerView.rotate(-180);
        };
    }
    
    @objc func keyboardWillHide(noti: Notification){
        print("keyboard will hide move view to lower  -- \(noti.object.debugDescription)");

        if keyboardEnabled {
            keyboardEnabled = false;
            
            self.constraint_bottomBanner_top.constant = 0;
            self.constraint_bottomBanner_bottom.constant = 0;
            
            //shows while user is not typing
            self.toggleContraint(value: false, constraintOn: self.constraint_topBanner_bottom, constarintOff: self.constraint_topBanner_top);
            self.topBannerView.isHidden = false;
            
            if !self.fixButton.isSelected{
                self.isUpSideDown = false;
            }
            self.topBannerView.rotate(180);
        };
    }
    
    func updateNativeInputMessage(){
        self.nativePlaceHolderLabel.text = String(format: "Please input your message to be translated as %@".localized(), self.transButton.language?.localized() ?? "English");
    }
    
    func updateTransMessage(){
        self.transPlaceHolderLabel.text = "Translated message will appear here".localized(locale: self.transLocale);
    }
    
    func fixTransLang(){
        guard !NaverPapago.canSupportTranslate(source: self.nativeLocale, target: self.transLocale) else{
            self.updateNativeInputMessage();
            return;
        }
        
        let target = self.supportedLangs.first { (key: String, value: String) -> Bool in
            return (self.nativeLocale.languageCode != "ko") ? key == "ko-Kore" : key == "en";
        }
        self.transLocale = Locale(identifier: target?.key ?? "en");
        print("fix translated locale. locale[\(self.transLocale)]");
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
    
    /**
        Toggles two layout constraint, turn on one, turn off another
     */
    func toggleContraint(value : Bool, constraintOn : NSLayoutConstraint, constarintOff : NSLayoutConstraint){
        if constraintOn.isActive{
            constraintOn.isActive = value;
            constarintOff.isActive = !value;
        }else{
            constarintOff.isActive = !value;
            constraintOn.isActive = value;
        }
    }
    
    // MARK: LSLanguagePickerButtonDelegate
    func languagePicker(_ picker: LSLanguagePickerButton, didFinishPickingLanguage language: String) {
        let lang = self.getLang(byLangName: language);
        
        if picker === self.nativeButton{
            self.nativeLocale = Locale(identifier: lang?.key ?? "");
        }else{
            self.transLocale = Locale(identifier: lang?.key ?? "");
        }
    }
    
    // MARK: GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if bannerView === self.topBannerView && !self.keyboardEnabled{
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
        let textLength = textView.text.lengthOfBytes(using: .utf8);
        let textNewLength = text.lengthOfBytes(using: .utf8);
        
        return (textLength - range.length + textNewLength) <= MainViewController.MaxNativeTextLength
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.nativePlaceHolderLabel.isHidden = true;
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView === self.nativeTextView else{
            return;
        }
        
        self.nativePlaceHolderLabel.isHidden = !textView.text.isEmpty;
    }
    
    //UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        guard self.av.isRunning else{
            return;
        }
        
        self.doneRecognition();
    }
}

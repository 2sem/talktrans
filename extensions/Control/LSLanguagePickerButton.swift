//
//  LSLanguagePickerButton.swift
//  talktrans
//
//  Created by 영준 이 on 2018. 4. 16..
//  Copyright © 2018년 leesam. All rights reserved.
//

import UIKit

protocol LSLanguagePickerButtonDelegate {
    func languagePicker(_ picker : LSLanguagePickerButton, didFinishPickingLanguage language: String);
}

class LSLanguagePickerButton: UIButton, LSLanguagePickerDataSource, LSLanguagePickerDelegate {
    private var hiddenTextField : UITextField!;
    private var picker : LSLanguagePicker!;
    var languages : [String] = [];
    var language : String?{
        didSet{
            let image = self.getImage(self.language?.lowercased() ?? "");
            self.setImage(image, for: .normal);
        }
    }
    
    open var delegate: LSLanguagePickerButtonDelegate?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.setupHiddenTextField();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.setupHiddenTextField();
    }
    
    private func setupHiddenTextField(){
        self.hiddenTextField = UITextField();
        self.addSubview(self.hiddenTextField);
        
        self.hiddenTextField.addTarget(self, action: #selector(self.onBeginEdit(_:)), for: .editingDidBegin);
        self.picker = LSLanguagePicker.init(self.hiddenTextField);
        self.picker.dataSource = self;
        self.picker.delegate = self;
    }
    
    @objc private func onBeginEdit(_ txt : UITextField){
        self.showPicker();
    }
    
    @IBAction func didFinishPicking(_ button : LSLanguagePickerButton){
        
    }
    
    func showPicker(){
        self.picker.showPicker(self.language ?? "");
    }
    
    private func getImage(_ lang : String) -> UIImage?{
        return UIImage(named: "langs/\(lang.lowercased()).png");
    }
    
    // MARK: LSLanguagePickerDataSource
    func languagePicker(_ picker: LSLanguagePicker, numberOfRowsInPart part: LSLanguagePicker.LanguagePart) -> Int {
        return self.languages.count;
    }
    
    func languagePicker(_ picker: LSLanguagePicker, languageForRow: Int, languageForPart: LSLanguagePicker.LanguagePart) -> String {
        return self.languages[languageForRow];
    }
    
    func languagePicker(_ picker: LSLanguagePicker, imageForRow: Int, imageForPart: LSLanguagePicker.LanguagePart) -> UIImage? {
        return self.getImage(self.languages[imageForRow]);
    }
    
    func rowForLanguage(_ picker: LSLanguagePicker, language: String) -> Int {
        return self.languages.index(of: language) ?? 0;
    }
    
    // MARK: LSLanguagePickerDelegate
    func languagePicker(_ picker: LSLanguagePicker, didFinishPickingLanguage language: String) {
        self.delegate?.languagePicker(self, didFinishPickingLanguage: language);
        //self.didFinishPicking(self);
        self.language = language;
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

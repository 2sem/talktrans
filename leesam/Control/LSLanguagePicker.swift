//
//  LSLanguagePicker.swift
//  talktrans
//
//  Created by 영준 이 on 2018. 4. 16..
//  Copyright © 2018년 leesam. All rights reserved.
//

import Foundation
import UIKit

protocol LSLanguagePickerDataSource : NSObjectProtocol{
    func languagePicker(_ picker: LSLanguagePicker, numberOfRowsInPart part: LSLanguagePicker.LanguagePart) -> Int;
    func languagePicker(_ picker : LSLanguagePicker, languageForRow: Int, languageForPart: LSLanguagePicker.LanguagePart) -> String;
    func languagePicker(_ picker : LSLanguagePicker, imageForRow: Int, imageForPart: LSLanguagePicker.LanguagePart) -> UIImage?;
    func rowForLanguage(_ picker : LSLanguagePicker, language: String) -> Int;
}

protocol LSLanguagePickerDelegate : NSObjectProtocol{
    func languagePicker(_ picker : LSLanguagePicker, didFinishPickingLanguage language: String);
}

class LSLanguagePicker : NSObject, UIPickerViewDataSource, UIPickerViewDelegate{
    private var picker = UIPickerView();
    var pickerToolbar : UIToolbar = UIToolbar();
    weak var textField : UITextField!;
    
    var dataSource : LSLanguagePickerDataSource?;
    var delegate : LSLanguagePickerDelegate?;
    
    private(set) var currentLanguage : String?;
    
    enum LanguagePart : Int{
        case Lang = 0
    }
    
    init(_ textField : UITextField) {
        super.init();
        self.textField = textField;
        
        let cancelButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.onCancelPicking(button:)));
        let doneButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(self.onDonePicking(button:)));
        let space = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        self.pickerToolbar.items = [cancelButtonItem, space, doneButtonItem];
        //self.pickerToolbar.setBackgroundImage(UIImage(named: "bg_nav"), forToolbarPosition: UIBarPosition.any, barMetrics: .default);
        //self.pickerToolbar.tintColor = UIColor.white;
        self.picker.autoresizingMask = [.flexibleWidth, .flexibleHeight];
    }
    
    func showPicker(_ lang : String){
        //self.picker.setDarkBackground();
        self.currentLanguage = lang;
        self.picker.dataSource = self;
        self.picker.delegate = self;
        self.picker.showsSelectionIndicator = true;
        
        self.textField.becomeFirstResponder();
        if self.textField.isFirstResponder{
            self.textField.inputView = self.picker;
            self.textField.inputAccessoryView = self.pickerToolbar;
            
            let row = self.dataSource?.rowForLanguage(self, language: lang) ?? 0;
            self.picker.selectRow(row, inComponent: 0, animated: false);
        }
        
        //self.picker.sizeToFit();
        self.picker.reloadComponent(0);
        self.picker.isUserInteractionEnabled = true;
        self.pickerToolbar.sizeToFit();
    }
    
    @IBAction func onCancelPicking(button : UIBarButtonItem){
        self.textField?.resignFirstResponder();
    }
    
    @IBAction func onDonePicking(button : UIBarButtonItem){
        self.textField?.resignFirstResponder();
        //var row = self.picker.selectedRow(inComponent: 0);
        self.delegate?.languagePicker(self, didFinishPickingLanguage: self.currentLanguage ?? "");
        return;
    }
    
    // MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let value = self.dataSource?.languagePicker(self, numberOfRowsInPart: .Lang) ?? 0;
        
        //print("calc picker row count[\(value)]");
        
        return value;
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let lang = self.dataSource?.languagePicker(self, languageForRow: row, languageForPart: .Lang) ?? "";
        let value = LSLanguagePickerCell.init(lang);
        value.image = self.dataSource?.languagePicker(self, imageForRow: row, imageForPart: .Lang);
        //value.textColor = UIColor.white;
        //value.highlightedTextColor = UIColor.yellow;
        //value.textAlignment = .center;
        
        print("language picker create cell. row[\(row)] lang[\(lang)]");
        
        return value;
    }
    
    /// MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cell = self.picker.view(forRow: row, forComponent: component) as? LSLanguagePickerCell;
        
        self.currentLanguage = cell?.language;
        //var row = self.picker.selectedRow(inComponent: 0);
        //var rowLabel : UILabel! = self.picker.view(forRow: row, forComponent: 0) as? UILabel;
        //button.isEnabled = false;
        
        /*if self.textField.isFirstResponder{
            self.delegate?.levelPicker(self, didPickLevel: row + 1);
            //self.levelTextField.isUserInteractionEnabled = false;
        }*/
        
        //self.firstResponder?.resignFirstResponder();
        //button.isEnabled = true;
        print("level picker did select row");
    }
    
}


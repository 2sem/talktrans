//
//  LSLanguagePickerCell.swift
//  talktrans
//
//  Created by 영준 이 on 2018. 4. 16..
//  Copyright © 2018년 leesam. All rights reserved.
//

import UIKit
import LSExtensions

class LSLanguagePickerCell: UIControl {

    private var stackView : UIStackView!;
    var imageView : UIImageView!;
    var namelabel : UILabel!;
    
    var image : UIImage?{
        didSet{
            self.imageView?.image = self.image;
        }
    }
    
    var language : String = ""{
        didSet{
            self.updateLanguage(self.language);
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        //create inner view
        self.imageView = UIImageView.init(image: UIImage());
        self.namelabel = UILabel();
        self.namelabel.textAlignment = .center;
        //self.namelabel.backgroundColor = .blue;
        self.stackView = UIStackView.init(arrangedSubviews: [self.imageView, self.namelabel]);
        self.stackView.spacing = 10;
        
        self.addSubview(self.stackView);
        self.stackView.frame = frame;
        self.stackView.backgroundColor = UIColor.blue;
        //self.stackView.distribution = .equalCentering;
        self.stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true;
        self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true;
        //self.stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor);
        self.stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 44).isActive = true;
        self.stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -44).isActive = true;
        //self.stackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6).isActive = true;
        self.stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        self.stackView.translatesAutoresizingMaskIntoConstraints = false;
        self.stackView.alignment = .center;
        self.imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true;
        //self.namelabel.widthAnchor.constraint(equalToConstant: 100);
        //self.backgroundColor = UIColor.yellow;
    }
    
    convenience init(_ lang: String) {
        self.init(frame: CGRect.zero);
        
        self.language = lang;
        self.updateLanguage(self.language);
        
        print("create language cell. lang[\(lang)] frame[\(frame)]");
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLanguage(_ lang : String){
        //self.imageView?.image = UIImage.init(named: "country/\(self.language).png");
        self.namelabel?.text = self.language.localized();
    }
}

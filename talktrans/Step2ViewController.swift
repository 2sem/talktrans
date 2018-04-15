//
//  Step2ViewController.swift
//  talktrans
//
//  Created by 영준 이 on 2018. 2. 1..
//  Copyright © 2018년 leesam. All rights reserved.
//

import UIKit

class Step2ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPop(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false);
    }
    
    @IBAction func onPopAnimate(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func onPopRoot(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false);
    }
    
    @IBAction func onPopRootAnimate(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

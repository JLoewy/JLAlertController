//
//  ViewController.swift
//  JLActionController
//
//  Created by Jason Loewy on 5/17/16.
//  Copyright © 2016 Jason Loewy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var messageTextView: UITextView!
    @IBOutlet var cancelTextField: UITextField!
    @IBOutlet var saveTextField: UITextField!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func showStandardAlert(sender: AnyObject) {
        
        
        let alertTitle   = titleTextView.text
        let alertMessage = messageTextView.text
        
        let cancelBtnTitle  = cancelTextField.text
        let regularBtnTitle = saveTextField.text

        var alertController:JLAlertViewController!
        if segmentedControl.selectedSegmentIndex == 0 {
            alertController = JLAlertViewController.alertController(alertTitle, message: alertMessage, cancelButtonText: cancelBtnTitle, regularButtonText: regularBtnTitle)
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            alertController = JLAlertViewController.inputAlertController(alertTitle, placeholder: alertMessage, cancelButtonText: cancelBtnTitle, regularButtonText: regularBtnTitle)
        }
        else if segmentedControl.selectedSegmentIndex == 2 {
            alertController = JLAlertViewController.secureInputAlertController(alertTitle, placeholder: alertMessage, cancelButtonText: cancelBtnTitle, regularButtonText: regularBtnTitle)
        }
        else {
            alertController = JLAlertViewController.decimalAlertController(alertTitle, placeholder: alertMessage, cancelButtonText: cancelBtnTitle, regularButtonText: regularBtnTitle)
        }
        
        alertController.didDismissBlock = { alertViewController, buttonTapped in
            
            print("TAPPED: \(buttonTapped.rawValue)")
            
        }
        alertController.show()
    }
}


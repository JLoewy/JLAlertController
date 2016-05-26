//
//  JLAlertViewController.Swift
//  JLAlertViewController
//
//  Created by Jason Loewy on 5/17/16.
//  Copyright © 2016 Jason Loewy. All rights reserved.
//

import UIKit
import Foundation

@objc enum JLAlertButtonType:Int {
    
    case Cancel
    case Regular
}

@objc enum JLAlertInputStyle:Int {
    case None
    case PlainText
    case SecureText
    case Decimal
    
    /// Responsible for telling the caller if the current type is of input type or not
    func isInputType()->Bool {
        return (self == .PlainText || self == .SecureText || self == .Decimal)
    }
}

class JLAlertViewController: UIViewController {
    
    
    /// Responsible for telling the caller that this alert view was dismissed by a button tap - this closure  gets called after all view dismissal has finished
    var didDismissBlock:((JLAlertViewController,JLAlertButtonType)->Void)?;
    
    var inputStyle:JLAlertInputStyle = .None
    
    private var titleText:String = ""
    private var messageText:String = ""
    private var cancelButtonText:String?
    private var regularButtonText:String?
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel?
    @IBOutlet var inputField: JLAlertTextField?
    var forcedTextFieldDelegate:UITextFieldDelegate?
    private var inputPlaceholderText:String?
    var inputPresetText:String?
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var regularButton: UIButton!
    
    // Styling Variables
    private let enabledButtonColor  = UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)
    private let disabledButtonColor = UIColor(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1.0)
    
    // MARK: - Initialization Methods
    
    /// Create a new plain style alertController
    static func alertController(title:String, message:String, cancelButtonText:String?, regularButtonText:String?)->JLAlertViewController
    {
        let alertController = JLAlertViewController(nibName: "JLAlertViewController", bundle: nil)
        alertController.configure(title, message: message, cancelButtonText: cancelButtonText, regularButtonText: regularButtonText, inputStyle: .None, placeholderText: nil)
        
        return alertController
    }
    
    /// Create a new plain text input style alertController
    static func inputAlertController(title:String, placeholder:String?, cancelButtonText:String?, regularButtonText:String?)->JLAlertViewController
    {
        let alertController = JLAlertViewController(nibName: "JLInputAlertViewController", bundle: nil)
        alertController.configure(title, message: "", cancelButtonText: cancelButtonText, regularButtonText: regularButtonText, inputStyle: .PlainText, placeholderText: placeholder)
        
        return alertController
    }
    
    /// Create a new plain text input style alertController with decimal keyboard input
    static func decimalAlertController(title:String, placeholder:String?, cancelButtonText:String?, regularButtonText:String?)->JLAlertViewController
    {
        let alertController = JLAlertViewController(nibName: "JLInputAlertViewController", bundle: nil)
        alertController.configure(title, message: "", cancelButtonText: cancelButtonText, regularButtonText: regularButtonText, inputStyle: .Decimal, placeholderText: placeholder)
        
        return alertController
    }
    
    /// Create a new secure text input style alertControler
    static func secureInputAlertController(title:String, placeholder:String?, cancelButtonText:String?, regularButtonText:String?)->JLAlertViewController
    {
        let alertController = JLAlertViewController(nibName: "JLInputAlertViewController", bundle: nil)
        alertController.configure(title, message: "", cancelButtonText: cancelButtonText, regularButtonText: regularButtonText, inputStyle: .SecureText, placeholderText: placeholder)
        
        return alertController
    }
    
    private func configure(title:String, message:String, cancelButtonText:String?, regularButtonText:String?, inputStyle:JLAlertInputStyle, placeholderText:String?)
    {
        self.titleText            = title
        self.messageText          = message
        self.cancelButtonText     = cancelButtonText
        self.regularButtonText    = regularButtonText
        self.inputStyle           = inputStyle
        self.inputPlaceholderText = placeholderText
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display the background properly based off of if visual effect is avaialble or not
        if #available(iOS 8.0, *) {
            
            let visualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
            visualEffectView.alpha = 0.625
            visualEffectView.frame = self.view.bounds
            visualEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(JLAlertViewController.backgroundViewTapped(_:))))
            self.view.insertSubview(visualEffectView, atIndex: 0)
        } else {
            // Fallback on earlier versions
            view.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        }
        
        
        alertView.layer.cornerRadius  = 2.0
        alertView.layer.shadowOffset  = CGSize(width: 0.0, height: 0.0)
        alertView.layer.shadowColor   = UIColor(white: 0.0, alpha: 1.0).CGColor
        alertView.layer.shadowOpacity = 0.3
        alertView.layer.shadowRadius  = 3.0
        
        titleLabel.text   = titleText
        
        
        // Style the layout based off of the input style
        if inputStyle == .None {
            messageLabel?.text   = messageText
            messageLabel?.hidden = false
            inputField?.hidden   = true
            
        }
        else if let inputTextField = inputField {
            
            messageLabel?.hidden  = true
            inputTextField.hidden = false
            
            if let forcedDelegate = forcedTextFieldDelegate {
                inputTextField.delegate = forcedDelegate
            }
            
            inputTextField.addTarget(self, action: #selector(JLAlertViewController.textFieldStringDidChange(_:)), forControlEvents: .EditingChanged)
            inputTextField.placeholder     = inputPlaceholderText
            inputTextField.frame           = CGRect(x: inputTextField.frame.origin.x, y: inputTextField.frame.origin.y, width: inputTextField.frame.size.width, height: 40)
            inputTextField.secureTextEntry = (inputStyle == .SecureText)
            
            if let presetText = inputPresetText {
                inputTextField.text = presetText
            }
            
            if inputStyle == .Decimal {
                inputTextField.keyboardType = UIKeyboardType.DecimalPad
            }
        }
        
        // Handle the cancel button setup
        if let cancelText = cancelButtonText {
            cancelButton.setTitle(cancelText, forState: .Normal)
        }
        else {
            cancelButton.hidden  = true
        }
        
        // Handle the regular button setup
        if let regularText = regularButtonText {
            
            regularButton.setTitle(regularText, forState: .Normal)
            if inputStyle.isInputType() {
                regularButton.setTitleColor(disabledButtonColor, forState: .Normal)
                regularButton.enabled = false
            }
            else {
                regularButton.setTitleColor(enabledButtonColor, forState: .Normal)
            }
        }
        else {
            regularButton.hidden  = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if inputStyle.isInputType() {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JLAlertViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JLAlertViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
            
            if let inputTextField = inputField {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.35 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    inputTextField.becomeFirstResponder()
                    if inputTextField.text?.characters.count > 0 {
                        self.regularButton.setTitleColor(self.enabledButtonColor, forState: .Normal)
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if inputStyle.isInputType() {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    /// Repsonsible for reacting to the user tapping the visualeffect background
    func backgroundViewTapped(sender:AnyObject)
    {
        view.endEditing(true)
    }
    
    // MARK: - Hide/Display Methods
    
    /// Responsible for displaying the alert controller over the topmost active view controller
    func show()
    {
        if let appDelegate = UIApplication.sharedApplication().delegate, let window = appDelegate.window, let rootViewController = window?.rootViewController {
            
            var topViewController = rootViewController
            while topViewController.presentedViewController != nil {
                topViewController = topViewController.presentedViewController!
            }
            
            // Add the alert view controller to the top most UIViewController of the application
            topViewController.addChildViewController(self)
            topViewController.view.addSubview(view)
            viewWillAppear(true)
            didMoveToParentViewController(topViewController)
            view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            view.alpha = 0.0
            view.frame = topViewController.view.bounds
            
            alertView.alpha     = 0.0
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                self.view.alpha = 1.0
                }, completion: nil)
            
            alertView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            alertView.center    = CGPoint(x: (self.view.bounds.size.width/2.0), y: (self.view.bounds.size.height/2.0)-10)
            UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveEaseOut, animations: { () -> Void in
                self.alertView.alpha = 1.0
                self.alertView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.alertView.center    = CGPoint(x: (self.view.bounds.size.width/2.0), y: (self.view.bounds.size.height/2.0))
                }, completion: nil)
        }
    }
    
    /**
     Responsible for hiding the currently displayed JLAlertViewControlller
     
     - parameter buttonTapped: [optional] The JLAlertButtonType that was just tapped to start dismissing this alert controller
     */
    func hide(buttonTapped:JLAlertButtonType?)
    {
        self.view.endEditing(true)
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseIn, animations: { () -> Void in
            self.alertView.alpha = 0.0
            self.alertView.transform = CGAffineTransformMakeScale(1.01, 1.01)
            self.alertView.center    = CGPoint(x: (self.view.bounds.size.width/2.0), y: (self.view.bounds.size.height/2.0)-5)
            }, completion: nil)
        
        UIView.animateWithDuration(0.3, delay: 0.05, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.alpha = 0.0
            
        }) { (completed) -> Void in
            
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            if let buttonType = buttonTapped, let dismissBlock = self.didDismissBlock {
                dismissBlock(self, buttonType)
            }
        }
    }
    
    // MARK: - Keyboard Relocation Methods
    
    /**
     Repsonsible for updating and animating the new constraint update
     
     - parameter constraintIdentifier: The string identifier of the constraint that you are working on
     - parameter value:                The value that it should be set to
     */
    private func updateConstraint(constraintIdentifier:String, value:CGFloat, constraintView:UIView) {
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            for (_, constraint) in constraintView.constraints.enumerate()
            {
                if constraint.identifier == constraintIdentifier
                {
                    constraint.constant = CGFloat(value)
                    break;
                }
            }
            self.view.layoutIfNeeded()
            }, completion:  nil)
    }
    
    /// Responsible for reacting to the keyboard being displayed
    func keyboardWillShow(notification:NSNotification)
    {
        let keyboardHeight = CGRectGetHeight((notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue());
        self.updateConstraint("alertview-center-y", value: -(keyboardHeight/2.0), constraintView: self.view)
    }
    
    /// Responsible for reacting ot the keyboard being hidden
    func keyboardWillHide(notification:NSNotification)
    {
        self.updateConstraint("alertview-center-y", value: 0, constraintView: self.view)
    }
    
    // MARK: - UITextField Methods
    
    /// Responsible for reacting to the fact that the textfields input changed
    func textFieldStringDidChange(sender:AnyObject)
    {
        if let inputTextField = inputField, let inputText = inputTextField.text {
            
            if inputText.characters.count > 0 {
                regularButton.setTitleColor(enabledButtonColor, forState: .Normal)
                regularButton.enabled = true
            }
            else {
                regularButton.setTitleColor(disabledButtonColor, forState: .Normal)
                regularButton.enabled = false
            }
        }
    }
    
    func getInputText()->String? {
        return inputField?.text
    }
    
    // MARK: - Button Interaction Methods
    
    @IBAction func cancelButtonTapped(sender: AnyObject) { hide(.Cancel) }
    
    @IBAction func regularButtonTapped(sender: AnyObject) { hide(.Regular) }
}

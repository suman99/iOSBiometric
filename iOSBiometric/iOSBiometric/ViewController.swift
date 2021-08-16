//
//  ViewController.swift
//  iOSBiometric
//
//  Created by Suman on 16/08/2021.
//

import UIKit

class ViewController: UIViewController {
   // Let’s bring the wrapper into use.
    let biometricAuth = BiometricAuthenticaiton()
    
    @IBOutlet weak var launchBiometricsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        launchBiometricsButton.setImage(UIImage(systemName: "faceid"), for: .normal)
    }

    @IBAction func verifyBiometrics(_ sender: Any) {
        
        biometricAuth.canEvalute {(canEvaluate,_,canEvaluateError) in
            guard canEvaluate else {
                // Face ID/Touch ID may not be available or configured
                self.alert(title: "Error", message: canEvaluateError?.localizedDescription ?? "Face ID/Touch ID may not be configure", okActionTitle: "Ssh!")
                return
            }
            biometricAuth.evaluate { [weak self] (success,error) in
                
                guard success else {
                    // Face ID/Touch ID may not be available or configured
                    self?.alert(title: "Error",
                                message: error?.localizedDescription ?? "Face ID/Touch ID may not be configured",
                                okActionTitle: "SSh!")
                    return
                }
                
                // You are successfully verified
                self?.alert(title: "Success",
                            message: "You have a free pass, now",
                            okActionTitle: "Yay!")
            }
        }
    }
    
    func alert(title: String, message: String, okActionTitle: String) {
        let alertView = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: okActionTitle, style: .default)
        alertView.addAction(okAction)
        present(alertView, animated: true)
    }
}


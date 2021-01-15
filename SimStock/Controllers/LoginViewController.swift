//
//  LoginViewController.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 1/14/21.
//

import Foundation
import UIKit
import GoogleSignIn
import Firebase
class LoginViewController: UIViewController{
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func loadView(){
        super.loadView()
        let googleSignInButton = GIDSignInButton()
        self.view.backgroundColor = .black
        self.view.addSubview(googleSignInButton)
        googleSignInButton.center = self.view.center
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
}


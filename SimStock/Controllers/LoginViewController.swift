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
class LoginViewController: UIViewController, GIDSignInDelegate{
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let db = Firestore.firestore()
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
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        let db = Firestore.firestore()
         if let error = error {
            print("banana potato apple")
            print(error.localizedDescription)
            print("banana potato apple")
         }
         print("successful sign in")
         guard let authentication = user.authentication else { return }
         let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
         let idToken = user.authentication.idToken // Safe to send to the server
           Auth.auth().signIn(with: credential) { (User, Error) in    //authenticates user's sign in info
               if let userInfo = User {
                //sets global vars defined in app delegate, then performs segue to homepage
                self.appDelegate.email = user.profile.email
                self.appDelegate.userId = user.userID
                self.appDelegate.fullName = user.profile.familyName
                self.appDelegate.lastName = user.profile.givenName
                self.createUser(email: self.appDelegate.email)
                let homeViewController = HomeViewController()
                
                self.navigationController?.pushViewController(homeViewController, animated: true)
               }
               else{
                   print("User could not be authenticated")
               }//else
           }
    }
    
    func createUser(email: String){
        db.collection("Users").whereField("email", isEqualTo: self.appDelegate.email)
        .getDocuments() { (querySnapshot, err) in
           if let err = err {
               print("Error getting documents: \(err)")
           } else {
               if (querySnapshot!.documents == []){
                self.db.collection("Users").document(email).setData([
                    "id": self.appDelegate.userId,
                    "firstName": self.appDelegate.lastName,
                    "lastName": self.appDelegate.fullName,
                    "email": self.appDelegate.email,
                    "stocks": []
                ])//setData
               }//if
           }//else
         }//getDocuments
        appDelegate.email = email
      //  appDelegate.
    }//createUser function
}

////Google sign in and user creation extension
//extension LoginViewController: GIDSignInDelegate{
//
//
//}


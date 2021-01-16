//
//  AppDelegate.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 12/19/20.
//

import UIKit
import Firebase
import GoogleSignIn
@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    // For client-side use only, global vals to hold google uer info
    var userId = ""
    var fullName = ""
    var lastName = ""
    var email = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
    
        // Override point for customization after application launch.
        FirebaseApp.configure()
        let db = Firestore.firestore()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        
    }

    //GIDSignin delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        guard let authentication = user.authentication else{return}
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        userId = user.userID
        fullName = user.profile.name
        lastName = user.profile.givenName
        email = user.profile.email
        Auth.auth().signIn(with: credential) { (User, Error) in    //authenticates user's sign in info
            if let userInfo = User {
                print("Authentication successful")
            }
            else{
                print("Authentication not successful")
            }
        }
        
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    //url handler function for google sign in
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    

}


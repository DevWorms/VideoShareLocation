//
//  LoginViewController.swift
//  WeShick
//
//  Created by Bani Azarael Mejia Flores on 31/10/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

var globalkey = "globalkey"
var globalid = "globalid"
var key = ""
var id : Int = 0

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let guardarDatos = UserDefaults.standard
    var datos = [[String : Any]]()
    var dict : [String : AnyObject]!
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    var loadingLogin = UIAlertController()
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["public_profile", "email", "user_friends"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.center = view.center
        view.addSubview(loginButton)
        self.loginButton.delegate = self
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (result.token != nil) {
            print("¡Login completado!")
            if let accessToken = FBSDKAccessToken.current() {
                print("Token de usuario ", accessToken)
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, gender, picture.type(large)"]).start(completionHandler: { (connection, result, error) -> Void in
                    guard (result as? [String: Any]) != nil else { return }
                    if (error == nil){
                        self.dict = result as! [String : AnyObject]
                        self.setInterfaz(result: self.dict as NSDictionary)
                    }
                })
            }
        }
        if (result.isCancelled){
            print("¡Cancelo Login!")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){
        print("Usuario Logout")
        let guardarDatos = UserDefaults.standard
        guardarDatos.setValue("No", forKey: "loginEnd")
    }
    
    func setInterfaz(result: NSDictionary){
        let idFace = result.value(forKey: "id") as! String
        let nombre = result.value(forKey: "first_name") as! String
        let apellido = result.value(forKey: "last_name") as! String
        let correo = result.value(forKey: "email") as! String
        let genero = result.value(forKey: "gender") as! String
        let imageURL = ("https://graph.facebook.com/\(idFace)/picture?type=large")
        let name = "\(nombre) \(apellido)"
        
        guardarDatos.setValue("Si", forKey: "loginEnd")
        guardarDatos.set(idFace, forKey: "idFace")
        guardarDatos.set(name, forKey: "nombre")
        guardarDatos.set(correo, forKey: "correo")
        guardarDatos.set(genero, forKey: "genero")
        guardarDatos.setValue(imageURL, forKey: "picture")
        
        print("ID Facebook: \(idFace)")
        print("Nombre: \(name)")
        print("Correo electronico: \(correo)")
        print("Genero: \(genero)")
        print("URL Foto: \(imageURL)")
        
        loadingLogin = UIAlertController(title: nil, message: "Por favor espere...\n\n", preferredStyle: .alert)
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        loadingLogin.view.addSubview(spinnerIndicator)
        self.present(loadingLogin, animated: false, completion: nil)
        login(token:idFace, name:name, imageURL: imageURL)
        print("Quitamos loading")
    }
    
    func dataAlreadyExist(userKey: String) -> Bool {
        return UserDefaults.standard.object(forKey: userKey) != nil
    }
    
    func login(token:String, name:String, imageURL: String) {
        let parameterString = "tokenfb=\(token)&name=\(name)&url_img=\(imageURL)"
        let strUrl = "https://weshick.com/api/login"
        if let httpBody = parameterString.data(using: String.Encoding.utf8) {
            var urlRequest = URLRequest(url: URL(string: strUrl)!)
            urlRequest.httpMethod = "POST"
            URLSession.shared.uploadTask(with: urlRequest, from: httpBody, completionHandler: parseJsonLogin).resume()
        } else {
            print("Error de codificación de caracteres.")
        }
    }
    
    func parseJsonLogin(data: Data?, urlResponse: URLResponse?, error: Error?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                //print(json)
                if let jsonResult = json as? [String: Any] {
                    DispatchQueue.main.async {
                        if let result = jsonResult["user"] as? [String: Any]{
                            key = result["apikey"] as! String
                            let idd = result["id"]
                            if idd != nil{
                                let r = idd as! Int
                                id = r
                            }
                            UserDefaults.standard.set(key, forKey: globalkey)
                            UserDefaults.standard.set(id, forKey: "globalid")
                            
                            print("API Key: \(key)")
                            print("ID Usuario: \(id)")
                            
                            let mMapaViewController = self.storyBoard.instantiateViewController(withIdentifier: "MapaViewController")
                            
                            self.loadingLogin.dismiss(animated: true, completion: nil)
                            
                            self.present(mMapaViewController, animated: false, completion: nil)
                        }
                    }
                }
            } else {
                print("HTTP Status Code: 200")
                print("El JSON de respuesta es inválido.")
            }
        }
    }
}

//
//  ViewController.swift
//  Video Share Location
//
//  Created by Bani Azarael Mejia Flores on 22/06/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var dict : [String : AnyObject]!
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
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
        
        let obtenerDatos = UserDefaults.standard
        let idFace : String = obtenerDatos.object(forKey: "idFace") as! String
        if (idFace != nil){
            let siguienteViewController = storyBoard.instantiateViewController(withIdentifier: "RegistroUsuarioViewController")
            self.present(siguienteViewController, animated: true, completion: nil)
        }
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (result.token != nil) {
            print("¡Login completado!")
            if let accessToken = FBSDKAccessToken.current() {
                print("Token de usuario ", accessToken)
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, gender"]).start(completionHandler: { (connection, result, error) -> Void in
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
    }
    
    func setInterfaz(result: NSDictionary){
        let idFace = result.value(forKey: "id") as! String
        let nombre = result.value(forKey: "first_name") as! String
        let apellido = result.value(forKey: "last_name") as! String
        let correo = result.value(forKey: "email") as! String
        let genero = result.value(forKey: "gender") as! String
        
        print("Id Facebook: ", idFace)
        print("Nombre: ", nombre)
        print("Apellido: ", apellido)
        print("Correo: ", correo)
        print("Genero: ", genero)
    
        let guardarDatos = UserDefaults.standard
        guardarDatos.set(idFace, forKey: "idFace")
        guardarDatos.set(nombre, forKey: "nombre")
        guardarDatos.set(apellido, forKey: "apellido")
        guardarDatos.set(correo, forKey: "correo")
        guardarDatos.set(genero, forKey: "genero")
        print("¡Datos guardados!")

        
        let siguienteViewController = storyBoard.instantiateViewController(withIdentifier: "RegistroUsuarioViewController")
        self.present(siguienteViewController, animated: true, completion: nil)
    }
}


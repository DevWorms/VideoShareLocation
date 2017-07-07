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
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["public_profile", "email", "user_friends"]
        return button
    }()
    
    @IBOutlet weak var lbl_idFb: UILabel!
    @IBOutlet weak var lbl_nombre: UILabel!
    @IBOutlet weak var lbl_apellido: UILabel!
    @IBOutlet weak var lbl_correo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.center = view.center
        view.addSubview(loginButton)
        self.loginButton.delegate = self
        
        if let accessToken = FBSDKAccessToken.current() {
            print("Token de usuario ", accessToken)
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    self.setInterfaz(result: self.dict as NSDictionary)
                }
            })
        }
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (result.token != nil) {
            print("¡Login completado!")
            self.setInterfaz(result: self.dict as NSDictionary)
        }
        if (result.isCancelled){
            print("¡Cancelo Login!")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){
        print("Usuario Logout")
        lbl_idFb.text=""
        lbl_nombre.text = ""
        lbl_apellido.text = ""
        lbl_correo.text = ""
    }
    
    func setInterfaz(result: NSDictionary){
        let idFace = result.value(forKey: "id") as! String
        let nombre = result.value(forKey: "name") as! String
        let apellido = result.value(forKey: "last_name") as! String
        let correo = result.value(forKey: "email") as! String
        
        lbl_idFb.text = idFace
        lbl_nombre.text = nombre
        lbl_apellido.text = apellido
        lbl_correo.text = correo
        print("Id Facebook: ", idFace)
        print("Nombre: ", nombre)
        print("Apellido: ", apellido)
        print("Correo: ", correo)

        let guardarDatos = UserDefaults.standard
        guardarDatos.set(idFace, forKey: "idFace")
        guardarDatos.set(nombre, forKey: "nombre")
        guardarDatos.set(apellido, forKey: "apellido")
        guardarDatos.set(correo, forKey: "correo")
        print("¡Datos guardados!")
        
        let facebookProfileUrl: String = "https://graph.facebook.com/\(idFace)/picture?type=large"
        print(facebookProfileUrl)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let siguienteViewController = storyBoard.instantiateViewController(withIdentifier: "RegistroUsuarioViewController")
        self.present(siguienteViewController, animated: true, completion: nil)
        
        //let facebookProfileUrl = NSURL(string: "https://graph.facebook.com/\(idFace)/picture?type=large")
        /*if let data = NSData(contentsOf: facebookProfileUrl! as URL) {
            fotoView.image = UIImage(data: data as Data)
        }
        */
    }
}


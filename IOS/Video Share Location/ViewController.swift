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

class ViewController: UIViewController {
    
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
        view.addSubview(loginButton)
        loginButton.center = view.center
        if let accessToken = FBSDKAccessToken.current() {
            print("Token de usuario ", accessToken)// User is logged in, use 'accessToken' here.
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in //recibimos respuesta de facebook con los datos del usuario
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    self.setInterfaz(result: self.dict as NSDictionary)
                }
                //aqui se maneja el error
            })
        }
        

        
        //self.loginButton.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result:
        FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("¡Login completado!")
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
    }
    
    func setInterfaz(result: NSDictionary){
        let idFace = result.value(forKey: "id") as! String
        let nombre = result.value(forKey: "name") as! String
        let apellido = result.value(forKey: "last_name") as! String
        let correo = result.value(forKey: "email") as! String
        //let genero = result.value(forKey: "gender") as! String
        //let edad = result.value(forKey: "age_range") as! String
        
        lbl_idFb.text = idFace
        lbl_nombre.text = nombre
        lbl_apellido.text = apellido
        lbl_correo.text = correo
        print("Id Facebook: ", idFace)
        print("Nombre: ", nombre)
        print("Apellido: ", apellido)
        print("Correo: ", correo)
        //print("Genero: ", genero)
        //print("Edad: ", edad)
        
        //almacenadas en el dispositivo permanentemente, bueno hasta que la app se desisntale o hasta que las borremos (cerrar sesion)
        
        //enviar estos datos a nuestro sitio web (bases de datos) -> procesar la informacion de facebook de nuestro usuario.

        /*
        let defaultvar = UserDefaults.standard
        defaultvar.set(idFace, forKey: "idFace")//almacenar valores persistentes
        defaultvar.set(name, forKey: "name")
        defaultvar.set(last_name, forKey: "last_name")
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)//instanciamos nuestro story
        
        let siguienteViewController = storyBoard.instantiateViewController(withIdentifier: "mainController")
        
        self.present(siguienteViewController, animated: true, completion: nil)//mostrar nuestro viewcontroller
        
        
        //nombreLabel.text = name
        //apellidoLabel.text = last_name
        
        //extraer la imagen de perfil
        
        let facebookProfileUrl = NSURL(string: "https://graph.facebook.com/\(idFace)/picture?type=large")
        
        if let data = NSData(contentsOf: facebookProfileUrl! as URL) {
            fotoView.image = UIImage(data: data as Data)
        }
        */
    }
    
    /*func loginButtonWillLogin(loginButton: FBSDKLoginButton!) –> Bool {
     return true
     }*/
}


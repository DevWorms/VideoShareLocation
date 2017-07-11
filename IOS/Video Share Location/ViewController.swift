//
//  ViewController.swift
//  Video Share Location
//
//  Created by Bani Azarael Mejia Flores on 22/06/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func iniciar(_ sender: Any) {

    }
    
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (dataAlreadyExist(dataKey: "dataUserUpdate")){
            mandarMapa()
        } else {
            if (dataAlreadyExist(dataKey: "loginEnd")){
                mandarRegistroUsuario()
            } else {
                mandarLogin()
            }
        }
    }
    
    func mandarLogin() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
        print("El Login no ha sido terminado")
    }
    
    func mandarRegistroUsuario() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegistroUsuarioViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
        print("El Registro de usuario no ha sido terminado")
    }
    
    func mandarMapa(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MapaViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
        print("Todo listo, iniciando..")
    }
    
    func dataAlreadyExist(dataKey: String) -> Bool {
        return UserDefaults.standard.object(forKey: dataKey) != nil
    }
}


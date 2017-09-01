//
//  MenuViewController.swift
//  WeShick
//
//  Created by Bani Azarael Mejia Flores on 31/08/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class MenuViewController: UIViewController {
    
    @IBAction func mandarTerminosyCondiciones(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TerminosyCondiciones")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        let alerta = UIAlertController(title: "¿Estas seguro hacer?", message: "Volveras a la pantalla de inicio", preferredStyle: UIAlertControllerStyle.alert)
        alerta.addAction(UIAlertAction(title: "Si", style: UIAlertActionStyle.default, handler: { alertAction in
            FBSDKAccessToken.current()
            FBSDKLoginManager().logOut()
            UserDefaults.standard.setValue("No", forKey: "loginEnd")
            alerta.dismiss(animated: true, completion: nil)
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
            print("Ahora el Login no ha sido terminado")

        }))
        alerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: { alertAction in
            
            alerta.dismiss(animated: true, completion: nil)
        }))
        self.present(alerta, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let regresarButton:UIBarButtonItem = UIBarButtonItem(title: "Regresar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MenuViewController.regresarButton(sender:)))
        self.navigationItem.setLeftBarButton(regresarButton, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func regresarButton(sender:UIButton) {
        navigationController?.popViewController(animated: true)
        print("Regresar")
    }
}

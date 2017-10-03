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

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoprogresog.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as!VideosTableViewCell
        cell.labelTitulo.text = videoprogresog[indexPath.row].path
        cell.labelEstado.text = videoprogresog[indexPath.row].estado
        cell.buttonBorrar.tag = indexPath.row
        cell .buttonBorrar.addTarget(self, action: #selector(getter: VideosTableViewCell.buttonBorrar), for: .touchUpInside)
        if (cell.labelEstado.text == "Subido con exito"){
            cell.labelEstado.textColor = UIColor.green
            cell.buttonBorrar.isHidden = false
        }
        if(cell.labelEstado.text == "Error al subir video"){
            cell.labelEstado.textColor = UIColor.red
            cell.buttonBorrar.isHidden = false
        }
        return cell
    }
    
    
    @IBAction func buttonBorrar(sender: UIButton){
        videoprogresog.remove(at: sender.tag)
    }
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

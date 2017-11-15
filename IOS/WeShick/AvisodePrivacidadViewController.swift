//
//  AvisodePrivacidadViewController.swift
//  WeShick
//
//  Created by Bani Azarael Mejia Flores on 14/11/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit
import WebKit

class AvisodePrivacidadViewController: UIViewController {

    @IBOutlet weak var cargarWebAvisodePrivacidad: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://www.devworms.com")!
        cargarWebAvisodePrivacidad.load(URLRequest(url: url))
        cargarWebAvisodePrivacidad.allowsBackForwardNavigationGestures = true
        
        let regresarButton:UIBarButtonItem = UIBarButtonItem(title: "Regresar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AvisodePrivacidadViewController.regresarButton(sender:)))
        self.navigationItem.setLeftBarButton(regresarButton, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func regresarButton(sender:UIButton) {
        navigationController?.popViewController(animated: true)
        print("Hecho")
    }
}

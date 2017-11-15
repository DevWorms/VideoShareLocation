//
//  TerminosyCondicionesViewController.swift
//  WeShick
//
//  Created by Bani Azarael Mejia Flores on 31/10/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit
import WebKit

class TerminosyCondicionesViewController: UIViewController {
    
    @IBOutlet weak var cargarWebTerminosyCondiciones: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://www.weshick.com")!
        cargarWebTerminosyCondiciones.load(URLRequest(url: url))
        cargarWebTerminosyCondiciones.allowsBackForwardNavigationGestures = true
        
        let regresarButton:UIBarButtonItem = UIBarButtonItem(title: "Regresar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TerminosyCondicionesViewController.regresarButton(sender:)))
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


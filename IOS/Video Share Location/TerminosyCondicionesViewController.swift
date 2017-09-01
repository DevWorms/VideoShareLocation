//
//  TerminosyCondicionesViewController.swift
//  WeShick
//
//  Created by Bani Azarael Mejia Flores on 31/08/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit

class TerminosyCondicionesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let regresarButton:UIBarButtonItem = UIBarButtonItem(title: "Regresar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TerminosyCondicionesViewController.regresarButton(sender:)))
        self.navigationItem.setLeftBarButton(regresarButton, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func regresarButton(sender:UIButton) {
        navigationController?.popViewController(animated: true)
        print("Hecho")
    }
}

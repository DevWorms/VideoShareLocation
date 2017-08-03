//
//  SelectUserViewController.swift
//  Video Share Location
//
//  Created by Bani Azarael Mejia Flores on 03/08/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit

class SelectUserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBAction func cerrarUsuario(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var collectionViewUser: UICollectionView!
    var images = ["one","two","three","four","five"]
    var usernames = ["Usuario 1","Usuario 2","Usuario 3","Usuario 4","Usuario 5"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewUser.delegate = self
        self.collectionViewUser.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionViewUser.dequeueReusableCell(withReuseIdentifier: "collectionUserData", for: indexPath) as! UserDataCollectionViewCell
        cell.imageViewUser.image = UIImage(named: images[indexPath.row])
        cell.labelUser.text = usernames[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Seleccionaste usuario ", indexPath.row+1)
    }
}

//
//  SelectUserViewController.swift
//  Video Share Location
//
//  Created by Bani Azarael Mejia Flores on 03/08/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit
import CoreLocation

class SelectUserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBAction func cerrarUsuario(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var collectionViewUser: UICollectionView!
    //var images = ["one","two","three","four","five"]
    var usernames = [String]()
    let diccionario = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //detectRoute.isHidden = false
        self.collectionViewUser.delegate = self
        self.collectionViewUser.dataSource = self
        
        let LatSelected : Double = diccionario.double(forKey: "LatSelected")
        let LongSelected : Double = diccionario.double(forKey: "LongSelected")
        //print(usuariosg.count)
        //print(usuariosg[8].videoinfo.count)
        for i in 0..<usuariosg.count{
            print(usuariosg[i].nombre)
            for h in 0..<usuariosg[i].videoinfo.count {
                let LatCurrent : Double = Double(usuariosg[i].videoinfo[h]["lat"] as! String)!
                let LongCurrent : Double = Double(usuariosg[i].videoinfo[h]["long"] as! String)!
                //print("Lat: \(LatCurrent) Long: \(LongCurrent)")
                
                let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
                let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
                let distancia = Punto1.distance(from: Punto2)
                
                //print("Distancia = \(distancia)")
                if(distancia<=UserDefaults.standard.double(forKey: "Distance")){
                    if (!usernames.contains(usuariosg[i].nombre)) {
                        usernames.append(usuariosg[i].nombre)
                        print("Add: \(usuariosg[i].nombre)")
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usernames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionViewUser.dequeueReusableCell(withReuseIdentifier: "collectionUserData", for: indexPath) as! UserDataCollectionViewCell
        cell.imageViewUser.image = UIImage(named: "video_icon")
        cell.labelUser.text = usernames[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Seleccionaste usuario ", indexPath.row)
        diccionario.setValue(usernames,forKey: "ArrayUserSelected")
        diccionario.set(indexPath.row,forKey: "NumUserSelected")
        showModalVideos()
    }
    
    func showModalVideos() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "VideoVC")
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
}

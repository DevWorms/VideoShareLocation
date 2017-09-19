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
    var usernames = [String]()
    var idUsers = [Int]()
    var urlPhotos = [String]()
    let diccionario = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewUser.delegate = self
        self.collectionViewUser.dataSource = self
        
        usernames = [String]()
        idUsers = [Int]()
        urlPhotos = [String]()
        let LatSelected : Double = UserDefaults.standard.double(forKey: "LatSelected")
        let LongSelected : Double = UserDefaults.standard.double(forKey: "LongSelected")
        for i in 0..<usuariosg.count{
            for h in 0..<usuariosg[i].videoinfo.count {
                let LatCurrent : Double = Double(usuariosg[i].videoinfo[h]["lat"] as! String)!
                let ant1 : String = usuariosg[i].videoinfo[h]["long"] as! String
                let ant2 : String = ant1.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
                let LongCurrent : Double = Double(ant2)!
                let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
                let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
                let distancia = Punto1.distance(from: Punto2)
                if(distancia<=UserDefaults.standard.double(forKey: "Distance")){
                    if (!idUsers.contains(Int(usuariosg[i].idusuario)!)) {
                        usernames.append(usuariosg[i].nombre)
                        idUsers.append(Int(usuariosg[i].idusuario)!)
                        let aString = usuariosg[i].url_img
                        let bString = aString.replacingOccurrences(of: "http://", with: "https://", options: .literal, range: nil)
                        urlPhotos.append(bString)
                        print("En el modal Usuario -> Usuario: \(Int(usuariosg[i].idusuario)!), Nombre: \(usuariosg[i].nombre)")
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
        DispatchQueue.main.async {
            let facebookProfileUrl = NSURL(string: self.urlPhotos[indexPath.row])
            if let data = NSData(contentsOf: facebookProfileUrl! as URL) {
                cell.imageViewUser.image = UIImage(data: data as Data)
            } else {
                cell.imageViewUser.image = UIImage(named: "icon_user")
            }
        }
        cell.labelUser.text = usernames[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        diccionario.setValue(idUsers,forKey: "ArrayUserSelected")
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

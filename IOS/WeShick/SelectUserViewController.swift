//
//  SelectUserViewController.swift
//  WeShick
//
//  Created by Bani Azarael Mejia Flores on 31/10/17.
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewUser.delegate = self
        self.collectionViewUser.dataSource = self
        
        usernames = [String]()
        idUsers = [Int]()
        urlPhotos = [String]()
        
        let LatSelected : Double = UserDefaults.standard.double(forKey: "LatSelected")
        let LongSelected : Double = UserDefaults.standard.double(forKey: "LongSelected")
        for i in 0..<LatUser.count{
            let LatCurrent : Double = Double(LatUser[i])!
            let LongCurrent : Double = Double(LongUser[i])!
            let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
            let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
            let distancia = Punto1.distance(from: Punto2)
            if(distancia<=UserDefaults.standard.double(forKey: "Distance")){
                if (!idUsers.contains(IdUser[i])) {
                    usernames.append(NombreUser[i])
                    idUsers.append(IdUser[i])
                    let aString = URLImgUser[i]
                    let bString = aString.replacingOccurrences(of: "http://", with: "https://", options: .literal, range: nil)
                    urlPhotos.append(bString)
                    print("En el modal Usuario -> Usuario: \(IdUser[i]), Nombre: \(NombreUser[i])")
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
            let ProfileUrl = NSURL(string: self.urlPhotos[indexPath.row])
            if let data = NSData(contentsOf: ProfileUrl! as URL) {
                cell.imageViewUser.image = UIImage(data: data as Data)
            } else {
                cell.imageViewUser.image = UIImage(named: "icon_user")
            }
        }
        cell.labelUser.text = usernames[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DataUserDefault.setValue(idUsers,forKey: "ArrayUserSelected")
        DataUserDefault.set(indexPath.row,forKey: "NumUserSelected")
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

//
//  SelectVideoViewController.swift
//  Video Share Location
//
//  Created by Bani Azarael Mejia Flores on 03/08/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit
import CoreLocation

class SelectVideoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionViewVideo: UICollectionView!
    //var images = ["six","seven","eight","nine","ten"]
    var video = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewVideo.delegate = self
        self.collectionViewVideo.dataSource = self
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        let diccionario = UserDefaults.standard
        
        let ArrayUserSelected = diccionario.stringArray(forKey: "ArrayUserSelected") ?? [String]()
        let NumUserSelected : Int = diccionario.integer(forKey: "NumUserSelected")
        let UserSelected : String = ArrayUserSelected[NumUserSelected]
        let LatSelected : Double = diccionario.double(forKey: "LatSelected")
        let LongSelected : Double = diccionario.double(forKey: "LongSelected")
        var IdUserSelected = -1
        for i in 0..<usuariosg.count{
            if (usuariosg[i].nombre.contains(UserSelected)) {
                IdUserSelected = i
                print(i)
            }
        }
        for h in 0..<usuariosg[IdUserSelected].videoinfo.count {
            let LatCurrent : Double = Double(usuariosg[IdUserSelected].videoinfo[h]["lat"] as! String)!
            let LongCurrent : Double = Double(usuariosg[IdUserSelected].videoinfo[h]["long"] as! String)!
            print("Lat: \(LatCurrent) Long: \(LongCurrent)")
            
            let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
            let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
            let distancia = Punto1.distance(from: Punto2)
            
            print("Distancia = \(distancia)")
            if(distancia<=1000000){
                print("Video: \(usuariosg[IdUserSelected].nombre)")
                video.append("Video \(distancia)")
            } else {
                print("No Video: \(usuariosg[IdUserSelected].nombre)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return video.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellVideo = collectionViewVideo.dequeueReusableCell(withReuseIdentifier: "collectionVideoData", for: indexPath) as! VideoDataCollectionViewCell
        //cellVideo.imageViewVideo.image = UIImage(named: images[indexPath.row])
        cellVideo.imageViewVideo.image = UIImage(named: "video_icon")
        cellVideo.labelVideo.text = video[indexPath.row]
        return cellVideo
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Seleccionaste video ", indexPath.row+1)
    }
    
    @IBAction func cerrarModalVideo(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }    
}

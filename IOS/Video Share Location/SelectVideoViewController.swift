//
//  SelectVideoViewController.swift
//  Video Share Location
//
//  Created by Bani Azarael Mejia Flores on 03/08/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit
import CoreLocation
import AVKit
import AVFoundation

class SelectVideoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionViewVideo: UICollectionView!
    //var images = ["six","seven","eight","nine","ten"]
    var nombreVideo = [String]()
    var urlVideo = [String]()
    var IdUserSelected = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewVideo.delegate = self
        self.collectionViewVideo.dataSource = self
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        let ArrayUserSelected = UserDefaults.standard.stringArray(forKey: "ArrayUserSelected") ?? [String]()
        let NumUserSelected : Int = UserDefaults.standard.integer(forKey: "NumUserSelected")
        let UserSelected : String = ArrayUserSelected[NumUserSelected]
        let LatSelected : Double = UserDefaults.standard.double(forKey: "LatSelected")
        let LongSelected : Double = UserDefaults.standard.double(forKey: "LongSelected")
        for i in 0..<usuariosg.count{
            if (usuariosg[i].nombre.contains(UserSelected)) {
                IdUserSelected = i
                print(i)
            }
        }
        for h in 0..<usuariosg[IdUserSelected].videoinfo.count {
            let LatCurrent : Double = Double(usuariosg[IdUserSelected].videoinfo[h]["lat"] as! String)!
            let LongCurrent : Double = Double(usuariosg[IdUserSelected].videoinfo[h]["long"] as! String)!
            //print("Lat: \(LatCurrent) Long: \(LongCurrent)")
            
            let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
            let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
            let distancia = Punto1.distance(from: Punto2)

            if(distancia <= UserDefaults.standard.double(forKey: "Distance")){
                //print("Video: \(usuariosg[IdUserSelected].nombre)")
                nombreVideo.append("Video \(distancia)")
                urlVideo.append(usuariosg[IdUserSelected].videoinfo[h]["url"] as! String)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nombreVideo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellVideo = collectionViewVideo.dequeueReusableCell(withReuseIdentifier: "collectionVideoData", for: indexPath) as! VideoDataCollectionViewCell
        //cellVideo.imageViewVideo.image = UIImage(named: images[indexPath.row])
        cellVideo.imageViewVideo.image = UIImage(named: "video_icon")
        cellVideo.labelVideo.text = nombreVideo[indexPath.row]
        return cellVideo
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoURL = URL(string: usuariosg[IdUserSelected].videoinfo[(indexPath.row)]["url"] as! String)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @IBAction func regresarModal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

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
    var nombreVideo = [String]()
    var numDeVideo = [Int]()
    var urlVideo = [String]()
    var previewImages = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewVideo.delegate = self
        self.collectionViewVideo.dataSource = self
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        
        let ArrayUserSelected = UserDefaults.standard.array(forKey: "ArrayUserSelected") ?? [Int]()
        let NumUserSelected : Int = UserDefaults.standard.integer(forKey: "NumUserSelected")
        let UserSelected : Int = ArrayUserSelected[NumUserSelected] as! Int
        
        let LatSelected : Double = UserDefaults.standard.double(forKey: "LatSelected")
        let LongSelected : Double = UserDefaults.standard.double(forKey: "LongSelected")
        var contador : Int = 0
        for h in 0..<LatUser.count {
            let LatCurrent : Double = Double(LatUser[h])!
            let LongCurrent : Double = Double(LongUser[h])!
            let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
            let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
            let distancia = Punto1.distance(from: Punto2)
            
            if(distancia <= UserDefaults.standard.double(forKey: "Distance") && IdUser[h] == UserSelected) {
                nombreVideo.append("Video \(h)")
                urlVideo.append(URLVideo[h])
                numDeVideo.append(contador)
                DispatchQueue.main.async {
                    let preview : UIImage = self.toStringURL(URLVideo: URLVideoImg[h])!
                    self.previewImages.append(preview)
                }
            }
            contador+=1
        }
    }
    
    func toStringURL(URLVideo: String) -> UIImage? {
        let url = URL(string:URLVideo)
        let data = try? Data(contentsOf: url!)
        let image: UIImage = UIImage(data: data!)!
        return image
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nombreVideo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellVideo = collectionViewVideo.dequeueReusableCell(withReuseIdentifier: "collectionVideoData", for: indexPath) as! VideoDataCollectionViewCell
        cellVideo.imageViewVideo.image = previewImages[indexPath.row]
        return cellVideo
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoURL = URL(string: urlVideo[indexPath.row])
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

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
    var IdUserSelected = -1
    
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
        for i in 0..<usuariosg.count{
            if (Int(usuariosg[i].idusuario) == UserSelected) {
                IdUserSelected = i
            }
        }
        
        var contador : Int = 0
        for h in 0..<usuariosg[IdUserSelected].videoinfo.count {
            let LatCurrent : Double = Double(usuariosg[IdUserSelected].videoinfo[h]["lat"] as! String)!
            let ant1 : String = usuariosg[IdUserSelected].videoinfo[h]["long"] as! String
            let ant2 : String = ant1.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
            let LongCurrent : Double = Double(ant2)!
            
            let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
            let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
            let distancia = Punto1.distance(from: Punto2)

            if(distancia <= UserDefaults.standard.double(forKey: "Distance")){
                nombreVideo.append("Video \(distancia)")
                urlVideo.append(usuariosg[IdUserSelected].videoinfo[h]["url"] as! String)
                numDeVideo.append(contador)
                DispatchQueue.main.async {
                    let preview : UIImage = self.videoSnapshot(URLVideo: usuariosg[self.IdUserSelected].videoinfo[h]["url"] as! String)!
                    self.previewImages.append(preview)
                }
            }
            contador+=1
        }
    }
    
    func videoSnapshot(URLVideo: String) -> UIImage? {
        let url = URL(string:URLVideo)
        let asset = AVURLAsset(url: url!)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 7)
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            let image:UIImage = UIImage.init(cgImage: imageRef)
            return image
        }
        catch let error as NSError {
            print("Error Preview, URL: \(URLVideo), Error: \(error)")
            return nil
        }
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
        let videoURL = URL(string: usuariosg[IdUserSelected].videoinfo[(numDeVideo[indexPath.row])]["url"] as! String)
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

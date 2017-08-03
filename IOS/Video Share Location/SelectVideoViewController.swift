//
//  SelectVideoViewController.swift
//  Video Share Location
//
//  Created by Bani Azarael Mejia Flores on 03/08/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit

class SelectVideoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionViewVideo: UICollectionView!
    var images = ["six","seven","eight","nine","ten"]
    var usernames = ["Video 1","Video 2","Video 3","Video 4","Video 5"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewVideo.delegate = self
        self.collectionViewVideo.dataSource = self
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellVideo = collectionViewVideo.dequeueReusableCell(withReuseIdentifier: "collectionVideoData", for: indexPath) as! VideoDataCollectionViewCell
        cellVideo.imageViewVideo.image = UIImage(named: images[indexPath.row])
        cellVideo.labelVideo.text = usernames[indexPath.row]
        return cellVideo
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Seleccionaste video ", indexPath.row+1)
    }
    
    @IBAction func cerrarModalVideo(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }    
}

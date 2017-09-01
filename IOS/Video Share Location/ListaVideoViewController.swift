
import UIKit
import AVKit
import AVFoundation

class ListaVideoViewController: UITableViewController {
    
    let VideoData = UserDefaults.standard
    var listaVideos = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listaVideos = self.VideoData.stringArray(forKey: "VideoPath") ?? [String]()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //self.lista.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaVideos.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        let VideoName = listaVideos[indexPath.row]
        let VideoNameEnd = (VideoName as NSString).lastPathComponent
        cell.textLabel?.text = VideoNameEnd
        cell.detailTextLabel?.text = "Datos del video"
        //cell.imageView?.image = UIImage(named: fruitName)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //print("Pulsaste \(indexPath.row)")
        var a: Int = 0
        for VideoName in listaVideos {
            if (a == indexPath.row) {
                //let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4") //por URL externo
                let player = AVPlayer(url: URL(fileURLWithPath: VideoName)) //Local
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
            a+=1
        }
    }
}

import UIKit
import MediaPlayer
import MobileCoreServices

class ReproducirVideoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playVideo(_ sender: AnyObject) {
        let res: Bool = startMediaBrowserFromViewController(self, usingDelegate: self)
        if(res){
            print("Ok Galeria")
        } else {
            print("Error Galeria")
        }
    }
    
    func startMediaBrowserFromViewController(_ viewController: UIViewController, usingDelegate delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate) -> Bool {
        // 1
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        
        // 2
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        
        // 3
        present(mediaUI, animated: true, completion: nil)
        return true
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension ReproducirVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 1
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        // 2
        dismiss(animated: true) {
            // 3
            if mediaType == kUTTypeMovie {
                let moviePlayer = MPMoviePlayerViewController(contentURL: info[UIImagePickerControllerMediaURL] as! URL)
                self.presentMoviePlayerViewControllerAnimated(moviePlayer)
            }
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension ReproducirVideoViewController: UINavigationControllerDelegate {
}

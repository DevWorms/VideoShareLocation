
import UIKit
import GoogleMaps
import MobileCoreServices

class MapaViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapContainer: GMSMapView!
    var locationManager = CLLocationManager()
    var camera: GMSCameraPosition!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ubicaciones"
        camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapContainer.camera = camera
        mapContainer.isMyLocationEnabled = true
        mapContainer.settings.allowScrollGesturesDuringRotateOrZoom = true
        mapContainer.settings.compassButton = true
        mapContainer.settings.consumesGesturesInView = true
        //mapContainer.settings.myLocationButton = true
        mapContainer.settings.zoomGestures = true

        /*let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapContainer*/
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:18)
        self.mapContainer?.animate(to: camera)
        let latitud: Double = (location?.coordinate.latitude)!
        let longitud: Double = (location?.coordinate.longitude)!
        print("Latitud, ", latitud)
        print("Longitud, ", longitud)
        //self.locationManager.stopUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func Grabar(_ sender: Any) {
        let res : Bool = startCameraFromViewController(self, withDelegate: self)
        if (res){
            print("Ok camara")
        } else{
            print("Error camara")
        }
    }
    
    func startCameraFromViewController(_ viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false
        }
        
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController.allowsEditing = false
        cameraController.videoMaximumDuration = 7
        cameraController.delegate = delegate
        
        present(cameraController, animated: true, completion: nil)
        return true
    }
    
    func video(_ videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        var title = "Guardado"
        var message = "Exito al guardar"
        if let _ = error {
            title = "Error"
            message = "Error al guardar"
        }
        print("Video Path", videoPath)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

    extension MapaViewController: UIImagePickerControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String :     Any]) {
            let mediaType = info[UIImagePickerControllerMediaType] as! NSString
            dismiss(animated: true, completion: nil)
            // Handle a movie capture
            if mediaType == kUTTypeMovie {
                let path = "/private/var/mobile/Media/DCIM/IMG_0273.MOV"//(info[UIImagePickerControllerMediaURL] as! URL).path;
                //print("Video Path Final: ", path)
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                    print("Ruta encontrada")
                    UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(MapaViewController.video(_:    didFinishSavingWithError:contextInfo:)), nil)
                }
                /*let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
                if let fileAbsoluteUrl = documentsUrl.appendingPathComponent( ".MOV")?.absoluteURL {
                    print("Relative ", fileAbsoluteUrl)
                 //  /private/var/mobile/Media/DCIM/IMG_0273.MOV
                }*/
            }
        }
    }

    extension MapaViewController: UINavigationControllerDelegate {
    }

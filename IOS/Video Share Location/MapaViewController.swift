
import UIKit
import GoogleMaps
import MobileCoreServices

class MapaViewController: UIViewController, CLLocationManagerDelegate {

    let VideoData = UserDefaults.standard
    
    @IBAction func revisarElementos(_ sender: Any) {
        var listaVideos = VideoData.stringArray(forKey: "VideoPath") ?? [String]()
        var listaNuevaVideos = [String]()
        let fileManager = FileManager.default
        var y: Int = 0
        var totalLista: Int = 0
        print(listaNuevaVideos.count, "Este es la nueva al iniciar")
        totalLista = listaVideos.count
        print("Total = ", totalLista)
        for var m in 0..<listaVideos.count {
            if (!fileManager.fileExists(atPath: listaVideos[m])){
                print("No existe el indice: ", m)
            } else {
                print("Si existe el indice: ", m)
                listaNuevaVideos.append(listaVideos[m])
                y+=1
            }
            m+=1
        }
        VideoData.set(listaNuevaVideos, forKey: "VideoPath")
    }
    @IBOutlet weak var mapContainer: GMSMapView!
    var locationManager = CLLocationManager()
    var camera: GMSCameraPosition!
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Ubicaciones"
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
        //Ahorrar bateria desactivando la actualizacion del GPS
        //let latitud: Double = (location?.coordinate.latitude)!
        //let longitud: Double = (location?.coordinate.longitude)!
        //print("Latitud, ", latitud)
        //print("Longitud, ", longitud)
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
                ///////Obtener la fecha para el nombre del video/////////
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .medium
                let temp1 : String = dateFormatter.string(from: date)
                let temp2 = temp1.replacingOccurrences(of: ":", with: "_")
                let temp3 = temp2.replacingOccurrences(of: "/", with: "_")
                let temp4 = temp3.replacingOccurrences(of: " ", with: "_")
                /////////////////////////////////////////////////////////
                let sourcePath = (info[UIImagePickerControllerMediaURL] as! URL).path;
                let fileManger = FileManager.default
                let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
                let destinationPath = doumentDirectoryPath.appendingPathComponent("Video_\(temp4).MOV")
                //let destinationPath = doumentDirectoryPath.appendingPathComponent("Video.MOV")
                do{
                    try fileManger.copyItem(atPath: sourcePath, toPath: destinationPath)
                }catch let error as NSError {
                    print("Error encontrado, Detalles: \(error)")
                }
                if(dataAlreadyExist(dataKey: "VideoPath")){
                    var array = VideoData.stringArray(forKey: "VideoPath") ?? [String]()
                    array.append(destinationPath)
                    VideoData.set(array, forKey: "VideoPath")
                } else {
                    var noArray = [String]()
                    noArray.append(destinationPath)
                    VideoData.set(noArray, forKey: "VideoPath")
                }
                print("Destino: ", destinationPath)
                
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(sourcePath) {
                    UISaveVideoAtPathToSavedPhotosAlbum(sourcePath, self, #selector(MapaViewController.video(_:    didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
        
        func dataAlreadyExist(dataKey: String) -> Bool {
            return UserDefaults.standard.stringArray(forKey: dataKey) != nil
        }
    }

    extension MapaViewController: UINavigationControllerDelegate {
    }


import UIKit
import Foundation
import GoogleMaps
import MobileCoreServices
import CoreLocation

class MapaViewController: UIViewController, CLLocationManagerDelegate {

    //CLASE USUARIOS
    class Usuarios{
        var nombre = ""
        var videoinfo = [[String:AnyObject]]()
    }
    //TERMINA CLASE USUARIOS
    
    var usuarios: [Usuarios] = []
    let DataUserDefault = UserDefaults.standard
    var latitud: Double = 0.0
    var longitud: Double = 0.0
    var locationManager = CLLocationManager()
    var camera: GMSCameraPosition!
    var api: String = ""
    var userid: String! = ""
    @IBOutlet weak var mapContainer: GMSMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let apikey = UserDefaults.standard.value(forKey: globalkey) {
            api = apikey as! String
        }
        
        if let id = UserDefaults.standard.value(forKey: globalid) {
            userid = id as! String
        }
        videos(apikey: api, id: userid)
        //camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        /////////////Configuracion de controles del mapa///////////////
        //mapContainer.camera = camera
        mapContainer.isMyLocationEnabled = true
        mapContainer.settings.allowScrollGesturesDuringRotateOrZoom = true
        mapContainer.settings.compassButton = true
        mapContainer.settings.consumesGesturesInView = true
        mapContainer.settings.myLocationButton = true
        mapContainer.settings.zoomGestures = true
        /////////////Configuracion de controles del mapa///////////////
        
        //let marker = GMSMarker()
        //marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        //marker.title = "Sydney"
        //marker.snippet = "Australia"
        //marker.tracksInfoWindowChanges = true
        //marker.map = mapContainer
        llenarMapaMarkers()
        //LLENAR MARKERS DE USUSARIOS DE LA API///
        crearMarkerr()
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func limpiarLista(_ sender: Any) {
        /////////////Crea un array con los videos que existen para llenar lista///////////////
        var listaVideos = DataUserDefault.stringArray(forKey: "VideoPath") ?? [String]()
        var listaNuevaVideos = [String]()
        let fileManager = FileManager.default
        var y: Int = 0
        var totalLista: Int = 0
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
        DataUserDefault.set(listaNuevaVideos, forKey: "VideoPath")
        /////////////Crea un array con los videos que existen para llenar lista///////////////
    }
    
    ////FUNCION CREAR MARKERS PARA LOS VIDEOS EXISTENTES
    func crearMarkerr(){
        for i in 0 ..< usuarios.count {
            for c in 0 ..< usuarios[i].videoinfo.count {
                let markerr = GMSMarker()
                let result = usuarios[i].videoinfo[c] as [String:Any]
                let latficticia = result["Lat"]
                let longficticia = result["Long"]
                markerr.position = CLLocationCoordinate2D(latitude: latficticia as! Double, longitude: longficticia as! Double)
                markerr.title = usuarios[i].nombre
                markerr.snippet = "Videos de \(usuarios[i].nombre)"
                markerr.icon = GMSMarker.markerImage(with: .brown)
                markerr.map = mapContainer
            }
            
        }
    }
    ///Funcion crear markers termina
    
    ///// CONEXION POST URL CON API OBTENER VIDEOS
    
    func videos(apikey: String, id: String) {
        
        let parameterString = "apikey=\(apikey)&id=\(id)"
        
        print(parameterString)
        
        let strUrl = "http://videoshare.devworms.com/api/videos"
        
        if let httpBody = parameterString.data(using: String.Encoding.utf8) {
            var urlRequest = URLRequest(url: URL(string: strUrl)!)
            urlRequest.httpMethod = "POST"
            
            URLSession.shared.uploadTask(with: urlRequest, from: httpBody, completionHandler: parseJsonLogin).resume()
        } else {
            print("Error de codificación de caracteres.")
        }
    }
    
    ////////RECOGE VIDEOS DE API
    func parseJsonLogin(data: Data?, urlResponse: URLResponse?, error: Error?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                //print(json)
                if let jsonResult = json as? [String: Any] {
                    DispatchQueue.main.async {
                        self.usuarios = [Usuarios]()
                        
                        if let result = jsonResult["users"] as?  [[String: Any]] {
                            for user in result{
                                let usuario = Usuarios()
                                if let nombre = user["name"] as? String, let videos = user["videos"] as? [String:AnyObject]{
                                    usuario.nombre = nombre
                                    usuario.videoinfo = [videos]
                                }
                                self.usuarios.append(usuario)
                            }
                        }
                        
                    }
                }
                
            } else {
                print("HTTP Status Code: 200")
                print("El JSON de respuesta es inválido.")
            }
            
        }
    }
    /////TERMINA JSON PARA RECUPERAR VIDESO DE API
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        latitud = (location?.coordinate.latitude)!
        longitud = (location?.coordinate.longitude)!
        //self.locationManager.stopUpdatingLocation()
    }
    
    func DistanciaGuardarMarker() {
        let LatLong = DataUserDefault.array(forKey: "LatLong") ?? [Double]()
        var ponerMarker: Bool = false
        let marker = GMSMarker()
        
        if (arrayAlreadyExist(dataKey: "LatVideo")){
            var LatVideo = DataUserDefault.array(forKey: "LatVideo") ?? [Double]()
            var LongVideo = DataUserDefault.array(forKey: "LongVideo") ?? [Double]()
            print("La lista tiene ", LatVideo.count, "indices")
            for var c in 0..<LatVideo.count {
                /////////////Calcular distancia///////////////
                let Punto1 = CLLocation(latitude: LatLong[0] as! Double, longitude: LatLong[1] as! Double)
                let Punto2 = CLLocation(latitude: LatVideo[c] as! Double, longitude: LongVideo[c] as! Double)
                let distancia = Punto1.distance(from: Punto2)
                /////////////Calcular distancia///////////////
                /////////////Verifica cercania de otros markers///////////////
                if (distancia<=10) {
                    print("Distancia dentro del rango")
                    ponerMarker = false //Indicador para poner marker en mapa
                    c=9999  //Existe algun video dentro del rango, sale del ciclo
                } else {
                    //Termino el recorrido sin ninguna coincidencia
                    print("Distancia fuera del rango")
                    ponerMarker = true
                }
                print("Distancia = ", distancia, " metros")
                /////////////Verifica cercania de otros markers///////////////
            }
            if (ponerMarker){
                marker.position = CLLocationCoordinate2D(latitude: LatLong[0] as! Double, longitude: LatLong[1] as! Double)
                marker.title = "Bani Azarael"
                //marker.snippet = "Videos de Bani"
                marker.icon = GMSMarker.markerImage(with: .blue)
                marker.map = mapContainer
                LatVideo.append(LatLong[0] as! Double)
                LongVideo.append(LatLong[1] as! Double)
                DataUserDefault.set(LatVideo, forKey: "LatVideo")
                DataUserDefault.set(LongVideo, forKey: "LongVideo")
            }
        } else {
            //Si no existe LatVideo, es el primer marker y lo agrega al mapa sin recorrer diccionario
            marker.position = CLLocationCoordinate2D(latitude: LatLong[0] as! Double, longitude: LatLong[1] as! Double)
            marker.title = "Bani Azarael"
            //marker.snippet = "Videos de Bani"
            marker.icon = GMSMarker.markerImage(with: .blue)
            marker.map = mapContainer
            var LatDouble = [Double]()
            var LongDouble = [Double]()
            LatDouble.append(LatLong[0] as! Double)
            LongDouble.append(LatLong[1] as! Double)
            DataUserDefault.set(LatDouble, forKey: "LatVideo")
            DataUserDefault.set(LongDouble, forKey: "LongVideo")
        }
    }
    
    func llenarMapaMarkers() {
        if (arrayAlreadyExist(dataKey: "LatVideo")){
            var LatVideo = DataUserDefault.array(forKey: "LatVideo") ?? [Double]()
            var LongVideo = DataUserDefault.array(forKey: "LongVideo") ?? [Double]()
            for c in 0..<LatVideo.count {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: LatVideo[c] as! Double, longitude: LongVideo[c] as! Double)
                marker.title = "Bani Azarael"
                marker.snippet = "Videos de Bani"
                marker.icon = GMSMarker.markerImage(with: .blue)
                marker.map = mapContainer
            }
        } else {
            print("¡No existen markers almacenados!")
        }
    }
    
    @IBAction func Grabar(_ sender: Any) {
        let res : Bool = startCameraFromViewController(self, withDelegate: self)
        if (res){
            print("OK camara")
        } else{
            print("Error camara")
        }
        let LatLong = [latitud,longitud]
        DataUserDefault.set(LatLong, forKey: "LatLong")
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
        self.present(alert, animated: true, completion: nil)
    }
}


    extension FloatingPoint {
        var degreesToRadians: Self { return self * .pi / 180 }
    }
    extension MapaViewController: UIImagePickerControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String :     Any]) {
            let mediaType = info[UIImagePickerControllerMediaType] as! NSString
            dismiss(animated: true, completion: nil)
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
                ///////Obtener la fecha para el nombre del video/////////
                let sourcePath = (info[UIImagePickerControllerMediaURL] as! URL).path;
                let fileManger = FileManager.default
                let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
                let destinationPath = doumentDirectoryPath.appendingPathComponent("Video_\(temp4).MOV")
                do{
                    try fileManger.copyItem(atPath: sourcePath, toPath: destinationPath)
                }catch let error as NSError {
                    print("Error encontrado, Detalles: \(error)")
                }
                if(dataAlreadyExist(dataKey: "VideoPath")){
                    var array = DataUserDefault.stringArray(forKey: "VideoPath") ?? [String]()
                    array.append(destinationPath)
                    DataUserDefault.set(array, forKey: "VideoPath")
                } else {
                    var noArray = [String]()
                    noArray.append(destinationPath)
                    DataUserDefault.set(noArray, forKey: "VideoPath")
                }
                print("Destino: ", destinationPath)
                let alerta = UIAlertController(title: "¿Que desea hacer?", message: "Elija una opción para continuar", preferredStyle: UIAlertControllerStyle.alert)
                alerta.addAction(UIAlertAction(title: "Subir video", style: UIAlertActionStyle.default, handler: { alertAction in
                    print("Subir al servidor")
                    self.DistanciaGuardarMarker()
                    //Codigo subir a API
                    alerta.dismiss(animated: true, completion: nil)
                }))
                alerta.addAction(UIAlertAction(title: "Guardar en el telefono", style: UIAlertActionStyle.default, handler: { alertAction in
                    if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(sourcePath) {
                        UISaveVideoAtPathToSavedPhotosAlbum(sourcePath, self, #selector(MapaViewController.video(_:    didFinishSavingWithError:contextInfo:)), nil)
                    }
                    self.DistanciaGuardarMarker()
                    print("Guardado en el telefono")
                    alerta.dismiss(animated: true, completion: nil)
                }))
                self.present(alerta, animated: true, completion: nil)
            }
        }
        
        func dataAlreadyExist(dataKey: String) -> Bool {
            return UserDefaults.standard.stringArray(forKey: dataKey) != nil
        }
        func arrayAlreadyExist(dataKey: String) -> Bool {
            return UserDefaults.standard.array(forKey: dataKey) != nil
        }
    }

    extension MapaViewController: UINavigationControllerDelegate {
    }


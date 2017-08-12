
import UIKit
import Foundation
import GoogleMaps
import MobileCoreServices
import CoreLocation
import SwiftyJSON
import Alamofire
import Foundation

var usuariosg: [Users] = []

class MapaViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    typealias Parameters = [String: String]
    var usuarios: [Users] = []
    let DataUserDefault = UserDefaults.standard
    var mlatitud: Double = 0.0
    var mlongitud: Double = 0.0
    var locationManager = CLLocationManager()
    var camera: GMSCameraPosition!
    var api: String = ""
    var userid: String! = ""
    @IBOutlet weak var mapContainer: GMSMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera = GMSCameraPosition.camera(withLatitude: 19.419444, longitude: -99.145556, zoom: 8.0)
        mapContainer.camera = camera
        if let apikey = UserDefaults.standard.value(forKey: globalkey) {
            api = apikey as! String
        }
        
        if let id = UserDefaults.standard.value(forKey: globalid) {
            userid = id as! String
        }
        videos(apikey: api, id: userid)
        /*
        ================================================================================================
        Configuracion de controles del mapa
        ================================================================================================
        */
        mapContainer.isMyLocationEnabled = true
        mapContainer.settings.allowScrollGesturesDuringRotateOrZoom = true
        mapContainer.settings.compassButton = true
        mapContainer.settings.consumesGesturesInView = true
        mapContainer.settings.myLocationButton = true
        mapContainer.settings.zoomGestures = true
        /*
        ================================================================================================
        */
        //let marker = GMSMarker()
        //marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        //marker.title = "Sydney"
        //marker.snippet = "Australia"
        //marker.tracksInfoWindowChanges = true
        //marker.map = mapContainer
        llenarMapaMarkers()
        //LLENAR MARKERS DE USUSARIOS DE LA API///
        //crearMarkerr()
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.mapContainer.delegate = self
        
        let logoutButton:UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MapaViewController.searchTapped(sender:)))
        self.navigationItem.setLeftBarButton(logoutButton, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchTapped(sender:UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
        print("Presionado")
    }
    
    @IBAction func limpiarLista(_ sender: Any) {
        /*
        ================================================================================================
        Crea un array con los videos que existen para llenar lista
        ================================================================================================
        */
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
        /*
        ================================================================================================
        */
    }
    
    ////FUNCION CREAR MARKERS PARA LOS VIDEOS EXISTENTES
    func crearMarkerr(){
        print(usuarios.count)
        for i in 0 ..< usuarios.count {
            for c in 0 ..< usuarios[i].videoinfo.count {
                let markerr = GMSMarker()
                let result = usuarios[i].videoinfo[c] as [String:Any]
                if let lat = result["lat"] as? String, let long = result["long"] as? String{
                    markerr.position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
                    markerr.title = usuarios[i].nombre
                    markerr.snippet = "Videos de \(usuarios[i].nombre)"
                    markerr.icon = GMSMarker.markerImage(with: .brown)
                    markerr.map = mapContainer
                }
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error obteniendo ubicacion: \(error)")
    }
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation) {
        //googleMap.clear()
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        Alamofire.request(url).responseJSON { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            for route in routes {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 3
                polyline.strokeColor = UIColor.blue
                polyline.map = self.mapContainer
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
                        self.usuarios = [Users]()
                        
                        if let result = jsonResult["users"] as?  [[String: Any]] {
                            //print(result)
                            for user in result{
                                //print(user)
                                //print(user["videos"])
                                let usuario = Users()
                                if let nombre = user["name"] as? String, let videos = user["videos"] as? [[String:Any]]{
                                    usuario.nombre = nombre
                                    for video in videos
                                    {
                                        usuario.videoinfo.append(video)
                                    }
                                    //usuario.videoinfo = [videos]
                                    print(nombre)
                                    print(usuario.videoinfo[0]["lat"])
                                    print("salto\n\n")
                                }
                                self.usuarios.append(usuario)
                                usuariosg = self.usuarios
                            }
                        }
                     self.crearMarkerr()
                    }
                    
                }
                
            } else {
                print("HTTP Status Code: 200")
                print("El JSON de respuesta es inválido.")
            }
            
        }
    }
    /////TERMINA JSON PARA RECUPERAR VIDESO DE API
    
    ////SUBIR VIDEO A API
    func SubirVideo(apikey: String, id : String, lat: String, long: String, path: String ) {
        let parameters = ["apikey": apikey,
                          "id": id,
                          "lat": lat,
                          "long": long]
        
        //guard let mediaImage = Media(withImage: #imageLiteral(resourceName: "testImage"), forKey: "image") else { return }
        
        guard let url = URL(string: "http://videoshare.devworms.com/api/video") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = generateBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Client-ID f65203f7020dddc", forHTTPHeaderField: "Authorization")
        
        let dataBody = createDataBody(withParameters: parameters, media: path , boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            }.resume()
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: Parameters?, media: String?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            //for photo in media {
            do{
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=archivo; filename=\"\("prueba")\"\(lineBreak)")
                body.append("Content-Type: \("video/quicktime" + lineBreak + lineBreak)")
                try body.append(NSData(contentsOfFile: media) as Data)
                body.append(lineBreak)
            }catch{
                print("error Body:\(error)")
            }
            
            //}
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    
    ////TERMINA SUBIR VIDEO A LA API
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        mlatitud = (location?.coordinate.latitude)!
        mlongitud = (location?.coordinate.longitude)!
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
        let LatLong = [mlatitud,mlongitud]
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
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Marker Seleccionado, Titulo: ", marker.snippet!, "Latitud: ", marker.position.latitude, " Longitud: ", marker.position.longitude)
        camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 20.0)
        mapContainer.camera = camera
        mapContainer.selectedMarker = marker
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        print("InfoWindow Cerrado, Titulo: ", marker.snippet!, "Latitud: ", marker.position.latitude, " Longitud: ", marker.position.longitude)
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("InfoWindow Seleccionado, Titulo: ", marker.snippet!, "Latitud: ", marker.position.latitude, " Longitud: ", marker.position.longitude)
        showModalUsuarios()
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        print("Mantener presionado")
        let location1 = CLLocation(latitude: mlatitud, longitude: mlongitud)
        let location2 = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
        mapContainer.clear()
        videos(apikey: api, id: userid)
        self.drawPath(startLocation: location1, endLocation: location2)
    }
    
    func showModalUsuarios() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserVC")
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    //var rightSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: #selector(MapaViewController.searchTapped))
    // 3
    //self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem,rightSearchBarButtonItem], animated: true)
    
}


/*
 ================================================================================================
 Comienzan extensiones de clases para grabar videos y almacenar
 ================================================================================================
 */
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
                    let latitudd = "\(self.mlatitud)"
                    let longitudd = "\(self.mlongitud)"
                    self.SubirVideo(apikey: self.api, id: self.userid, lat: latitudd, long: longitudd, path: destinationPath)
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

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

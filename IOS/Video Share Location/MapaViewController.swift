
import UIKit
import Foundation
import GoogleMaps
import MobileCoreServices
import CoreLocation
import SwiftyJSON
import Alamofire
import Foundation

var usuariosg: [Users] = []
let notificacionSubir = NSNotification.Name("uploadNotification")
let notificacionTermina = NSNotification.Name("uploadedNotification")

class MapaViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var progressBar: UIProgressView!
    typealias Parameters = [String: String]
    var usuarios: [Users] = []
    let DataUserDefault = UserDefaults.standard
    var mlatitud: Double = -13.965953
    var mlongitud: Double = -138.157899
    var locationManager = CLLocationManager()
    var camera: GMSCameraPosition!
    var apikey : String! = ""
    var userid : String! = ""
    var useridd : Int = 0
    var LatVideo = [Double]()
    var LongVideo = [Double]()
    
    @IBOutlet weak var mapContainer: GMSMapView!
    var usernames = [String]()
    var idUsers = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apikey = DataUserDefault.string(forKey: "globalkey")
        userid = DataUserDefault.string(forKey: "globalid")
        useridd = DataUserDefault.integer(forKey: "globalidd")
        DataUserDefault.set(15, forKey: "Distance")
        DataUserDefault.set(LatVideo, forKey: "LatVideo")
        DataUserDefault.set(LongVideo, forKey: "LongVideo")
        LatVideo = DataUserDefault.array(forKey: "LatVideo") as! [Double]
        LongVideo = DataUserDefault.array(forKey: "LongVideo") as! [Double]
        
        reloadMapData()
        
        camera = GMSCameraPosition.camera(withLatitude: 19.419444, longitude: -99.145556, zoom: 8.0) //Posicion de CDMX Centro
        mapContainer.camera = camera
        mapContainer.isMyLocationEnabled = true
        mapContainer.settings.allowScrollGesturesDuringRotateOrZoom = true
        mapContainer.settings.compassButton = true
        mapContainer.settings.consumesGesturesInView = true
        mapContainer.settings.myLocationButton = true
        mapContainer.settings.zoomGestures = true

        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.mapContainer.delegate = self
        
        let refresh:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(MapaViewController.refresh))
        let menu = UIButton(type: .custom)
        menu.setImage(UIImage(named: "icon_menu"), for: .normal)
        menu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        menu.addTarget(self, action: #selector(MapaViewController.menu), for: .touchUpInside)
        let menuItem = UIBarButtonItem(customView: menu)
        
        let navBackgroundImage:UIImage! = UIImage(named: "barra1")
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.darkText
        nav!.setBackgroundImage(navBackgroundImage, for:.default)
        
        self.navigationItem.setLeftBarButton(refresh, animated: true)
        self.navigationItem.setRightBarButtonItems([menuItem], animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func menu(sender:UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MenuViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func refresh(sender:UIButton) {
        reloadMapData()
    }
    
    func reloadMapData(){
        mapContainer.clear()
        videos(apikey: apikey, id: userid)
    }
    
    func crearMarker() {
        LatVideo.removeAll()
        LongVideo.removeAll()
        LatVideo.append(-13.965953)
        LongVideo.append(-138.157899)
        
        let marker = GMSMarker()
        marker.tracksInfoWindowChanges = true
        
        var lat : Double
        var long : Double
        let IndiceUsuario : Int = DataUserDefault.integer(forKey: "IndiceUsuario") - 1
        var ponerMarker: Bool = true
        var mContador:Int = 0
        print("Recibe IndiceUsuario: \(IndiceUsuario)")
        if(IndiceUsuario != -1){
            for nVideo in 0 ..< usuarios[IndiceUsuario].videoinfo.count {
                let result = usuarios[IndiceUsuario].videoinfo[nVideo] as [String:Any]
                lat = Double(result["lat"] as! String)!
                long = Double(result["long"] as! String)!
                ponerMarker=true
                for var nCoord in 0 ..< LatVideo.count {
                    let Punto1 = CLLocation(latitude: lat , longitude: long)
                    let Punto2 = CLLocation(latitude: LatVideo[nCoord] , longitude: LongVideo[nCoord]) //Almacenado
                    let distancia = Punto1.distance(from: Punto2)
                    if (distancia<=(UserDefaults.standard.double(forKey: "Distance"))) {
                        ponerMarker = false //Indicador para poner marker en mapa
                        nCoord=9999  //Existe algun video dentro del rango, sale del ciclo
                    }
                }
                if (ponerMarker){
                    if (mContador==0){
                        LatVideo.removeAll()
                        LongVideo.removeAll()
                    }
                    LatVideo.insert(lat, at: mContador)
                    LongVideo.insert(long, at: mContador)
                    DataUserDefault.set(LatVideo, forKey: "LatVideo")
                    DataUserDefault.set(LongVideo, forKey: "LongVideo")
                    mContador+=1
                }
            }
            markerUsuario()
            //TERMINA COLOCACION DE MARCADORES DE USUARIO
        } else {
            print("El usuario no tiene videos")
        }
        //INICIA COLOCACION DE MARCADORES DE OTROS USUARIOS
        for nUsuario in 0 ..< usuarios.count {
            //print("Siguiente usuario: \(usuarios[nUsuario].nombre)")
            //if(IndiceUsuario != nUsuario){
            for nVideo in 0 ..< usuarios[nUsuario].videoinfo.count {
                //print("Videos actuales: \(nVideo)")
                let result = usuarios[nUsuario].videoinfo[nVideo] as [String:Any]
                lat = Double(result["lat"] as! String)!
                let ant1 : String = result["long"] as! String
                let ant2 : String = ant1.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
                long = Double(ant2)!
                ponerMarker=true
                for var nCoord in 0 ..< LatVideo.count {
                    let Punto1 = CLLocation(latitude: lat , longitude: long)
                    let Punto2 = CLLocation(latitude: LatVideo[nCoord] , longitude: LongVideo[nCoord]) //Almacenado
                    let distancia = Punto1.distance(from: Punto2)
                    if (distancia<=(UserDefaults.standard.double(forKey: "Distance"))) {
                        ponerMarker = false //Indicador para poner marker en mapa
                        nCoord=9999  //Existe algun video dentro del rango, sale del ciclo
                    }
                }
                if (ponerMarker){
                    if (mContador==0){
                        LatVideo.removeAll()
                        LongVideo.removeAll()
                    }
                    LatVideo.append(lat)
                    LongVideo.append(long)
                    DataUserDefault.set(LatVideo, forKey: "LatVideo")
                    DataUserDefault.set(LongVideo, forKey: "LongVideo")
                    mContador+=1
                }
                //}
            }
        }
        markerOtroUsuario()
    }
    
    func markerUsuario() {
        if (LatVideo.count > 0){
            var LatVideo = DataUserDefault.array(forKey: "LatVideo") ?? [Double]()
            var LongVideo = DataUserDefault.array(forKey: "LongVideo") ?? [Double]()
            for c in 0..<LatVideo.count {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: LatVideo[c] as! Double, longitude: LongVideo[c] as! Double)
                marker.title = "WeShick"
                marker.snippet = "Videos: 0"
                marker.icon = UIImage(named: "marker1")
                marker.map = mapContainer
                let circulo = CLLocationCoordinate2D(latitude: LatVideo[c] as! Double, longitude: LongVideo[c] as! Double)
                let radio = GMSCircle(position: circulo, radius: (UserDefaults.standard.double(forKey: "Distance")))
                let ab = GMSCircle(position: circulo, radius: (0.4))
                ab.map = mapContainer
                radio.map = mapContainer
            }
        }
    }
    
    func markerOtroUsuario() {
        if (LatVideo.count > 0){
            var LatVideo = DataUserDefault.array(forKey: "LatVideo") ?? [Double]()
            var LongVideo = DataUserDefault.array(forKey: "LongVideo") ?? [Double]()
            for c in 0..<LatVideo.count {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: LatVideo[c] as! Double, longitude: LongVideo[c] as! Double)
                marker.title = "WeShick"
                marker.snippet = "Videos: 0"
                marker.icon = UIImage(named: "marker2")
                marker.map = mapContainer
                let circulo = CLLocationCoordinate2D(latitude: LatVideo[c] as! Double, longitude: LongVideo[c] as! Double)
                let radio = GMSCircle(position: circulo, radius: (UserDefaults.standard.double(forKey: "Distance")))
                radio.map = mapContainer
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error obteniendo ubicacion: \(error)")
    }
 
    func mostrarRuta(inicio: CLLocation, destino: CLLocation) {
        let origin = "\(inicio.coordinate.latitude),\(inicio.coordinate.longitude)"
        let destination = "\(destino.coordinate.latitude),\(destino.coordinate.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking"
        Alamofire.request(url).responseJSON { response in
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
    
    func videos(apikey: String, id: String) {
        let parameterString = "apikey=\(apikey)&id=0"
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

    func parseJsonLogin(data: Data?, urlResponse: URLResponse?, error: Error?) {
        if error != nil {
            print("Error al entrar Parse: \(error!)")
        } else if urlResponse != nil {
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                //print(json)
                if let jsonResult = json as? [String: Any] {
                    DispatchQueue.main.async {
                        self.usuarios = [Users]()
                        if let result = jsonResult["users"] as?  [[String: Any]] {
                            var contador : Int = 1
                            for user in result {
                                let usuario = Users()
                                if let nombre = user["name"] as? String, let videos = user["videos"] as? [[String:Any]], let idd = user["id"] as? Int, let url_img = user["url_img"] as? String {
                                    if (idd==self.useridd){
                                        self.DataUserDefault.set(contador, forKey: "IndiceUsuario")
                                        print("Envia IndiceUsuario \(contador)")
                                    }
                                    contador+=1
                                    print("En el servidor -> Usuario: \(idd), Nombre: \(nombre)")
                                    usuario.nombre = nombre
                                    usuario.url_img = url_img
                                    usuario.idusuario = "\(idd)"
                                    var contVideo:Int = 0
                                    for video in videos {
                                        usuario.videoinfo.append(video)
                                        print("\t \(usuario.videoinfo[contVideo]["url"]!)")
                                        contVideo+=1
                                    }
                                }
                                self.usuarios.append(usuario)
                                usuariosg = self.usuarios
                            }
                        }
                        print("Total de usuarios: \(self.usuarios.count)")
                        self.crearMarker()
                    }
                }
            }
        }
    }
 ////////Inicia Subir video a API
    func SubirVideo(apikey: String, id : String, lat: String, long: String, path: String ) {
        let parameters = ["apikey": apikey,
                          "id": id,
                          "lat": lat,
                          "long": long]
        let boundary = generateBoundary()
        guard let url = URL(string: "http://videoshare.devworms.com/api/video") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Client-ID f65203f7020dddc", forHTTPHeaderField: "Authorization")
        
        let dataBody = createDataBody(withParameters: parameters, media: path , boundary: boundary)
        request.httpBody = dataBody
        let session = URLSession.shared
        session.uploadTask(with: request, from: dataBody) { (data, response, error) in
            if let response = response {
                print("Respuesta: \(response)")
            }
            if let data = data {
                ////////////Notificacion para menuviewcontroller que mostrará si el video se subio o no
                NotificationCenter.default.post(name: notificacionSubir, object: nil)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Respuesta JSON: \(json)")
                    self.reloadMapData()
                } catch {
                    print("Error formando JSON: \(error)")
                    let alerta = UIAlertController(title: "Error de conexion a intenet", message: "Revisa tu conexion", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Entendido", style: UIAlertActionStyle.default, handler: { alertAction in
                        alerta.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alerta, animated: true, completion: nil)
                }
            }
        }.resume()
        //////////////Notificación de que el video ya se subió
        NotificationCenter.default.post(name: notificacionTermina, object: nil)
        
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
            do{
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=archivo; filename=\"\(media)\"\(lineBreak)")
                body.append("Content-Type: \("video/quicktime" + lineBreak + lineBreak)")
                try body.append(NSData(contentsOfFile: media) as Data)
                body.append(lineBreak)
            }catch{
                print("Error Media:\(error)")
            }
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        mlatitud = (location?.coordinate.latitude)!
        mlongitud = (location?.coordinate.longitude)!
        //self.locationManager.stopUpdatingLocation()
    }

    @IBAction func Grabar(_ sender: Any) {
        let res : Bool = startCameraFromViewController(self, withDelegate: self)
        if (res){
            print("Inciando camara...")
        } else{
            print("Error al iniciar camara...")
        }
        //let LatLong = [mlatitud,mlongitud]
        //DataUserDefault.set(LatLong, forKey: "LatLong")
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
        var message = "Guardado correctamente"
        if let _ = error {
            title = "Error"
            message = "Error al guardar"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        DataUserDefault.set(marker.position.latitude, forKey: "LatSelected")
        DataUserDefault.set(marker.position.longitude, forKey: "LongSelected")
        camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 20.0)
        mapContainer.camera = camera
        
        self.obtenerUsuariosMarker()
        if (usernames.count==1) {
            marker.title = "\(usernames[0])"
        } else if (usernames.count==2) {
            marker.title = "\(usernames[0]), \(usernames[1])"
        } else if (usernames.count>=3) {
            marker.title = "\(usernames[0]), \(usernames[1]), \(usernames[2])..."
        }
        
        let numVideos : Int = self.obtenerNumVideos()
        if numVideos == 1 {
            marker.snippet = "Video: \(numVideos)"
        } else {
            marker.snippet = "Videos: \(numVideos)"
        }
        mapContainer.selectedMarker = marker
        marker.map = mapContainer
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        //print("InfoWindow Cerrado, Titulo: ", marker.snippet!, "Latitud: ", marker.position.latitude, " Longitud: ", marker.position.longitude)
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        //print("InfoWindow Seleccionado, Titulo: ", marker.snippet!, "Latitud: ", marker.position.latitude, " Longitud: ", marker.position.longitude)
        DataUserDefault.set(marker.position.latitude, forKey: "LatSelected")
        DataUserDefault.set(marker.position.longitude, forKey: "LongSelected")
        showModalUsuarios()
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        //print("InfoWindow fue mantenido presionado")
        let ubicacionInicio = CLLocation(latitude: mlatitud, longitude: mlongitud)
        let ubicacionDestino = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
        reloadMapData()
        self.mostrarRuta(inicio: ubicacionInicio, destino: ubicacionDestino)
    }
    
    func showModalUsuarios() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserVC")
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    func obtenerUsuariosMarker() {
        usernames = [String]()
        idUsers = [Int]()
        let LatSelected : Double = UserDefaults.standard.double(forKey: "LatSelected")
        let LongSelected : Double = UserDefaults.standard.double(forKey: "LongSelected")
        for i in 0..<usuariosg.count{
            for h in 0..<usuariosg[i].videoinfo.count {
                let LatCurrent : Double = Double(usuariosg[i].videoinfo[h]["lat"] as! String)!
                let ant1 : String = usuariosg[i].videoinfo[h]["long"] as! String
                let ant2 : String = ant1.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
                let LongCurrent : Double = Double(ant2)!
                let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
                let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
                let distancia = Punto1.distance(from: Punto2)
                if(distancia<=UserDefaults.standard.double(forKey: "Distance")){
                    if (!idUsers.contains(Int(usuariosg[i].idusuario)!)) {
                        usernames.append(usuariosg[i].nombre)
                        print("En el mapa -> ID Usuario: \(Int(usuariosg[i].idusuario)!), Nombre: \(usuariosg[i].nombre)")
                        idUsers.append(Int(usuariosg[i].idusuario)!)
                    }
                }
            }
        }
    }
    
    func obtenerNumVideos() -> Int {
        var numVideos : Int = 0
        let LatSelected : Double = UserDefaults.standard.double(forKey: "LatSelected")
        let LongSelected : Double = UserDefaults.standard.double(forKey: "LongSelected")
        for id in idUsers {
            for i in 0..<usuariosg.count {
                if (Int(usuariosg[i].idusuario)! == id){
                    for h in 0..<usuariosg[i].videoinfo.count {
                        let LatCurrent : Double = Double(usuariosg[i].videoinfo[h]["lat"] as! String)!
                        let ant1 : String = usuariosg[i].videoinfo[h]["long"] as! String
                        let ant2 : String = ant1.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
                        let LongCurrent : Double = Double(ant2)!
                        let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
                        let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
                        let distancia = Punto1.distance(from: Punto2)
                        if(distancia<=UserDefaults.standard.double(forKey: "Distance")){
                            numVideos += 1
                        }
                    }
                }
            }
        }
        return numVideos
    }
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
                let sourcePath = (info[UIImagePickerControllerMediaURL] as! URL).path;
                let alerta = UIAlertController(title: "¿Que desea hacer?", message: "Elija una opción para continuar", preferredStyle: UIAlertControllerStyle.alert)
                alerta.addAction(UIAlertAction(title: "Subir video", style: UIAlertActionStyle.default, handler: { alertAction in
                    let UploadLat = "\(self.mlatitud)"
                    let UploadLong = "\(self.mlongitud)"
                    self.SubirVideo(apikey: self.apikey, id: String(self.userid), lat: UploadLat , long: UploadLong, path: sourcePath)
                    alerta.dismiss(animated: true, completion: nil)
                    self.reloadMapData()
                }))
                alerta.addAction(UIAlertAction(title: "Guardar en el telefono", style: UIAlertActionStyle.default, handler: { alertAction in
                    self.moverVideo(destinationPath: sourcePath)
                    alerta.dismiss(animated: true, completion: nil)
                }))
                self.present(alerta, animated: true, completion: nil)
            }
        }
        
        func moverVideo(destinationPath: String){
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(destinationPath) {
                UISaveVideoAtPathToSavedPhotosAlbum(destinationPath, self, #selector(MapaViewController.video(_: didFinishSavingWithError:contextInfo:)), nil)
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

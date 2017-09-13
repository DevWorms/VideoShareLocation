
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
    var apikey : String! = ""
    var userid : String! = ""
    var useridd : Int = 0
    var LatVideo = [Double]()
    var LongVideo = [Double]()
    var marker = GMSMarker()
    
    @IBOutlet weak var mapContainer: GMSMapView!
    var usernames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apikey = DataUserDefault.string(forKey: "globalkey")
        userid = DataUserDefault.string(forKey: "globalid")
        useridd = DataUserDefault.integer(forKey: "globalidd")
        DataUserDefault.set(7, forKey: "Distance")
        DataUserDefault.set(LatVideo, forKey: "LatVideo")
        DataUserDefault.set(LongVideo, forKey: "LongVideo")
        LatVideo = DataUserDefault.array(forKey: "LatVideo") as! [Double]
        LongVideo = DataUserDefault.array(forKey: "LongVideo") as! [Double]
        
        videos(apikey: apikey, id: "0")
        //let marker = GMSMarker()
        //marker.tracksInfoWindowChanges = true
        //marker.icon = UIImage(named: "marker")
        //marker.position = CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
        //marker.title = "Cargando usuarios..."
        //marker.snippet = "Cargando usuarios..."
        //marker.map = mapContainer
        
        camera = GMSCameraPosition.camera(withLatitude: 19.419444, longitude: -99.145556, zoom: 8.0)
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
        
        let navBackgroundImage:UIImage! = UIImage(named: "video_icon")
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
        mapContainer.clear()
        videos(apikey: apikey, id: userid)
    }
    
    func crearMarker() {
        //Para videos del usuario
        for _ in 0 ..< 4 {
            print("\n")
        }
        LatVideo.removeAll()
        LongVideo.removeAll()
        LatVideo.append(0.00000)
        LongVideo.append(0.00000)
        
        marker.tracksInfoWindowChanges = true
        //marker.icon = UIImage(named: "marker")
        //marker.icon = GMSMarker.markerImage(with: .blue)
        var lat : Double
        var long : Double
        let IndiceUsuario : Int = DataUserDefault.integer(forKey: "IndiceUsuario") - 1
        //print("Existen: \(usuarios.count) usuarios")
        //print("Eres el usuario: \(IndiceUsuario)")
        //print("Numero de videos de tu usuario: \(usuarios[IndiceUsuario].videoinfo.count)")
        
        for nVideo in 0 ..< usuarios[IndiceUsuario].videoinfo.count {
            print("Video \(nVideo)")
            let result = usuarios[IndiceUsuario].videoinfo[nVideo] as [String:Any]
            lat = Double(result["lat"] as! String)!
            long = Double(result["long"] as! String)!

            for nCoord in 0 ..< LatVideo.count {
                let Punto1 = CLLocation(latitude: lat , longitude: long)
                let Punto2 = CLLocation(latitude: LatVideo[nCoord] , longitude: LongVideo[nCoord]) //Almacenado
                print("Lat: \(LatVideo[nCoord]), Long: \(LongVideo[nCoord]) vs Lat: \(lat), Long: \(long)")
                let distancia = Punto1.distance(from: Punto2)
                print("Distancia: \(distancia)")
                if (distancia>=(UserDefaults.standard.double(forKey: "Distance"))) {
                    print("Fuera de rango\n")
                    LatVideo = DataUserDefault.array(forKey: "LatVideo") as! [Double]
                    LongVideo = DataUserDefault.array(forKey: "LongVideo") as! [Double]
                    LatVideo.append(lat)
                    LongVideo.append(long)
                    DataUserDefault.set(LatVideo, forKey: "LatVideo")
                    DataUserDefault.set(LongVideo, forKey: "LongVideo")
                } else {
                    print("Dentro del rango\n")
                }
            }
            /*
            //print("Latitud: \(lat), Longitud: \(long)")
            LatVideo = DataUserDefault.array(forKey: "LatVideo") as! [Double]
            LongVideo = DataUserDefault.array(forKey: "LongVideo") as! [Double]
            //print("Contienes \(LatVideo.count) ubicaciones")
            if(LatVideo.count > 0) {
                print("2. Resto de videos")
                print("Ubicacion: \(LatVideo.count)")
                for nCoord in 0 ... LatVideo.count {
                    let Punto1 = CLLocation(latitude: lat , longitude: long)
                    let Punto2 = CLLocation(latitude: LatVideo[nCoord] , longitude: LongVideo[nCoord]) //Almacenado
                    print("Lat: \(LatVideo[nCoord]), Long: \(LongVideo[nCoord]) vs Lat: \(lat), Long: \(long)")
                    let distancia = Punto1.distance(from: Punto2)
                    print("Distancia: \(distancia)")
                    if (distancia>=UserDefaults.standard.double(forKey: "Distance")) {
                        print("Fuera de rango\n")
                        LatVideo = DataUserDefault.array(forKey: "LatVideo") as! [Double]
                        LongVideo = DataUserDefault.array(forKey: "LongVideo") as! [Double]
                        LatVideo.append(lat)
                        LongVideo.append(long)
                        DataUserDefault.set(LatVideo, forKey: "LatVideo")
                        DataUserDefault.set(LongVideo, forKey: "LongVideo")
                    } else {
                        print("Dentro del rango\n")
                    }
                }
            } else {
                print("1. Primer video propio\n")
                LatVideo.append(lat)
                LongVideo.append(long)
                print("1. Add Latitud: \(lat), Longitud: \(long)")
                DataUserDefault.set(LatVideo, forKey: "LatVideo")
                DataUserDefault.set(LongVideo, forKey: "LongVideo")
            }*/
        }
        LatVideo = DataUserDefault.array(forKey: "LatVideo") as! [Double]
        LongVideo = DataUserDefault.array(forKey: "LongVideo") as! [Double]
        print("Contienes \(LatVideo.count) videos en el mapa")
        for nCoord in 0 ..< LatVideo.count {
            marker.position = CLLocationCoordinate2D(latitude: LatVideo[nCoord] , longitude: LongVideo[nCoord])
            marker.icon = UIImage(named: "marker")
            //marker.title = "Cargando usuarios..."
            marker.snippet = "Cargando usuarios..."
            marker.map = mapContainer
            let circulo = CLLocationCoordinate2D(latitude: LatVideo[nCoord], longitude: LongVideo[nCoord])
            let radio = GMSCircle(position: circulo, radius: 3.5)
            radio.map = mapContainer
        }
    }
    
    /*
    
                let usuarioString : String = String(useridd)
                if (usuario == usuarioString) {
                    marker.icon = GMSMarker.markerImage(with: .blue)
                } else {
                    marker.icon = GMSMarker.markerImage(with: .brown)
                }
                
                if (arrayAlreadyExist(dataKey: "LatLong")){
                    //Ya existen videos en el mapa
                    LatLong = DataUserDefault.array(forKey: "LatLong") as! [Double]
                    if ()
                } else {
            
            
        }
        
        
        print("Usuarios recibidos: \(usuarios.count)")
        for i in 0 ..< usuarios.count {
            print("Numero de videos: \(usuarios[i].videoinfo.count)")
            for c in 0 ..< usuarios[i].videoinfo.count {
                
                let marker = GMSMarker()
                marker.tracksInfoWindowChanges = true
                
                let result = usuarios[i].videoinfo[c] as [String:Any]
                if let lat = result["lat"] as? String, let long = result["long"] as? String, let usuario = result["user_id"] as? String {
                    
                    let usuarioString : String = String(useridd)
                    if (usuario == usuarioString) {
                        marker.icon = GMSMarker.markerImage(with: .blue)
                    } else {
                        marker.icon = GMSMarker.markerImage(with: .brown)
                    }
                    
                    if (arrayAlreadyExist(dataKey: "LatLong")){
                        //Ya existen videos en el mapa
                        LatLong = DataUserDefault.array(forKey: "LatLong") as! [Double]
                        if ()
                    } else {
                        //Si no existe LatVideo, es el primer marker y lo agrega al mapa sin recorrer diccionario
                        LatLong[0] = usuarios[i].videoinfo[c]["lat"] as! Double
                        LatLong[1] = usuarios[i].videoinfo[c]["long"] as! Double
                        marker.position = CLLocationCoordinate2D(latitude: LatLong[0] , longitude: LatLong[1] )
                        marker.title = "Cargando usuarios..."
                        marker.icon = GMSMarker.markerImage(with: .blue)
                        //var LatDouble = [Double]()
                        //var LongDouble = [Double]()
                        //LatDouble.append(LatLong[0] as! Double)
                        //LongDouble.append(LatLong[1] as! Double)
                        //DataUserDefault.set(LatDouble, forKey: "LatVideo")
                        //DataUserDefault.set(LongDouble, forKey: "LongVideo")
                        DataUserDefault.set(LatLong, forKey: "LatLong")
                    }
                    marker.map = mapContainer
                    
                    //marker.position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
                    //marker.snippet = "Videos de \(usuarios[i].nombre)"
                    //marker.snippet = "Videos"
                    
                    
                    marker.map = mapContainer
                    
                    print("ID Usuario: \(usuarios[i].idusuario), URL Video: \(usuarios[i].videoinfo[c]["url"] as! String)")
                    print("Latitud: \(usuarios[i].videoinfo[c]["lat"] as! String), Longitud: \(usuarios[i].videoinfo[c]["long"] as! String)")
                    
     
                }
            }
        }
    }
    
    func DistanciaGuardarMarker() {
        
        
        var ponerMarker: Bool = false
        let marker = GMSMarker()
        
        if (arrayAlreadyExist(dataKey: "LatVideo")){
            var LatVideo = DataUserDefault.array(forKey: "LatVideo") ?? [Double]()
            var LongVideo = DataUserDefault.array(forKey: "LongVideo") ?? [Double]()
            for var c in 0..<LatVideo.count {
                let Punto1 = CLLocation(latitude: LatLong[0] , longitude: LatLong[1] )
                let Punto2 = CLLocation(latitude: LatVideo[c] as! Double, longitude: LongVideo[c] as! Double)
                let distancia = Punto1.distance(from: Punto2)
                /////////////Verifica cercania de otros markers///////////////
                if (distancia<=UserDefaults.standard.double(forKey: "Distance")) {
                    ponerMarker = false //Indicador para poner marker en mapa
                    c=9999  //Existe algun video dentro del rango, sale del ciclo
                } else {
                    //Termino el recorrido sin ninguna coincidencia
                    //print("Distancia fuera del rango")
                    ponerMarker = true
                }
                //print("Distancia = ", distancia, " metros")
                /////////////Verifica cercania de otros markers///////////////
            }
            if (ponerMarker){
                marker.position = CLLocationCoordinate2D(latitude: LatLong[0] , longitude: LatLong[1] )
                marker.title = "Bani Azarael"
                //marker.snippet = "Videos de \(usuarios[i].nombre"
                marker.icon = GMSMarker.markerImage(with: .blue)
                marker.map = mapContainer
                LatVideo.append(LatLong[0] )
                LongVideo.append(LatLong[1] )
                DataUserDefault.set(LatVideo, forKey: "LatVideo")
                DataUserDefault.set(LongVideo, forKey: "LongVideo")
            }
        } else {
            //Si no existe LatVideo, es el primer marker y lo agrega al mapa sin recorrer diccionario
        }
    }
 */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error obteniendo ubicacion: \(error)")
    }
 
    func mostrarRuta(inicio: CLLocation, destino: CLLocation) {
        let origin = "\(inicio.coordinate.latitude),\(inicio.coordinate.longitude)"
        let destination = "\(destino.coordinate.latitude),\(destino.coordinate.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
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
    //Funcion crear markers termina
    
    ///// CONEXION POST URL CON API OBTENER VIDEOS
    func videos(apikey: String, id: String) {
        //let parameterString = "apikey=\(apikey)&id=\(id)" -> Pasamos 0 para que devuelva todos los videos y obtenemos nuestro indice
        let parameterString = "apikey=\(apikey)&id=0"
        let strUrl = "http://videoshare.devworms.com/api/videos"
        print("Pasamos los parametros: \(parameterString)")
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
                                if let nombre = user["name"] as? String, let videos = user["videos"] as? [[String:Any]], let idd = user["id"] as? Int{
                                    if (idd==self.useridd){
                                        self.DataUserDefault.set(contador, forKey: "IndiceUsuario")
                                        //print("Tu eres el IndiceUsuario: \(contador)")
                                    }
                                    contador+=1
                                    //print("Usuario: \(idd), Nombre: \(nombre)")
                                    usuario.nombre = nombre
                                    usuario.idusuario = "\(idd)"
                                    for video in videos {
                                        usuario.videoinfo.append(video)
                                    }
                                }
                                self.usuarios.append(usuario)
                                usuariosg = self.usuarios
                            }
                        }
                        self.crearMarker()
                    }
                }
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
        let boundary = generateBoundary()
        guard let url = URL(string: "http://videoshare.devworms.com/api/video") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Client-ID f65203f7020dddc", forHTTPHeaderField: "Authorization")
        
        let dataBody = createDataBody(withParameters: parameters, media: path , boundary: boundary)
        request.httpBody = dataBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print("Respuesta: \(response)")
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Respuesta JSON: \(json)")
                } catch {
                    print("Error formando JSON: \(error)")
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
    ////TERMINA SUBIR VIDEO A LA API
    
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
        print(marker.snippet!, "Latitud: ", marker.position.latitude, " Longitud: ", marker.position.longitude)
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
        print("InfoWindow Cerrado, Titulo: ", marker.snippet!, "Latitud: ", marker.position.latitude, " Longitud: ", marker.position.longitude)
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("InfoWindow Seleccionado, Titulo: ", marker.snippet!, "Latitud: ", marker.position.latitude, " Longitud: ", marker.position.longitude)
        DataUserDefault.set(marker.position.latitude, forKey: "LatSelected")
        DataUserDefault.set(marker.position.longitude, forKey: "LongSelected")
        showModalUsuarios()
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        print("InfoWindow fue mantenido presionado")
        let ubicacionInicio = CLLocation(latitude: mlatitud, longitude: mlongitud)
        let ubicacionDestino = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
        mapContainer.clear()
        videos(apikey: apikey, id: userid)
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
        let LatSelected : Double = UserDefaults.standard.double(forKey: "LatSelected")
        let LongSelected : Double = UserDefaults.standard.double(forKey: "LongSelected")
        for i in 0..<usuariosg.count{
            for h in 0..<usuariosg[i].videoinfo.count {
                let LatCurrent : Double = Double(usuariosg[i].videoinfo[h]["lat"] as! String)!
                let LongCurrent : Double = Double(usuariosg[i].videoinfo[h]["long"] as! String)!
                let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
                let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
                let distancia = Punto1.distance(from: Punto2)
                if(distancia<=UserDefaults.standard.double(forKey: "Distance")){
                    if (!usernames.contains(usuariosg[i].nombre)) {
                        usernames.append(usuariosg[i].nombre)
                    }
                }
            }
        }
    }
    
    func obtenerNumVideos() -> Int {
        var numVideos : Int = 0
        let LatSelected : Double = UserDefaults.standard.double(forKey: "LatSelected")
        let LongSelected : Double = UserDefaults.standard.double(forKey: "LongSelected")
        for nombre in usernames {
            for i in 0..<usuariosg.count {
                if (usuariosg[i].nombre.contains(nombre)){
                    for h in 0..<usuariosg[i].videoinfo.count {
                        let LatCurrent : Double = Double(usuariosg[i].videoinfo[h]["lat"] as! String)!
                        let LongCurrent : Double = Double(usuariosg[i].videoinfo[h]["long"] as! String)!
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

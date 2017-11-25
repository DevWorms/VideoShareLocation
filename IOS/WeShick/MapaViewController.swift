//
//  MapaViewController.swift
//  WeShick
//
//  Created by Bani Azarael Mejia Flores on 31/10/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
import MobileCoreServices
import CoreLocation
import SwiftyJSON
import Alamofire
import Foundation
import AVKit
import SystemConfiguration

var videoprogresog: [VideoProgreso] = []
var username = [String]()
var userid = [String]()
let DataUserDefault = UserDefaults.standard

var LatUser = [String]()
var LongUser = [String]()
var NombreUser = [String]()
var URLImgUser = [String]()
var URLVideo = [String]()
var URLVideoImg = [String]()
var IdUser = [Int]()

class MapaViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var progressBar: UIProgressView!
    typealias Parameters = [String: String]
    var videoprogreso: [VideoProgreso] = []
    var mlatitud: Double = -13.965953
    var mlongitud: Double = -138.157899
    
    var mPosLat: Double = -13.965953
    var mPosLong: Double = -138.157899
    var locationManager = CLLocationManager()
    var camera: GMSCameraPosition!
    var apikey : String! = ""
    var userid : Int = 0
    var LatVideo = [String]()
    var LongVideo = [String]()
    var TengoVideo = [Int]()
    
    @IBOutlet weak var imagePreview: UIImageView!
    
    @IBOutlet weak var mapContainer: GMSMapView!
    var usernames = [String]()
    var idUsers = [Int]()   //Arreglo donde se guardan los ID de los usuarios
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (dataAlreadyExist(dataKey: "loginEnd")){
            let loginReceived:String = UserDefaults.standard.string(forKey: "loginEnd")!
            if (loginReceived == "Si") {
                apikey = DataUserDefault.string(forKey: "globalkey")
                userid = DataUserDefault.integer(forKey: "globalid")
                //10206265586238734 FB Token Juan Ibarra
                //apikey = "$2y$10$X3H4hkbXWhb2ZD0AbbbyO.1Mm0CFGj5Bxn8gOOpbs/nzCLyu7ry5y"
                //Bani $2y$10$YkCM/lM6Ro2fkO2NtKBnXeQ7kNXoylUKt2aVPXF9t/rC6cpNIAEn6
                //userid = 10
                //Bani 8
                DataUserDefault.set(16, forKey: "Distance")
                DataUserDefault.set(LatVideo, forKey: "LatVideo")
                DataUserDefault.set(LongVideo, forKey: "LongVideo")
                LatVideo = DataUserDefault.array(forKey: "LatVideo") as! [String]
                LongVideo = DataUserDefault.array(forKey: "LongVideo") as! [String]
                
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
                
                let refresh:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(MapaViewController.reloadMapData))
                
                let navBackgroundImage:UIImage! = UIImage(named: "barra1")
                let nav = self.navigationController?.navigationBar
                nav?.contentMode = .scaleAspectFit
                nav?.tintColor = UIColor.darkText
                nav!.setBackgroundImage(navBackgroundImage, for:.default)
                
                self.navigationItem.setLeftBarButton(refresh, animated: true)
                RightBarButtonItem()
                
                let when = DispatchTime.now() + 2 // Delay para que obtenga la ubicacion
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.reloadMapData()
                }
            } else if (loginReceived == "No") {
                mandarLogin()
            }
        } else {
            mandarLogin()
        }
    }
    /*
     ================================================================================================
     MenuHamburguer para Cerrar sesion y terminos y condiciones
     ================================================================================================
     */
    func RightBarButtonItem() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapaViewController.menu(sender:)))
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        customView.addGestureRecognizer(tapRecognizer)
        let imageView = UIImageView(image: #imageLiteral(resourceName: "icon_menu"))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = customView.bounds
        customView.addSubview(imageView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    /*
     ================================================================================================
     Manda a menu de cerrar sesion y terminos y condiciones
     ================================================================================================
     */
    @objc func menu(sender:UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MenuViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /*
     ================================================================================================
     Recarga videos
     ================================================================================================
     */
    @objc func reloadMapData(){
        if(isInternetAvailable()) {
            mapContainer.clear()
            videos(apikey: apikey, id: String(userid), lat: String(self.mPosLat), long: String(self.mPosLong))
        } else {
            showNoInternetConnection()
        }
    }
    /*
     ================================================================================================
     Coloca las ubicaciones obtenidas de videos en Marker del mapa
     ================================================================================================
     */
    func ColocarMarker(){
        var cont = 0
        for _ in LatVideo {
            let marker = GMSMarker()
            marker.tracksInfoWindowChanges = true
            //print("[\(cont)] = TengoVideo: \(TengoVideo[cont])")
            //print("[\(cont)] = Lat: \(LatVideo[cont])")
            //print("[\(cont)] = Long: \(LongVideo[cont])")
            
            let lat = Double(LatVideo[cont])!
            let long = Double(LongVideo[cont])!
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            marker.title = "WeShick"
            marker.snippet = "Videos: 0"
            if(TengoVideo[cont] == 1){ //1 = SI hay videos del usuario, 0 no hay videos del usuario
                marker.icon = UIImage(named: "marker1")
            } else {
                marker.icon = UIImage(named: "marker2")
            }
            //let circulo = CLLocationCoordinate2D(latitude: lat, longitude: long)
            //let radio = GMSCircle(position: circulo, radius: (UserDefaults.standard.double(forKey: "Distance")))
            //radio.map = mapContainer
            marker.map = mapContainer
            cont+=1
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error obteniendo ubicacion: \(error)")
    }
    /*
     ================================================================================================
     Obtiene las trazas que pintara y las coloca en el mapa
     ================================================================================================
     */
    func mostrarRuta(inicio: CLLocation, destino: CLLocation) {
        let origin = "\(inicio.coordinate.latitude),\(inicio.coordinate.longitude)"
        let destination = "\(destino.coordinate.latitude),\(destino.coordinate.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking"
        reloadMapData()
        Alamofire.request(url).responseJSON { response in
            let json = try? JSON(data: response.data!)
            let routes = json!["routes"].arrayValue
            for route in routes {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 3
                polyline.strokeColor = UIColor.blue
                polyline.map = self.mapContainer
                //try self.Context!.save()
            }
        }
    }
    /*
     ================================================================================================
     Consulta nuevos videos en la API
     ================================================================================================
     */
    func videos(apikey: String, id: String, lat: String, long: String) {
        let parameterString = "apikey=\(apikey)&id=\(userid)&lat=\(lat)&long=\(long)"
        //print("Parametros videos: \(parameterString)")
        let strUrl = "https://weshick.com/api/videos"
        if let httpBody = parameterString.data(using: String.Encoding.utf8) {
            var urlRequest = URLRequest(url: URL(string: strUrl)!)
            urlRequest.httpMethod = "POST"
            URLSession.shared.uploadTask(with: urlRequest, from: httpBody, completionHandler: parseJsonLogin).resume()
        } else {
            print("Error de codificación de caracteres.")
        }
    }
    /*
     ================================================================================================
     Obtener videos de la API
     ================================================================================================
     */
    func parseJsonLogin(data: Data?, urlResponse: URLResponse?, error: Error?) {
        if error != nil {
            print("Error al entrar Parse de Videos: \(error!)")
        } else if urlResponse != nil {
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                if let jsonResult = json as? [String: Any] {
                    if let videos = jsonResult["videos"] as?  [[String: Any]] {
                        LatVideo.removeAll()
                        LongVideo.removeAll()
                        TengoVideo.removeAll()
                        
                        LatUser.removeAll()
                        LongUser.removeAll()
                        NombreUser.removeAll()
                        URLImgUser.removeAll()
                        IdUser.removeAll()
                        URLVideo.removeAll()
                        URLVideoImg.removeAll()
                        
                        var contador = 0
                        
                        for video in videos {
                            let url_video = video["url"]!
                            let url_thumbnail = video["url_thumbnail"]!
                            let lat = video["lat"]!
                            let long = video["long"]!
                            
                            LatVideo.append(lat as! String)
                            LongVideo.append(long as! String)
                            
                            LatUser.append(lat as! String)
                            LongUser.append(long as! String)
                            URLVideo.append(url_video as! String)
                            URLVideoImg.append(url_thumbnail as! String)
                            
                            //print("\n\n***********Principal***********")
                            //print("Video: \(url_video)")
                            //print("Thumbnail: \(url_thumbnail)")
                            //print("Lat: \(lat)")
                            //print("Long: \(long)")
                            if let usuario = video["usuario"] as? [String:Any] {   //Usuario del video principal
                                //print("Usuario:")
                                let id = usuario["id"]!
                                let username = usuario["name"]!
                                let url_img = usuario["url_img"]!
                                //print("\tID: \(id)")
                                //print("\tNombre: \(username)")
                                //print("\tFoto: \(url_img)")
                                NombreUser.append(username as! String)
                                IdUser.append(id as! Int)
                                URLImgUser.append(url_img as! String)
                            }
                            //print("\n\t***********Videos cercanos***********")
                            for videosCercanos in video["videosCercanos"] as! [[String:Any]] {
                                let lat = videosCercanos["lat"]!
                                let long = videosCercanos["long"]!
                                let url_video = videosCercanos["url"]!
                                let url_thumbnail = videosCercanos["url_thumbnail"]!
                                
                                LatUser.append(lat as! String)
                                LongUser.append(long as! String)
                                URLVideo.append(url_video as! String)
                                URLVideoImg.append(url_thumbnail as! String)
                                
                                //print("\t\tLat: \(lat), Long: \(long)")
                                //let circulo = CLLocationCoordinate2D(latitude: Double(lat as! String)!, longitude: Double(long as! String)!)
                                //let radio = GMSCircle(position: circulo, radius: 0.3)
                                //radio.map = mapContainer
                                //print("\t\tURLVideo: \(url_video), URLThumb: \(url_thumbnail)")
                                if let usuarioCercano = videosCercanos["usuario"] as? [String:Any] {
                                    let id = usuarioCercano["id"]!
                                    let username = usuarioCercano["name"]!
                                    let url_img = usuarioCercano["url_img"]!
                                    //print("\t\t\tUsuario cercano ID: \(id)")
                                    //print("\t\t\tUsuario cercano Nombre: \(username)")
                                    //print("\t\t\tUsuario cercano Foto: \(url_img)\n")
                                    NombreUser.append(username as! String)
                                    IdUser.append(id as! Int)
                                    URLImgUser.append(url_img as! String)
                                }
                            }
                            if let usuarios = video["users"] as? [[String: Any]] {
                                var yo = 0
                                for usuario in usuarios {
                                    let id:Int = usuario["id"]! as! Int
                                    let username = usuario["name"]!
                                    let url_img = usuario["url_img"]!
                                    print("\tUsuario ID: \(id)")
                                    print("\tUsuario Nombre: \(username)")
                                    print("\tUsuario Foto: \(url_img)")
                                    if(id == userid){
                                        yo=1
                                    }
                                }
                                if (yo==1){
                                    TengoVideo.append(1)
                                } else {
                                    TengoVideo.append(0)
                                }
                                contador+=1
                            }
                            ColocarMarker()
                        }
                    }
                }
            }
        }
    }
    /*
     ================================================================================================
     Subir video a API
     ================================================================================================
     */
    func SubirVideo(apikey: String, id : String, lat: String, long: String, videoPath: String, thumbnailPath: String) {
        let parameters = ["apikey": apikey,
                          "id": id,
                          "lat": lat,
                          "long": long
        ]
        self.videoprogreso = [VideoProgreso]()
        let video = VideoProgreso()
        video.id = id
        video.lat = lat
        video.long = long
        video.path = videoPath
        video.estado = "Subiendo"
        videoprogresog.append(video)
        //videoprogresog = self.videoprogreso
        let boundary = generateBoundary()
        guard let url = URL(string: "https://weshick.com/api/video") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Client-ID f65203f7020dddc", forHTTPHeaderField: "Authorization")
        
        let dataBody = createDataBody(withParameters: parameters, videoPath: videoPath, thumbnailPath: thumbnailPath  , boundary: boundary)
        request.httpBody = dataBody
        let session = URLSession.shared
        session.uploadTask(with: request, from: dataBody) { (data, response, error) in
            if let response = response {
                print("Respuesta: \(response)")
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Respuesta JSON: \(json)")
                    self.reloadMapData() //Recarga al subir un video para ver los cambios
                    let n = videoprogresog.count
                    let vid = n - 1
                    videoprogresog[vid].estado = "Completo"
                    //videoprogresog = self.videoprogreso
                } catch {
                    print("Error formando JSON: \(error)")
                    let vid = videoprogresog.count
                    let n = vid - 1
                    videoprogresog[n].estado = "Error"
                    let alerta = UIAlertController(title: "Error de conexion a intenet", message: "Revisa tu conexion", preferredStyle: UIAlertControllerStyle.alert)
                    alerta.addAction(UIAlertAction(title: "Entendido", style: UIAlertActionStyle.default, handler: { alertAction in
                        alerta.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alerta, animated: true, completion: nil)
                }
            }
            }.resume()
        
        
    }
    /*
     ================================================================================================
     Generar cuerpo de POST para subir video
     ================================================================================================
     */
    func createDataBody(withParameters params: Parameters?, videoPath: String?, thumbnailPath: String?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        if let media = videoPath {
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
        if let media = thumbnailPath {
            do{
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=thumbnail; filename=\"\(media)\"\(lineBreak)")
                body.append("Content-Type: \("image/jpeg" + lineBreak + lineBreak)")
                try body.append(NSData(contentsOfFile: media) as Data)
                body.append(lineBreak)
            }catch{
                print("Error Media:\(error)")
            }
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    /*
     ================================================================================================
     Obtiene localizacion actual del usuario en tiempo real
     ================================================================================================
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        mlatitud = (location?.coordinate.latitude)!
        mlongitud = (location?.coordinate.longitude)!
        //self.locationManager.stopUpdatingLocation()
    }
    /*
     ================================================================================================
     Control de apertura y presencia de camara
     ================================================================================================
     */
    @IBAction func Grabar(_ sender: Any) {
        let res : Bool = startCameraFromViewController(self, withDelegate: self)
        if (res){
            print("Inciando camara...")
        } else{
            print("Error al iniciar camara...")
        }
    }
    /*
     ================================================================================================
     Parametros de video
     ================================================================================================
     */
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
    /*
     ================================================================================================
     Estado actual del video
     ================================================================================================
     */
    @objc func video(_ videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
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
    /*
     ================================================================================================
     Obtener nombre de los usuarios en un Marker
     ================================================================================================
     */
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
    /*
     ================================================================================================
     Mostrar modal de usuarios en el mapa
     ================================================================================================
     */
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        //print("InfoWindow Seleccionado, Titulo: ", marker.snippet!, "Latitud: ", marker.position.latitude, " Longitud: ", marker.position.longitude)
        DataUserDefault.set(marker.position.latitude, forKey: "LatSelected")
        DataUserDefault.set(marker.position.longitude, forKey: "LongSelected")
        showModalUsuarios()
    }
    /*
     ================================================================================================
     Mostrar ruta para llegar de la ubicacion actual hacia el Marker seleccionado
     ================================================================================================
     */
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        //print("InfoWindow fue mantenido presionado")
        let ubicacionInicio = CLLocation(latitude: mlatitud, longitude: mlongitud)
        let ubicacionDestino = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
        //reloadMapData()
        self.mostrarRuta(inicio: ubicacionInicio, destino: ubicacionDestino)
    }
    /*
     ================================================================================================
     TEST: Saber que posicion se le manda a el consumo de servicios
     ================================================================================================
     */
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //Posicion de la camara al establecer la camara en un punto del mapa
        mPosLat = position.target.latitude
        mPosLong = position.target.longitude
        //print("Mandamos \(mlatitud), \(mlongitud)")
        //reloadMapData()
    }
    /*
     ================================================================================================
     Manda a modal de Usuarios
     ================================================================================================
     */
    func showModalUsuarios() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserVC")
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    /*
     ================================================================================================
     Obtiene el numero de usuarios en un Marker
     ================================================================================================
     */
    func obtenerUsuariosMarker() {
        usernames = [String]()
        idUsers = [Int]()
        let LatSelected : Double = UserDefaults.standard.double(forKey: "LatSelected")
        let LongSelected : Double = UserDefaults.standard.double(forKey: "LongSelected")
        
        for i in 0..<LatUser.count {
            let LatCurrent : Double = Double(LatUser[i])!
            let LongCurrent : Double = Double(LongUser[i])!
            let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
            let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
            let distancia = Punto1.distance(from: Punto2)
            if(distancia<=UserDefaults.standard.double(forKey: "Distance")){
                if (!idUsers.contains(IdUser[i])) {
                    usernames.append(NombreUser[i])
                    print("En el mapa -> ID Usuario: \(IdUser[i]), Nombre: \(NombreUser[i])")
                    idUsers.append(IdUser[i])
                }
            }
        }
    }
    /*
     ================================================================================================
     Comprobar la conexion a internet del usuario
     ================================================================================================
     */
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    /*
     ================================================================================================
     Obtener Num de videos en un Marker
     ================================================================================================
     */
    func obtenerNumVideos() -> Int {
        var numVideos : Int = 0
        let LatSelected : Double = UserDefaults.standard.double(forKey: "LatSelected")
        let LongSelected : Double = UserDefaults.standard.double(forKey: "LongSelected")
        for id in idUsers {
            for i in 0..<LatUser.count {
                if (IdUser[i] == id) {
                    let LatCurrent : Double = Double(LatUser[i])!
                    let LongCurrent : Double = Double(LongUser[i])!
                    let Punto1 = CLLocation(latitude: LatSelected, longitude: LongSelected)
                    let Punto2 = CLLocation(latitude: LatCurrent, longitude: LongCurrent)
                    let distancia = Punto1.distance(from: Punto2)
                    if(distancia<=UserDefaults.standard.double(forKey: "Distance")){
                        numVideos += 1
                    }
                }
            }
        }
        return numVideos
    }
    /*
     ================================================================================================
     Mandar a Login para cuando el usuario no inicie sesion
     ================================================================================================
     */
    func mandarLogin() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
    }
    /*
     ================================================================================================
     Pantalla de que no hay conexion a internet disponible
     ================================================================================================
     */
    func showNoInternetConnection(){
        let alerta = UIAlertController(title: "Error de conectividad", message: "No hay una conexion estable a internet, intentelo en unos momentos", preferredStyle: UIAlertControllerStyle.alert)
        alerta.addAction(UIAlertAction(title: "Entendido", style: UIAlertActionStyle.default, handler: { alertAction in
            alerta.dismiss(animated: true, completion: nil)
        }))
        self.present(alerta, animated: true, completion: nil)
    }
    /*
     ================================================================================================
     Consulta si existe en UserDefault una llave
     ================================================================================================
     */
    func dataAlreadyExist(dataKey: String) -> Bool {
        return UserDefaults.standard.object(forKey: dataKey) != nil
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
                let thumbnailPath = self.GenerarPreview(PathVideo: sourcePath)
                self.SubirVideo(apikey: self.apikey, id: String(self.userid), lat: UploadLat , long: UploadLong, videoPath: sourcePath, thumbnailPath: thumbnailPath!)
                alerta.dismiss(animated: true, completion: nil)
            }))
            alerta.addAction(UIAlertAction(title: "Guardar en el telefono", style: UIAlertActionStyle.default, handler: { alertAction in
                self.moverVideo(destinationPath: sourcePath)
                alerta.dismiss(animated: true, completion: nil)
            }))
            self.present(alerta, animated: true, completion: nil)
        }
    }
    /*
     ================================================================================================
     Mueve video grabado a carpeta /Aplicacion/Documents/Nombre_del_video
     ================================================================================================
     */
    func moverVideo(destinationPath: String){
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(destinationPath) {
            UISaveVideoAtPathToSavedPhotosAlbum(destinationPath, self, #selector(MapaViewController.video(_: didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    /*
     ================================================================================================
     Consulta si existe en UserDefault una llave
     ================================================================================================
     */
    func arrayAlreadyExist(dataKey: String) -> Bool {
        return UserDefaults.standard.array(forKey: dataKey) != nil
    }
    /*
     ================================================================================================
     Genera preview de un video para subir a la API -> se guarda en /Aplicacion/Documents/Nombre_preview
     ================================================================================================
     */
    func GenerarPreview(PathVideo: String) -> String? {
        let vidURL = URL(fileURLWithPath:PathVideo as String)
        let asset = AVURLAsset(url: vidURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let timestamp = CMTime(seconds: 1, preferredTimescale: 7)
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            let image:UIImage = UIImage.init(cgImage: imageRef)
            if let data = UIImageJPEGRepresentation(image, 0.8) {
                let filename = getDocumentsDirectory().appendingPathComponent("Imagen.jpeg")
                try? data.write(to: filename)
                return filename.path
            } else {
                return "Error"
            }
        }
        catch let error as NSError {
            print("Error Preview, URL: \(PathVideo), Error: \(error)")
            return nil
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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

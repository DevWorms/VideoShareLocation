
import UIKit

class RegistroUsuarioViewController: UIViewController {
    
    @IBOutlet weak var fotoPerfilFB: UIImageView!
    @IBOutlet weak var et_nombre: UITextField!
    @IBOutlet weak var et_apellido: UITextField!
    @IBAction func actualizarDatos(_ sender: Any) {
        let nombre: String = et_nombre.text!
        let apellido: String = et_apellido.text!
        let guardarDatos = UserDefaults.standard
        guardarDatos.set(nombre, forKey: "nombre")
        guardarDatos.set(apellido, forKey: "apellido")
    }
    
    @IBAction func guardarRegistro(_ sender: Any) {
        let guardarDatos = UserDefaults.standard
        guardarDatos.set("Si", forKey: "dataUserUpdate")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let obtenerDatos = UserDefaults.standard
        let idFace : String = obtenerDatos.object(forKey: "idFace") as! String
        let nombre : String = obtenerDatos.object(forKey: "nombre") as! String
        let apellido : String = obtenerDatos.object(forKey: "apellido") as! String
        //let correo : String = obtenerDatos.object(forKey: "correo") as! String
        
        let facebookProfileUrl = NSURL(string: "https://graph.facebook.com/\(idFace)/picture?width=500")
        if let data = NSData(contentsOf: facebookProfileUrl! as URL) {
            fotoPerfilFB.image = UIImage(data: data as Data)
        }
        et_nombre.text = nombre
        et_apellido.text = apellido
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        et_nombre.resignFirstResponder()
        et_apellido.resignFirstResponder()
    }
    
    // Conexion con api
    
    func login(token:String, nombre:String) {
        
        let parameterString = "apikey=\(globalkey)&id=\(globalId)"
        
        print(parameterString)
        
        let strUrl = "http://videoshare.devworms.com/api/profile"
        
        if let httpBody = parameterString.data(using: String.Encoding.utf8) {
            var urlRequest = URLRequest(url: URL(string: strUrl)!)
            urlRequest.httpMethod = "POST"
            
            URLSession.shared.uploadTask(with: urlRequest, from: httpBody, completionHandler: parseJsonLogin).resume()
        } else {
            print("Error de codificación de caracteres.")
        }
    }
    
    //recoge apikey del JSon
    func parseJsonLogin(data: Data?, urlResponse: URLResponse?, error: Error?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                //print(json)
                if let jsonResult = json as? [String: Any] {
                    DispatchQueue.main.async {
                        
                        if let result = jsonResult["estado"]{
                            print(result as! String)
                        }
                        
                    }
                }
                
            } else {
                print("HTTP Status Code: 200")
                print("El JSON de respuesta es inválido.")
            }
            
        }
    }
}

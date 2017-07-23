import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit

var globalkey = ""
var globalId = ""


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var datos = [[String : Any]]()
    var dict : [String : AnyObject]!
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["public_profile", "email", "user_friends"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.center = view.center
        view.addSubview(loginButton)
        self.loginButton.delegate = self
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (result.token != nil) {
            print("¡Login completado!")
            if let accessToken = FBSDKAccessToken.current() {
                print("Token de usuario ", accessToken)
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, gender"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        self.dict = result as! [String : AnyObject]
                        self.setInterfaz(result: self.dict as NSDictionary)
                    }
                })
            }
        }
        if (result.isCancelled){
            print("¡Cancelo Login!")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){
        print("Usuario Logout")
        let guardarDatos = UserDefaults.standard
        guardarDatos.set(nil, forKey: "loginEnd")
    }
    
    func setInterfaz(result: NSDictionary){
        let idFace = result.value(forKey: "id") as! String
        let nombre = result.value(forKey: "first_name") as! String
        let apellido = result.value(forKey: "last_name") as! String
        let correo = result.value(forKey: "email") as! String
        let genero = result.value(forKey: "gender") as! String
        
        print("Id Facebook: ", idFace)
        print("Nombre: ", nombre)
        print("Apellido: ", apellido)
        print("Correo: ", correo)
        print("Genero: ", genero)
        
        let guardarDatos = UserDefaults.standard
        guardarDatos.set("Si", forKey: "loginEnd")
        guardarDatos.set(idFace, forKey: "idFace")
        guardarDatos.set(nombre, forKey: "nombre")
        guardarDatos.set(apellido, forKey: "apellido")
        guardarDatos.set(correo, forKey: "correo")
        guardarDatos.set(genero, forKey: "genero")
        print("¡Datos guardados!")
    
        
        //ejecuta conexion con api
    
        login(token:idFace, nombre:nombre)
        
        
        let siguienteViewController = storyBoard.instantiateViewController(withIdentifier: "RegistroUsuarioViewController")
        self.present(siguienteViewController, animated: true, completion: nil)
    }
    
    func dataAlreadyExist(userKey: String) -> Bool {
        return UserDefaults.standard.object(forKey: userKey) != nil
    }
    
    // Conexion con api
    
    func login(token:String, nombre:String) {
        
        let parameterString = "tokenfb=\(token)&name=\(nombre)"
        
        print(parameterString)
        
        let strUrl = "http://videoshare.devworms.com/api/login"
        
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
                            
                            if let result = jsonResult["user"] as? [String: Any]{
                                globalkey = result["apikey"] as! String
                                globalId = result["id"] as! String
                                print(globalkey)
                                print(globalId)
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
    



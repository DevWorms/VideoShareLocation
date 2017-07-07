
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

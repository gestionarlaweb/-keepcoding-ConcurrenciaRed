//
//  AddTopicViewController.swift
//  CyR_DavidR_Proyecto
//
//  Created by David Rabassa Planas on 12/04/2020.
//  Copyright © 2020 David Rabassa. All rights reserved.
//

import UIKit

class AddTopicViewController: UIViewController {
   
    // Viene de Add @IBAction func addTopicButton
    var delegate: topicDelegate?
    
     @IBOutlet weak var my_textField: UITextField!
      
        override func viewDidLoad() {
            super.viewDidLoad()
            // Posicionar el cursor en el my_textField
            my_textField.becomeFirstResponder()
        }
        
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func click_Button(_ sender: Any) {
            // Mejor después crear extensión enviar Topic
                   crearTopic()
        }
         
        func crearTopic(){
            
            //guard let topicTitle = createTopicInput.text else { return }
            guard let my_url = URL(string: "https://mdiscourse.keepcoding.io/posts.json") else {return}
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration)
            
            var request = URLRequest(url: my_url)
            // POST - Enviar
            request.httpMethod = "POST" // CREATE
            request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-key")
            request.addValue("gestionarlaweb", forHTTPHeaderField: "Api-Username")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type") // Necesario también
            
            let body: [String: Any] = [
                
                "title": "\(String(my_textField.text!))",
                 "raw": "Aquí le paso un RAW estandar, por poner algo, sabes ?"
            ]
            // El Body
            // print(body)
            guard let dataBody = try? JSONSerialization.data(withJSONObject: body) else {return}
            request.httpBody = dataBody
            
            let dataTask = session.dataTask(with: request) { (_, response, error) in // _ porque no le mando el data
                
                if let response = response as? HTTPURLResponse{
                    // entre 400 y 500 son errores
                    DispatchQueue.main.async { [weak self] in
                        self?.showAlert(title: "Ok", message: "Código respuesta \(response.statusCode)")
                    }
                   // Código respuesta
                    print(response.statusCode)
                  }
                
                  if let error = error {
                    DispatchQueue.main.async { [weak self] in
                      self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                    return
                  }
                }
             dataTask.resume()
        }
        
        
        func showAlert(title: String, message: String){
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
        
        
        struct UpdateStatusResponse: Codable {
           let success: String
        }
    }

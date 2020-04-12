//
//  DetailUserVC.swift
//  CyR_DavidR_Proyecto
//
//  Created by David Rabassa Planas on 12/04/2020.
//  Copyright © 2020 David Rabassa. All rights reserved.
//

import UIKit

enum UserError: Error {
    case emptyData
    case malformedURL
}

class DetailUserVC: UIViewController {
    
    var userRes: UserResponse?
    var username: String?

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var updateStateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Mostramos el boton y namTextField en el Arranque
       self.updateStateButton.isHidden = true
        self.nameTextField.isHidden = true
    
        fetchUser { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.userRes = user
                self?.setupRes()
            case .failure(let error):
                print(error)
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func setupRes() {
        if let finalUser = userRes {
            idLabel.text = String(finalUser.user.id)
            nameLabel.text = finalUser.user.username
            nameLabel.text = finalUser.user.name ?? "Sin nombre definido" // Si no hay nombre muestrame el texto " "
            if finalUser.user.canEditName == true {
                nameTextField.isHidden = false
                nameLabel.isHidden = true
                updateStateButton.isHidden = false
                nameTextField.text = finalUser.user.name
            }
        }

    }
  
    @IBAction func dissmisButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickButton(_ sender: Any) {
        
        guard let nameField = nameTextField.text, let username = username, let updateNameURL = URL(string: "https://mdiscourse.keepcoding.io/users/\(username)") else {return}

        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)

        var request = URLRequest(url: updateNameURL)
        request.httpMethod = "PUT"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("gestionarlaweb", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
          "name": nameField
        ]
        guard let dataBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = dataBody

        let dataTask = session.dataTask(with: request) { (_, response, error) in
            
            if let response = response as? HTTPURLResponse {
                print(response.statusCode)
                if response.statusCode != 200 {
                    DispatchQueue.main.async { [weak self] in
                        self?.showAlert(title: "Error", message: "Error de red, status code: \(response.statusCode)")
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                    self?.showAlert(title: "Success", message: "Name register Ok :-)")

                    }
                }
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
    
    convenience init(withUsername username: String) {
        self.init(nibName: "DetailUserVC", bundle: nil)
        self.username = username
        self.title = "Detail User \(username)"
    }

    // Mostrar datos
    func fetchUser(completion: @escaping (Result<UserResponse, Error>) -> Void) {
        if let username = username {
            guard let userURL = URL(string: "https://mdiscourse.keepcoding.io/users/\(username).json") else {
                completion(.failure(UserError.malformedURL))
                return
            }
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration)

            var request = URLRequest(url: userURL)
            request.httpMethod = "GET"
            request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
            request.addValue("gestionarlaweb", forHTTPHeaderField: "Api-Username")
            
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(UserError.emptyData))
                    }
                    return
                }

                do {
                    let response = try JSONDecoder().decode(UserResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
                } catch(let error) {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}


struct UserResponse: Codable {
    let user: SingleUser
}

struct SingleUser: Codable {
    let id: Int
    let username: String
    let name: String?
    let canEditName: Bool
    
        enum CodingKeys: String, CodingKey {
            case id
            case username
            case name
            case canEditName = "can_edit_name"
        }
}

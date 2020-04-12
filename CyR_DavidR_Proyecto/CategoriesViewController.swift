//
//  CategoriesViewController.swift
//  CyR_DavidR_Proyecto
//
//  Created by David Rabassa Planas on 12/04/2020.
//  Copyright © 2020 David Rabassa. All rights reserved.
//

import UIKit

enum CategoriesError: Error {
    case malformedURL // Si la url esta mal
    case emptyData
}

class CategoriesViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var categoriesTableView: UITableView!
    
    var categories: [Category] = []
    
    // Suficiente con UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    // Suficiente con UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        categoriesTableView.dataSource = self
        // Celda creada por código al no haber .xib
        categoriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Por último la llamada
        fetchCategories { [weak self] (result) in
            switch result {
            case .success(let categories):
                self?.categories = categories
                self?.categoriesTableView.reloadData()
            case .failure(let error):
                self?.showErrorAlert(message: error.localizedDescription)
                // También si no quieres poner el showErrorAlert
                // le pones un
                print(error)
            }
        }
    }
    
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    //Muestra Request
        
        // conexión a la url
        func fetchCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
            guard let categoriesURL = URL(string: "https://mdiscourse.keepcoding.io/categories.json") else {
                completion(.failure(CategoriesError.malformedURL))
                return
                // https://mdiscourse.keepcoding.io/categories.json
                // https://mdiscourse.keepcoding.io/posts.json
            }

            // Crear la session
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration)

            // Crear la request
            var request = URLRequest(url: categoriesURL)
            request.httpMethod = "GET" // Obtener
            // Nos podemos validar de varias formas. En este ejemplo vamos ha hacerlo con un ApiKey y un nombre de usuario
            request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
            request.addValue("gestionarlaweb", forHTTPHeaderField: "Api-Username")
            
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    // Si error
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                // Si no hay dados
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(CategoriesError.emptyData))
                    }
                    return
                }
                // Si no hay error y hay datos
                do {
                    let response = try JSONDecoder().decode(CategoriesResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response.categoryList.categories))
                    }
                    // en caso de error en la carga de datos (corte de conexión por ejemplo)
                } catch(let error) {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }

            dataTask.resume()
        }

    }

    struct CategoriesResponse: Codable {
        let categoryList: CategoryList // "category_list"

        // Los booleanos hay que pasarlos a Strings
        enum CodingKeys: String, CodingKey {
            case categoryList = "category_list" // "category_list"
        }
    }


    struct CategoryList: Codable {
        // las variables tienen que ser igual que en el json url
        
        let canCreateCategory: Bool // "can_create_category": false,
        let canCreateTopic: Bool // "can_create_topic": false,
        var draft: Bool? //  "draft": null,        Para que no pete al compilar debo ponerle un optional ?
        let draftKey: String // "draft_key": "new_topic",
        let draftSequence: Int // "draft_sequence": null,
        let categories: [Category] // "categories": [

        // Los booleanos hay que pasarlos a Strings
        enum CodingKeys: String, CodingKey {
            case canCreateCategory = "can_create_category"
            case canCreateTopic = "can_create_topic"
            //case draft
            case draftKey = "draft_key"
            case draftSequence = "draft_sequence"
            case categories // Este también porque dentro del Array hay booleanos
        }
    }

    struct Category: Codable {
        let name: String
    }

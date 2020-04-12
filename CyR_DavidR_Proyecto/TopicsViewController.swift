//
//  TopicsViewController.swift
//  CyR_DavidR_Proyecto
//
//  Created by David Rabassa Planas on 12/04/2020.
//  Copyright © 2020 David Rabassa. All rights reserved.
//

import UIKit

protocol topicDelegate {
    func refreshView()
}

// latest_posts
enum LatestTopicsError: Error {
    case malformedURL // Si la url esta mal
    case emptyData
}

class TopicsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, topicDelegate {
    
    @IBOutlet weak var topicsTableView: UITableView!
    @IBOutlet weak var addTopic: UIButton!
    
        var topics: [Topic] = []
        
        // MARK: - UITableViewDelegate
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
           let topic = topics[indexPath.row]
            // withId : -> convenience
           let topicsDetailVC = DetailTopicViewController.init(withId: topic.id)
           topicsDetailVC.delegate = self
           let navigationController = UINavigationController(rootViewController: topicsDetailVC)
           navigationController.modalPresentationStyle = .fullScreen
           self.present(navigationController, animated: true, completion: nil)
           
           tableView.deselectRow(at: indexPath, animated: true)
       }
        
        // MARK: - UITableViewDatasource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return topics.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
             let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = topics[indexPath.row].title
           
                   return cell
        }
        
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            topicsTableView.dataSource = self
            topicsTableView.delegate = self
            
            topicsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            
            // Por último la llamada
            fetchTopics { [weak self] (result) in
                switch result {
                case .success(let let_topics):
                    self?.topics = let_topics
                    self?.topicsTableView.reloadData()
                case .failure(let error):
                    self?.showErrorAlert(message: error.localizedDescription)
                    // También si no quieres poner el showErrorAlert
                    // le pones un
                    print(error)
                }
            }
        }
        
    // CREAR TOPIC
    @IBAction func addTopicButton(_ sender: Any) {
        let newTopicVC = AddTopicViewController()
            let navigationController = UINavigationController(rootViewController: newTopicVC)
        
        //  Necesito del protocol TopicDelegate {
            navigationController.modalPresentationStyle = .fullScreen
            newTopicVC.delegate = self
        // En Controller destino
        // var delegate: TopicViewControllerDelegate?
            self.present(navigationController, animated: true, completion: nil)
    }
    
    func refreshView() {
        fetchTopics { [weak self] (result) in
            switch result {
            case .success(let latestTopics):
                self?.topics = latestTopics
                self?.topicsTableView.reloadData()
            case .failure(let error):
                print(error)
                self?.showErrorAlert(message: error.localizedDescription)
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
            func fetchTopics(completion: @escaping (Result<[Topic], Error>) -> Void) {
                guard let usersURL = URL(string: "https://mdiscourse.keepcoding.io/latest.json") else {
                    completion(.failure(LatestTopicsError.malformedURL))
                    return
                }

                // Crear la session
                let configuration = URLSessionConfiguration.default
                let session = URLSession(configuration: configuration)

                // Crear la request
                var request = URLRequest(url: usersURL)
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
                            completion(.failure(LatestTopicsError.emptyData))
                        }
                        return
                    }
                    // Si no hay error y hay datos
                    do {
                        let response = try JSONDecoder().decode(StructResultTopics.self, from: data)
                        DispatchQueue.main.async {
                            // ESTA LÍNEA ES LA QUE VALE LA PENA MIRARSELA UN BUEN RATO !
                            completion(.success(response.topicList.topics))
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

            

struct StructResultTopics: Codable {
        let topicList: TopicList
        enum CodingKeys: String, CodingKey {
            case topicList = "topic_list"
        }
    }


    struct TopicList: Codable {
        let topics: [Topic]
    }

    struct Topic: Codable {
        let id: Int
        let title: String

    }

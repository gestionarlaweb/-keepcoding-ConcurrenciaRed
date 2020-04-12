//
//  DetailTopicViewController.swift
//  CyR_DavidR_Proyecto
//
//  Created by David Rabassa Planas on 12/04/2020.
//  Copyright © 2020 David Rabassa. All rights reserved.
//

import UIKit

enum topicError: Error {
    case malformedURL
    case emptyData
}


class DetailTopicViewController: UIViewController {
    
    var topic: topicResponse?
    var id: Int?
    var delegate: topicDelegate?
    
    @IBOutlet weak var titleTopic: UILabel!
    @IBOutlet weak var idTopic: UILabel!
    @IBOutlet weak var numberPost: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeButton.isHidden = true
    
        fetchTopics { [weak self] (result) in
            switch result {
            case .success(let topic):
                self?.topic = topic
                DispatchQueue.main.async {
                    self?.userRes()
                }
            case .failure(let error):
                self?.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    
    func userRes() {
        titleTopic.text = topic?.title
        idTopic.text = String(topic!.id)
        numberPost.text = String(topic!.postsCount)
        if topic?.details.can_delete == true {
            self.removeButton.isHidden = false
        }
        
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    convenience init(withId id: Int) {
        self.init(nibName: "DetailTopicViewController", bundle: nil)
        self.id = id
        self.title = "Detail user ID: \(id)"
    }
    
    @IBAction func removeTopic(_ sender: Any) {
        if let id = id {
            guard let updateStatusURL = URL(string: "https://mdiscourse.keepcoding.io/t/\(id).json") else { return }

            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration)

            var request = URLRequest(url: updateStatusURL)
            request.httpMethod = "DELETE"
            request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
            request.addValue("gestionarlaweb", forHTTPHeaderField: "Api-Username")

            let dataTask = session.dataTask(with: request) { (data, response, error) in

                if let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.refreshView()
                    }
                    if response.statusCode != 200 {
                        DispatchQueue.main.async { [weak self] in
                            self?.showAlert(title: "Error", message: "Error de red, status code: \(response.statusCode)")
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
            
            // Llevame a la pantalla anterior
            self.dismiss(animated: true, completion: nil)
            
        }
    }
     
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func fetchTopics(completion: @escaping (Result<topicResponse, Error>) -> Void) {
        guard let singleTopicURL = URL(string: "https://mdiscourse.keepcoding.io/t/\(id ?? 0).json") else {
            completion(.failure(LatestTopicsError.malformedURL))
            return
        }

        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)

        var request = URLRequest(url: singleTopicURL)
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
                    completion(.failure(topicError.emptyData))
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(topicResponse.self, from: data)
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
    
    
    @IBAction func deleteTopic(_ sender: Any) {
        if let id = id {
            guard let updateStatusURL = URL(string: "https://mdiscourse.keepcoding.io/t/\(id).json") else { return }

            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration)

            var request = URLRequest(url: updateStatusURL)
            request.httpMethod = "DELETE"
            request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
            request.addValue("gestionarlaweb", forHTTPHeaderField: "Api-Username")

            let dataTask = session.dataTask(with: request) { (_, response, error) in

                if let response = response as? HTTPURLResponse {
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.refreshView()
                    }
                    if response.statusCode != 200 {
                        DispatchQueue.main.async { [weak self] in
                            self?.showAlert(title: "Error", message: "Error de red, status code: \(response.statusCode)")
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
            self.dismiss(animated: true, completion: nil)
            
        }
    }

    @IBAction func closeTopic(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}



struct topicResponse: Codable {
    let id: Int
    let title: String
    let postsCount: Int
    let details: Detail
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case postsCount = "posts_count"
        case details
    }
}


struct Detail: Codable {
    let can_delete: Bool?
}

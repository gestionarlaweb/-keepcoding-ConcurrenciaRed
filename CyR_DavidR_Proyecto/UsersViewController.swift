//
//  UsersViewController.swift
//  CyR_DavidR_Proyecto
//
//  Created by David Rabassa Planas on 12/04/2020.
//  Copyright © 2020 David Rabassa. All rights reserved.
//

import UIKit

enum UsersError: Error {
    case emptyData
}

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var usersTableView: UITableView!
    
    var users: [Users] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()

            usersTableView.dataSource = self
            usersTableView.delegate = self
            usersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

            fetch { [weak self] result in
                switch result {
                case .success(let users):
                    self?.users = users
                    self?.usersTableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }

        func fetch(completion: @escaping (Result<[Users], Error>) -> Void){
            
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration)
            guard let url = URL(string:"https://mdiscourse.keepcoding.io/directory_items.json?period=all") else { fatalError() }

            let task = session.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    if let data = data {
                        guard let UsersListResponse = try? JSONDecoder().decode(UsersListResponse.self, from: data) else {
                            completion(.failure(UsersError.emptyData))
                            return
                        }
                        completion(.success(UsersListResponse.directoryItems))
                    }
                }
            }
            
            task.resume()
        }
        
    // MARK: - UITableViewDatasource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return users.count
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = users[indexPath.row].user.username
            
            // Carga de imagen
            DispatchQueue.global(qos:.userInitiated).async { [weak self] in
                if let avatarTemplate = self?.users[indexPath.row].user.avatarTemplate {
                    
                    let sized = avatarTemplate.replacingOccurrences(of: "{size}", with: "150")
                    
                    let usersURL = "https://mdiscourse.keepcoding.io\(sized)"
                    
                    guard let url = URL(string: usersURL),
                    let data = try? Data(contentsOf: url) else {return}
                    let image = UIImage(data: data)
                    
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                        cell.setNeedsLayout()
                    }
                }
            }
            return cell
        }
        
        // MARK: UITableViewDelegate
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let singleUser = users[indexPath.row]
            let userDetailVC = DetailUserVC.init(withUsername: singleUser.user.username)
            let navigationController = UINavigationController(rootViewController: userDetailVC)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        }

}


struct UsersListResponse: Codable {
    let directoryItems: [Users]
    enum CodingKeys: String, CodingKey {
        case directoryItems = "directory_items"
    }
}

struct Users: Codable {
    let user: User
    
}

struct User: Codable {
    let username: String
    let name: String?
    let avatarTemplate: String
    
    enum CodingKeys: String, CodingKey {
        case avatarTemplate = "avatar_template"
        case username
        case name
    }
}

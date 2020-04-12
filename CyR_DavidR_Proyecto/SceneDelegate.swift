//
//  SceneDelegate.swift
//  CyR_DavidR_Proyecto
//
//  Created by David Rabassa Planas on 12/04/2020.
//  Copyright © 2020 David Rabassa. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        //guard let _ = (scene as? UIWindowScene) else { return }
        guard let windowScene = (scene as? UIWindowScene) else { return }
       
        let topicsVC  = TopicsViewController.init(nibName:  "TopicsViewController", bundle: nil)
        let categoriesVC = CategoriesViewController.init(nibName: "CategoriesViewController", bundle: nil)
        let usersVC    = UsersViewController.init(nibName: "UsersViewController", bundle: nil)
        
        let navTopicsVC = UINavigationController.init(rootViewController: topicsVC)
        let navCategoriesVC = UINavigationController.init(rootViewController: categoriesVC)
        let navUsersVC = UINavigationController.init(rootViewController: usersVC)

        // Setup Navigation Bar
        UINavigationBar.appearance().overrideUserInterfaceStyle = .dark
        UINavigationBar.appearance().tintColor = UIColor.init(red: 235/255.0, green: 172/255.0, blue: 38/255.0, alpha: 1.0)
        
        
        topicsVC.tabBarItem  = UITabBarItem.init(title: "Topics", image: UIImage.init(systemName: "square.and.pencil"), tag: 0)
        categoriesVC.tabBarItem   = UITabBarItem.init(title: "Categories", image: UIImage.init(systemName: "tag.fill"), tag: 1)
        usersVC.tabBarItem   = UITabBarItem.init(title: "Users", image: UIImage.init(systemName: "person.2.fill"), tag: 2)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers  = [navTopicsVC,navCategoriesVC,navUsersVC]
        
        
        tabBarController.tabBar.barStyle  = .default
        tabBarController.tabBar.isTranslucent  = true
        tabBarController.tabBar.tintColor = UIColor.init(red: 235/255.0, green: 172/255.0, blue: 38/255.0, alpha: 1.0)

        UINavigationBar.appearance().overrideUserInterfaceStyle = .dark
        UINavigationBar.appearance().tintColor = UIColor.gray
        
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
   /*
        let viewController = TopicsViewController()
               
               window = UIWindow(frame: windowScene.coordinateSpace.bounds)
               window?.windowScene = windowScene
               window?.rootViewController = viewController
               window?.makeKeyAndVisible()
 */
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


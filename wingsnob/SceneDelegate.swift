//
//  SceneDelegate.swift
//  wingsnob
//
//  Created by Mikita on 19/07/2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // Создаем табы
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        
        let menuVC = MenuViewController()
        menuVC.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(systemName: "fork.knife"), tag: 1)
        
        let careersVC = CareersViewController()
        careersVC.tabBarItem = UITabBarItem(title: "Careers", image: UIImage(systemName: "briefcase.fill"), tag: 2)
        
        let faqVC = FAQViewController()
        faqVC.tabBarItem = UITabBarItem(title: "FAQ", image: UIImage(systemName: "questionmark.circle.fill"), tag: 3)
        
        // Настраиваем Tab Bar Controller
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeVC, menuVC, careersVC, faqVC]
        
        // Стилизация Таббара под скриншот
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(white: 0.07, alpha: 1.0) // Темный фон
        
        // Цвет активной иконки/текста (Красный)
        appearance.stackedLayoutAppearance.selected.iconColor = .systemRed
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemRed]
        
        // Цвет неактивных элементов (Серый)
        appearance.stackedLayoutAppearance.normal.iconColor = .lightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        
        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
}

//
//  GFTabBarController.swift
//  GithubFollowers
//
//  Created by Osman Emre Ömürlü on 11.03.2024.
//

import UIKit

class GFTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().tintColor = .systemGreen // it effects whole tabbar
        viewControllers = [createSearchNC(), createFavoritesNC(), createProfileNC()]
        configureTabBarAppearance()
    }
    
    
    func createSearchNC() -> UINavigationController {
        let searchVC = SearchVC()
        searchVC.title = "Search"
        searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        return UINavigationController(rootViewController: searchVC)
    }
    
    
    func createFavoritesNC() -> UINavigationController {
        let favoritesVC = FavoriteListVC()
        favoritesVC.title = "Favorites"
        favoritesVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        
        return UINavigationController(rootViewController: favoritesVC)
    }
    
    
    func createProfileNC() -> UINavigationController {
        let profileVC = ProfileVC()
        profileVC.title = "Profile"
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 2)
        
        return UINavigationController(rootViewController: profileVC)
    }
    
    
    func configureTabBarAppearance() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            
            appearance.backgroundColor = UIColor.systemBackground // for light mode
            appearance.configureWithDefaultBackground() // for dark mode
            
            // Appearance'ı tabBar'a uygula
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}

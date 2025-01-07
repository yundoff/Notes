//
//  TabBarController.swift
//  Notes
//
//  Created by Aleksey Yundov on 06.01.2025.
//

import UIKit

enum Tabs: Int {
    case Home
    case List
    case Search
    case Note
}

final class TabBarController: UITabBarController {
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        view.backgroundColor = Resources.Colors.background
    }
    // MARK: - Methods
    
    func setupView() {
        setupTabBar()
        setupNavigationControllers()
    }
    
    func setupTabBar() {
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.tintColor = Resources.Colors.active
        tabBar.barTintColor = Resources.Colors.inactive
        tabBar.backgroundColor = Resources.Colors.background
        tabBar.layer.masksToBounds = true
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 2)
        topBorder.backgroundColor = Resources.Colors.separator.cgColor
        tabBar.layer.addSublayer(topBorder)
    }
    
    func setupNavigationControllers() {
        
        let HomeNavController = UINavigationController(rootViewController: HomeViewController())
        let ListNavController = UINavigationController(rootViewController: ListViewController())
//        let SearchNavController = UINavigationController(rootViewController: ListViewController())
        let NoteNavController = UINavigationController(rootViewController: NoteViewController())
        
        HomeNavController.tabBarItem = UITabBarItem(
            title: "",
            image: Resources.Images.TabBar.Home,
            tag: Tabs.Home.rawValue)
        ListNavController.tabBarItem = UITabBarItem(
            title: "",
            image: Resources.Images.TabBar.List,
            tag: Tabs.List.rawValue)
//        SearchNavController.tabBarItem = UITabBarItem(
//            title: "",
//            image: Resources.Images.TabBar.Search,
//            tag: Tabs.Search.rawValue)
        NoteNavController.tabBarItem = UITabBarItem(
            title: "",
            image: Resources.Images.TabBar.Note,
            tag: Tabs.Note.rawValue)
        
        
        setViewControllers(
            [HomeNavController, ListNavController, NoteNavController],
            animated: false
        )
    }
}

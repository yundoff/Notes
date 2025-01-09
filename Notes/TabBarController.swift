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
    case Note
}

final class TabBarController: UITabBarController {
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Resources.Colors.background
        setupNavigationControllers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTabBar()
    }
    // MARK: - Private Methods

    private func setupTabBar() {
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.tintColor = Resources.Colors.active
        tabBar.barTintColor = Resources.Colors.inactive
        tabBar.backgroundColor = Resources.Colors.background
        tabBar.layer.masksToBounds = true

        tabBar.layer.sublayers?.removeAll(where: { $0.name == "TopBorder" })

        let topBorder = CALayer()
        topBorder.name = "TopBorder"
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 2)
        topBorder.backgroundColor = Resources.Colors.separator.cgColor
        tabBar.layer.addSublayer(topBorder)
    }
    
    private func setupNavigationControllers() {
        
        let HomeNavController = UINavigationController(rootViewController: HomeViewController())
        let ListNavController = UINavigationController(rootViewController: ListViewController())
        let NoteNavController = UINavigationController(rootViewController: NoteViewController())
        
        HomeNavController.tabBarItem = UITabBarItem(
            title: "",
            image: Resources.Images.TabBar.Home,
            tag: Tabs.Home.rawValue)
        ListNavController.tabBarItem = UITabBarItem(
            title: "",
            image: Resources.Images.TabBar.List,
            tag: Tabs.List.rawValue)
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

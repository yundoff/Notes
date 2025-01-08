//
//  Resources.swift
//  Notes
//
//  Created by Aleksey Yundov on 07.01.2025.
//

import UIKit

enum Resources {
    enum Colors {
        static var active = UIColor(hexString: "#C5C5C5")
        static var inactive = UIColor(hexString: "#757575")
        static var background = UIColor(hexString: "#363636")
        static var separator = UIColor(hexString: "#404040")
        static var delete = UIColor(hexString: "#06C28D")
        static var text = UIColor(hexString: "#000000")
    }
    enum Images {
        enum TabBar {
            static var Home = UIImage(named: "house")
            static var List = UIImage(named: "list.clipboard")
            static var Search = UIImage(named: "text.page.badge.magnifyingglass")
            static var Note = UIImage(named: "square.and.pencil")
        }
    }
}

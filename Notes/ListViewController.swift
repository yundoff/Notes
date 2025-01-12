//
//  ListViewController.swift
//  Notes
//
//  Created by Aleksey Yundov on 07.01.2025.
//

import UIKit

final class ListViewController: UIViewController {
    
    // MARK: - UI Properties
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [appTitle, screenTitle])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let appTitle: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        label.textColor = Resources.Colors.active
        label.font = UIFont(name: "Andale Mono", size: 48)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let screenTitle: UILabel = {
        let label = UILabel()
        label.text = "History"
        label.textColor = Resources.Colors.active
        label.font = UIFont(name: "Andale Mono", size: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Resources.Colors.background
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        updateLayoutForOrientation()
        setupNavigationBar()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        view.backgroundColor = Resources.Colors.background
        view.addSubview(titleStackView)
        view.addSubview(tableView)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
    }
    
    @objc private func addNote() {
        if let tabBarController = self.tabBarController,
           let viewControllers = tabBarController.viewControllers,
           viewControllers.count > 1 {
            tabBarController.selectedIndex = 2
        }
    }

    
    // MARK: - Constraints
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeLeftConstraints: [NSLayoutConstraint] = []
    private var landscapeRightConstraints: [NSLayoutConstraint] = []
    
    private func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        portraitConstraints = [
            titleStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 56),
            titleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ]
        
        landscapeLeftConstraints = [
            titleStackView.topAnchor.constraint(equalTo: view.topAnchor),
            titleStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
        ]
        
        landscapeRightConstraints = [
            titleStackView.topAnchor.constraint(equalTo: view.topAnchor),
            titleStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
        ]
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            screenTitle.leadingAnchor.constraint(equalTo: titleStackView.leadingAnchor, constant: 4),
        ])
    }
    
    // MARK: - Orientation Handling
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.updateLayoutForOrientation()
        })
    }
    
    private func updateLayoutForOrientation() {
        NSLayoutConstraint.deactivate(portraitConstraints + landscapeLeftConstraints + landscapeRightConstraints)
        
        if UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isFlat {
            NSLayoutConstraint.activate(portraitConstraints)
        } else if UIDevice.current.orientation == .landscapeLeft {
            NSLayoutConstraint.activate(landscapeLeftConstraints)
        } else if UIDevice.current.orientation == .landscapeRight {
            NSLayoutConstraint.activate(landscapeRightConstraints)
        }
        view.layoutIfNeeded()
    }
    
}

//
//  NoteViewController.swift
//  Notes
//
//  Created by Aleksey Yundov on 07.01.2025.
//

import UIKit

final class NoteViewController: UIViewController {
    
    // MARK: - UI Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Resources.Colors.background
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .lightGray
        textView.text = "Enter title..."
        textView.font = UIFont(name: "Andale Mono", size: 28)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let noteTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Enter notes..."
        textView.textColor = .lightGray
        textView.font = UIFont(name: "Andale Mono", size: 18)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Properties
    private weak var activeTextView: UITextView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = Resources.Colors.background

        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleTextView)
        contentView.addSubview(noteTextView)

        setupLayout()
        setupNavigationBar()
        registerKeyboardNotifications()
        setupGestures()
        setupTextViewDelegates()
    }

    
    private func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            titleTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            noteTextView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 16),
            noteTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            noteTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            noteTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        let buttonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Andale Mono", size: 18) ?? UIFont.systemFont(ofSize: 18),
            .foregroundColor: Resources.Colors.delete
        ]
        
        let backButton = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(handleBackButton)
        )
        backButton.setTitleTextAttributes(buttonAttributes, for: .normal)
        backButton.setTitleTextAttributes(buttonAttributes, for: .highlighted)
        
        let saveButton = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(handleSaveButton)
        )
        saveButton.setTitleTextAttributes(buttonAttributes, for: .normal)
        saveButton.setTitleTextAttributes(buttonAttributes, for: .highlighted)
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    // MARK: - Button Actions
    @objc private func handleBackButton() {
        if let tabBarController = self.tabBarController,
           let viewControllers = tabBarController.viewControllers,
           viewControllers.count > 1 {
            tabBarController.selectedIndex = 1
        }
    }

    var onSave: ((Note) -> Void)?
    
    @objc private func handleSaveButton() {
        let titleText = titleTextView.text ?? ""
        let noteText = noteTextView.text ?? ""
        let note = Note(title: titleText, text: noteText, creationDate: Date())
        
        onSave?(note)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Keyboard Notifications
    private func registerKeyboardNotifications() {
        let keyboardNotifications: [(NSNotification.Name, Selector)] = [
            (UIResponder.keyboardWillShowNotification, #selector(adjustForKeyboard)),
            (UIResponder.keyboardWillHideNotification, #selector(adjustForKeyboard))
        ]
        
        for (notification, selector) in keyboardNotifications {
            NotificationCenter.default.addObserver(
                self, selector: selector, name: notification, object: nil
            )
        }
    }
    
    @objc private func adjustForKeyboard(notification: NSNotification) {
        let keyboardFrameInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
        guard let keyboardFrame = keyboardFrameInfo as? NSValue else { return }
        
        let keyboardHeight = (notification.name == UIResponder.keyboardWillShowNotification) ? keyboardFrame.cgRectValue.height : 0
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        if notification.name == UIResponder.keyboardWillShowNotification,
           let textView = activeTextView {
            let keyboardTop = view.frame.height - keyboardHeight
            let textViewBottom = scrollView.convert(textView.frame, to: view).maxY
            if textViewBottom > keyboardTop {
                let offset = textViewBottom - keyboardTop + 16
                scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        }
    }

    // MARK: - Gestures
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    // MARK: - UITextView Delegates
    private func setupTextViewDelegates() {
        titleTextView.delegate = self
        noteTextView.delegate = self
    }
}

// MARK: - UITextViewDelegate
extension NoteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView

        if textView == titleTextView && textView.text == "Enter title..." {
            textView.text = ""
            textView.textColor = .white
        } else if textView == noteTextView && textView.text == "Enter notes..." {
            textView.text = ""
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
        
        if textView == titleTextView && textView.text.isEmpty {
            textView.text = "Enter title..."
            textView.textColor = .lightGray
        } else if textView == noteTextView && textView.text.isEmpty {
            textView.text = "Enter notes..."
            textView.textColor = .lightGray
        }
    }
}

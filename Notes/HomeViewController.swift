//
//  HomeViewController.swift
//  Notes
//
//  Created by Aleksey Yundov on 07.01.2025.
//

import UIKit

final class HomeViewController: UIViewController {

    // MARK: - UI Properties

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()

    private let appTitle: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        label.textColor = Resources.Colors.active
        label.font = UIFont(name: "Andale Mono", size: 48)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("clear screen", for: .normal)
        button.backgroundColor = Resources.Colors.delete
        button.layer.cornerRadius = 8
        button.configurationUpdateHandler = { button in
            var config = button.configuration ?? UIButton.Configuration.plain()
            config.imagePadding = 8

            // Конфигурация иконки с заданием размера
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            let image = UIImage(systemName: "trash")?.withConfiguration(symbolConfig)
            
            // Установка изображения и цвета
            config.image = image?.withTintColor(Resources.Colors.text, renderingMode: .alwaysOriginal)
            config.imagePlacement = .trailing

            var titleAttr = AttributedString(button.currentTitle ?? "")
            titleAttr.font = UIFont(name: "Andale Mono", size: 20)
            titleAttr.foregroundColor = Resources.Colors.text
            config.attributedTitle = titleAttr
            button.configuration = config
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteAllTextViews), for: .touchUpInside)
        return button
    }()



    private lazy var textView: (CGPoint) -> UITextView = { point in
        let textView = UITextView()
        let frame = self.view.frame.width
        textView.frame = CGRect(origin: point, size: CGSize(width: frame / 8, height: frame / 8))
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "Andale Mono", size: 24)
        textView.textColor = Resources.Colors.active
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.widthTracksTextView = true
        return textView
    }

    private var activeTextView: UITextView?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // MARK: - UI Setup
    
    private func setupView() {
        view.backgroundColor = Resources.Colors.background
        setupKeyboardAndGesture()
        setupSubviews()
        setupLayout()
    }
    
    private func setupSubviews() {
        view.addSubview(appTitle)
        view.addSubview(scrollView)
        view.addSubview(deleteButton)
    }
    
    private func setupKeyboardAndGesture() {
        registerKeyboardNotifications()
        scrollView.addGestureRecognizer(gesture)
    }
    
    private func setupLayout() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            appTitle.topAnchor.constraint(equalTo: safeArea.topAnchor),
            appTitle.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),

            scrollView.topAnchor.constraint(equalTo: appTitle.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            deleteButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            deleteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),

        ])
    }

    // MARK: - Gestures
    
    private lazy var gesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTap(_:)))
        return gesture
    }()
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: scrollView)
        
        if location.x > (view.frame.width - 32) { return }
        if activeTextView?.isFirstResponder == true { view.endEditing(true) }
        else { addTextView(at: gesture.location(in: scrollView)) }
    }

    // MARK: - TextView Handling

    private func addTextView(at point: CGPoint) {
        let textView = self.textView(point)
        scrollView.addSubview(textView)
        textView.becomeFirstResponder()
        activeTextView = textView
        updateScrollViewContentSize()
    }
    
    private func updateScrollViewContentSize() {
        let textViewMaxHeights = scrollView.subviews.compactMap { subview in
            return (subview as? UITextView)?.frame.maxY
        }
        let maxHeight = textViewMaxHeights.max() ?? 0
        
        let newScrollViewHeight = max(maxHeight + 20, scrollView.bounds.height)
        scrollView.contentSize = CGSize(width: view.bounds.width, height: newScrollViewHeight)
    }

    @objc private func deleteAllTextViews() {
        scrollView.subviews.forEach { subview in
            if subview is UITextView {
                subview.removeFromSuperview()
            }
        }
        updateScrollViewContentSize()
    }

    // MARK: - Keyboard Handling

    private func registerKeyboardNotifications() {
        let keyboardNotifications: [(NSNotification.Name, Selector)] = [
            (UIResponder.keyboardWillShowNotification, #selector(adjustForKeyboard)),
            (UIResponder.keyboardWillHideNotification, #selector(adjustForKeyboard))]
        
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
                let offset = textViewBottom - keyboardTop
                scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension HomeViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty { textView.removeFromSuperview() }
        updateScrollViewContentSize()
    }

    func textViewDidChange(_ textView: UITextView) {
        let maxWidth = view.bounds.width - textView.frame.origin.x - 16
        let size = textView.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: min(size.width, maxWidth), height: size.height)
        updateScrollViewContentSize()
    }
}

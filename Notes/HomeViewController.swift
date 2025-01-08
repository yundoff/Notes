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
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [appTitle, appSubTitle])
        stackView.axis = .vertical
        stackView.spacing = 8
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
    
    private let appSubTitle: UILabel = {
        let label = UILabel()
        label.text = "Quick"
        label.textColor = Resources.Colors.active
        label.font = UIFont(name: "Andale Mono", size: 28)
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
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            
            let image = UIImage(systemName: "trash")?.withConfiguration(symbolConfig)
            config.image = image?.withTintColor(Resources.Colors.text, renderingMode: .alwaysOriginal)
            config.imagePadding = 8
            config.imagePlacement = .trailing
            
            var attributes = AttributedString(button.currentTitle ?? "")
            attributes.font = UIFont(name: "Andale Mono", size: 20)
            attributes.foregroundColor = Resources.Colors.text
            config.attributedTitle = attributes
            button.configuration = config
        }
        button.addAction(onClick, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var onClick = UIAction { [unowned self] _ in
        let alert = UIAlertController(title: "", message: "Are you sure?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteAllTextViews()
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        
        self.present(alert, animated: true, completion: nil)
    }
    
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
        view.addSubview(titleStackView)
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
            titleStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            titleStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            
            scrollView.topAnchor.constraint(equalTo: appTitle.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            deleteButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -12),
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
        
        let newScrollViewHeight = max(maxHeight + 48, scrollView.bounds.height)
        scrollView.contentSize = CGSize(width: view.bounds.width, height: newScrollViewHeight)
    }
    
    private func deleteAllTextViews() {
        scrollView.subviews.forEach { subview in
            if subview is UITextView {
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    subview.removeFromSuperview()
                    self.updateScrollViewContentSize()
                }
                
                let fadeAnimation = CABasicAnimation(keyPath: "opacity")
                fadeAnimation.fromValue = 1.0
                fadeAnimation.toValue = 0.0
                fadeAnimation.duration = 0.2
                
                let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                scaleAnimation.fromValue = 1.0
                scaleAnimation.toValue = 1.5
                scaleAnimation.duration = 0.2
                
                let animationGroup = CAAnimationGroup()
                animationGroup.animations = [fadeAnimation, scaleAnimation]
                animationGroup.duration = 0.2
                
                subview.layer.add(animationGroup, forKey: "removalAnimation")
                subview.layer.opacity = 0.0
                
                CATransaction.commit()
            }
        }
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

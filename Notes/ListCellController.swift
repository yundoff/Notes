//
//  ListCellController.swift
//  Notes
//
//  Created by Aleksey Yundov on 09.01.2025.
//

import UIKit

final class ListCell: UICollectionViewCell {
    
    // MARK: - UI Properties
    static let identifier = "ListCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private lazy var listStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupView() {
        setupSubviews()
        setupLayout()
    }
    
    private func setupSubviews() {
        contentView.addSubview(listStackView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            listStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            listStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            listStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            listStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}

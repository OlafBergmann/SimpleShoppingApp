//
//  BasketItemCell.swift
//  SimpleShoppingApp2
//
//  Created by Olaf Bergmann on 06/10/2025.
//

import UIKit
import RxSwift
import RxCocoa

final class BasketItemCell: UITableViewCell {

    let nameLabel = UILabel()
    let quantityLabel = UILabel()
    let minusButton = UIButton(type: .system)
    let plusButton = UIButton(type: .system)
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        minusButton.setTitle("–", for: .normal)
        plusButton.setTitle("+", for: .normal)
        quantityLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [minusButton, quantityLabel, plusButton])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [nameLabel, stack])
        mainStack.axis = .horizontal
        mainStack.spacing = 16
        mainStack.distribution = .fillProportionally

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}

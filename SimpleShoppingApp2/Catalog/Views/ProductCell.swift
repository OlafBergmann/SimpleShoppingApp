//
//  ProductCell.swift
//  SimpleShoppingApp2
//
//  Created by Olaf Bergmann on 06/10/2025.
//

import UIKit

final class ProductCell: UITableViewCell {
    
    static let identifier = "ProductCell"
    
    // MARK: - UI Elements
    private let productImageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let quantityBadge = UILabel()
    
    var quantity: Int = 0
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = 8
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: inset - 4, left: inset, bottom: inset - 4, right: inset))
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        selectionStyle = .none
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 10
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .boldSystemFont(ofSize: 16)
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .secondaryLabel
        
        quantityBadge.font = .systemFont(ofSize: 12)
        quantityBadge.textColor = .white
        quantityBadge.backgroundColor = .systemRed
        quantityBadge.textAlignment = .center
        quantityBadge.layer.cornerRadius = 12
        quantityBadge.clipsToBounds = true
        quantityBadge.isHidden = true
        
        let labelsStack = UIStackView(arrangedSubviews: [nameLabel, priceLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 4
        
        let mainStack = UIStackView(arrangedSubviews: [productImageView, labelsStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        contentView.addSubview(quantityBadge)
        
        quantityBadge.translatesAutoresizingMaskIntoConstraints = false
        quantityBadge.layer.zPosition = 1
        
        NSLayoutConstraint.activate([
            productImageView.widthAnchor.constraint(equalToConstant: 60),
            productImageView.heightAnchor.constraint(equalToConstant: 60),
            
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            quantityBadge.widthAnchor.constraint(equalToConstant: 24),
            quantityBadge.heightAnchor.constraint(equalToConstant: 24),
            quantityBadge.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 6),
            quantityBadge.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: -6)
        ])
        
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        
    }
    
    // MARK: - Configure Cell
    func configure(with product: Product, quantity: Int) {
        nameLabel.text = product.name
        priceLabel.text = "$\(String(format: "%.2f", product.priceUSD)) / \(product.unit)"
        productImageView.image = UIImage(named: product.imageName)
        
        if quantity > 0 {
            quantityBadge.isHidden = false
            
            // Animate only if quantity changed
            if self.quantity != quantity {
                self.quantity = quantity
                quantityBadge.text = "\(quantity)"
                quantityBadge.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: .curveEaseOut) {
                    self.quantityBadge.transform = .identity
                }
            }
        } else {
            quantityBadge.isHidden = true
            self.quantity = 0
        }
    }
}

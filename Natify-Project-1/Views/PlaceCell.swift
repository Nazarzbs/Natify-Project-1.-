//
//  PlaceCell.swift
//  Natify-Project-1
//
//  Created by Nazar on 22.02.2026.
//


import UIKit

final class PlaceCell: UITableViewCell {

    static let reuseIdentifier = "PlaceCell"

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemOrange
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.nameFontSize, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.secondaryFontSize)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.secondaryFontSize)
        label.textColor = .systemOrange
        return label
    }()

    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.textStackSpacing
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with place: Place) {
        nameLabel.text = place.name
        addressLabel.text = place.address ?? ""
        iconImageView.image = UIImage(systemName: iconName(for: place.types))

        if let rating = place.rating {
            ratingLabel.text = String(format: "Rating: %.1f", rating)
            ratingLabel.isHidden = false
        } else {
            ratingLabel.isHidden = true
        }
    }
}

private extension PlaceCell {
    func setupViews() {
        selectionStyle = .none

        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(addressLabel)
        textStack.addArrangedSubview(ratingLabel)

        contentView.addSubview(iconImageView)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),

            textStack.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: Constants.iconTextSpacing
            ),
            textStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.horizontalPadding
            ),
            textStack.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.verticalPadding
            ),
            textStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.verticalPadding
            )
        ])
    }

    func iconName(for types: [String]) -> String {
        if types.contains("cafe") {
            return "cup.and.saucer.fill"
        }
        return "fork.knife"
    }
}

private extension PlaceCell {
    enum Constants {
        static let iconSize: CGFloat = 32
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let iconTextSpacing: CGFloat = 12
        static let textStackSpacing: CGFloat = 4
        static let nameFontSize: CGFloat = 16
        static let secondaryFontSize: CGFloat = 14
    }
}

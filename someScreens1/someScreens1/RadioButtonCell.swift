//
//  RadioButtonCell.swift
//  someScreens1
//
//  Created by andriy kruglyanko on 25.04.2025.
//

import UIKit

struct Option {
    let title: String
    var isSelected: Bool
}


class RadioButtonCell: UITableViewCell {
    let titleLabel = UILabel()
    let radioButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setup() {
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
            titleLabel.textColor = UIColor.gray
        } else {
            titleLabel.textColor = UIColor.label
        }
        backgroundColor = .yellow
//        radioButton.setImage(UIImage(systemName: "circle"), for: .normal)
        radioButton.setImage(UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        radioButton.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .selected)
        radioButton.isUserInteractionEnabled = false // Prevent direct tapping

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        radioButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(radioButton)

        NSLayoutConstraint.activate([
            radioButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            radioButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            radioButton.widthAnchor.constraint(equalToConstant: 24),
            radioButton.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(with position: Position) {
        titleLabel.text = position.name
        radioButton.isSelected = position.isSelected
        if position.isSelected {
            radioButton.tintColor = UIColor(red: 0, green: 189/255, blue: 211/255, alpha: 1)
        } else {
            radioButton.tintColor = .darkGray
        }
    }
}

//
//  ListCell.swift
//  Contacts
//
//  Created by Dmitry Reshetnik on 26.05.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class ListCell: UICollectionViewCell {
    static let reuseIdentifier = "list-cell-reuse-identifier"
    let imageView = UIImageView()
    let label = UILabel()
    let indicator = UIView()
    let seperatorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        seperatorView.backgroundColor = .lightGray
        addSubview(seperatorView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.white
        imageView.layer.cornerRadius = 25
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        indicator.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = UIColor.green
        indicator.layer.borderWidth = 2.0
        indicator.layer.borderColor = UIColor.systemBackground.cgColor
        indicator.layer.cornerRadius = 8
        indicator.isHidden = true
        addSubview(indicator)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.preferredFont(forTextStyle: .body)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50.0),
            imageView.heightAnchor.constraint(equalToConstant: 50.0),
            
            indicator.centerYAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8.0),
            indicator.centerXAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8.0),
            indicator.widthAnchor.constraint(equalToConstant: 16.0),
            indicator.heightAnchor.constraint(equalToConstant: 16.0),

            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8.0),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            label.firstBaselineAnchor.constraint(equalTo: topAnchor, constant: 32.0),
            
            seperatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            seperatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 5),
            seperatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            seperatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
}

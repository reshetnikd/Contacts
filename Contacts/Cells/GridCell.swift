//
//  GridCell.swift
//  Contacts
//
//  Created by Dmitry Reshetnik on 26.05.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class GridCell: UICollectionViewCell {
    static let reuseIdentifier = "grid-cell-reuse-identifier"
    let imageView = UIImageView()
    let indicator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            indicator.centerYAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8.0),
            indicator.centerXAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8.0),
            indicator.widthAnchor.constraint(equalToConstant: 16.0),
            indicator.heightAnchor.constraint(equalToConstant: 16.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemnted.")
    }
}

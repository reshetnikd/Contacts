//
//  DetailedInfoViewController.swift
//  Contacts
//
//  Created by Dmitry Reshetnik on 26.05.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class DetailedInfoViewController: UIViewController {
    var backButton = UIButton(type: .custom)
    var imageView = UIImageView()
    var statusLabel = UILabel()
    var nameLabel = UILabel()
    var emailButton = UIButton()
    
    var person: Person? {
        didSet {
            guard let person = person else { return }
            
            imageView.image = person.avatar
            statusLabel.text = person.status ? "online" : "offline"
            nameLabel.text = person.name
            emailButton.setTitle(person.email, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        view.addSubview(backButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.white
        imageView.layer.cornerRadius = imageView.image!.size.height / 2
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        // Apply different size constraints for used avatar images.
        if imageView.image != nil && imageView.image!.isEqual(UIImage(systemName: "person.crop.circle")) {
            imageView.widthAnchor.constraint(equalToConstant: 100 * UIScreen.main.scale).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 100 * UIScreen.main.scale).isActive = true
        } else {
            imageView.widthAnchor.constraint(equalToConstant: imageView.image!.size.width).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageView.image!.size.height).isActive = true
        }
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        view.addSubview(statusLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        view.addSubview(nameLabel)
        
        emailButton.translatesAutoresizingMaskIntoConstraints = false
        emailButton.setTitleColor(.systemBlue, for: .normal)
        emailButton.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
        view.addSubview(emailButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            
            emailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    @objc func backButtonAction() {
        dismiss(animated: true)
    }
    
    @objc func sendEmail() {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

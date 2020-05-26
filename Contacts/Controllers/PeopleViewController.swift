//
//  PeopleViewController.swift
//  Contacts
//
//  Created by Dmitry Reshetnik on 26.05.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private var collectionView: UICollectionView! = nil
    private var segmentedControl: UISegmentedControl! = nil
    private var flowLayout = ColumnFlowLayout()
    private var isUpdating = false
    
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titles = ["List", "Grid"]
        // Setup segmented control.
        segmentedControl = UISegmentedControl(items: titles)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setWidth(100, forSegmentAt: 0)
        segmentedControl.setWidth(100, forSegmentAt: 1)
        segmentedControl.addTarget(self, action: #selector(changeLayout), for: .valueChanged)
        navigationItem.titleView = segmentedControl
        
        // Setup toolbar.
        navigationController?.isToolbarHidden = false
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(UIBarButtonItem(title: "Simulate Changes", style: .plain, target: self, action: #selector(simulateChanges)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        toolbarItems = items
        
        // Setup collection view.
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.reuseIdentifier)
        collectionView.register(GridCell.self, forCellWithReuseIdentifier: GridCell.reuseIdentifier)
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
        
        // Activate collection view constraints.
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 5),
            collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5)
        ])
        
        let spinnerController = SpinnerViewController()

        // Add the spinner view controller.
        addChild(spinnerController)
        spinnerController.view.frame = view.frame
        view.addSubview(spinnerController.view)
        spinnerController.didMove(toParent: self)
        
        DispatchQueue.global(qos: .background).async {
            self.isUpdating = true
            if let mailsURL = Bundle.main.url(forResource: "mail", withExtension: "txt") {
                if let mailList = try? String(contentsOf: mailsURL) {
                    mailList.components(separatedBy: "\n").dropLast().forEach { (mail) in
                        self.people.append(Person.fetchDataOfProfile(with: mail))
                    }
                    DispatchQueue.main.async {
                        self.segmentedControl.selectedSegmentIndex = 0
                        self.collectionView.reloadData()
                        spinnerController.willMove(toParent: nil)
                        spinnerController.view.removeFromSuperview()
                        spinnerController.removeFromParent()
                        self.isUpdating = false
                    }
                }
            }
        }
    }
    
    @objc func changeLayout() {
        if segmentedControl.selectedSegmentIndex == 1 && !isUpdating {
            collectionView.setCollectionViewLayout(UICollectionViewFlowLayout.init(), animated: true) { [weak self] (_) in
                self?.collectionView.reloadData()
            }
        } else if !isUpdating {
            collectionView.setCollectionViewLayout(flowLayout, animated: true) { [weak self] (_) in
                self?.collectionView.reloadData()
            }
        }
    }
    
    @objc func simulateChanges() {
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.collectionViewLayout is ColumnFlowLayout {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.reuseIdentifier, for: indexPath) as? ListCell else {
                preconditionFailure("Failed to load collection view cell")
            }
            
            cell.label.text = people[indexPath.item].name
            cell.indicator.isHidden = !people[indexPath.item].status
            cell.imageView.image = people[indexPath.item].avatar
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.reuseIdentifier, for: indexPath) as? GridCell else {
                preconditionFailure("Failed to load collection view cell")
            }
            
            cell.indicator.isHidden = !people[indexPath.item].status
            cell.imageView.image = people[indexPath.item].avatar
            
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ListCell {
            let destinationVC = storyboard?.instantiateViewController(identifier: "DetailedInfo") as! DetailedInfoViewController
            destinationVC.person = people[collectionView.indexPath(for: cell)!.item]
            present(destinationVC, animated: true)
        } else if let cell = collectionView.cellForItem(at: indexPath) as? GridCell {
            let destinationVC = storyboard?.instantiateViewController(identifier: "DetailedInfo") as! DetailedInfoViewController
            destinationVC.person = people[collectionView.indexPath(for: cell)!.item]
            present(destinationVC, animated: true)
        }
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

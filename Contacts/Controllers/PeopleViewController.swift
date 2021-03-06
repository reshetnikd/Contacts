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
    private var simulateButton: UIButton! = nil
    private var spinnerController = SpinnerViewController()
    private var flowLayout = ColumnFlowLayout()
    private var isUpdating = false
    
    var people = [Person]()
    var selectedCell: UICollectionViewCell?
    var selectedCellImageViewSnapshot: UIView?
    var transitionAnimator: ViewControllerTransitionAnimator?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titles = ["List", "Grid"]
        // Setup segmented control.
        segmentedControl = UISegmentedControl(items: titles)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setWidth(100, forSegmentAt: 0)
        segmentedControl.setWidth(100, forSegmentAt: 1)
        segmentedControl.addTarget(self, action: #selector(changeLayout), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        // Setup bottom button.
        simulateButton = UIButton(type: .system)
        simulateButton.translatesAutoresizingMaskIntoConstraints = false
        simulateButton.setTitle("Simulate Changes", for: .normal)
        simulateButton.addTarget(self, action: #selector(simulateChanges), for: .touchUpInside)
        simulateButton.isEnabled = false
        view.addSubview(simulateButton)
        
        // Setup collection view.
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.reuseIdentifier)
        collectionView.register(GridCell.self, forCellWithReuseIdentifier: GridCell.reuseIdentifier)
        view.addSubview(collectionView)
        
        // Add spinner view controller.
        spinnerController.view.center = view.center
        view.addSubview(spinnerController.view)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
        
        // Activate constraints.
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            segmentedControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            spinnerController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinnerController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: simulateButton.topAnchor, constant: -10),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            
            simulateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            simulateButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        
        DispatchQueue.global(qos: .background).async {
            self.isUpdating = true
            let data = MailData()
            
            data.mailboxes.forEach { (mailbox) in
                self.people.append(Person.fetchDataOfProfile(with: mailbox))
            }
            DispatchQueue.main.async {
                self.segmentedControl.selectedSegmentIndex = 0
                self.collectionView.reloadData()
                self.spinnerController.view.removeFromSuperview()
                self.spinnerController.removeFromParent()
                self.isUpdating = false
                self.simulateButton.isEnabled = true
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        spinnerController.view.center = view.center
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        view.setNeedsLayout()
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
        renameAndReloadRandomPeople()
        deleteRandomPeople()
        insertRandomPeople()
    }
    
    func renameAndReloadRandomPeople() {
        guard people.count > 2 else {
            // The simulate button is enabled only if the list still has 2 people in it.
            simulateButton.isEnabled = false
            return
        }
        
        var randomIndecies = [Int]()
        var peopleUpdates = [Person.PersonUpdate]()
        
        // Generate random indecies.
        for _ in 0...people.count {
            if Bool.random() {
                randomIndecies.append(Int.random(in: 0...people.count - 1))
            }
        }
        
        // Populate peopleUpdates with reload or rename actions.
        randomIndecies.removingDuplicates().forEach { (index) in
            let action = Int.random(in: 0...1)
            
            switch action {
            case 0:
                peopleUpdates.append(Person.PersonUpdate.reload(index))
            case 1:
                peopleUpdates.append(Person.PersonUpdate.rename(index))
            default:
                break
            }
        }
        
        // Perform any cell reloads without animation because there is no movement.
        UIView.performWithoutAnimation {
            collectionView.performBatchUpdates({
                for update in peopleUpdates {
                    if case let .reload(index) = update {
                        people[index].status = Bool.random()
                        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    } else if case let .rename(index) = update {
                        people[index].name = people[index].name.components(separatedBy: " ").reversed().joined(separator: " ")
                        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
            })
        }
    }
    
    func deleteRandomPeople() {
        guard people.count > 2 else {
            // The simulate button is enabled only if the list still has 2 people in it.
            simulateButton.isEnabled = false
            return
        }
        var randomIndecies = [Int]()
        var peopleUpdates = [Person.PersonUpdate]()
        
        // Generate random indecies.
        for _ in 0...people.count {
            if Bool.random() {
                randomIndecies.append(Int.random(in: 0...people.count - 1))
            }
        }
        
        // Populate peopleUpdates with delete actions.
        randomIndecies.removingDuplicates().forEach { (index) in
            peopleUpdates.append(Person.PersonUpdate.delete(index))
        }
        
        // Animate all other update types together.
        collectionView.performBatchUpdates({
            var deletes = [Int]()
            
            for update in peopleUpdates {
                switch update {
                case let .delete(index):
                    collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                    deletes.append(index)
                default: break
                }
            }
            
            // Apply deletions in descending order.
            for deletedIndex in deletes.sorted().reversed() {
                people.remove(at: deletedIndex)
            }
        })
    }
    
    func insertRandomPeople() {
        guard people.count > 2 else {
            // The simulate button is enabled only if the list still has 2 people in it.
            simulateButton.isEnabled = false
            return
        }
        var randomIndecies = [Int]()
        var peopleUpdates = [Person.PersonUpdate]()
        
        // Generate random indecies.
        for _ in 0...people.count {
            if Bool.random() {
                randomIndecies.append(Int.random(in: 0...people.count - 1))
            }
        }
        
        // Populate peopleUpdates with insert actions.
        randomIndecies.removingDuplicates().forEach { (index) in
            peopleUpdates.append(Person.PersonUpdate.insert(Person(name: "Simulated Person", email: "person@server.com", status: false, avatar: UIImage(systemName: "person.crop.circle")!), index))
        }
        
        // Animate all other update types together.
        collectionView.performBatchUpdates({
            var inserts = [(person:Person, index:Int)]()
            
            for update in peopleUpdates {
                switch update {
                case let .insert(person, index):
                    collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                    inserts.append((person, index))
                default: break
                }
            }
            
            // Apply insertions in ascending order.
            let sortedInserts = inserts.sorted(by: { (personA, personB) -> Bool in
                return personA.index <= personB.index
            })
            
            for insertion in sortedInserts {
                if people.indices.contains(insertion.index) {
                    people.insert(insertion.person, at: insertion.index)
                }
            }
        })
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
            selectedCell = cell
            selectedCellImageViewSnapshot = cell.imageView.snapshotView(afterScreenUpdates: false)
            
            let destinationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailedInfo") as! DetailedInfoViewController
            destinationVC.modalPresentationStyle = .overCurrentContext
            destinationVC.person = people[collectionView.indexPath(for: cell)!.item]
            destinationVC.transitioningDelegate = self
            present(destinationVC, animated: true)
        } else if let cell = collectionView.cellForItem(at: indexPath) as? GridCell {
            selectedCell = cell
            selectedCellImageViewSnapshot = cell.imageView.snapshotView(afterScreenUpdates: false)
            
            let destinationVC = storyboard?.instantiateViewController(identifier: "DetailedInfo") as! DetailedInfoViewController
            destinationVC.modalPresentationStyle = .overCurrentContext
            destinationVC.person = people[collectionView.indexPath(for: cell)!.item]
            destinationVC.transitioningDelegate = self
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

extension PeopleViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let sourceVC = presenting as? PeopleViewController, let destinationVC = presented as? DetailedInfoViewController, let selectedSnapshot = selectedCellImageViewSnapshot else {
            return nil
        }
        
        transitionAnimator = ViewControllerTransitionAnimator(type: .present, source: sourceVC, destination: destinationVC, snapshot: selectedSnapshot)
        return transitionAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let currentVC = dismissed as? DetailedInfoViewController, let selectedSnapshot = selectedCellImageViewSnapshot else {
            return nil
        }
        
        transitionAnimator = ViewControllerTransitionAnimator(type: .dismiss, source: self, destination: currentVC, snapshot: selectedSnapshot)
        return transitionAnimator
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

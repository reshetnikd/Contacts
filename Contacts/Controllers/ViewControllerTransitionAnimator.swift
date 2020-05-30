//
//  ViewControllerTransitionAnimator.swift
//  Contacts
//
//  Created by Dmitry Reshetnik on 30.05.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

enum PresentationType {
    case present, dismiss
    
    var isPresenting: Bool {
        return self == .present
    }
}

final class ViewControllerTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    static let duration: TimeInterval = 0.25
    
    private let type: PresentationType
    private let sourceVC: PeopleViewController
    private let destinationVC: DetailedInfoViewController
    private let selectedCellImageViewSnapshot: UIView
    private let cellImageViewRect: CGRect
    
    init?(type: PresentationType, source: PeopleViewController, destination: DetailedInfoViewController, snapshot: UIView) {
        self.type = type
        self.sourceVC = source
        self.destinationVC = destination
        self.selectedCellImageViewSnapshot = snapshot
        
        guard let window = source.view.window ?? destination.view.window, let selectedCell = source.selectedCell else {
            return nil
        }
        
        if selectedCell is ListCell, let cellImageView = (selectedCell as? ListCell)?.imageView {
            self.cellImageViewRect = cellImageView.convert(cellImageView.bounds, to: window)
        } else if selectedCell is GridCell, let cellImageView = (selectedCell as? GridCell)?.imageView {
            self.cellImageViewRect = cellImageView.convert(cellImageView.bounds, to: window)
        } else {
            self.cellImageViewRect = .zero
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return ViewControllerTransitionAnimator.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toView = destinationVC.view else {
            transitionContext.completeTransition(false)
            return
        }
        
        containerView.addSubview(toView)
        
        guard let selectedCell = sourceVC.selectedCell, let window = sourceVC.view.window ?? destinationVC.view.window, let cellImageSnapshot = selectedCell is ListCell ? (selectedCell as! ListCell).imageView.snapshotView(afterScreenUpdates: true) : (selectedCell as! GridCell).imageView.snapshotView(afterScreenUpdates: true), let controllerImageSnapshot = destinationVC.imageView.snapshotView(afterScreenUpdates: true) else {
            transitionContext.completeTransition(true)
            return
        }
        
        let isPresenting = type.isPresenting
        let imageViewSnapshot: UIView
        
        if isPresenting {
            imageViewSnapshot = cellImageSnapshot
        } else {
            imageViewSnapshot = controllerImageSnapshot
        }
        
        toView.alpha = 0
        containerView.addSubview(imageViewSnapshot)
        
        let controllerImageViewRect = destinationVC.imageView.convert(destinationVC.imageView.bounds, to: window)
        imageViewSnapshot.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
        
        UIView.animateKeyframes(
            withDuration: ViewControllerTransitionAnimator.duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 1,
                    animations: {
                        imageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                    }
                )
            }, completion: { (_) in
                imageViewSnapshot.removeFromSuperview()
                toView.alpha = 1
                transitionContext.completeTransition(true)
            }
        )
        
    }
}

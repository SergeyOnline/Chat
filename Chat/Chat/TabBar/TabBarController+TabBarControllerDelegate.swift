//
//  TabBarController+TabBarControllerDelegate.swift
//  Chat
//
//  Created by Сергей on 27.11.2021.
//

import UIKit

extension TabBarController: UITabBarControllerDelegate {
	
	private class TransitioningsTabBarController: NSObject, UIViewControllerAnimatedTransitioning {
		
		private enum Direction: CGFloat {
			case left = 1.0
			case right = -1.0
		}
		
		private let tabBarController: UITabBarController
		
		init(_ tabBarController: UITabBarController) {
			self.tabBarController = tabBarController
		}
		
		func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
			guard
				let fromView: UIView = transitionContext.view(forKey: .from),
				let toView: UIView = transitionContext.view(forKey: .to),
				let fromVC: UIViewController = transitionContext.viewController(forKey: .from),
				let toVC: UIViewController = transitionContext.viewController(forKey: .to)
			else { return }

			let containerView = transitionContext.containerView
			
			var direction = Direction.left
			if let controllers = tabBarController.viewControllers,
			   let fromIndex = controllers.firstIndex(of: fromVC),
			   let toIndex = controllers.firstIndex(of: toVC) {
				direction = (fromIndex < toIndex) ? .left : .right
			}
		
			containerView.clipsToBounds = false
			containerView.addSubview(toView)
			
			var fromViewEndFrame = fromView.frame
			fromViewEndFrame.origin.x -= (containerView.frame.width * direction.rawValue)
			fromViewEndFrame.origin.y += containerView.frame.height
			
			let toViewEndFrame = transitionContext.finalFrame(for: toVC)
			var toViewStartFrame = toViewEndFrame
			toViewStartFrame.origin.x += (containerView.frame.width * direction.rawValue)
			toViewStartFrame.origin.y += containerView.frame.height
			toView.frame = toViewStartFrame
			
			toView.alpha = 0.0
			UIView.animate(withDuration: transitionDuration(using: transitionContext),
									   delay: 0.0, usingSpringWithDamping: 1.0,
									   initialSpringVelocity: 0.0,
									   options: UIView.AnimationOptions.curveEaseInOut,
									   animations: { () -> Void in
				toView.alpha = 1.0
				toView.frame = toViewEndFrame
				fromView.alpha = 0.0
				fromView.frame = fromViewEndFrame
			}, completion: { (completed) -> Void in
				toView.alpha = 1.0
				fromView.removeFromSuperview()
				transitionContext.completeTransition(completed)
				containerView.clipsToBounds = true
			})
			
		}

		func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
			return 0.5
		}
	}
	
	func tabBarController(
		_ tabBarController: UITabBarController,
		animationControllerForTransitionFrom fromVC: UIViewController,
		to toVC: UIViewController
	) -> UIViewControllerAnimatedTransitioning? {
		return TransitioningsTabBarController(tabBarController)
	}
}

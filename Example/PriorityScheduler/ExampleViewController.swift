//
//  ExampleViewController.swift
//  PriorityScheduler
//
//  Created by Sebastian Grail on 14/02/15.
//  Copyright (c) 2015 Sebastian Grail. All rights reserved.
//

import UIKit
import PrioritySchedulerPod

/* Helper Methods */

func randomUniform (count: Int) -> Int {
	return Int(arc4random_uniform(UInt32(count)))
}

func randomUniform (count: CGFloat) -> CGFloat {
	return CGFloat(arc4random_uniform(UInt32(count)))
}

extension Array {
	func findIndex (f: T -> Bool) -> Int? {
		for idx in 0..<self.count {
			if f(self[idx]) {
				return idx
			}
		}
		return nil
	}
}


class ExampleViewController: UIViewController {

	var manager: OperationManager<(), UIColor>?
	var root: Node<Operation<(),UIColor>>?
	
	override func viewDidLoad() {
		let rootOp = Operation<(), UIColor>(input: (), work: { _ in return UIColor.redColor() }, callback: { _ in ()})
		rootOp.scheduled = true
		let root = Node(value: rootOp)
		self.root = root
		manager = OperationManager(root: root, maxConcurrentOperationCount: 3)
	}
	
	@IBAction func addNode(sender: AnyObject) {
		self.view.addSubview(randomView())
	}
	
	
	let colors = [UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.redColor()]
	func randomColor () -> UIColor {
		return colors[randomUniform(colors.count)]
	}

	
	let viewSize = CGSize(width: 200, height: 200)
	
	/// Creates a random view and schedules changing its background colour
	func randomView () -> UIView {
		let position = CGPoint(
			x: randomUniform(CGRectGetWidth(self.view.bounds)-viewSize.width),
			y: randomUniform(CGRectGetHeight(self.view.bounds)-viewSize.height))
		
		let view = UIView(frame: CGRect(origin: position, size: viewSize))
		view.backgroundColor = UIColor.lightGrayColor()
		let bgOperation = Operation<(), UIColor>(input: (), work: { _ in
			sleep(3)
			return self.randomColor()
		}, callback: { color in
				view.backgroundColor = color
		})
		
		// Operation node to change the bg colour
		let bgNode = Node(value: bgOperation)
		
		for idx in 0..<4 {
			let x = CGFloat(idx%2)*viewSize.width/2
			let y = CGFloat((idx/2)%2)*viewSize.height/2
			let rect = CGRect(x: x, y: y, width: viewSize.width/2, height: viewSize.height/2)
			let subview = UIView(frame: CGRectInset(rect, 10, 10))
			subview.backgroundColor = UIColor.darkGrayColor()
			view.addSubview(subview)
			
			let operation = Operation<(), UIColor>(input: (), work: { _ in
				sleep(3)
				return self.randomColor()
				}, callback: { color in
					subview.backgroundColor = color
			})
			// Operation node for the subview
			bgNode.addChild(Node(value: operation))
		}
		
		// Gesture Recognisers to manipulate view and operation hierarchy
		
		// Tap to move view one level to the front. Priority will change accordingly
		let gr = UITapGestureRecognizer()
		gr.rac_gestureSignal().subscribeNext({ [weak view] x in
			if let view = view {
				if let idx = view.superview?.subviews.findIndex({ $0 as NSObject == view }) {
					let superview = view.superview!
					view.removeFromSuperview()
					superview.insertSubview(view, atIndex: idx+1)
					bgNode.moveLeft()
				}
			}
			println(x)
		})
		view.addGestureRecognizer(gr)
		
		// Pan to move view, doesn't change its priority
		let panGR = UIPanGestureRecognizer()
		panGR.rac_gestureSignal().subscribeNext({ [weak view] gr in
			if let view = view {
				let delta = gr.translationInView(view)
				view.center = CGPoint(x: view.center.x+delta.x, y: view.center.y+delta.y)
				gr.setTranslation(CGPointZero, inView: view)
			}
		})
		view.addGestureRecognizer(panGR)
		
		// Long press to remove a view and all associated work
		let lpGR = UILongPressGestureRecognizer()
		lpGR.rac_gestureSignal().subscribeNext({ [weak view] _ in
			view?.removeFromSuperview()
			bgNode.removeFromParent()
		})
		view.addGestureRecognizer(lpGR)
		
		self.root?.addChildToFront(bgNode)
		return view
	}
}

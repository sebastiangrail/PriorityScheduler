//
//  OperationManager.swift
//  Pods
//
//  Created by Sebastian Grail on 15/02/15.
//
//

import Foundation
import ReactiveCocoa

public class OperationManager <T,U> {
	
	let operationTree: Node<Operation<T, U>>
	let queue: NSOperationQueue
	
	public init (root: Node<Operation<T,U>>, maxConcurrentOperationCount: Int) {
		operationTree = root
		queue = NSOperationQueue()
		queue.maxConcurrentOperationCount = maxConcurrentOperationCount
		
		RACObserve(queue, "operationCount")
			.combineLatestWith(operationTree.nodeDidChangeSignal)
			.subscribeNext({ [weak self] tuple in
				if let manager = self {
					let (operationCount, _): (Int, Node<Operation<T,U>>) = convertTwoTuple(tuple as RACTuple)
					if operationCount < manager.queue.maxConcurrentOperationCount {
						manager.scheduleNext()
					}
				}
			})
	}
	
	func scheduleNext () -> () {
		if var op = operationTree.find({ !$0.scheduled }) {
			op.scheduled = true
			queue.addOperationWithBlock({
				let x = op.backgroundWork(op.input)
				NSOperationQueue.mainQueue().addOperationWithBlock({
					op.callback(x)
				})
			})
		}
	}
	
}
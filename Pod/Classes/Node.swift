//
//  Node.swift
//  Pods
//
//  Created by Sebastian Grail on 14/02/15.
//
//

import Foundation
import ReactiveCocoa

/// Describes a change in a Node
///
public enum NodeChange <T> : Equatable {
	case DidRemoveChild(Node<T>, /*fromParent*/ Node<T>)
	case DidAddChild(Node<T>)
	case DidMoveChild(Node<T>)
}

public func == <T> (lhs: NodeChange<T>, rhs: NodeChange<T>) -> Bool {
	switch (lhs, rhs) {
	case (.DidAddChild(let a), .DidAddChild(let b)):
		return a == b
	case (.DidMoveChild(let a), .DidMoveChild(let b)):
		return a == b
	case (.DidRemoveChild(let a, let parentA), .DidRemoveChild(let b, let parentB)):
		return a == b && parentA == parentB
	default:
		return false
	}
}

/// A node in a mutable tree
///
/// Conforms to NSObject for default `==` implementation
public class Node <T> : NSObject {
	
	// Boxing the value prevents the Swift compiler crashing in Xcode 6.1.1
	let _value: Box<T>
	public var value: T { get { return _value.value } }
	
	public private (set) var children = [Node<T>]()
	
	weak var parent: Node<T>? = nil
	
	// nodeDidChangeSubject is an implementation detail of nodeDidChangeSignal
	private var nodeDidChangeSubject = RACSubject()
	
	/// sends a signal everytime a change occurs.
	/// The changes are always sent through the signal of the root of the tree
	public var nodeDidChangeSignal: RACSignal {
		get {
			return nodeDidChangeSubject
		}
	}
	
	public init (value: T) {
		self._value = Box(value: value)
	}
	
	private func sendChange (change: NodeChange<T>) -> () {
		if let parent = self.parent {
			parent.sendChange(change)
		} else {
			self.nodeDidChangeSubject.sendNext(Box(value: change))
		}
	}
	
	/// Adds a child to the end of the array of children
	public func addChild (child: Node<T>) {
		assert(child.parent == nil, "node already has a parent")
		children.append(child)
		child.parent = self
		sendChange(.DidAddChild(child))
	}
	
	/// Adds a child to the front of the Array of children
	public func addChildToFront (child: Node<T>) {
		assert(child.parent == nil, "node already has a parent")
		children.insert(child, atIndex: 0)
		child.parent = self
		sendChange(.DidAddChild(child))
	}
	
	/// Removes a child from its parent node
	public func removeChild (child: Node<T>) {
		children.remove( { $0 == child } )
		child.parent = nil
		sendChange(.DidRemoveChild(child, self))
	}
	
	/// Moves the node one position to the left
	public func moveLeft () -> () {
		if let idx = self.parent?.children.findIndex({ $0 == self }) {
			if idx > 0 {
				self.parent?.children.swapItemAtIndex(idx, withItemAtIndex: idx-1)
			}
		}
		parent?.sendChange(.DidMoveChild(self))
	}

	/// Moves the node one position to the right
	public func moveRight () -> () {
		if let idx = self.parent?.children.findIndex({ $0 == self }) {
			println("index = \(idx)")
			if idx < (self.parent!.children.count-1) {
				println("swapping")
				self.parent?.children.swapItemAtIndex(idx, withItemAtIndex: idx+1)
			}
		}
		parent?.sendChange(.DidMoveChild(self))
	}
	
	/// Removes the node from its parent
	public func removeFromParent () -> () {
		self.parent?.removeChild(self)
	}
	
	/// Finds a node that satisfies the predicate using depth-first traversal
	/// Returns nil if no node in the tree satisfies the predicate
	func find (p: T -> Bool) -> T? {
		for child in self.children {
			if let result = child.find(p) {
				return result
			}
		}
		if p(self._value.value) {
			return self._value.value
		} else {
			return nil
		}
	}
}
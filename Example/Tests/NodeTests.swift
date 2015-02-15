//
//  NodeTests.swift
//  PriorityScheduler
//
//  Created by Sebastian Grail on 15/02/15.
//  Copyright (c) 2015 Sebastian Grail. All rights reserved.
//

import UIKit
import XCTest
import PrioritySchedulerPod

class ChangesTestHelper {
	
	var changes = [NodeChange<Int>]()
	
	init (node: Node<Int>) {
		node.nodeDidChangeSignal.subscribeNext { [weak self] changeObj in
			if let s = self {
				if let change = changeObj as? Box<NodeChange<Int>> {
					s.changes.append(change.value)
				} else {
					XCTAssert(false, "")
				}
			}
		}
	}
	
}

class NodeTests: XCTestCase {
	
	// Set default values to avoid using Optional
	var root: Node<Int> = Node(value: 0)
	let a = Node(value: 1)
	let b = Node(value: 2)
	let c = Node(value: 3)

    override func setUp() {
        super.setUp()
		root = Node(value: 0)
		let a = Node(value: 1)
		let b = Node(value: 2)
		let c = Node(value: 3)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testAddChild () {
		let changesHelper = ChangesTestHelper(node: root)
		root.addChild(a)
		root.addChild(b)
		root.addChildToFront(c)
		
		XCTAssertEqual(root.children.count, 3, "")
		XCTAssertEqual(root.children[0].value, 3, "")
		XCTAssertEqual(root.children[1].value, 1, "")
		XCTAssertEqual(root.children[2].value, 2, "")
		
		XCTAssertEqual(changesHelper.changes.count, 3, "")
		XCTAssertEqual(changesHelper.changes[0], NodeChange.DidAddChild(a), "")
		XCTAssertEqual(changesHelper.changes[1], NodeChange.DidAddChild(b), "")
		XCTAssertEqual(changesHelper.changes[2], NodeChange.DidAddChild(c), "")
	}
	
	func testRemoveChild () {
		let changesHelper = ChangesTestHelper(node: root)
		
		root.addChild(a)
		root.addChild(b)
		root.removeChild(a)
		XCTAssertEqual(root.children.count, 1, "")
		XCTAssertEqual(root.children[0].value, 2, "")
		
		XCTAssertEqual(changesHelper.changes.count, 3, "")
		XCTAssertEqual(changesHelper.changes[2], NodeChange.DidRemoveChild(a, root), "")
	}
	
	func testMoveLeft () {
		let changesHelper = ChangesTestHelper(node: root)
		
		root.addChild(a)
		root.addChild(b)
		root.addChild(c)
		root.children[2].moveLeft()
		XCTAssertEqual(root.children.count, 3, "")
		XCTAssertEqual(root.children[0].value, 1, "")
		XCTAssertEqual(root.children[1].value, 3, "")
		XCTAssertEqual(root.children[2].value, 2, "")
		
		XCTAssertEqual(changesHelper.changes.count, 4, "")
		XCTAssertEqual(changesHelper.changes[3], NodeChange.DidMoveChild(c), "")
	}
	
	func testMoveRight () {
		let changesHelper = ChangesTestHelper(node: root)
		
		root.addChild(a)
		root.addChild(b)
		root.addChild(c)
		root.children[0].moveRight()
		XCTAssertEqual(root.children.count, 3, "")
		XCTAssertEqual(root.children[0].value, 2, "")
		XCTAssertEqual(root.children[1].value, 1, "")
		XCTAssertEqual(root.children[2].value, 3, "")
		
		XCTAssertEqual(changesHelper.changes.count, 4, "")
		XCTAssertEqual(changesHelper.changes[3], NodeChange.DidMoveChild(a), "")
	}
	
	func testRemoveFromParent () {
		let changesHelper = ChangesTestHelper(node: root)
		
		root.addChild(a)
		root.addChild(b)
		root.children[0].removeFromParent()
		XCTAssertEqual(root.children.count, 1, "")
		XCTAssertEqual(root.children[0].value, 2, "")
		
		XCTAssertEqual(changesHelper.changes.count, 3, "")
		XCTAssertEqual(changesHelper.changes[2], NodeChange.DidRemoveChild(a, root), "")
	}
	
	func testFind () {
		let left = Node(value: 1)
		let right = Node(value: 2)
		let left_one = Node(value: 3)
		left_one.addChild(Node(value: -1))
		let left_two = Node(value: 4)
		left.addChild(left_one)
		left.addChild(left_two)
		root.addChild(left)
		root.addChild(right)
		
		let node = root.find({ $0 > 0 })
		XCTAssertEqual(node!.value, 3, "")
	}

}

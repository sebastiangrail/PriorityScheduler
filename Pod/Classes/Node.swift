//
//  Node.swift
//  Pods
//
//  Created by Sebastian Grail on 14/02/15.
//
//

import Foundation
import ReactiveCocoa

public class Node <T> {
	let value: T
	var children = [Node<T>]()
	weak var parent: Node<T>? = nil
	
	var nodeDidChangeSubject = RACSubject()
	public var nodeDidChangeSignal: RACSignal {
		get {
			return nodeDidChangeSubject
		}
	}
	
	init (value: T) {
		self.value = value
	}
}
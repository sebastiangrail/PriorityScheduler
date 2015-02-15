//
//  Operation.swift
//  Pods
//
//  Created by Sebastian Grail on 15/02/15.
//
//

import Foundation

/// Represents work to be done in the background
public class Operation <T,U> {
	public let input: T
	let backgroundWork: T -> U
	let callback: U -> ()
	public var scheduled: Bool = false
	
	public init (input: T, work: T -> U, callback: U -> ()) {
		self.input = input
		self.backgroundWork = work
		self.callback = callback
	}
}
//
//  Box.swift
//  Pods
//
//  Created by Sebastian Grail on 15/02/15.
//
//

/// Boxes a value
///
/// Necessary because of Swift langauge shortcomings

public class Box<T> {
	public let value: T
	
	public init (value: T) {
		self.value = value
	}
}
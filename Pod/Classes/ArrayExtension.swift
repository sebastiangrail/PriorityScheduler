//
//  ArrayExtension.swift
//  Pods
//
//  Created by Sebastian Grail on 15/02/15.
//
//

extension Array {
	
	/// Finds the first element that satisfies the predicate `p`
	/// Returns nil if no element satisifies `p`
	func find (p: T -> Bool) -> T? {
		for x in self {
			if p(x) {
				return x
			}
		}
		return nil
	}
	
	/// Finds the index of the first element that satisfies the predicate `p`
	/// Returns nil, if no element satisifies `p`, returns nil
	func findIndex (p: T -> Bool) -> Int? {
		for idx in 0..<self.count {
			if p(self[idx]) {
				return idx
			}
		}
		return nil
	}
	
	/// Removes the first element that satisfies the predicate
	mutating func remove (p: T -> Bool) -> () {
		if let idx = self.findIndex(p) {
			self.removeAtIndex(idx)
		}
	}
	
	/// Swaps items at the given indexes
	mutating func swapItemAtIndex(n: Int, withItemAtIndex m: Int) {
		let tmp = self[n]
		self[n] = self[m]
		self[m] = tmp
	}
}
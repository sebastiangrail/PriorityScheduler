//
//  RACHelpers.swift
//  Pods
//
//  Created by Sebastian Grail on 15/02/15.
//
//

import Foundation
import ReactiveCocoa

/// Replacement function for RACObserver macro
func RACObserve(target: NSObject!, keyPath: String) -> RACSignal  {
	return target.rac_valuesForKeyPath(keyPath, observer: target)
}

/// Explicitly convert as RAC 2-Tuple into a Swift 2-Tuple
func convertTwoTuple<T,U> (tuple: RACTuple) -> (T,U) {
	let first = tuple.first as T
	let second = tuple.second as U
	return (first, second)
}
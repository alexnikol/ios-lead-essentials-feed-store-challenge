//
//  XCTestCase+MemoryLeakTracking.swift
//  Tests
//
//  Created by Alexander Nikolaychuk on 20.01.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

extension XCTestCase {
	
	func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}
	
}

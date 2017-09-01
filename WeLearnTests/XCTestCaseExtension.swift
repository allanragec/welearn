//
//  XCTestCaseExtension.swift
//  Enjoei
//
//  Created by Allan Melo on 16/08/17.
//  Copyright © 2017 Test. All rights reserved.
//

import XCTest

extension XCTestCase {
	func wait(timeout: Double? = 8) {
		waitForExpectations(timeout: timeout!) { error in
			if let error = error {
				XCTFail(error.localizedDescription)
			}
		}
	}
}

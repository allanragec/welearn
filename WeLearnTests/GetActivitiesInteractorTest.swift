
//
//  WeLearnTests.swift
//  WeLearnTests
//
//  Created by Allan Melo on 01/09/17.
//  Copyright © 2017 Test. All rights reserved.
//

import XCTest
//@testable import WeLearn

class GetActivitiesTests: XCTestCase {
	func testGetActivitiesInteractor() {
		let expect = expectation(description: "testGetActivitiesInteractor")

		interactor.execute(
			onSuccess: { (activities) in
				XCTAssertTrue(!activities.isEmpty)
				expect.fulfill()
			},
			onError: { (error) in
				XCTFail()

				expect.fulfill()
			}
		)

		wait()
	}

	let interactor = GetActivitiesInteractor()
}

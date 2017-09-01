//
//  UpdateActivitiesInteractor.swift
//  WeLearn
//
//  Created by Allan Melo on 01/09/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

class UpdateActivitiesInteractor {
	func excute(payload: [String: AnyObject]) {
		guard let url = baseUrl else {
			return
		}

		let config = URLSessionConfiguration.default
		let session = URLSession(configuration: config)
		var request = URLRequest(url: url)
		request.httpMethod = "POST"

		try! request.httpBody = JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")

		let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in })

		task.resume()
	}

	private let baseUrl = URL(string: "http://192.168.110.72:9253/hackaday_learning/context/123")
}

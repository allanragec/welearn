//
//  GetActivities.swift
//  WeLearn
//
//  Created by Allan Melo on 01/09/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation


class GetActivitiesInteractor  {
	func execute(onSuccess: @escaping (([Activity], [String: AnyObject])->()), onError: @escaping ((Error)->())) {
		guard let url = baseUrl else {
			return
		}

		let config = URLSessionConfiguration.default
		let session = URLSession(configuration: config)

		let task = session.dataTask(with: url) { (data, response, error) in
			if let data = data {
				do {
					guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
						let hits = json["hits"] as? [String: AnyObject],
						let hitsJson = hits["hits"] as? [[String: AnyObject]],
						let sourceJson = hitsJson.first?["_source"] as? [String: AnyObject],
						let mediasJson = sourceJson["media"] as? [[String: AnyObject]] else {

						let error = NSError.init(domain: "Could not possible deserializer the response", code: 0, userInfo: nil)
						DispatchQueue.main.async {
							onError(error)
						}

						return
					}

					let activities = mediasJson.map({ json -> Activity in
						return self.mapActivity(activityJson: json)
					})

					DispatchQueue.main.async {
						onSuccess(activities, sourceJson)
					}
				}
				catch {
					let error = NSError.init(domain: "Could not possible deserializer the response", code: 0, userInfo: nil)
					DispatchQueue.main.async {
						onError(error)
					}
				}
			}
			else if let error = error {
				DispatchQueue.main.async {
					onError(error)
				}
			}
		}

		task.resume()
	}

	private func mapActivity(activityJson: [String: AnyObject]) -> Activity {
		let activity = Activity()

		activity.current = activityJson["current"] as? Bool ?? false
		activity.type = activityJson["type"] as? String ?? ""
		activity.id = activityJson["id"] as? Int ?? 0

		switch activity.type {
			case "video":
				activity.videoURL = activityJson["videoURL"] as? String ?? ""
				activity.time = activityJson["time"] as? Float ?? 0
				break
			case "ebook":
				activity.imageURLs = activityJson["imageURLs"] as? [String] ?? [String]()
				activity.currentPage = activityJson["currentPage"] as? Int ?? 0
				break
			case "excercise":
				activity.question = activityJson["question"] as? String ?? ""
				activity.answers = activityJson["answers"] as? [String] ?? [String]()
				activity.selectedAnswer = activityJson["selectedAnswer"] as? Int ?? 0
				break

			default:
				break
		}

		return activity
	}
	
	private let baseUrl = URL(string: "http://192.168.110.72:9253/hackaday_learning/context/_search")
}

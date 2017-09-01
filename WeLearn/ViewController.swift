//
//  ViewController.swift
//  WeLearn
//
//  Created by Allan Melo on 01/09/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation
import youtube_ios_player_helper
import UIKit

class ViewController: UIViewController, YTPlayerViewDelegate {

	@IBOutlet weak var playerView: YTPlayerView!
	@IBOutlet weak var loading: UIActivityIndicatorView!

	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet weak var option1: UIButton!
	@IBOutlet weak var option2: UIButton!
	@IBOutlet weak var option3: UIButton!
	@IBOutlet weak var excerciseContainer: UIView!
	@IBOutlet weak var ebookView: UIView!

	@IBOutlet weak var nextActivityButton: UIButton!
	override func viewDidLoad() {
		super.viewDidLoad()

		loading.startAnimating()
		GetActivitiesInteractor().execute(
			onSuccess:{ [weak self] activities, jsonData in
				self?.activities = activities
				self?.jsonData = jsonData
				self?.setupContent()
				self?.loading.stopAnimating()
			},
			onError:{ [weak self] error in
				self?.loading.stopAnimating()
			}
		)
	}

	@IBAction func nextActivity(_ sender: Any) {
		guard let currentActivity = getCurrentActivity() else {
			return
		}

		let index = activities.index { activity -> Bool in
			return currentActivity.id == activity.id
		}

		currentActivity.current = false

		let newIndex = Int(index!.toIntMax() + 1)

		if (newIndex < activities.count) {
			activities[newIndex].current = true

			saveCurrentState()
			setupContent()
		}
	}

	func getCurrentActivity() -> Activity? {
		guard let currentActivity = activities.filter({ activity in
			return activity.current
		}).first else {
			return nil
		}

		return currentActivity
	}

	func setupContent() {
		guard let currentActivity = getCurrentActivity() else {
			return
		}

		playerView.isHidden = true
		nextActivityButton.isHidden = true
		excerciseContainer.isHidden = true
		ebookView.isHidden = true

		switch currentActivity.type {
			case "video":
				setupVideo()
				break
			case "ebook":
				setupEbook()
				break
			case "excercise":
				setupExcercise()
				break
			default:
				break
		}

	}

	func setAsnwer(_ answer: Int) {
		guard let currentActivity = getCurrentActivity(),
			currentActivity.type == "excercise" else {

				return
		}

		currentActivity.selectedAnswer = answer
	}

	@IBAction func option1Action(_ sender: Any) {
		setAsnwer(1)
	}

	@IBAction func option2Action(_ sender: Any) {
		setAsnwer(2)
	}

	@IBAction func option3Action(_ sender: Any) {
		setAsnwer(3)
	}

	func setupExcercise() {
		guard let currentActivity = getCurrentActivity(),
			currentActivity.type == "excercise" else {

				return
		}

		excerciseContainer.isHidden = false

		questionLabel.text = currentActivity.question
		option1.setTitle(currentActivity.answers[0], for: .normal)
		option2.setTitle(currentActivity.answers[2], for: .normal)
		option3.setTitle(currentActivity.answers[3], for: .normal)
	}

	func setupEbook() {
		nextActivityButton.isHidden = false
		ebookView.isHidden = false

		
	}

	func setupVideo() {
		guard let currentActivity = getCurrentActivity(),
			currentActivity.type == "video" else {

			return
		}

		playerView.isHidden = false
		playerView.delegate = self

		playerView.load(withVideoId: getVideoId(activity: currentActivity))
	}

	func getVideoId(activity: Activity) -> String {
		let url = URL(string: activity.videoURL)
		if let id = url?.query?.replacingOccurrences(of: "v=", with: "") {
			return id
		}

		return ""
	}

	func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
		guard let currentActivity = getCurrentActivity(),
			currentActivity.type == "video" else {

			return
		}

		let startTime = currentActivity.time

		playerView.loadVideo(
			byId: getVideoId(activity: currentActivity),
			startSeconds: startTime, suggestedQuality: .auto)
	}

	func playerView(
		_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {

		if (state == .paused) {
			saveCurrentState()
		}
		else if (state == .ended) {
			nextActivity(state)
		}
	}

	private func saveCurrentState() {
		guard let currentActivity = getCurrentActivity() else {
			return
		}

		let isVideo = currentActivity.type == "video"
		let isExcercise = currentActivity.type == "excercise"

		let activitiesJson = jsonData["media"] as? [[String: AnyObject]]

		var updatedActivities = [[String: AnyObject]]()
		for var activity in activitiesJson! {
			let id = activity["id"] as? Int ?? 0

			if (currentActivity.id == id) {
				activity.updateValue(true as AnyObject, forKey: "current")

				if (isVideo) {
					activity.updateValue(playerView.currentTime() as AnyObject, forKey: "time")
				}

				if (isExcercise) {
					activity.updateValue(currentActivity.selectedAnswer as AnyObject, forKey: "answer")
				}
			}
			else {
				activity.updateValue(false as AnyObject, forKey: "current")
			}

			updatedActivities.append(activity)
		}

		UpdateActivitiesInteractor().excute(payload: ["media": updatedActivities as AnyObject])
		print(updatedActivities)
	}

	var jsonData = [String: AnyObject]()
	var activities: [Activity] = [Activity]()
}


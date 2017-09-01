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

class ViewController: UIViewController, YTPlayerViewDelegate,
	UIPageViewControllerDataSource, UIPageViewControllerDelegate {

	@IBOutlet weak var playerView: YTPlayerView!
	@IBOutlet weak var loading: UIActivityIndicatorView!

	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet weak var option1: UIButton!
	@IBOutlet weak var option2: UIButton!
	@IBOutlet weak var option3: UIButton!
	@IBOutlet weak var excerciseContainer: UIView!
	@IBOutlet weak var ebookView: UIView!

	@IBOutlet weak var pageControll: UIPageControl!
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

		pageViewController = UIPageViewController(
			transitionStyle: UIPageViewControllerTransitionStyle.scroll,
			navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal,
			options: nil)

		setupPageViewController()
	}

	private func setupPageViewController() {
		pageViewController.dataSource = self
		pageViewController.delegate = self

		pageViewController.view.frame = ebookView.frame
		ebookView.addSubview(pageViewController.view)
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

		nextActivity(currentActivity)
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
		option2.setTitle(currentActivity.answers[1], for: .normal)
		option3.setTitle(currentActivity.answers[2], for: .normal)
	}

	func setupEbook() {
		nextActivityButton.isHidden = false
		ebookView.isHidden = false

		guard let currentActivity = getCurrentActivity(),
			currentActivity.type == "ebook" else {

				return
		}

		let storyboard = UIStoryboard(name: "Main", bundle: nil)

		photoPageViewControllers = currentActivity.imageURLs.map({(imageUrl) in
			let photoPageViewController = storyboard.instantiateViewController(withIdentifier: "photoPageViewController")
				as! PhotoPageViewController

			photoPageViewController.photoUrl = imageUrl

			return photoPageViewController
		})

		guard let initialViewController = photoPageViewControllers.first else {
			return
		}

		pageViewController.setViewControllers([initialViewController],
		                                      direction: UIPageViewControllerNavigationDirection.forward,
		                                      animated: false,
		                                      completion: nil)

		pageControll.numberOfPages = photoPageViewControllers.count
		ebookView.bringSubview(toFront: pageControll)
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

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let photoPageViewController = viewController as? PhotoPageViewController,
			let index = photoPageViewControllers.index(of: photoPageViewController), index > 0 else {

				return nil
		}

		return photoPageViewControllers[index - 1]
	}

	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
	                        previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

		if (completed) {
			pageControll.currentPage = photoPageViewControllers.index(of: pageViewController.viewControllers?.first as! PhotoPageViewController)!
		}
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let photoPageViewController = viewController as? PhotoPageViewController,
			let index = photoPageViewControllers.index(of: photoPageViewController),
			index < (photoPageViewControllers.count - 1) else {

				return nil
		}

		return photoPageViewControllers[index + 1]
	}

	var photoPageViewControllers = [PhotoPageViewController]()
	var jsonData = [String: AnyObject]()
	var activities: [Activity] = [Activity]()
	var pageViewController : UIPageViewController!
}


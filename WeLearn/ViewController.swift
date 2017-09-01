//
//  ViewController.swift
//  WeLearn
//
//  Created by Allan Melo on 01/09/17.
//  Copyright © 2017 Test. All rights reserved.
//

import youtube_ios_player_helper
import UIKit

class ViewController: UIViewController, YTPlayerViewDelegate {

	@IBOutlet weak var playerView: YTPlayerView!

	override func viewDidLoad() {
		super.viewDidLoad()


		playerView.delegate = self
		playerView.load(withVideoId: id)
	}

	func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
		let startTime: Float = 50

		playerView.loadVideo(byId: id, startSeconds: startTime, suggestedQuality: .small)
	}

	func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
		if (state == .paused) {
			saveCurrentState()
		}
	}

	private func saveCurrentState() {
		print("saveCurrentState \(playerView.currentTime())" )
	}

	let id = "9bZkp7q19f0"
	let type: String? = nil
}


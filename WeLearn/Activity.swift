//
//  Activity.swift
//  WeLearn
//
//  Created by Allan Melo on 01/09/17.
//  Copyright © 2017 Test. All rights reserved.
//

class Activity {
	var current = false
	var type = ""
	var id = 0

	// type "video"
	var videoURL = ""
	var time: Float = 0

	// type "ebook"
	var imageURLs = [String]()
	var currentPage = 0


	// type excercise
	var question = ""
	var answers = [String]()
	var selectedAnswer = 0
}

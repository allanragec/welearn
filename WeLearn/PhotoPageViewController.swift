//
//  PhotoPageViewController
//  WeLearn
//
//  Created by Allan Melo on 01/09/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoPageViewController: UIViewController {

	var photoUrl: String?
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imageView: UIImageView!

	override func viewDidLoad() {
		guard let photoUrl = photoUrl else {
			return
		}

		activityIndicator.startAnimating()
		imageView.sd_setImage(with: URL(string: photoUrl)) { [weak self] (image, error, type, url) in
			self?.activityIndicator.stopAnimating()
		}
	}
}

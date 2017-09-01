
import UIKit

extension UIColor {

	convenience init(rgb: NSString) {
		var rgb: NSString = rgb

		if (rgb.hasPrefix("#")) {
			rgb = rgb.substring(from: 1) as NSString
		}

		var red, green, blue, alpha : String

		if (rgb.length == 6) {
			alpha = "FF"
			red = rgb.substring(with: NSMakeRange(0, 2))
			green = rgb.substring(with: NSMakeRange(2, 2))
			blue = rgb.substring(with: NSMakeRange(4, 2))
		}
		else if (rgb.length == 8) {
			alpha = rgb.substring(with: NSMakeRange(0, 2))
			red = rgb.substring(with: NSMakeRange(2, 2))
			green = rgb.substring(with: NSMakeRange(4, 2))
			blue = rgb.substring(with: NSMakeRange(6, 2))
		}
		else {
			self.init()

			return
		}

		var a: UInt32 = 0
		var r: UInt32 = 0
		var g: UInt32 = 0
		var b: UInt32 = 0

		Scanner(string:alpha).scanHexInt32(&a)
		Scanner(string:red).scanHexInt32(&r)
		Scanner(string:green).scanHexInt32(&g)
		Scanner(string:blue).scanHexInt32(&b)

		if ((r == g) && (g == b)) {
			self.init(white:(CGFloat(r) / 255), alpha:(CGFloat(a) / 255))
		}
		else {
			self.init(
				red:(CGFloat(r) / 255), green:(CGFloat(g) / 255),
				blue:(CGFloat(b) / 255), alpha:(CGFloat(a) / 255))
		}
	}

}

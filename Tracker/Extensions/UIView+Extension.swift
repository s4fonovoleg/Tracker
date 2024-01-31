import Foundation
import UIKit

extension UIView {
	func addGradient(colors: [CGColor], lineWidth: CGFloat) {
		let gradient = CAGradientLayer()
		gradient.frame =  CGRect(
			origin: CGPointZero,
			size: self.frame.size
		)
		gradient.colors = colors
		gradient.startPoint = CGPoint(x: 0, y: 0.5)
		gradient.endPoint = CGPoint(x: 1, y: 0.5)
		gradient.masksToBounds = true

		let shape = CAShapeLayer()
		shape.lineWidth = lineWidth
		shape.path = UIBezierPath(
			roundedRect: bounds,
			cornerRadius: self.layer.cornerRadius
		).cgPath
		shape.strokeColor = UIColor.black.cgColor
		shape.fillColor = UIColor.clear.cgColor
		gradient.mask = shape

		self.layer.addSublayer(gradient)
	}
}

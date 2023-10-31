import UIKit

final class TabBarController: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		tabBar.layer.borderColor = UIColor.lightGray.cgColor
		tabBar.layer.borderWidth = 0.5
	}
}

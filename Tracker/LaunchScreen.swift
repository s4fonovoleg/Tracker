import UIKit

final class LaunchScreen: UIViewController {
	private var logoView: UIImageView = {
		let logo = UIImage(named: "LauncScreenLogo")
		let logoView = UIImageView(image: logo)
		
		logoView.translatesAutoresizingMaskIntoConstraints = false
		
		
		return logoView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .ypBlue
		addLogo()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigateToTrackersViewController()
	}
	
	private func addLogo() {
		view.addSubview(logoView)
		NSLayoutConstraint.activate([
			logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			logoView.widthAnchor.constraint(equalToConstant: 91),
			logoView.heightAnchor.constraint(equalToConstant: 94)
		])
	}
	
	private func navigateToTrackersViewController() {
		guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
		let navigationController = UINavigationController(rootViewController: TrackersViewController())
		let statisticsController = StatisticsViewController()
		let tabBarController = TabBarController()
		
		navigationController.tabBarItem = UITabBarItem(
			title: "Трекеры",
			image: UIImage(named: "TrackerTabBarItemImage"),
			selectedImage: UIImage(named: "TrackerTabBarItemSelectedImage"))
		
		statisticsController.tabBarItem = UITabBarItem(
			title: "Статистика",
			image: UIImage(named: "StatisticsTabBarItemImage"),
			selectedImage: UIImage(named: "StatisticsTabBarItemSelectedImage"))
		
		tabBarController.viewControllers = [
			navigationController, statisticsController
		]
		
		window.rootViewController = tabBarController
	}
}

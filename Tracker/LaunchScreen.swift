import UIKit

final class LaunchScreen: UIViewController {
	
	// MARK: Private properties
	
	
	
	// MARK: Private UI properties
	
	private var logoView: UIImageView = {
		let logo = UIImage(named: "LauncScreenLogo")
		let logoView = UIImageView(image: logo)
		
		logoView.translatesAutoresizingMaskIntoConstraints = false
		
		
		return logoView
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .ypBlue
		addLogo()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let skipOnboarding = UserDefaults.standard.bool(forKey: "SkipOnboarding")
		
		if skipOnboarding {
			navigateToTrackersViewController()
		} else {
			navigateToOnboardingViewController()
		}
	}
	
	// MARK: UI methods
	
	private func addLogo() {
		view.addSubview(logoView)
		NSLayoutConstraint.activate([
			logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			logoView.widthAnchor.constraint(equalToConstant: 91),
			logoView.heightAnchor.constraint(equalToConstant: 94)
		])
	}
	
	// MARK: Private methods
	
	private func navigateToOnboardingViewController() {
		guard let window = UIApplication.shared.windows.first else {
			fatalError("Invalid Configuration")
		}
		
		let onboardingVoewController = OnboardingViewController(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal)
		
		window.rootViewController = onboardingVoewController
	}
	
	private func navigateToTrackersViewController() {
		guard let window = UIApplication.shared.windows.first else {
			fatalError("Invalid Configuration")
		}
		
		let trackersViewController = TrackersViewController()
		trackersViewController.dataProvider = DataProvider()
		let navigationController = UINavigationController(rootViewController: trackersViewController)
		let statisticsController = StatisticsViewController()
		let tabBarController = TabBarController()
		
		navigationController.tabBarItem = UITabBarItem(
			title: NSLocalizedString("trackers", comment: "Название экрана с трекерами"),
			image: UIImage(named: "TrackerTabBarItemImage"),
			selectedImage: UIImage(named: "TrackerTabBarItemSelectedImage"))
		
		statisticsController.tabBarItem = UITabBarItem(
			title: NSLocalizedString("statistics", comment: "Название экрана статистики"),
			image: UIImage(named: "StatisticsTabBarItemImage"),
			selectedImage: UIImage(named: "StatisticsTabBarItemSelectedImage"))
		
		tabBarController.viewControllers = [
			navigationController, statisticsController
		]
		
		window.rootViewController = tabBarController
	}
}

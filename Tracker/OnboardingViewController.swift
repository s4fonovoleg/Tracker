import UIKit

final class OnboardingViewController: UIPageViewController {
	
	// MARK: Private properties
	
	private lazy var pageControl: UIPageControl = {
		let pageControll = UIPageControl()
		
		pageControll.translatesAutoresizingMaskIntoConstraints = false
		
		pageControll.numberOfPages = pages.count
		pageControll.currentPage = 0
		
		pageControll.currentPageIndicatorTintColor = .ypBlack
		pageControll.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
		
		return pageControll
	}()
	
	private lazy var pages: [UIViewController] = {
		let first = getOnboardingViewController(
			imageName: "Onboarding1",
			text: "Отслеживайте только то, что хотите")
		let second = getOnboardingViewController(
			imageName: "Onboarding2",
			text: "Даже если это не литры воды и йога")
		
		return [first, second]
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dataSource = self
		delegate = self
		
		if let first = pages.first {
			setViewControllers(
				[first],
				direction: .forward,
				animated: true)
		}
		
		view.addSubview(pageControl)
		
		NSLayoutConstraint.activate([
			pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
			pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])
	}
	
	// MARK: Private methods
	
	private func getOnboardingViewController(imageName: String, text: String) -> UIViewController {
		let viewController = UIViewController()
		let image = UIImage(named: imageName)
		let imageView = UIImageView(image: image)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlack
		button.setTitle("Вот это технологии!", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(navigateToTrackersViewController), for: .touchUpInside)
		
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = text
		label.font = .systemFont(ofSize: 32, weight: .bold)
		label.textColor = .ypBlack
		label.textAlignment = .center
		label.numberOfLines = 2
		
		viewController.view.addSubview(imageView)
		viewController.view.addSubview(button)
		viewController.view.addSubview(label)
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
			imageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
			
			button.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
			button.heightAnchor.constraint(equalToConstant: 60),
			button.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			button.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
			
			label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),
			label.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			label.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
		])
		
		return viewController
	}
	
	@objc private func navigateToTrackersViewController() {
		guard let window = UIApplication.shared.windows.first else {
			fatalError("Invalid Configuration")
		}
		
		UserDefaults.standard.set(true, forKey: "SkipOnboarding")
		
		let navigationController = UINavigationController(rootViewController: TrackersViewController())
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

// MARK: UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController? {
		guard let index = pages.firstIndex(of: viewController) else {
			return nil
		}
		
		let newIndex = index - 1
		
		guard newIndex >= 0 else {
			return nil
		}
		
		return pages[newIndex]
	}
	
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController? {
		guard let index = pages.firstIndex(of: viewController) else {
			return nil
		}
		
		let newIndex = index + 1
		
		guard newIndex < pages.count else {
			return nil
		}
		
		return pages[newIndex]
	}
}

// MARK: UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
	func pageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating finished: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted completed: Bool
	) {
		guard let currentViewController = pageViewController.viewControllers?.first,
			  let currentIndex = pages.firstIndex(of: currentViewController) else {
			return
		}
		
		pageControl.currentPage = currentIndex
	}
}

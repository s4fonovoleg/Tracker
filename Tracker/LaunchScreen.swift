import UIKit

final class LaunchScreen: UIViewController {
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
		navigateToOnboardingViewController()
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
}

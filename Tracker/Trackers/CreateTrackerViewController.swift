import UIKit

final class CreateTrackerViewController: UIViewController, CreateTrackerDelegateProtocol {
	// MARK: Public properties
	
	var delegate: CreateTrackerDelegateProtocol?
	
	// MARK: UI properies
	
	private lazy var headerLabel = {
		let label = UILabel()
		label.text = "Создание трекера"
		label.textColor = .black
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var addHabitButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlackButton
		button.setTitle("Привычка", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.layer.cornerRadius = 16
		
		return button
	}()
	
	private lazy var addIrregularEventButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlackButton
		button.setTitle("Нерегулярное событие", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.layer.cornerRadius = 16
		
		return button
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		addHeaderLabel()
		addButtons()
	}
	
	// MARK: UI methods
	
	private func addHeaderLabel() {
		view.addSubview(headerLabel)
		
		NSLayoutConstraint.activate([
			headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
	}
	
	private func addButtons() {
		let stackView = UIStackView()
		stackView.addSubview(addHabitButton)
		stackView.addSubview(addIrregularEventButton)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.backgroundColor = .white
		stackView.axis = .vertical
		
		view.addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.heightAnchor.constraint(equalToConstant: 136),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			stackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 295),

			addHabitButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
			addHabitButton.heightAnchor.constraint(equalToConstant: 60),
			addHabitButton.topAnchor.constraint(equalTo: stackView.topAnchor),

			addIrregularEventButton.topAnchor.constraint(equalTo: addHabitButton.bottomAnchor, constant: 16),
			addIrregularEventButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
			addIrregularEventButton.heightAnchor.constraint(equalToConstant: 60)
		])
		
		addHabitButton.addTarget(self, action: #selector(addHabitButtonDidTap), for: .touchUpInside)
		addIrregularEventButton.addTarget(self, action: #selector(addIrregularEventButtonDidTap), for: .touchUpInside)
	}
	
	// MARK: Private methods
	
	@objc private func addHabitButtonDidTap() {
		let controller = CreateHabitViewController()
		controller.modalPresentationStyle = .pageSheet
		controller.delegate = self
		
		present(controller, animated: true)
	}
	
	@objc private func addIrregularEventButtonDidTap() {
		let controller = CreateIrregularEventViewController()
		controller.modalPresentationStyle = .pageSheet
		controller.delegate = self
		
		present(controller, animated: true)
	}
	
	// MARK: Public methods
	
	func trackerCreated(tracker: Tracker) {
		delegate?.trackerCreated(tracker: tracker)
		self.presentingViewController?.dismiss(animated: true)
	}
}

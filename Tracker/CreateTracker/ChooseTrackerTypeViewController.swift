import UIKit

final class ChooseTrackerTypeViewController: UIViewController {
	
	// MARK: Public properties
	
	var delegate: CreateTrackerDelegateProtocol?
	
	// MARK: UI properies
	
	private lazy var headerLabel = {
		let label = UILabel()
		label.text = NSLocalizedString(
			"creatingTracker",
			comment: "Заголовок создания трекера"
		)
		label.textColor = .black
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var addHabitButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlack
		button.setTitle(
			NSLocalizedString(
				"habit",
				comment: "Заголовок кнопки создания привычки"
			),
			for: .normal
		)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.layer.cornerRadius = 16
		
		return button
	}()
	
	private lazy var addIrregularEventButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlack
		button.setTitle(
			NSLocalizedString(
				"irregularEvent",
				comment: "Заголовок кнопки создания нерегулярного события"
			),
			for: .normal
		)
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
		addNewTracker(isHabit: true)
	}
	
	@objc private func addIrregularEventButtonDidTap() {
		addNewTracker(isHabit: false)
	}
	
	private func addNewTracker(isHabit: Bool) {
		let controller = CreateTrackerViewController()
		controller.modalPresentationStyle = .pageSheet
		controller.delegate = self
		controller.isHabit = isHabit
		
		present(controller, animated: true)
	}
}

extension ChooseTrackerTypeViewController: CreateTrackerDelegateProtocol {
	func editTracker(tracker: Tracker, in category: TrackerCategory) {
		delegate?.editTracker(tracker: tracker, in: category)
		self.presentingViewController?.dismiss(animated: true)
	}
	
	func trackerCreated(tracker: Tracker, in category: TrackerCategory) {
		delegate?.trackerCreated(tracker: tracker, in: category)
		self.presentingViewController?.dismiss(animated: true)
	}
}

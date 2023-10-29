import UIKit

final class CreateHabitViewController: UIViewController, ScheduleViewControllerDelegateProtocol {
	// MARK: Private properties
	
	private var weekDays: Set<WeekDay> = Set()
	
	// MARK: Public properties
	
	var delegate: CreateTrackerDelegateProtocol?
	
	// MARK: UI properties
	
	private lazy var headerLabel = {
		let label = UILabel()
		label.text = "Новая привычка"
		label.textColor = .black
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var trackerNameTextField = {
		let textField = UITextFieldWithPadding()
		
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.placeholder = "Введите название трекера"
		textField.layer.cornerRadius = 16
		textField.backgroundColor = .lightGreyBackground
		textField.leftInset = 16
		textField.rightInset = 16
		
		return textField
	}()
	
	private lazy var categoryButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .lightGreyBackground
		button.setTitle("Категория", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .light)
		button.layer.cornerRadius = 16
		button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		button.contentHorizontalAlignment = .leading
		button.titleEdgeInsets.left = 16
		button.titleEdgeInsets.right = 16
		
		return button
	}()
	
	private lazy var scheduleButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .lightGreyBackground
		button.setTitle("Расписание", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .light)
		button.layer.cornerRadius = 16
		button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		button.contentHorizontalAlignment = .leading
		button.titleEdgeInsets.left = 16
		button.titleEdgeInsets.right = 16
		
		return button
	}()
	
	private lazy var divider = {
		let divider = UIView(frame: CGRect(x: 0, y: 0, width: 311.09, height: 0.5))
		
		divider.translatesAutoresizingMaskIntoConstraints = false
		divider.backgroundColor = .greyDividerColor
		
		return divider
	}()
	
	private lazy var cancelButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .white
		button.setTitle("Отменить", for: .normal)
		button.setTitleColor(.ypRedButton, for: .normal)
		button.layer.cornerRadius = 16
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.ypRedButton.cgColor
		
		return button
	}()
	
	private lazy var createButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlackButton
		button.setTitle("Создать", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 16
		
		return button
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		addHeaderLabel()
		addTextField()
		addCategoryButton()
		addDivider()
		addScheduleButton()
		addCancelButton()
		addCreateButton()
	}
	
	// MARK: UI Methods
	
	private func addHeaderLabel() {
		view.addSubview(headerLabel)
		
		NSLayoutConstraint.activate([
			headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
	}
	
	private func addTextField() {
		view.addSubview(trackerNameTextField)
		
		NSLayoutConstraint.activate([
			trackerNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			trackerNameTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
			trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
			trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
	}
	
	private func addCategoryButton() {
		view.addSubview(categoryButton)
		
		let accessoryImage = UIImage(named: "RightAccessoryArrow")
		let accessoryImageView = UIImageView(image: accessoryImage)
		accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
		view.insertSubview(accessoryImageView, belowSubview: categoryButton)
		
		NSLayoutConstraint.activate([
			categoryButton.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
			categoryButton.heightAnchor.constraint(equalToConstant: 75),
			categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			
			accessoryImageView.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
			accessoryImageView.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
			accessoryImageView.widthAnchor.constraint(equalToConstant: 24),
			accessoryImageView.heightAnchor.constraint(equalToConstant: 24)
		])
	}
	
	private func addDivider() {
		categoryButton.addSubview(divider)
		
		NSLayoutConstraint.activate([
			divider.centerYAnchor.constraint(equalTo: categoryButton.bottomAnchor),
			divider.heightAnchor.constraint(equalToConstant: divider.frame.height),
			divider.widthAnchor.constraint(equalToConstant: divider.frame.width),
			divider.centerXAnchor.constraint(equalTo: categoryButton.centerXAnchor)
		])
	}
	
	private func addScheduleButton() {
		view.addSubview(scheduleButton)
		
		let accessoryImage = UIImage(named: "RightAccessoryArrow")
		let accessoryImageView = UIImageView(image: accessoryImage)
		accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
		view.insertSubview(accessoryImageView, belowSubview: scheduleButton)
		
		NSLayoutConstraint.activate([
			scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
			scheduleButton.heightAnchor.constraint(equalToConstant: 75),
			scheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			scheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			
			accessoryImageView.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor),
			accessoryImageView.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor, constant: -16),
			accessoryImageView.widthAnchor.constraint(equalToConstant: 24),
			accessoryImageView.heightAnchor.constraint(equalToConstant: 24)
		])
		
		scheduleButton.addTarget(self, action: #selector(openScheduleView), for: .touchUpInside)
	}
	
	private func addCancelButton() {
		view.addSubview(cancelButton)
		
		// 20 - отступы кнопок от краев экрана, 8 - отступ между кнопками
		let buttonWidth = (view.frame.width - 48) / 2
		
		NSLayoutConstraint.activate([
			cancelButton.heightAnchor.constraint(equalToConstant: 60),
			cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			cancelButton.widthAnchor.constraint(equalToConstant: buttonWidth)
		])
		
		cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
	}
	
	private func addCreateButton() {
		view.addSubview(createButton)
		
		// 20 - отступы кнопок от краев экрана, 8 - отступ между кнопками
		let buttonWidth = (view.frame.width - 48) / 2
		
		NSLayoutConstraint.activate([
			createButton.heightAnchor.constraint(equalToConstant: 60),
			createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			createButton.widthAnchor.constraint(equalToConstant: buttonWidth)
		])
		
		createButton.addTarget(self, action: #selector(createButtonDidTap), for: .touchUpInside)
	}
	
	// MARK: Private methods
	
	@objc private func cancelButtonDidTap() {
		dismiss(animated: true)
	}
	
	@objc private func createButtonDidTap() {
		delegate?.trackerCreated(tracker: Tracker(
			id: UUID(),
			name: trackerNameTextField.text ?? "",
			color: .lightGray,
			emoji: "🤪",
			weekDays: weekDays)
		)
		dismiss(animated: true)
	}
	
	@objc private func openScheduleView() {
		let controller = ScheduleViewController()
		controller.modalPresentationStyle = .pageSheet
		controller.delegate = self
		controller.weekDays = weekDays
		
		present(controller, animated: true)
	}
	
	// MARK: Public methods
	
	func addSchedule(weekDays: Set<WeekDay>) {
		self.weekDays = weekDays
	}
}

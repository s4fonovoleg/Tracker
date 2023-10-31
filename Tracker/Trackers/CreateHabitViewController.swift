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
	
	private lazy var categoryAccessoryImageView = {
		let accessoryImage = UIImage(named: "RightAccessoryArrow")
		let accessoryImageView = UIImageView(image: accessoryImage)
		accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
		
		return accessoryImageView
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
		button.addTarget(self, action: #selector(openScheduleView), for: .touchUpInside)
		
		return button
	}()
	
	private lazy var scheduleAccessoryImageView = {
		let accessoryImage = UIImage(named: "RightAccessoryArrow")
		let accessoryImageView = UIImageView(image: accessoryImage)
		accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
		
		return accessoryImageView
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
		button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
		
		return button
	}()
	
	private lazy var createButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlackButton
		button.setTitle("Создать", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(createButtonDidTap), for: .touchUpInside)
		
		return button
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		
		setupViews()
		setupConstraints()
	}
	
	// MARK: UI Methods
	
	private func setupViews() {
		view.addSubview(headerLabel)
		view.addSubview(trackerNameTextField)
		view.addSubview(categoryButton)
		categoryButton.addSubview(divider)
		view.addSubview(scheduleButton)
		view.addSubview(cancelButton)
		view.addSubview(createButton)
		view.insertSubview(categoryAccessoryImageView, belowSubview: categoryButton)
		view.insertSubview(scheduleAccessoryImageView, belowSubview: categoryButton)
	}
	
	private func setupConstraints() {
		setupHeaderConstraints()
		setupTextFieldConstraints()
		setupCategoryButtonConstraints()
		setupDividerConstraints()
		setupScheduleButtonConstraints()
		setupCancelButtonConstraints()
		setupCreateButtonConstraints()
	}
	
	private func setupHeaderConstraints() {
		NSLayoutConstraint.activate([
			headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
	}
	
	private func setupTextFieldConstraints() {
		NSLayoutConstraint.activate([
			trackerNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			trackerNameTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
			trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
			trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
	}
	
	private func setupCategoryButtonConstraints() {
		NSLayoutConstraint.activate([
			categoryButton.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
			categoryButton.heightAnchor.constraint(equalToConstant: 75),
			categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			
			categoryAccessoryImageView.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
			categoryAccessoryImageView.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
			categoryAccessoryImageView.widthAnchor.constraint(equalToConstant: 24),
			categoryAccessoryImageView.heightAnchor.constraint(equalToConstant: 24)
		])
	}
	
	private func setupDividerConstraints() {
		NSLayoutConstraint.activate([
			divider.centerYAnchor.constraint(equalTo: categoryButton.bottomAnchor),
			divider.heightAnchor.constraint(equalToConstant: divider.frame.height),
			divider.widthAnchor.constraint(equalToConstant: divider.frame.width),
			divider.centerXAnchor.constraint(equalTo: categoryButton.centerXAnchor)
		])
	}
	
	private func setupScheduleButtonConstraints() {
		NSLayoutConstraint.activate([
			scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
			scheduleButton.heightAnchor.constraint(equalToConstant: 75),
			scheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			scheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			
			scheduleAccessoryImageView.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor),
			scheduleAccessoryImageView.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor, constant: -16),
			scheduleAccessoryImageView.widthAnchor.constraint(equalToConstant: 24),
			scheduleAccessoryImageView.heightAnchor.constraint(equalToConstant: 24)
		])
	}
	
	private func setupCancelButtonConstraints() {
		// 20 - отступы кнопок от краев экрана, 8 - отступ между кнопками
		let buttonWidth = (view.frame.width - 48) / 2
		
		NSLayoutConstraint.activate([
			cancelButton.heightAnchor.constraint(equalToConstant: 60),
			cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			cancelButton.widthAnchor.constraint(equalToConstant: buttonWidth)
		])
	}
	
	private func setupCreateButtonConstraints() {
		// 20 - отступы кнопок от краев экрана, 8 - отступ между кнопками
		let buttonWidth = (view.frame.width - 48) / 2
		
		NSLayoutConstraint.activate([
			createButton.heightAnchor.constraint(equalToConstant: 60),
			createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			createButton.widthAnchor.constraint(equalToConstant: buttonWidth)
		])
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

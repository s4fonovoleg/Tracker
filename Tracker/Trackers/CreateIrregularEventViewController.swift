import UIKit

final class CreateIrregularEventViewController: UIViewController {
	// MARK: Public properties
	
	var delegate: CreateTrackerDelegateProtocol?
	
	// MARK: UI properties
	
	private lazy var headerLabel = {
		let label = UILabel()
		label.text = "Новое нерегулярное событие"
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
		button.contentHorizontalAlignment = .leading
		button.titleEdgeInsets.left = 16
		button.titleEdgeInsets.right = 16
		
		return button
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
		addCancelButton()
		addCreateButton()
	}
	
	// MARK: UI methods
	
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
		
	}
}

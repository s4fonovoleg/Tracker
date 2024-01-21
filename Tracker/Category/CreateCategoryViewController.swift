import UIKit

protocol CreateCategoryDelegateProtocol {
	func categoryCreated(name: String)
}

final class CreateCategoryViewController: UIViewController {
	
	// MARK: Private properties
	
	var delegate: CreateCategoryDelegateProtocol?
	
	// MARK: Private UI properties
	
	private lazy var headerLabel = {
		let label = UILabel()
		label.text = "Категория"
		label.textColor = .black
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var categoryNameTextField = {
		let textField = UITextFieldWithPadding()
		
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.placeholder = "Введите название категории"
		textField.layer.cornerRadius = 16
		textField.backgroundColor = .lightGreyBackground
		textField.leftInset = 16
		textField.rightInset = 16
		
		return textField
	}()
	
	private lazy var doneButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlack
		button.setTitle("Готово", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
		
		return button
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupViews()
		setupConstraints()
	}
	
	// MARK: Private methods
	
	private func setupViews() {
		view.backgroundColor = .white
		view.addSubview(headerLabel)
		view.addSubview(categoryNameTextField)
		view.addSubview(doneButton)
	}
	
	private func setupConstraints() {
		setupHeaderConstraints()
		setupTextFieldConstraints()
		setupDoneButtonConstraints()
	}
	
	private func setupHeaderConstraints() {
		NSLayoutConstraint.activate([
			headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27)
		])
	}
	
	private func setupTextFieldConstraints() {
		NSLayoutConstraint.activate([
			categoryNameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			categoryNameTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
			categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
			categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
	}
	
	private func setupDoneButtonConstraints() {
		NSLayoutConstraint.activate([
			doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			doneButton.heightAnchor.constraint(equalToConstant: 60),
			doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
	}
	
	@objc private func doneButtonDidTap() {
		guard let name = categoryNameTextField.text else {
			return
		}
		
		delegate?.categoryCreated(name: name)
		dismiss(animated: true)
	}
}

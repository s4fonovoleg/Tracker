import UIKit

protocol CategoryViewControllerDelegate {
	func categorySelected(_ category: TrackerCategory)
}

final class CategoryViewController: UIViewController {
	
	// MARK: Public properties
	
	var delegate: CategoryViewControllerDelegate?
	
	// MARK: Private properties
	
	private let reuseIdentifier = "cell"
	
	private let viewModel = CategoriesViewModel()
	
	// MARK: Private UI properties
	
	private lazy var headerLabel = {
		let label = UILabel()
		label.text = "Категория"
		label.textColor = .black
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private let tableView = {
		let tableView = UITableView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.separatorStyle = .none
		
		return tableView
	}()
	
	private lazy var emptyCategoriesImageView = {
		let image = UIImage(named: "EmptyListImage")
		let view = UIImageView(image: image)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	private lazy var emptyCategoriesLabel = {
		let label = UILabel()
		label.text = """
					Привычки и события можно
					объединить по смыслу
					"""
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 2
		label.textAlignment = .center
		
		return label
	}()
	
	private lazy var addCategoryButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlack
		button.setTitle("Добавить категорию", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(addCategoryButtonDidTap), for: .touchUpInside)
		
		return button
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupViews()
		setupConstraints()
		
		viewModel.$categories.bind(action: { _ in
			self.tableView.reloadData()
		})
	}
	
	// MARK: Private methods
	
	private func setupViews() {
		view.backgroundColor = .white
		
		view.addSubview(headerLabel)
		view.addSubview(addCategoryButton)
		view.addSubview(tableView)
		view.addSubview(emptyCategoriesImageView)
		view.addSubview(emptyCategoriesLabel)
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
	}
	
	private func setupConstraints() {
		setupHeaderLabelConstraints()
		setupEmptyCategoriesImageViewConstraints()
		setupEmptyCategoriesLabelConstraints()
		setupAddCategoryButtonConstraints()
		setupTableViewConstraints()
	}
	
	private func setupHeaderLabelConstraints() {
		NSLayoutConstraint.activate([
			headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
	}
	
	private func setupAddCategoryButtonConstraints() {
		NSLayoutConstraint.activate([
			addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
			addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
	}
	
	private func setupEmptyCategoriesImageViewConstraints() {
		NSLayoutConstraint.activate([
			emptyCategoriesImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
			emptyCategoriesImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
			emptyCategoriesImageView.widthAnchor.constraint(equalToConstant: 80),
			emptyCategoriesImageView.heightAnchor.constraint(equalToConstant: 80)
		])
	}
	
	private func setupEmptyCategoriesLabelConstraints() {
		NSLayoutConstraint.activate([
			emptyCategoriesLabel.topAnchor.constraint(equalTo: emptyCategoriesImageView.bottomAnchor, constant: 8),
			emptyCategoriesLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
		])
	}
	
	private func setupTableViewConstraints() {
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
			tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
	}
	
	@objc private func addCategoryButtonDidTap() {
		let controller = CreateCategoryViewController()
		controller.modalPresentationStyle = .pageSheet
		controller.delegate = self
		
		present(controller, animated: true)
	}
	
	private func categorySelected(_ category: TrackerCategory) {
		delegate?.categorySelected(category)
		dismiss(animated: true)
	}
}

// MARK: UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.categories.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? CategoryTableViewCell else {
			return CategoryTableViewCell()
		}
		
		var viewModel = viewModel.categories[indexPath.item]
		viewModel.first = indexPath.item == 0
		viewModel.last = indexPath.item + 1 == self.viewModel.categories.count
		
		cell.viewModel = viewModel
		
		return cell
	}
}

// MARK: UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		75
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let category = viewModel.didSelectRow(index: indexPath.item)
		
		categorySelected(category)
	}
}

// MARK: CreateCategoryDelegateProtocol

extension CategoryViewController: CreateCategoryDelegateProtocol {
	func categoryCreated(name: String) {
		viewModel.createCategory(name: name)
	}
}

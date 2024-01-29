import UIKit

protocol FiltersViewControllerDelegate {
	func applyFilter(_ filterIndex: Int)
}

final class FiltersViewController: UIViewController {
	
	// MARK: Public properties
	
	var selectedFilterIndex: Int?
	var delegate: FiltersViewControllerDelegate?
	
	// MARK: Private properties
	
	private let reuseIdentifier = "cell"
	
	private let filters = [
		NSLocalizedString(
			"filters.allTrackers",
			comment: "Фильтры: все трекеры"
		),
		NSLocalizedString(
			"filters.todayTrackers",
			comment: "Фильтры: трекеры на сегодня"
		),
		NSLocalizedString(
			"filters.completed",
			comment: "Фильтры: завершенные"
		),
		NSLocalizedString(
			"filters.notCompleted",
			comment: "Фильтры: не завершенные"
		)
	]
	
	// MARK: Private UI properties
	
	private lazy var headerLabel = {
		let label = UILabel()
		label.text = NSLocalizedString(
			"filtersButton",
			comment: "Заголовок кнопки фильтров"
		)
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
		view.addSubview(tableView)
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(
			FiltersTableViewCell.self,
			forCellReuseIdentifier: reuseIdentifier
		)
	}
	
	private func setupConstraints() {
		setupHeaderLabelConstraints()
		setupTableViewConstraints()
	}
	
	private func setupHeaderLabelConstraints() {
		NSLayoutConstraint.activate([
			headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
	}
	
	private func setupTableViewConstraints() {
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
	}
}

// MARK: UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		filters.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(
			withIdentifier: reuseIdentifier,
			for: indexPath
		) as? FiltersTableViewCell else {
			return FiltersTableViewCell()
		}
		
		let filter = filters[indexPath.row]
		let checked = indexPath.row == selectedFilterIndex
		
		cell.configure(
			title: filter,
			first: indexPath.item == 0,
			last: indexPath.item + 1 == filters.count, 
			checked: checked
		)
		
		return cell
	}
}

// MARK: UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		75
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		delegate?.applyFilter(indexPath.row)
		
		dismiss(animated: true)
	}
}

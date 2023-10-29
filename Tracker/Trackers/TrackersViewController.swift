import UIKit

final class TrackersViewController: UIViewController, CreateTrackerDelegateProtocol {
	// MARK: Private properties
	private let defaultCategoryName = "Общее"
	
	private let calendar = Calendar(identifier: .gregorian)
	
	private let cellReuseIdentifier = "cell"
	
	private var currentDate: Date = Date() {
		didSet {
			filterCategories()
		}
	}
	
	private var categories: [TrackerCategory] = []
	
	private var visibleCategories: [TrackerCategory] = [TrackerCategory]() {
		didSet {
			updateEmptyTrackersImage()
		}
	}
	
	private var completedTrackers: [TrackerRecord] = [TrackerRecord]()
	
	// MARK: UI properties
	
	private lazy var datePicker = {
		let datePicker = UIDatePicker()
		datePicker.preferredDatePickerStyle = .compact
		datePicker.datePickerMode = .date
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		datePicker.locale = .current
		
		return datePicker
	}()
	
	private lazy var trackerLabel = {
		let trackerLabel = UILabel()
		trackerLabel.text = "Трекеры"
		trackerLabel.font = .systemFont(ofSize: 34, weight: .bold)
		trackerLabel.translatesAutoresizingMaskIntoConstraints = false
		trackerLabel.textColor = .black
		
		return trackerLabel
	}()
	
	private lazy var searchField = {
		let searchField = UISearchTextField()
		searchField.translatesAutoresizingMaskIntoConstraints = false
		searchField.placeholder = "Поиск"
		searchField.addTarget(self, action: #selector(searchFieldChanged), for: .editingChanged)
		
		return searchField
	}()
	
	private lazy var emptyTrackersImageView = {
		let image = UIImage(named: "EmptyTrackersImage")
		let view = UIImageView(image: image)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	private lazy var emptyTrackersLabel = {
		let label = UILabel()
		label.text = "Что будем отслеживать?"
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var collectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		return collectionView
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initUI()
		updateEmptyTrackersImage()
	}
	
	// MARK: UI methods
	
	private func initUI() {
		view.backgroundColor = .white
		
		addNavigationBarItems()
		addTrackerLabel()
		addSearchField()
		addCollectionView()
		addEmptyTrackersImageView()
		addEmptyTrackersLabel()
	}
	
	private func addNavigationBarItems() {
		guard let navigationBar = navigationController?.navigationBar else {
			return
		}
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidTap))
		addButton.tintColor = .black

		navigationBar.topItem?.leftBarButtonItem = addButton
		navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
		
		datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
	}
	
	private func addTrackerLabel() {
		view.addSubview(trackerLabel)
		
		NSLayoutConstraint.activate([
			trackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			trackerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
		])
	}
	
	private func addSearchField() {
		view.addSubview(searchField)
		searchField.delegate = self
		
		NSLayoutConstraint.activate([
			searchField.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 16),
			searchField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			searchField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
		])
	}
	
	private func addEmptyTrackersImageView() {
		view.addSubview(emptyTrackersImageView)
		
		NSLayoutConstraint.activate([
			emptyTrackersImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
			emptyTrackersImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
			emptyTrackersImageView.widthAnchor.constraint(equalToConstant: 80),
			emptyTrackersImageView.heightAnchor.constraint(equalToConstant: 80)
		])
	}
	
	private func addEmptyTrackersLabel() {
		view.addSubview(emptyTrackersLabel)
		
		NSLayoutConstraint.activate([
			emptyTrackersLabel.topAnchor.constraint(equalTo: emptyTrackersImageView.bottomAnchor),
			emptyTrackersLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
		])
	}
	
	private func addCollectionView() {
		view.addSubview(collectionView)
		
		collectionView.dataSource = self
		collectionView.delegate = self
		
		collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
		collectionView.register(TrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 34),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
	// MARK: Private methods
	
	@objc private func dateChanged(sender: UIDatePicker) {
		currentDate = sender.date
	}
	
	@objc private func addButtonDidTap() {
		let controller = CreateTrackerViewController()
		controller.modalPresentationStyle = .pageSheet
		controller.delegate = self
		
		present(controller, animated: true)
	}
	
	@objc private func searchFieldChanged(_ textField: UITextField) {
		filterCategories()
	}
	
	private func updateEmptyTrackersImage() {
		emptyTrackersImageView.isHidden = !visibleCategories.isEmpty
		emptyTrackersLabel.isHidden = !visibleCategories.isEmpty
	}
	
	private func filterCategories() {
		let date = datePicker.date
		let weekDayNum = calendar.component(.weekday, from: date)
		
		guard let text = searchField.text,
			  let weekDay = WeekDay(rawValue: weekDayNum) else {
			return
		}
		
		var filteredCategories = [TrackerCategory]()
		
		for category in categories {
			let visibleTrackers = category.trackers.filter { tracker in
				(text.isEmpty || tracker.name.contains(text)) &&
				tracker.weekDays.contains(weekDay)
			}
			
			if !visibleTrackers.isEmpty {
				let newCategory = TrackerCategory(
					name: category.name,
					trackers: visibleTrackers
				);
				filteredCategories.append(newCategory)
			}
		}
		
		visibleCategories = filteredCategories
		collectionView.reloadData()
	}
	
	// MARK: Public methods
	
	func trackerCreated(tracker: Tracker) {
		let currentCategories = categories
		let currentTrackers = currentCategories.count > 0 ?
			currentCategories[0].trackers :
			[Tracker]()
		
		var newCategories = currentCategories
		var newTrackers = currentTrackers
		
		newTrackers.append(tracker)
		
		newCategories.append(TrackerCategory(name: defaultCategoryName, trackers: newTrackers))
		
		categories = newCategories
		
		filterCategories()
	}
}

// MARK: UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let num = visibleCategories.count - 1 < section ? 0 : visibleCategories[section].trackers.count
		print(visibleCategories.count - 1 < section)
		
		return num
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? TrackerViewCell else {
			return TrackerViewCell()
		}
		
		let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
		let completedTrackersOnDateCount = completedTrackers.filter { trackerRecord in
			trackerRecord.trackerId == tracker.id &&
			trackerRecord.date == datePicker.date
		}.count
		
		cell.delegate = self
		cell.configure(tracker: tracker, doneOnDate: completedTrackersOnDateCount > 0)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let supplementaryView =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerSupplementaryView else {
			return TrackerSupplementaryView()
		}

		supplementaryView.titleLabel.text =
			visibleCategories.count - 1 < indexPath.section ?
			"" :
			visibleCategories[indexPath.section].name
		return supplementaryView
	}
}

// MARK: TrackerViewCellDelegate

extension TrackersViewController: TrackerViewCellDelegate {
	func doneButtonDidTap(_ cell: TrackerViewCell) {
		guard let tracker = cell.tracker else {
			return
		}
		
		let date = datePicker.date
		
		if date > Date() {
			return
		}
		
		var completedTrackersOnDateCount = completedTrackers.filter { trackerRecord in
			trackerRecord.trackerId == tracker.id &&
			trackerRecord.date == date
		}.count
		
		if completedTrackersOnDateCount > 0 {
			completedTrackers.removeAll { trackerRecord in
				trackerRecord.trackerId == tracker.id &&
				trackerRecord.date == date
			}
			completedTrackersOnDateCount -= 1
		} else {
			completedTrackers.append(TrackerRecord(trackerId: tracker.id, date: date))
			completedTrackersOnDateCount += 1
		}
		
		let completedTrackersCount = completedTrackers.filter { trackerRecord in
			trackerRecord.trackerId == tracker.id
		}.count
		
		let daysCaption = getNumberEnding(
			for: completedTrackersCount,
			"дней",
			"день",
			"дня")
		
		cell.countLabel.text = "\(completedTrackersCount) \(daysCaption)"
		cell.doneOnDate = completedTrackersOnDateCount > 0
	}
}

// MARK: UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
	
}

// MARK: UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		CGSize(width: collectionView.bounds.width / 2 - 7, height: 148)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		7
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		let indexPath = IndexPath(row: 0, section: section)
		let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
		
		return headerView.systemLayoutSizeFitting(CGSize(
			width: collectionView.frame.width,
			height: UIView.layoutFittingExpandedSize.height),
			withHorizontalFittingPriority: .required,
			verticalFittingPriority: .fittingSizeLevel)
	}
}

extension TrackersViewController: UITextFieldDelegate {
//	func textFieldDidEndEditing(_ textField: UITextField) {
//
//	}
//
//	func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
//		let x = 42
//	}
//
//	func textFieldDidBeginEditing(_ textField: UITextField) {
//		guard let text = textField.text else {
//			return
//		}
//
//		if (text.isEmpty) {
//			return
//		}
//
//		var newCategories = [TrackerCategory]()
//
//		for category in categories {
//			let visibleTrackers = category.trackers.filter { tracker in
//				tracker.name.contains(text)
//			}
//
//			if !visibleTrackers.isEmpty {
//				let newCategory = TrackerCategory(
//					name: category.name,
//					trackers: []
//				);
//				newCategories.append(newCategory)
//			}
//		}
//
//		categories = newCategories
//		collectionView.reloadData()
//	}
}

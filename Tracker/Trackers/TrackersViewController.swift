import UIKit

final class TrackersViewController: UIViewController, CreateTrackerDelegateProtocol {
	// MARK: Private properties

	private let defaultCategoryName = "Общее"
	private let cellReuseIdentifier = "cell"
	private var calendar = Calendar(identifier: .gregorian)
	
	private var currentDate: Date = Date() {
		didSet {
			filterCategories()
		}
	}
	
	private var categories: [TrackerCategory] = [] {
		didSet {
			filterCategories()
		}
	}
	
	private var visibleCategories: [TrackerCategory] = [TrackerCategory]()
	
	private var completedTrackers: [TrackerRecord] = [TrackerRecord]() {
		didSet {
			filterCategories()
		}
	}
	
	private let dataProvider = DataProvider()
	
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
		dataProvider.delegate = self
		categories = dataProvider.categories
		completedTrackers = dataProvider.trackerRecords
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
			searchField.heightAnchor.constraint(equalToConstant: 36),
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
		let controller = ChooseTrackerTypeViewController()
		controller.modalPresentationStyle = .pageSheet
		controller.delegate = self
		
		present(controller, animated: true)
	}
	
	private func updateEmptyTrackersImage() {
		emptyTrackersImageView.isHidden = !visibleCategories.isEmpty
		emptyTrackersLabel.isHidden = !visibleCategories.isEmpty
	}
	
	private func filterCategories() {
		guard let date = datePicker.date.removeTime else {
			return
		}
		
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
		updateEmptyTrackersImage()
	}
	
	// MARK: Public methods
	
	func trackerCreated(tracker: Tracker) {
		if categories.isEmpty {
			categories.append(TrackerCategory(
				name: defaultCategoryName,
				trackers: [Tracker]())
			)
		}
		try? dataProvider.trackerCreated(tracker, in: categories[0])
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
		let completed = completedTrackers.filter { trackerRecord in
			trackerRecord.trackerId == tracker.id &&
			trackerRecord.date == datePicker.date.removeTime
		}.count > 0
		let totalCompletedCounter = completedTrackers.filter { trackerRecord in
			trackerRecord.trackerId == tracker.id
		}.count
		
		cell.delegate = self
		cell.configure(tracker: tracker, completedOnDate: completed, counter: totalCompletedCounter)
		
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
		guard let tracker = cell.tracker,
			  let date = datePicker.date.removeTime,
			  date <= Date() else {
			return
		}
		
		let trackerRecord = TrackerRecord(trackerId: tracker.id, date: date)
		var completedToday = completedTrackers.filter { trackerRecord in
			trackerRecord.trackerId == tracker.id &&
			trackerRecord.date == date
		}.count > 0
		
		dataProvider.setTrackerRecord(trackerRecord, completed: completedToday)
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

// MARK: UITextFieldDelegate

extension TrackersViewController: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		filterCategories()
		return true
	}
}

// MARK: DataProviderDelegate

extension TrackersViewController: DataProviderDelegate {
	func didChangeCategory() {
		categories = dataProvider.categories
	}
	
	func didChangeTracker() {
		categories = dataProvider.categories
	}
	
	func didChangeTrackerRecord() {
		completedTrackers = dataProvider.trackerRecords
	}
}

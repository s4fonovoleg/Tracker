import UIKit

final class TrackersViewController: UIViewController {
	
	// MARK: Public properties
	
	var dataProvider: DataProviderProtocol?
	
	// MARK: Private properties
	
	private var currentFilterIndex = 0 {
		didSet {
			if currentFilterIndex == 1 {
				let date = Date()
				datePicker.date = date
				currentDate = date
			}
			filterCategories()
			UserDefaults.standard.set(currentFilterIndex, forKey: "CurrentFilterIndex")
		}
	}
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
	
	// MARK: UI properties
	
	private lazy var addButton = {
		let addButton = UIBarButtonItem(
			barButtonSystemItem: .add,
			target: self,
			action: #selector(addButtonDidTap)
		)
		addButton.tintColor = .ypTextColor
		
		return addButton
	}()
	
	private lazy var datePicker = {
		let datePicker = UIDatePicker()
		datePicker.preferredDatePickerStyle = .compact
		datePicker.datePickerMode = .date
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		datePicker.locale = .current
		datePicker.calendar.firstWeekday = 2
		datePicker.addTarget(
			self, 
			action: #selector(dateChanged),
			for: .valueChanged
		)
		
		return datePicker
	}()
	
	private lazy var searchController = {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = NSLocalizedString(
			"search",
			comment: "Placeholder поля поиска"
		)
		searchController.searchResultsUpdater = self
		searchController.hidesNavigationBarDuringPresentation = false
		
		return searchController
	}()
	
	private lazy var emptyTrackersImageView = {
		let image = UIImage(named: "EmptyListImage")
		let view = UIImageView(image: image)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	private lazy var emptyTrackersLabel = {
		let label = UILabel()
		label.text = NSLocalizedString(
			"whatWillWeTrack",
			comment: "Сообщение при пустом списке трекеров"
		)
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = .ypTextColor
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var filtersButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlue
		button.setTitle(
			NSLocalizedString(
				"filtersButton",
				comment: "Заголовок кнопки фильтров"
			),
			for: .normal
		)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
		button.layer.cornerRadius = 16
		button.addTarget(
			self,
			action: #selector(filtersButtonDidTap),
			for: .touchUpInside
		)
		
		return button
	}()
	
	private lazy var collectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.backgroundColor = .ypBackground
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		return collectionView
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initUI()
		onTrackersUpdated()
		dataProvider?.delegate = self
		categories = dataProvider?.categories ?? []
		completedTrackers = dataProvider?.trackerRecords ?? []
		
		let currentFilterIndex = UserDefaults.standard.integer(forKey: "CurrentFilterIndex")
		self.currentFilterIndex = currentFilterIndex
		
		collectionView.alwaysBounceVertical = true
		collectionView.contentInset.bottom += 50
	}
	
	// MARK: UI methods
	
	private func initUI() {
		view.backgroundColor = .ypBackground
		
		navigationItem.largeTitleDisplayMode = .always
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.largeTitleTextAttributes = [
			.foregroundColor: UIColor.ypTextColor
		]
		navigationItem.title = NSLocalizedString(
			"trackers",
			comment: "Название экрана с трекерами"
		)
		
		self.navigationController?.hidesBarsOnSwipe = false
		
		addNavigationBarItems()
		addCollectionView()
		addEmptyTrackersImageView()
		addEmptyTrackersLabel()
		addFiltersButton()
	}
	
	private func addNavigationBarItems() {
		navigationItem.leftBarButtonItem = addButton
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
		navigationItem.searchController = searchController
		
		NSLayoutConstraint.activate([
			datePicker.widthAnchor.constraint(equalToConstant: 120)
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
			emptyTrackersLabel.topAnchor.constraint(equalTo: emptyTrackersImageView.bottomAnchor, constant: 8),
			emptyTrackersLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
		])
	}
	
	private func addFiltersButton() {
		view.addSubview(filtersButton)
		
		NSLayoutConstraint.activate([
			filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			filtersButton.widthAnchor.constraint(equalToConstant: 114),
			filtersButton.heightAnchor.constraint(equalToConstant: 50)
		])
	}
	
	private func addCollectionView() {
		view.addSubview(collectionView)
		
		collectionView.dataSource = self
		collectionView.delegate = self
		
		collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
		collectionView.register(TrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 34),
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
	
	private func onTrackersUpdated() {
		emptyTrackersImageView.isHidden = !visibleCategories.isEmpty
		emptyTrackersLabel.isHidden = !visibleCategories.isEmpty
		filtersButton.isHidden = visibleCategories.isEmpty
	}
	
	private func filterCategories() {
		guard let date = datePicker.date.removeTime else {
			return
		}
		
		let weekDayNum = calendar.component(.weekday, from: date)
		
		guard let text = searchController.searchBar.text,
			  let weekDay = WeekDay(rawValue: weekDayNum) else {
			return
		}
		
		var filteredCategories = [TrackerCategory]()
		
		for category in categories {
			var visibleTrackers = category.trackers.filter { tracker in
				(text.isEmpty || tracker.name.contains(text)) &&
				tracker.weekDays.contains(weekDay)
			}
			
			switch currentFilterIndex {
			case 2:
				visibleTrackers = visibleTrackers.filter { tracker in
					isTrackerCompleted(tracker)
				}
				break
			case 3:
				visibleTrackers = visibleTrackers.filter { tracker in
					!isTrackerCompleted(tracker)
				}
				break
			default:
				break
			}
			
			if !visibleTrackers.isEmpty {
				let newCategory = TrackerCategory(
					id: category.id,
					name: category.name,
					position: category.position,
					trackers: visibleTrackers
				);
				filteredCategories.append(newCategory)
			}
		}

		visibleCategories = filteredCategories
		collectionView.reloadData()
		onTrackersUpdated()
	}
	
	private func isTrackerCompleted(_ tracker: Tracker) -> Bool {
		completedTrackers.filter { trackerRecord in
			trackerRecord.trackerId == tracker.id &&
			trackerRecord.date == datePicker.date.removeTime
		}.count > 0
	}
	
	@objc func filtersButtonDidTap() {
		let controller = FiltersViewController()
		controller.selectedFilterIndex = currentFilterIndex
		controller.delegate = self
		controller.modalPresentationStyle = .pageSheet
		
		present(controller, animated: true)
	}
}

// MARK: UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		visibleCategories.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let num = visibleCategories.count - 1 < section ? 0 : visibleCategories[section].trackers.count
		print(visibleCategories.count - 1 < section)
		
		return num
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? TrackerViewCell else {
			return TrackerViewCell()
		}
		
		let category = visibleCategories[indexPath.section]
		let tracker = category.trackers[indexPath.row]
		let completed = isTrackerCompleted(tracker)
		let totalCompletedCounter = completedTrackers.filter { trackerRecord in
			trackerRecord.trackerId == tracker.id
		}.count
		
		cell.delegate = self
		cell.configure(
			category: category,
			tracker: tracker,
			completedOnDate: completed,
			counter: totalCompletedCounter
		)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let supplementaryView =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerSupplementaryView else {
			return TrackerSupplementaryView()
		}
		
		let category = visibleCategories[indexPath.section]
		let categoryTitle = category.id == pinnedCategoryId ?
			NSLocalizedString(
				"pinnedCategory",
				comment: "Название закрепленной категории"
			) :
		category.name
		
		supplementaryView.titleLabel.text = categoryTitle
		
		return supplementaryView
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

// MARK: TrackerViewCellDelegate

extension TrackersViewController: TrackerViewCellDelegate {
	func doneButtonDidTap(_ cell: TrackerViewCell) {
		guard let tracker = cell.tracker,
			  let date = datePicker.date.removeTime,
			  date <= Date() else {
			return
		}
		
		let trackerRecord = TrackerRecord(trackerId: tracker.id, date: date)
		let completedToday = isTrackerCompleted(tracker)
		
		dataProvider?.setTrackerRecord(trackerRecord, completed: completedToday)
	}
	
	func pinTracker(tracker: Tracker, category: TrackerCategory) {
		try? dataProvider?.pinTracker(tracker: tracker, category: category)
	}
	
	func unpinTracker(tracker: Tracker) {
		dataProvider?.unpinTracker(tracker: tracker)
	}
	
	func editTracker(tracker: Tracker, category: TrackerCategory, daysCountText: String) {
		let controller = CreateTrackerViewController()
		controller.modalPresentationStyle = .pageSheet
		controller.delegate = self
		controller.existingTracker = tracker
		controller.category = category
		controller.dayCountLabelCaption = daysCountText
		
		present(controller, animated: true)
	}
	
	func deleteTrackerConfirmation(tracker: Tracker) {
		let deleteConfirmationMessage = NSLocalizedString(
			"deleteConfirmation",
			comment: "Текст подтверджения удаления трекера"
		)
		let deleteCaption = NSLocalizedString(
			"delete",
			comment: "Кнопка подтверджения удаления трекера"
		)
		let cancelCaption = NSLocalizedString(
			"cancel",
			comment: "Кнопка отмены удаления трекера"
		)
		let alert = UIAlertController(
			title: deleteConfirmationMessage,
			message: nil,
			preferredStyle: .actionSheet
		)
		
		alert.addAction(UIAlertAction(
			title: deleteCaption,
			style: .destructive,
			handler: { _ in
				self.deleteTracker(tracker: tracker)
			}))
		alert.addAction(UIAlertAction(
			title: cancelCaption,
			style: .cancel,
			handler: { _ in
				
			}))
		present(alert, animated: true, completion: nil)
	}
	
	func deleteTracker(tracker: Tracker) {
		dataProvider?.deleteTracker(tracker)
	}
}

// MARK: UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		filterCategories()
	}
}

// MARK: DataProviderDelegate

extension TrackersViewController: DataProviderDelegate {
	func didChangeCategory() {
		categories = dataProvider?.categories ?? []
	}
	
	func didChangeTracker() {
		categories = dataProvider?.categories ?? []
	}
	
	func didChangeTrackerRecord() {
		completedTrackers = dataProvider?.trackerRecords ?? []
	}
}

// MARK: CreateTrackerDelegateProtocol

extension TrackersViewController: CreateTrackerDelegateProtocol {
	func trackerCreated(tracker: Tracker, in category: TrackerCategory) {
		try? dataProvider?.trackerCreated(tracker, in: category)
		self.collectionView.reloadData()
	}
	
	func editTracker(tracker: Tracker, in category: TrackerCategory) {
		try? dataProvider?.editTracker(tracker, in: category)
	}
}

// MARK: FiltersViewControllerDelegate

extension TrackersViewController: FiltersViewControllerDelegate {
	func applyFilter(_ filterIndex: Int) {
		currentFilterIndex = filterIndex
	}
}

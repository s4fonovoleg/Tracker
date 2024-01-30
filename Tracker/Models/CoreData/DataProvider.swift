import Foundation
import UIKit

enum DataProviderError: Error {
	case trackerCategoryAddingError
	case trackerCategoryFetchingError
}

protocol DataProviderProtocol {
	var delegate: DataProviderDelegate? { get set }
	var categories: [TrackerCategory] { get }
	var trackerRecords: [TrackerRecord] { get }
	func setTrackerRecord(_ trackerRecord: TrackerRecord, completed: Bool)
	func pinTracker(tracker: Tracker, category: TrackerCategory) throws
	func unpinTracker(tracker: Tracker)
	func deleteTracker(_ tracker: Tracker)
	func trackerCreated(_ tracker: Tracker, in category: TrackerCategory) throws
	func editTracker(_ tracker: Tracker, in category: TrackerCategory) throws
}

protocol DataProviderDelegate {
	func didChangeCategory()
	func didChangeTracker()
	func didChangeTrackerRecord()
}

// MARK: DataProvider

final class DataProvider: DataProviderProtocol {
	
	// MARK: Public properties
	
	var delegate: DataProviderDelegate?
	
	var categories: [TrackerCategory] {
		trackerCategoryStore.categories
	}
	
	var trackers: [Tracker] {
		trackerStore.trackers
	}
	
	var trackerRecords: [TrackerRecord] {
		trackerRecordStore.trackerRecords
	}
	
	// MARK: Private properties
	
	private var trackerStore = TrackerStore()
	private var trackerCategoryStore = TrackerCategoryStore()
	private var trackerRecordStore = TrackerRecordStore()
	
	// MARK: Lifecycle
	
	init() {
		trackerStore.delegate = self
		trackerCategoryStore.delegate = self
		trackerRecordStore.delegate = self
	}
	
	// MARK: Public methods
	
	func trackerCreated(_ tracker: Tracker, in category: TrackerCategory) throws {
		guard let categoryCoreData = try? trackerCategoryStore.addNewTrackerCategoryIfNotExists(category) else {
			throw DataProviderError.trackerCategoryAddingError
		}
		
		try? trackerStore.addNewTracker(tracker, in: categoryCoreData)
	}
	
	func setTrackerRecord(_ trackerRecord: TrackerRecord, completed: Bool) {
		if !completed {
			try? trackerRecordStore.addNewTrackerRecord(trackerRecord)
		} else {
			trackerRecordStore.deleteTrackerRecord(trackerRecord)
		}
	}
	
	func pinTracker(tracker: Tracker, category: TrackerCategory) throws {
		guard let pinnedCategoryId else {
			return
		}
		let pinnedCategory = TrackerCategory(
			id: pinnedCategoryId,
			name: NSLocalizedString(
				"pinnedCategory",
				comment: "Название категории с закрепленными трекерами"
			),
			position: 0,
			trackers: []
		)
		
		guard let categoryCoreData = try? trackerCategoryStore.addNewTrackerCategoryIfNotExists(pinnedCategory) else {
			throw DataProviderError.trackerCategoryAddingError
		}
		
		guard let oldCategory = trackerCategoryStore.categoryCoreData(with: category.name) else {
			throw DataProviderError.trackerCategoryFetchingError
		}
		
		trackerStore.pinTracker(
			tracker: tracker,
			pinnedCategory: categoryCoreData,
			oldCategory: oldCategory
		)
	}
	
	func unpinTracker(tracker: Tracker) {
		trackerStore.unpinTracker(tracker: tracker)
	}
	
	func editTracker(_ tracker: Tracker, in category: TrackerCategory) throws {
		guard let categoryCoreData = try? trackerCategoryStore.addNewTrackerCategoryIfNotExists(category) else {
			throw DataProviderError.trackerCategoryAddingError
		}
		
		trackerStore.editTracker(tracker, category: categoryCoreData)
	}
	
	func deleteTracker(_ tracker: Tracker) {
		trackerStore.deleteTracker(tracker)
	}
}

// MARK: TrackerStoreDelegate

extension DataProvider: TrackerStoreDelegate {
	func didChangeTracker() {
		delegate?.didChangeTracker()
	}
}

// MARK: TrackerCategoryStoreDelegate

extension DataProvider: TrackerCategoryStoreDelegate {
	func didChangeCategory() {
		delegate?.didChangeCategory()
	}
}

// MARK: TrackerRecordStoreDelegate

extension DataProvider: TrackerRecordStoreDelegate {
	func didChangeTrackerRecord() {
		delegate?.didChangeTrackerRecord()
	}
}

import Foundation
import UIKit

enum DataProviderError: Error {
	case trackerCategoryAddingError
}

protocol DataProviderDelegate {
	func didChangeCategory()
	func didChangeTracker()
	func didChangeTrackerRecord()
}

// MARK: DataProvider

final class DataProvider {
	
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

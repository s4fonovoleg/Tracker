import CoreData
import UIKit

enum TrackerRecordStoreError: Error {
	case decodingError
}

protocol TrackerRecordStoreDelegate {
	func didChangeTrackerRecord()
}

final class TrackerRecordStore: NSObject {
	
	// MARK: Private properties
	
	private var context: NSManagedObjectContext
	
	private lazy var fetchedResultsController = {
		let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
		
		request.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(TrackerRecordCoreData.date), ascending: true)
		]
		
		let fetchedResultsController = NSFetchedResultsController(
			fetchRequest: request,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil)
		
		fetchedResultsController.delegate = self
		try? fetchedResultsController.performFetch()
		
		return fetchedResultsController
	}()
	
	// MARK: Public Properties
	
	var delegate: TrackerRecordStoreDelegate?
	
	var trackerRecords: [TrackerRecord] {
		guard let objects = self.fetchedResultsController.fetchedObjects else {
			return []
		}
		
		let trackerRecords = try? objects.map { item in
			try trackerRecord(from: item)
		}
		
		return trackerRecords ?? []
	}
	
	// MARK: Lifecycle
	
	init(context: NSManagedObjectContext) {
		self.context = context
	}
	
	convenience override init() {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			self.init()
			return
		}
		self.init(context: appDelegate.persistentContainer.viewContext)
	}
	
	// MARK: Private methods
	
	private func trackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
		guard let trackerId = trackerRecordCoreData.trackerId,
			  let date = trackerRecordCoreData.date else {
			throw TrackerRecordStoreError.decodingError
		}
		return TrackerRecord(
			trackerId: trackerId,
			date: date)
	}
	
	// MARK: Public methods
	
	func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
		let trackerRecordCoreData = TrackerRecordCoreData(context: context)
		
		trackerRecordCoreData.trackerId = trackerRecord.trackerId
		trackerRecordCoreData.date = trackerRecord.date
		
		try context.save()
	}
	
	func deleteTrackerRecord(_ trackerRecord: TrackerRecord) {
		let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
		request.predicate = NSPredicate(
			format: "%K == %@ AND %K == %@",
			argumentArray: [
				#keyPath(TrackerRecordCoreData.trackerId),
							trackerRecord.trackerId,
				#keyPath(TrackerRecordCoreData.date),
				trackerRecord.date
			]
		)
		
		guard let trackerRecords = try? context.fetch(request),
			  let trackerRecordCoreData = trackerRecords.first else {
			return
		}
		
		context.delete(trackerRecordCoreData)
	}
}

// MARK: NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.didChangeTrackerRecord()
	}
}

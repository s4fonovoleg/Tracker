import CoreData
import UIKit

enum TrackerRecordStoreError: Error {
	case decodingError
}

protocol TrackerRecordStoreDelegate {
	func didChangeTrackerRecord()
}

// MARK: TrackerRecordStore

final class TrackerRecordStore: NSObject {
	
	// MARK: Public Properties
	
	static let standard = TrackerRecordStore()
	
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
	
	// MARK: Public methods
	
	func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
		let trackerRecordCoreData = TrackerRecordCoreData(context: context)
		
		trackerRecordCoreData.trackerId = trackerRecord.trackerId
		trackerRecordCoreData.date = trackerRecord.date
		
		saveContext()
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
		saveContext()
	}
	
	func deleteTrackerRecords(trackerId: UUID) {
		let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
		request.predicate = NSPredicate(
			format: "%K == %@",
			argumentArray: [
				#keyPath(TrackerRecordCoreData.trackerId),
				trackerId
			]
		)
		
		guard let trackerRecords = try? context.fetch(request),
			  let trackerRecordCoreData = trackerRecords.first else {
			return
		}
		
		context.delete(trackerRecordCoreData)
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
	
	private func saveContext() {
		do {
			try context.save()
		}
		catch {
			let nserror = error as NSError
			print("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
}

// MARK: NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.didChangeTrackerRecord()
	}
}

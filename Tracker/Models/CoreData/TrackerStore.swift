import CoreData
import UIKit

enum TrackerStoreError: Error {
	case decodingError
}

protocol TrackerStoreDelegate: AnyObject {
	func didChangeTracker()
}

// MARK: TrackerStore

final class TrackerStore: NSObject {
	
	// MARK: Public properties
	
	var insertedIndexes: [IndexPath]?
	var delegate: TrackerStoreDelegate?
	var trackers: [Tracker] {
		guard let objects = self.fetchedResultsController.fetchedObjects else {
			return []
		}
		
		let trackers = try? objects.map { item in
			try tracker(from: item)
		}
		
		return trackers ?? []
	}
	
	// MARK: Private properties
	
	private var context: NSManagedObjectContext
	private var uiColorMarshaling = UIColorMarshalling()
	private var weekDayMarshalling = WeekDayMarshalling()
	
	private lazy var fetchedResultsController = {
		let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
		
		request.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)
		]
		
		let fetchedResultsController = NSFetchedResultsController(
			fetchRequest: request,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil)
		
		try? fetchedResultsController.performFetch()
		
		return fetchedResultsController
	}()
	
	// MARK: Lifecycle
	
	init(context: NSManagedObjectContext) {
		self.context = context
		super.init()
		fetchedResultsController.delegate = self
	}
	
	convenience override init() {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			self.init()
			return
		}
		self.init(context: appDelegate.persistentContainer.viewContext)
	}
	
	// MARK: Public methods
	
	func addNewTracker(_ tracker: Tracker, in category: TrackerCategoryCoreData) throws {
		let trackerCoreData = TrackerCoreData(context: context)
		let weekDayNumbers = weekDayMarshalling.weekDayNumbers(from: tracker.weekDays)
		
		trackerCoreData.name = tracker.name
		trackerCoreData.color = uiColorMarshaling.hexString(from: tracker.color)
		trackerCoreData.emoji = tracker.emoji
		trackerCoreData.id = tracker.id
		trackerCoreData.weekDays = weekDayNumbers as NSObject
		trackerCoreData.category = category
		
		do {
			try context.save()
		}
		catch {
			let nserror = error as NSError
			print("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
	
	func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
		guard let id = trackerCoreData.id,
			  let name = trackerCoreData.name,
			  let color = trackerCoreData.color,
			  let emoji = trackerCoreData.emoji,
			  let weekDayNumbers = trackerCoreData.weekDays as? [Int]
		else {
			throw TrackerStoreError.decodingError
		}
		
		let weekDays = try weekDayMarshalling.weekDays(from: weekDayNumbers)
		
		return Tracker(
			id: id,
			name: name,
			color: uiColorMarshaling.color(from: color),
			emoji: emoji,
			weekDays: weekDays)
	}
}

// MARK: NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.didChangeTracker()
	}
}

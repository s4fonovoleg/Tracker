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
	
	static let standard = TrackerStore()
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
			cacheName: nil
		)
		
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
	
	func getTrackerCoreData() {
		
	}
	
	func addNewTracker(_ tracker: Tracker, in category: TrackerCategoryCoreData) throws {
		let trackerCoreData = TrackerCoreData(context: context)
		
		trackerToCoreData(tracker: tracker, trackerCoreData: trackerCoreData)
		trackerCoreData.category = category
		saveContext()
	}
	
	func pinTracker(
		tracker: Tracker,
		pinnedCategory: TrackerCategoryCoreData,
		oldCategory: TrackerCategoryCoreData
	) {
		guard let trackerCoreData = fetchedResultsController.fetchedObjects?.first(
			where: { trackerCoreData in
				trackerCoreData.id == tracker.id
			}
		) else {
			return
		}
		
		trackerCoreData.cachedCategory = oldCategory
		trackerCoreData.category = pinnedCategory
		saveContext()
	}
	
	func unpinTracker(tracker: Tracker) {
		guard let trackerCoreData = trackerCoreData(with: tracker.id) else {
			return
		}
		
		trackerCoreData.category = trackerCoreData.cachedCategory
		trackerCoreData.cachedCategory = nil
		saveContext()
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
		var cachedCategory: TrackerCategory? = nil
		
		if let cachedCategoryCoreData = trackerCoreData.cachedCategory {
			cachedCategory = try? TrackerCategoryStore.standard.trackerCategory(
				from: cachedCategoryCoreData,
				withTrackers: false
			)
		}
		
		return Tracker(
			id: id,
			name: name,
			color: uiColorMarshaling.color(from: color),
			emoji: emoji,
			weekDays: weekDays,
			cachedCategory: cachedCategory
		)
	}
	
	func editTracker(_ tracker: Tracker, category: TrackerCategoryCoreData) {
		guard let trackerCoreData = trackerCoreData(with: tracker.id) else {
			return
		}
		
		trackerToCoreData(tracker: tracker, trackerCoreData: trackerCoreData)
		
		let tracker2 = trackers.first(where: { item in
			tracker.id == item.id
		})
		
		if tracker2?.cachedCategory != nil {
			trackerCoreData.cachedCategory = category
		} else {
			trackerCoreData.category = category
		}
		
		saveContext()
	}
	
	func deleteTracker(_ tracker: Tracker) {
		guard let trackerCoreData = trackerCoreData(with: tracker.id) else {
			return
		}
		
		context.delete(trackerCoreData)
		saveContext()
	}
	
	// MARK: Private methods
	
	private func trackerCoreData(with id: UUID) -> TrackerCoreData? {
		guard let trackerCoreData = fetchedResultsController.fetchedObjects?.first(
			where: { trackerCoreData in
				trackerCoreData.id == id
			}
		) else {
			return nil
		}
		
		return trackerCoreData
	}
	
	private func trackerToCoreData(tracker: Tracker, trackerCoreData: TrackerCoreData) {
		let weekDayNumbers = weekDayMarshalling.weekDayNumbers(from: tracker.weekDays)
		
		trackerCoreData.name = tracker.name
		trackerCoreData.color = uiColorMarshaling.hexString(from: tracker.color)
		trackerCoreData.emoji = tracker.emoji
		trackerCoreData.id = tracker.id
		trackerCoreData.weekDays = weekDayNumbers as NSObject
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

extension TrackerStore: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.didChangeTracker()
	}
}

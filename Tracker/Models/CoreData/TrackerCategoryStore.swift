import CoreData
import UIKit

enum TrackerCategoryStoreError: Error {
	case decodingError
}

protocol TrackerCategoryStoreDelegate {
	func didChangeCategory()
}

// MARK: TrackerCategoryStore

final class TrackerCategoryStore: NSObject {
	// MARK: Private properties
	
	private var context: NSManagedObjectContext
	
	private var uiColorMarshaling = UIColorMarshalling()
	private var weekDayMarshalling = WeekDayMarshalling()
	
	private lazy var fetchedResultsController = {
		let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
		
		request.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.name), ascending: true)
		]
		request.includesSubentities = true
		
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
	
	var categories: [TrackerCategory] {
		guard let objects = self.fetchedResultsController.fetchedObjects else {
			return []
		}
		
		let categories = try? objects.map { item in
			try trackerCategory(from: item)
		}
		
		return categories ?? []
	}
	
	var delegate: TrackerCategoryStoreDelegate?
	
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
	
	private func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
		guard let name = trackerCategoryCoreData.name else {
			throw TrackerCategoryStoreError.decodingError
		}
		
		let trackersCoreData = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData]
		var trackers: [Tracker] = []
		
		if let trackersCoreData {
			trackers = try trackersCoreData.map { item in
				try tracker(from: item)
			}
		}
		
		return TrackerCategory(
			name: name,
			trackers: trackers)
	}
	
	private func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
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
	
	private func addNewTrackerCategory(_ category: TrackerCategory) throws -> TrackerCategoryCoreData {
		let categoryCoreData = TrackerCategoryCoreData(context: context)
		
		categoryCoreData.name = category.name
		
		try context.save()
		
		return categoryCoreData
	}
	
	// MARK: Public methods
	
	func addNewTrackerCategoryIfNotExists(_ category: TrackerCategory) throws -> TrackerCategoryCoreData {
		guard let categoryCoreData = categoryCoreData(with: category.name) else {
			return try addNewTrackerCategory(category)
		}
		
		return categoryCoreData
	}
	
	func categoryCoreData(with name: String) -> TrackerCategoryCoreData? {
		fetchedResultsController.fetchedObjects?.first(where: { item in
			item.name == name
		})
	}
}

// MARK: NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
	
}

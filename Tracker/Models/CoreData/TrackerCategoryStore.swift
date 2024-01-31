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
	
	// MARK: Public Properties
	
	static let standard = TrackerCategoryStore()
	
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
	
	// MARK: Private properties
	
	private var context: NSManagedObjectContext
	
	private var uiColorMarshaling = UIColorMarshalling()
	private var weekDayMarshalling = WeekDayMarshalling()
	
	private lazy var fetchedResultsController = {
		let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
		
		request.sortDescriptors = [
			NSSortDescriptor(
				key: #keyPath(TrackerCategoryCoreData.position),
				ascending: true
			)
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
	
	func trackerCategory(
		from trackerCategoryCoreData: TrackerCategoryCoreData,
		withTrackers: Bool = true
	) throws -> TrackerCategory {
		guard let name = trackerCategoryCoreData.name,
			  let id = trackerCategoryCoreData.id else {
			throw TrackerCategoryStoreError.decodingError
		}
		
		let position = Int(trackerCategoryCoreData.position)
		let trackersCoreData = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData]
		var trackers: [Tracker] = []
		
		if withTrackers,
		   let trackersCoreData {
			trackers = try trackersCoreData.map { item in
				try TrackerStore.standard.tracker(from: item)
			}
		}
		
		return TrackerCategory(
			id: id,
			name: name,
			position: position,
			trackers: trackers
		)
	}
	
	// MARK: Private methods
	
	private func addNewTrackerCategory(_ category: TrackerCategory) throws -> TrackerCategoryCoreData {
		let categoryCoreData = TrackerCategoryCoreData(context: context)
		
		categoryCoreData.id = category.id
		categoryCoreData.name = category.name
		categoryCoreData.position = Int64(category.position)
		
		try context.save()
		
		return categoryCoreData
	}
}

// MARK: NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.didChangeCategory()
	}
}

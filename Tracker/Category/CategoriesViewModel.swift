import Foundation

final class CategoriesViewModel {
	
	// MARK: Private properties
	
	@Observable
	private(set) var categories: [CategoryViewModel] = []
	
	private let categoryStore = TrackerCategoryStore()
	
	// MARK: Public properties
	
	var lastSelectedIndex: Int?
	
	// MARK: Lifecycle
	
	init() {
		initCategories()
	}
	
	// MARK: Public methods
	
	func createCategory(name: String) {
		let category = TrackerCategory(name: name, trackers: [])
		try? categoryStore.addNewTrackerCategoryIfNotExists(category)
		
		initCategories()
	}
	
	func didSelectRow(index: Int) -> TrackerCategory {
		categories[index].checked = true
		
		guard let lastSelectedIndex else {
			self.lastSelectedIndex = index
			return categories[index].category
		}
		
		categories[lastSelectedIndex].checked = false
		self.lastSelectedIndex = index
		
		return categories[index].category
	}
	
	// MARK: Private methods
	
	private func initCategories() {
		categories = getCategories()
	}
	
	private func getCategories() -> [CategoryViewModel] {
		categoryStore.categories.map { category in
			CategoryViewModel(category: category, name: category.name)
		}
	}
}

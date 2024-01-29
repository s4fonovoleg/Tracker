import Foundation

final class CategoriesViewModel {
	
	// MARK: Private properties
	
	@Observable
	private(set) var categories: [CategoryViewModel] = []
	
	private let categoryStore = TrackerCategoryStore()
	
	// MARK: Public properties
	
	var lastSelectedIndex: Int?
	var selectedCategory: TrackerCategory?
	
	// MARK: Lifecycle
	
	init() {
		initCategories()
	}
	
	init(selectedCategory: TrackerCategory?) {
		self.selectedCategory = selectedCategory
		initCategories()
	}
	
	// MARK: Public methods
	
	func createCategory(name: String) {
		let category = TrackerCategory(
			id: UUID(),
			name: name,
			position: categories.count + 1,
			trackers: []
		)
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
		let categoryViewModels = categoryStore.categories.map { category in
			CategoryViewModel(
				category: category,
				name: category.name,
				checked: category.name == selectedCategory?.name
			)
		}
		
		return categoryViewModels.filter({ categoryViewModel in
			categoryViewModel.category.id != pinnedCategoryId
		})
	}
}

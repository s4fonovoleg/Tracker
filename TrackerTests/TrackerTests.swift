import XCTest
import SnapshotTesting
@testable import Tracker

final class MockDataProvider: DataProviderProtocol {
	var delegate: DataProviderDelegate?
	
	var categories: [TrackerCategory] = [
		TrackerCategory(id: UUID(), name: "Общее", position: 0, trackers: [
			Tracker(
				id: UUID(),
				name: "Спать 8 часов",
				color: .trackerColor1,
				emoji: "😇",
				weekDays: [.monday, .thuesday, .wednesday, .thursday,
					.friday, .saturday, .sunday],
				cachedCategory: nil
			),
			Tracker(
				id: UUID(),
				name: "Чистить зубы",
				color: .trackerColor2,
				emoji: "🙌",
				weekDays: [.monday, .thuesday, .wednesday, .thursday,
					.friday, .saturday, .sunday],
				cachedCategory: nil
			)
		]),
		TrackerCategory(id: UUID(), name: "Важное", position: 0, trackers: [
			Tracker(
				id: UUID(),
				name: "Заниматься спортом",
				color: .trackerColor3,
				emoji: "🥇",
				weekDays: [.monday, .thuesday, .wednesday, .thursday,
					.friday, .saturday, .sunday],
				cachedCategory: nil
			),
			Tracker(
				id: UUID(),
				name: "Гулять на свежем воздухе",
				color: .trackerColor4,
				emoji: "🏝",
				weekDays: [.monday, .thuesday, .wednesday, .thursday,
					.friday, .saturday, .sunday],
				cachedCategory: nil
			)
		])
	]
	
	var trackerRecords: [TrackerRecord] = []
	
	func setTrackerRecord(_ trackerRecord: TrackerRecord, completed: Bool) {
		
	}
	
	func pinTracker(tracker: Tracker, category: TrackerCategory) throws {
		
	}
	
	func unpinTracker(tracker: Tracker) {
		
	}
	
	func deleteTracker(_ tracker: Tracker) {
		
	}
	
	func trackerCreated(_ tracker: Tracker, in category: TrackerCategory) throws {
		
	}
	
	func editTracker(_ tracker: Tracker, in category: TrackerCategory) throws {
		
	}
}

final class TrackerTests: XCTestCase {
	func testTrackersViewController() {
		let trackersViewController = TrackersViewController()
		trackersViewController.dataProvider = MockDataProvider()
		
		let navigationController = UINavigationController(
			rootViewController: trackersViewController
		)
		let statisticsController = StatisticsViewController()
		let tabBarController = TabBarController()
		
		navigationController.tabBarItem = UITabBarItem(
			title: NSLocalizedString("trackers", comment: "Название экрана с трекерами"),
			image: UIImage(named: "TrackerTabBarItemImage"),
			selectedImage: UIImage(named: "TrackerTabBarItemSelectedImage"))
		
		statisticsController.tabBarItem = UITabBarItem(
			title: NSLocalizedString("statistics", comment: "Название экрана статистики"),
			image: UIImage(named: "StatisticsTabBarItemImage"),
			selectedImage: UIImage(named: "StatisticsTabBarItemSelectedImage"))
		
		tabBarController.viewControllers = [
			navigationController, statisticsController
		]
		
		assertSnapshot(
			matching: navigationController,
			as: .image(traits: .init(userInterfaceStyle: .light)),
			record: false
		)
		assertSnapshot(
			matching: navigationController,
			as: .image(traits: .init(userInterfaceStyle: .dark)),
			record: false
		)
	}
}

import UIKit

struct Tracker {
	let id: UUID
	let name: String
	let color: UIColor
	let emoji: String
	let weekDays: Set<WeekDay>
	let cachedCategory: TrackerCategory?
}

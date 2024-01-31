import Foundation

struct TrackerCategory {
	let id: UUID
	let name: String
	let position: Int
	let trackers: [Tracker]
}

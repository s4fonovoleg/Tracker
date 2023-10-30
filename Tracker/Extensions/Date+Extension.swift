import Foundation

extension Date {
	public var removeTime: Date? {
		guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
		return nil
		}
		return date
	}
}

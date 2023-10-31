import Foundation

protocol ScheduleViewControllerDelegateProtocol {
	func addSchedule(weekDays: Set<WeekDay>)
}

import Foundation

enum WeekDay: Int {
	case monday = 2
	case thuesday = 3
	case wednesday = 4
	case thursday = 5
	case friday = 6
	case saturday = 7
	case sunday = 1
}

let weekDayName: [WeekDay: String] = [
	.monday: "Понедельник",
	.thuesday: "Вторник",
	.wednesday: "Среда",
	.thursday: "Четверг",
	.friday: "Пятница",
	.saturday: "Суббота",
	.sunday: "Воскресенье"
]

let weekDayShortName: [WeekDay: String] = [
	.monday: "Пн",
	.thuesday: "Вт",
	.wednesday: "Ср",
	.thursday: "Чт",
	.friday: "Пт",
	.saturday: "Сб",
	.sunday: "Вс"
]

extension WeekDay: Decodable, Encodable {
	
}

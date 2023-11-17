import Foundation

enum WeekDayMarshallingError: Error {
	case invalidWeekDayRawValue
}

final class WeekDayMarshalling {
	func weekDays(from weekDayNumbers: [Int]) throws -> Set<WeekDay> {
		var result = Set<WeekDay>()
		
		for day in weekDayNumbers {
			guard let weekDay = WeekDay(rawValue: day) else {
				throw WeekDayMarshallingError.invalidWeekDayRawValue
			}
			
			result.insert(weekDay)
		}
		
		return result
	}
	
	func weekDayNumbers(from weekDays: Set<WeekDay>) -> [Int] {
		weekDays.map { weekDay in
			weekDay.rawValue
		}
	}
}

import Foundation
import YandexMobileMetrica

final class AnalyticsService {
	func reportEvent(eventName: String, parameters: [AnyHashable : Any]) {
		YMMYandexMetrica.reportEvent(
			eventName,
			parameters: parameters,
			onFailure: { error in
				print("Report event error: \(error.localizedDescription)")
			}
		)
	}
}

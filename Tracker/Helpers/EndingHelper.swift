import Foundation

func getNumberEnding(for num: Int, _ firstForm: String, _ secondForm: String, _ thirdFrom: String) -> String {
	let lastNumber = num % 10
	
	if lastNumber == 0 || lastNumber > 4 {
		return firstForm
	}
	
	if lastNumber == 1 {
		return secondForm
	}
	
	return thirdFrom
}

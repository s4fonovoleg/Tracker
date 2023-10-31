import UIKit

class UITextFieldWithPadding: UITextField {
	var leftInset: CGFloat = 0
	var rightInset: CGFloat = 0
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return CGRectInset(bounds, leftInset, rightInset);
	}

	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return CGRectInset(bounds, leftInset, rightInset);
	}
}

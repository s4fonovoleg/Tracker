import UIKit

protocol TrackerViewCellDelegate: AnyObject {
	func doneButtonDidTap(_ cell: TrackerViewCell)
}

final class TrackerViewCell: UICollectionViewCell {
	
	// MARK: Public properties
	
	weak var delegate: TrackerViewCellDelegate?
	
	var tracker: Tracker?
	
	var completedOnDate: Bool = false {
		didSet {
			updateDoneButton()
		}
	}
	
	// MARK: Private UI properties
	
	private lazy var countLabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "0 дней"
		label.textColor = .black
		label.font = .systemFont(ofSize: 12, weight: .medium)
		
		return label
	}()
	
	private lazy var emojiBackground = {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = view.frame.width / 2
		
		return view
	}()

	private lazy var emojiLabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var colorView = {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 167, height: 90))
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 16
		
		return view
	}()
	
	private lazy var textView = {
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.backgroundColor = .clear
		textView.textColor = .white
		textView.textAlignment = .left
		
		return textView
	}()
	
	private lazy var doneButton = {
		let symbolSize = UIImage.SymbolConfiguration(pointSize: 11)
		let image = UIImage(systemName: completedOnDate ? "checkmark" : "plus", withConfiguration: symbolSize)
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = button.frame.width / 2
		button.tintColor = .white
		button.setImage(image, for: .normal)
		button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
		
		return button
	}()
	
	// MARK: Lifecycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Public methods
	
	func configure(tracker: Tracker, completedOnDate: Bool, counter: Int) {
		self.tracker = tracker
		self.completedOnDate = completedOnDate
		
		textView.text = tracker.name
		colorView.backgroundColor = tracker.color
		emojiBackground.backgroundColor = UIColor(white: 1, alpha: 0.3)
		emojiLabel.text = tracker.emoji
		doneButton.backgroundColor = tracker.color
		
		let daysCaption = getNumberEnding(
			for: counter,
			"дней",
			"день",
			"дня")
		
		countLabel.text = "\(counter) \(daysCaption)"
		self.completedOnDate = completedOnDate
		
		updateDoneButton()
	}
	
	// MARK: Private methods
	
	private func updateDoneButton() {
		let symbolSize = UIImage.SymbolConfiguration(pointSize: 11)
		let image = UIImage(systemName: completedOnDate ? "checkmark" : "plus", withConfiguration: symbolSize)
		doneButton.setImage(image, for: .normal)
	}
	
	private func setupViews() {
		contentView.addSubview(colorView)
		contentView.addSubview(countLabel)
		contentView.addSubview(doneButton)
		colorView.addSubview(emojiBackground)
		colorView.addSubview(emojiLabel)
		colorView.addSubview(textView)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			colorView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
			colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
			colorView.heightAnchor.constraint(equalToConstant: 90),
			
			emojiBackground.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
			emojiBackground.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
			emojiBackground.widthAnchor.constraint(equalToConstant: 24),
			emojiBackground.heightAnchor.constraint(equalToConstant: 24),
			
			emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
			emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
			emojiLabel.widthAnchor.constraint(equalToConstant: 24),
			emojiLabel.heightAnchor.constraint(equalToConstant: 24),
			
			textView.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
			textView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
			textView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
			textView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
			
			countLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 16),
			countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
			
			doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
			doneButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
			doneButton.widthAnchor.constraint(equalToConstant: doneButton.frame.width),
			doneButton.heightAnchor.constraint(equalToConstant: doneButton.frame.height)
		])
	}
	
	@objc private func doneButtonDidTap() {
		delegate?.doneButtonDidTap(self)
	}
	
	private func getNumberEnding(for num: Int, _ firstForm: String, _ secondForm: String, _ thirdFrom: String) -> String {
		let lastNumber = num % 10
		
		if lastNumber == 0 || lastNumber > 4 {
			return firstForm
		}
		
		if lastNumber == 1 {
			return secondForm
		}
		
		return thirdFrom
	}
}

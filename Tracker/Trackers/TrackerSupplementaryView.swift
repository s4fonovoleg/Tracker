import UIKit

final class TrackerSupplementaryView: UICollectionReusableView {
	
	// MARK: UI properties
	
	lazy var titleLabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .black
		label.font = .systemFont(ofSize: 19, weight: .bold)
		
		return label
	}()
	
	// MARK: Lifecycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(titleLabel)
		setupTitleLabelConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Private methods
	
	private func setupTitleLabelConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
		])
	}
}

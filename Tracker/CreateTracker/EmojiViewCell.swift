import UIKit

final class EmojiViewCell: UICollectionViewCell {
	
	// MARK: Public properties
	
	lazy var titleLabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .systemFont(ofSize: 32)
		
		return label
	}()
	
	lazy var selectionView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 16
		view.backgroundColor = .ypLightGrey
		view.isHidden = true
		
		return view
	}()
	
	// MARK: Lifecycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.addSubview(selectionView)
		contentView.addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			selectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
			selectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			selectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			selectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		selectionView.isHidden = true
	}
}

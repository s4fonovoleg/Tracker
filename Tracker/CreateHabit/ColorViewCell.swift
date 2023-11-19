import UIKit

final class ColorViewCell: UICollectionViewCell {
	
	// MARK: Public properties
	
	lazy var colorView = {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 8
		
		return view
	}()
	
	lazy var selectionView = {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 8
		view.layer.borderWidth = 3
		view.isHidden = true
		
		return view
	}()
	
	// MARK: Lifecycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		selectionView.layer.borderColor = colorView.backgroundColor?.cgColor
		selectionView.layer.opacity = 0.3
		
		contentView.addSubview(colorView)
		contentView.addSubview(selectionView)
		
		NSLayoutConstraint.activate([
			colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			colorView.widthAnchor.constraint(equalToConstant: colorView.frame.width),
			colorView.heightAnchor.constraint(equalToConstant: colorView.frame.height),
			
			selectionView.widthAnchor.constraint(equalToConstant: selectionView.frame.width),
			selectionView.heightAnchor.constraint(equalToConstant: selectionView.frame.height),
			selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
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

import UIKit

final class CategoryTableViewCell: UITableViewCell {
	
	// MARK: Public properties
	
	var viewModel: CategoryViewModel? {
		didSet {
			guard let viewModel else {
				return
			}
			
			nameLabel.text = viewModel.name
			checkmark.isHidden = !viewModel.checked
			setupMaskedCorners()
			setupDivider()
		}
	}
	
	// MARK: Private properties
	
	private let nameLabel = {
		let label = UILabel()
		label.textColor = .black
		label.font = .systemFont(ofSize: 17, weight: .regular)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private let checkmark = {
		let checkmark = UIImage(named: "Checkmark")
		let imageView = UIImageView(image: checkmark)
		
		imageView.translatesAutoresizingMaskIntoConstraints = false
		
		return imageView
	}()
	
	private let divider = {
		let divider = UIView(frame: CGRect(x: 0, y: 0, width: 311, height: 0.5))
		divider.translatesAutoresizingMaskIntoConstraints = false
		divider.backgroundColor = .greyDividerColor
		
		return divider
	}()
	
	// MARK: Lifecycle
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setupViews()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Private methods
	
	private func setupViews() {
		contentView.backgroundColor = .lightGreyBackground
		
		contentView.addSubview(nameLabel)
		contentView.addSubview(checkmark)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -41),
			
			checkmark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			checkmark.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
			checkmark.widthAnchor.constraint(equalToConstant: 24),
			checkmark.heightAnchor.constraint(equalToConstant: 24)
		])
	}
	
	private func setupMaskedCorners() {
		guard let viewModel else {
			return
		}
		
		if viewModel.first && viewModel.last {
			contentView.layer.cornerRadius = 16
			return
		}
		
		if viewModel.first {
			contentView.layer.cornerRadius = 16
			contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
			return
		}
		
		if viewModel.last {
			contentView.layer.cornerRadius = 16
			contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
			return
		}
	}
	
	private func setupDivider() {
		guard let viewModel,
			!(viewModel.first && viewModel.last),
			!viewModel.last else {
			return
		}
		
		contentView.addSubview(divider)
		
		NSLayoutConstraint.activate([
			divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.95),
			divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.95),
			divider.heightAnchor.constraint(equalToConstant: 0.5)
		])
	}
}

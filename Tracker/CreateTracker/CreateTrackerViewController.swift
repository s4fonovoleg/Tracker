import UIKit

protocol CreateTrackerDelegateProtocol {
	func trackerCreated(tracker: Tracker, in category: TrackerCategory)
	func editTracker(tracker: Tracker, in category: TrackerCategory)
}

final class CreateTrackerViewController: UIViewController {
	
	// MARK: Public properties
	
	var existingTracker: Tracker?
	var dayCountLabelCaption: String?
	var isHabit = true
	var delegate: CreateTrackerDelegateProtocol?
	
	// MARK: Private properties
	
	private let emojiCellReuseIdentifier = "EmojiCell"
	private let colorCellReuseIdentifier = "ColorCell"
	private let emojies = [
		"🙂", "😻", "🌺", "🐶", "❤️", "😱",
		"😇", "😡", "🥶", "🤔", "🙌", "🍔",
		"🥦", "🏓", "🥇", "🎸", "🏝", "😪",
	]
	private let colors: [UIColor] = [
		.trackerColor1, .trackerColor2, .trackerColor3, .trackerColor4,
		.trackerColor5, .trackerColor6, .trackerColor7, .trackerColor8,
		.trackerColor9, .trackerColor10, .trackerColor11, .trackerColor12,
		.trackerColor13, .trackerColor14, .trackerColor15, .trackerColor16,
		.trackerColor17, .trackerColor18,
	]
	
	var category: TrackerCategory? {
		didSet {
			updateCategoryButtonTitle()
		}
	}
	private var weekDays: Set<WeekDay> = Set() {
		didSet {
			updateScheduleButtonTitle()
		}
	}
	private var lastSelectedEmojiIndexPath: IndexPath?
	private var lastSelectedColorIndexPath: IndexPath?
	
	// MARK: Private UI properties
	
	private lazy var scrollView = {
		let view = UIScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isScrollEnabled = true
		
		return view
	}()
	
	private var contentView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	private lazy var headerLabel = {
		var caption = NSLocalizedString(
			"editingTracker",
			comment: "Заголовок экрана редактирования трекера"
		)
		
		if existingTracker == nil {
			caption = isHabit ?
			NSLocalizedString(
				"newHabit",
				comment: "Заголовок экрана создания привычки"
			) :
			NSLocalizedString(
				"newIrregularEvent",
				comment: "Заголовок экрана создания нерегулярного события"
			)
		}
		
		let label = UILabel()
		label.textAlignment = .center
		label.text = caption
		label.textColor = .black
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var dayCountLabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.text = dayCountLabelCaption ?? ""
		label.textColor = .black
		label.font = .systemFont(ofSize: 32, weight: .bold)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var trackerNameTextField = {
		let textField = UITextFieldWithPadding()
		
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.placeholder = NSLocalizedString(
			"enterTrackerName",
			comment: "Placeholder поля с именем трекера"
		)
		textField.layer.cornerRadius = 16
		textField.backgroundColor = .lightGreyBackground
		textField.leftInset = 16
		textField.rightInset = 16
		
		return textField
	}()
	
	private lazy var categoryButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .lightGreyBackground
		button.layer.cornerRadius = 16
		button.titleEdgeInsets.left = 16
		button.titleEdgeInsets.right = 16
		button.contentHorizontalAlignment = .leading
		
		if isHabit {
			button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		}
		
		button.addTarget(self, action: #selector(openCategoryView), for: .touchUpInside)
		
		return button
	}()
	
	private lazy var categoryButtonTitle = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = NSLocalizedString(
			"category",
			comment: "Заголовок экрана категорий"
		)
		label.textColor = .black
		label.font = .systemFont(ofSize: 16, weight: .light)
		
		return label
	}()
	
	private lazy var categoryButtonSubtitle = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .ypLightGreyText
		label.font = .systemFont(ofSize: 16, weight: .light)
		
		return label
	}()
	
	private var categoryButtonTitleVerticalConstraint: NSLayoutConstraint?
	
	private lazy var categoryAccessoryImageView = {
		getRightAccesoryArrow()
	}()
	
	private lazy var scheduleButton = {
		let button = UIButton(type: .custom)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .lightGreyBackground
		button.layer.cornerRadius = 16
		button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		button.contentHorizontalAlignment = .leading
		button.titleEdgeInsets.left = 16
		button.titleEdgeInsets.right = 16
		button.addTarget(self, action: #selector(openScheduleView), for: .touchUpInside)
		
		return button
	}()
	
	private lazy var scheduleButtonTitle = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = NSLocalizedString(
			"schedule",
			comment: "Заголовок кнопки перехода на экран расписания"
		)
		label.textColor = .black
		label.font = .systemFont(ofSize: 16, weight: .light)
		
		return label
	}()
	
	private lazy var scheduleButtonSubtitle = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .ypLightGreyText
		label.font = .systemFont(ofSize: 16, weight: .light)
		
		return label
	}()
	
	private var scheduleButtonTitleVerticalConstraint: NSLayoutConstraint?
	
	private lazy var scheduleAccessoryImageView = {
		getRightAccesoryArrow()
	}()
	
	private lazy var divider = {
		let divider = UIView(frame: CGRect(x: 0, y: 0, width: 311.09, height: 0.5))
		
		divider.translatesAutoresizingMaskIntoConstraints = false
		divider.backgroundColor = .greyDividerColor
		
		return divider
	}()
	
	private lazy var cancelButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .white
		button.setTitle("Отменить", for: .normal)
		button.setTitleColor(.ypRed, for: .normal)
		button.layer.cornerRadius = 16
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.ypRed.cgColor
		button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
		
		return button
	}()
	
	private lazy var doneButton = {
		let caption = existingTracker == nil ?
		NSLocalizedString(
			"create",
			comment: "Заголовок кнопки создания трекера"
		) :
		NSLocalizedString(
			"save",
			comment: "Заголовок кнопки сохранения отредактированного трекера"
		)
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlack
		button.setTitle(caption, for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 16
		button.addTarget(
			self,
			action: #selector(createButtonDidTap),
			for: .touchUpInside
		)
		
		return button
	}()
	
	private lazy var emojiCollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		return collectionView
	}()
	
	private lazy var colorCollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		return collectionView
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		
		setupViews()
		setupConstraints()
		initExistingTracker()
		updateCategoryButtonTitle()
	}
	
	// MARK: Private UI Methods
	
	private func setupViews() {
		view.addSubview(scrollView)
		
		scrollView.addSubview(contentView)
		
		contentView.addSubview(headerLabel)
		
		if let dayCountLabelCaption {
			contentView.addSubview(dayCountLabel)
		}
		
		contentView.addSubview(trackerNameTextField)
		contentView.addSubview(categoryButton)
		contentView.insertSubview(categoryAccessoryImageView, belowSubview: categoryButton)
		categoryButton.addSubview(categoryButtonTitle)
		categoryButton.addSubview(categoryButtonSubtitle)
		
		if isHabit {
			categoryButton.addSubview(divider)
			contentView.addSubview(scheduleButton)
			contentView.insertSubview(scheduleAccessoryImageView, belowSubview: scheduleButton)
			scheduleButton.addSubview(scheduleButtonTitle)
			scheduleButton.addSubview(scheduleButtonSubtitle)
		}
		
		contentView.addSubview(emojiCollectionView)
		contentView.addSubview(colorCollectionView)
		contentView.addSubview(cancelButton)
		contentView.addSubview(doneButton)
		
		emojiCollectionView.dataSource = self
		emojiCollectionView.delegate = self
		
		colorCollectionView.dataSource = self
		colorCollectionView.delegate = self
		
		emojiCollectionView.register(EmojiViewCell.self, forCellWithReuseIdentifier: emojiCellReuseIdentifier)
		colorCollectionView.register(ColorViewCell.self, forCellWithReuseIdentifier: colorCellReuseIdentifier)
		
		emojiCollectionView.register(EmojiSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
		colorCollectionView.register(EmojiSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
	}
	
	private func setupConstraints() {
		setupScrollViewConstraints()
		setupContentViewConstraints()
		setupHeaderConstraints()
		
		if let dayCountLabelCaption {
			setupDayCountLabelConstraints()
		}
		
		setupTextFieldConstraints()
		setupCategoryButtonConstraints()
		
		if isHabit {
			setupDividerConstraints()
			setupScheduleButtonConstraints()
		}
		
		setupEmojiCollectionViewConstraints()
		setupColorCollectionViewConstraints()
		setupCancelButtonConstraints()
		setupCreateButtonConstraints()
	}
	
	private func setupScrollViewConstraints() {
		let width = view.frame.width - 32;
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			scrollView.widthAnchor.constraint(equalToConstant: width)
		])
	}
	
	private func setupContentViewConstraints() {
		NSLayoutConstraint.activate([
			contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
			contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
			contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
			contentView.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
		])
	}
	
	private func setupHeaderConstraints() {
		NSLayoutConstraint.activate([
			headerLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			headerLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 27)
		])
	}
	
	private func setupDayCountLabelConstraints() {
		NSLayoutConstraint.activate([
			dayCountLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			dayCountLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38)
		])
	}
	
	private func setupTextFieldConstraints() {
		let topView = dayCountLabelCaption == nil ? headerLabel : dayCountLabel
		
		NSLayoutConstraint.activate([
			trackerNameTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			trackerNameTextField.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 38),
			trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
			trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
		])
	}
	
	private func setupCategoryButtonConstraints() {
		NSLayoutConstraint.activate([
			categoryButton.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
			categoryButton.heightAnchor.constraint(equalToConstant: 75),
			categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			categoryAccessoryImageView.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
			categoryAccessoryImageView.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
			categoryAccessoryImageView.widthAnchor.constraint(equalToConstant: 24),
			categoryAccessoryImageView.heightAnchor.constraint(equalToConstant: 24),
			
			categoryButtonTitle.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
			
			categoryButtonSubtitle.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
			categoryButtonSubtitle.bottomAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: -14)
		])
		
		categoryButtonTitleVerticalConstraint = categoryButtonTitle.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor)
		categoryButtonTitleVerticalConstraint?.isActive = true
	}
	
	private func setupDividerConstraints() {
		let width = view.frame.width - 64
		
		NSLayoutConstraint.activate([
			divider.centerYAnchor.constraint(equalTo: categoryButton.bottomAnchor),
			divider.heightAnchor.constraint(equalToConstant: divider.frame.height),
			divider.widthAnchor.constraint(equalToConstant: width),
			divider.centerXAnchor.constraint(equalTo: categoryButton.centerXAnchor)
		])
	}
	
	private func setupScheduleButtonConstraints() {
		NSLayoutConstraint.activate([
			scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
			scheduleButton.heightAnchor.constraint(equalToConstant: 75),
			scheduleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			scheduleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			scheduleAccessoryImageView.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor),
			scheduleAccessoryImageView.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor, constant: -16),
			scheduleAccessoryImageView.widthAnchor.constraint(equalToConstant: 24),
			scheduleAccessoryImageView.heightAnchor.constraint(equalToConstant: 24),
			
			scheduleButtonTitle.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
			
			scheduleButtonSubtitle.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
			scheduleButtonSubtitle.bottomAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: -14)
		])
		
		scheduleButtonTitleVerticalConstraint = scheduleButtonTitle.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor)
		scheduleButtonTitleVerticalConstraint?.isActive = true
	}
	
	private func setupEmojiCollectionViewConstraints() {
		let bottomButton = isHabit ? scheduleButton : categoryButton
		
		NSLayoutConstraint.activate([
			emojiCollectionView.topAnchor.constraint(equalTo: bottomButton.bottomAnchor, constant: 32),
			emojiCollectionView.heightAnchor.constraint(equalToConstant: 222), // 484
			emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
			emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19)
		])
	}
	
	private func setupColorCollectionViewConstraints() {
		NSLayoutConstraint.activate([
			colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor),
			colorCollectionView.heightAnchor.constraint(equalToConstant: 222), // 484
			colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
			colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19)
		])
	}
	
	private func setupCancelButtonConstraints() {
		// 20 - отступы кнопок от краев экрана, 8 - отступ между кнопками
		let buttonWidth = (view.frame.width - 48) / 2
		
		NSLayoutConstraint.activate([
			cancelButton.heightAnchor.constraint(equalToConstant: 60),
			cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor),
			cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			cancelButton.widthAnchor.constraint(equalToConstant: buttonWidth),
			cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	private func setupCreateButtonConstraints() {
		// 20 - отступы кнопок от краев экрана, 8 - отступ между кнопками
		let buttonWidth = (view.frame.width - 48) / 2
		
		NSLayoutConstraint.activate([
			doneButton.heightAnchor.constraint(equalToConstant: 60),
			doneButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor),
			doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			doneButton.widthAnchor.constraint(equalToConstant: buttonWidth),
			doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	private func getRightAccesoryArrow() -> UIImageView {
		let accessoryImage = UIImage(named: "RightAccessoryArrow")
		let accessoryImageView = UIImageView(image: accessoryImage)
		accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
		
		return accessoryImageView
	}
	
	private func updateCategoryButtonTitle() {
		if categoryButtonTitleVerticalConstraint == nil {
			return
		}
		
		categoryButtonTitleVerticalConstraint?.isActive = false
		
		if (category != nil) {
			categoryButtonTitleVerticalConstraint = categoryButtonTitle.bottomAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: -38)
			categoryButtonSubtitle.text = category?.name
		} else {
			categoryButtonTitleVerticalConstraint = categoryButtonTitle.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor)
			categoryButtonSubtitle.text = ""
		}
		
		categoryButtonTitleVerticalConstraint?.isActive = true
	}
	
	private func updateScheduleButtonTitle() {
		scheduleButtonTitleVerticalConstraint?.isActive = false
		
		if (weekDays.count > 0) {
			scheduleButtonTitleVerticalConstraint = scheduleButtonTitle.bottomAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: -38)
			scheduleButtonSubtitle.text = getWeekDaysShortNames()
		} else {
			scheduleButtonTitleVerticalConstraint = scheduleButtonTitle.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor)
			scheduleButtonSubtitle.text = ""
		}
		
		scheduleButtonTitleVerticalConstraint?.isActive = true
	}
	
	// MARK: Private methods
	
	private func initExistingTracker() {
		guard let existingTracker,
			  let emojiIndex = emojies.firstIndex(of: existingTracker.emoji),
			  let colorIndex = colors.firstIndex(where: { color in
				  isColorEqual(color, to: existingTracker.color)
			  })
		else {
			return
		}
		
		trackerNameTextField.text = existingTracker.name
		lastSelectedEmojiIndexPath = IndexPath(row: emojiIndex, section: 0)
		lastSelectedColorIndexPath = IndexPath(row: colorIndex, section: 0)
		weekDays = existingTracker.weekDays
	}
	
	private func isColorEqual(_ color: UIColor, to: UIColor) -> Bool {
		guard let colorComponents = color.cgColor.components,
			  let toComponents = to.cgColor.components
		else {
			return false
		}
		
		return isEqual(colorComponents[0], to: toComponents[0]) &&
			   isEqual(colorComponents[1], to: toComponents[1]) &&
			   isEqual(colorComponents[2], to: toComponents[2]) &&
			   isEqual(colorComponents[3], to: toComponents[3])
	}
	
	private func isEqual(
		_ number: CGFloat,
		to: CGFloat,
		with precision: CGFloat = 0.001
	) -> Bool {
		abs(number - to) <= precision
	}
	
	private func getWeekDaysShortNames() -> String {
		weekDays.map { item in
			weekDayShortName[item] ?? ""
		}.joined(separator: ", ")
	}
	
	@objc private func cancelButtonDidTap() {
		dismiss(animated: true)
	}
	
	@objc private func createButtonDidTap() {
		guard let emojiIndex = lastSelectedEmojiIndexPath?.row,
			  let colorIndex = lastSelectedColorIndexPath?.row,
			  let category else {
			return
		}
		
		let emoji = emojies[emojiIndex]
		let color = colors[colorIndex]
		let tracker = Tracker(
			id: existingTracker?.id ?? UUID(),
			name: trackerNameTextField.text ?? "",
			color: color,
			emoji: emoji,
			weekDays: getWeekDays(),
			cachedCategory: nil
		)
		
		if existingTracker == nil {
			delegate?.trackerCreated(tracker: tracker, in: category)
		} else {
			delegate?.editTracker(tracker: tracker, in: category)
		}
		
		dismiss(animated: true)
	}
	
	@objc private func openScheduleView() {
		let controller = ScheduleViewController()
		controller.modalPresentationStyle = .pageSheet
		controller.delegate = self
		controller.weekDays = weekDays
		
		present(controller, animated: true)
	}
	
	@objc private func openCategoryView() {
		let category = existingTracker?.cachedCategory ?? category
		let viewModel = CategoriesViewModel(selectedCategory: category)
		let controller = CategoryViewController()
		controller.delegate = self
		controller.viewModel = viewModel
		controller.modalPresentationStyle = .pageSheet
		
		present(controller, animated: true)
	}
	
	private func getWeekDays() -> Set<WeekDay> {
		if isHabit {
			return weekDays
		}
		
		return [
			.monday,
			.thuesday,
			.wednesday,
			.thursday,
			.friday,
			.saturday,
			.sunday,
		]
	}
}

// MARK: ScheduleViewControllerDelegateProtocol

extension CreateTrackerViewController: ScheduleViewControllerDelegateProtocol {
	func addSchedule(weekDays: Set<WeekDay>) {
		self.weekDays = weekDays
	}
}

// MARK: UICollectionViewDataSource

extension CreateTrackerViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == collectionView ? emojies.count : colors.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == emojiCollectionView {
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellReuseIdentifier, for: indexPath) as? EmojiViewCell else {
				return EmojiViewCell()
			}
			
			cell.titleLabel.text = emojies[indexPath.row]
			if lastSelectedEmojiIndexPath == indexPath {
				cell.selectionView.isHidden = false
			}
			return cell
		}
		
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCellReuseIdentifier, for: indexPath) as? ColorViewCell else {
			return ColorViewCell()
		}
		
		cell.colorView.backgroundColor = colors[indexPath.row]
		
		if lastSelectedColorIndexPath == indexPath {
			cell.selectionView.layer.borderColor = cell.colorView.backgroundColor?.cgColor
			cell.selectionView.isHidden = false
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let supplementaryView =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? EmojiSupplementaryView else {
			return EmojiSupplementaryView()
		}
		
		let headerCaption = collectionView == emojiCollectionView ?
			NSLocalizedString("emoji", comment: "Заголовок коллекции emoji") :
			NSLocalizedString("color", comment: "Заголовок коллекции цветов")
		supplementaryView.titleLabel.text = headerCaption
		return supplementaryView
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 0, bottom: 40.0, right: 0)
	}
}

// MARK: UICollectionViewDelegate

extension CreateTrackerViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == emojiCollectionView {
			let indexesToReload = [indexPath, lastSelectedEmojiIndexPath].compactMap({ $0 })
			
			if lastSelectedEmojiIndexPath == indexPath {
				lastSelectedEmojiIndexPath = nil
			} else {
				lastSelectedEmojiIndexPath = indexPath
			}
			collectionView.reloadItems(at: indexesToReload)
		} else {
			let indexesToReload = [indexPath, lastSelectedColorIndexPath].compactMap({ $0 })
			
			if lastSelectedColorIndexPath == indexPath {
				lastSelectedColorIndexPath = nil
			} else {
				lastSelectedColorIndexPath = indexPath
			}
			collectionView.reloadItems(at: indexesToReload)
		}
	}
}

// MARK: UICollectionViewDelegateFlowLayout

extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		0
	}
	
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath) -> CGSize {
			CGSize(width: 52, height: 52)
		}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		let indexPath = IndexPath(row: 0, section: section)
		let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
		
		return headerView.systemLayoutSizeFitting(
			CGSize(
				width: collectionView.frame.width,
				height: UIView.layoutFittingExpandedSize.height
			),
			withHorizontalFittingPriority: .required,
			verticalFittingPriority: .fittingSizeLevel
		)
	}
}

// MARK: CategoryViewControllerDelegate

extension CreateTrackerViewController: CategoryViewControllerDelegate {
	func categorySelected(_ category: TrackerCategory) {
		self.category = category
	}
}

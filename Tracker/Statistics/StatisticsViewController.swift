import UIKit

class StatisticsViewController: UIViewController {

	// MARK: Public properties
	
	var bestPeriodCount = 0 {
		didSet {
			bestPeriodCountLabel.text = "\(bestPeriodCount)"
		}
	}
	var perfectDaysCount = 0 {
		didSet {
			perfectDaysCountLabel.text = "\(perfectDaysCount)"
		}
	}
	var completedTrackersCount = 0 {
		didSet {
			completedTrackersCountLabel.text = "\(completedTrackersCount)"
		}
	}
	var averageValueCount = 0 {
		didSet {
			averageValueCountLabel.text = "\(averageValueCount)"
		}
	}
	// MARK: Private properties
	
	let trackerRecordStore = TrackerRecordStore.standard
	
	// MARK: Private UI properties
	
	private lazy var headerLabel = {
		let label = UILabel()
		label.text = NSLocalizedString(
			"statistics",
			comment: "Заголовок экрана статистики"
		)
		label.textColor = .ypTextColor
		label.font = .systemFont(ofSize: 34, weight: .bold)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	
	private lazy var emptyStatisticsImageView = {
		let image = UIImage(named: "EmptyStatisticsImage")
		let view = UIImageView(image: image)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	private lazy var emptyStatisticsLabel = {
		let label = UILabel()
		label.text = NSLocalizedString(
			"nothingToAnalyze",
			comment: "Сообщение при пустом списке статистики"
		)
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = .ypTextColor
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var stackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		return stackView
	}()
	
	private lazy var bestPeriodCountLabel = {
		getCountLabel(bestPeriodCount)
	}()
	private lazy var perfectDaysCountLabel = {
		getCountLabel(perfectDaysCount)
	}()
	private lazy var completedTrackersCountLabel = {
		getCountLabel(completedTrackersCount)
	}()
	private lazy var averageValueCountLabel = {
		getCountLabel(averageValueCount)
	}()
	
	private lazy var bestPeriodView = {
		getStatisticView(caption: NSLocalizedString(
			"statistics.bestPeriod",
			comment: "Заголовок статистики лучшего периода"
		), count: bestPeriodCount, countLabel: bestPeriodCountLabel)
	}()
	
	private lazy var perfectDaysView = {
		getStatisticView(caption: NSLocalizedString(
			"statistics.perfectDays",
			comment: "Заголовок статистики идеальных дней"
		), count: perfectDaysCount, countLabel: perfectDaysCountLabel)
	}()
	
	private lazy var completedTrackersView = {
		getStatisticView(caption: NSLocalizedString(
			"statistics.completedTrackers",
			comment: "Заголовок статистики завершенных трекеров"
		), count: completedTrackersCount, countLabel: completedTrackersCountLabel)
	}()
	
	private lazy var averageValueView = {
		getStatisticView(caption: NSLocalizedString(
			"statistics.averageValue",
			comment: "Заголовок статистики среднего значения"
		), count: averageValueCount, countLabel: averageValueCountLabel)
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initStatistics()
		setupViews()
		setupConstraints()
		updateVisibility()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		initStatistics()
		updateVisibility()
	}
	
	// MARK: Private methods
	
	private func initStatistics() {
		completedTrackersCount = trackerRecordStore.trackerRecords.count
	}
	
	private func updateVisibility() {
		let emptyStatistics = isStatisticEmpty()
		
		emptyStatisticsImageView.isHidden = !emptyStatistics
		emptyStatisticsLabel.isHidden = !emptyStatistics
		stackView.isHidden = emptyStatistics
	}
	
	private func isStatisticEmpty() -> Bool {
		bestPeriodCount == 0 &&
		perfectDaysCount == 0 &&
		completedTrackersCount == 0 &&
		averageValueCount == 0
	}
	
	private func getStatisticView(caption: String, count: Int, countLabel: UILabel) -> UIView {
		let view = UIView(
			frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: 90)
		)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		view.layer.cornerRadius = 16
		view.layer.masksToBounds = true
		view.clipsToBounds = true
		
		let captionLabel = UILabel()
		captionLabel.text = caption
		captionLabel.font = .systemFont(ofSize: 12, weight: .medium)
		
		captionLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(countLabel)
		view.addSubview(captionLabel)
		
		NSLayoutConstraint.activate([
			captionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
			captionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
			countLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
			countLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12)
		])
		
		let colors: [UIColor] = [.redGradient, .greenGradient, .blueGradient]
		
		view.addGradient(
			colors: colors.map { $0.cgColor}, lineWidth: 2
		)
		
		
		return view
	}
	
	private func getCountLabel(_ count: Int) -> UILabel {
		let countLabel = UILabel()
		countLabel.text = "\(count)"
		countLabel.textColor = .ypTextColor
		countLabel.font = .systemFont(ofSize: 34, weight: .bold)
		countLabel.translatesAutoresizingMaskIntoConstraints = false
		
		return countLabel
	}
	
	private func setupViews() {
		view.backgroundColor = .ypBackground
		
		view.addSubview(headerLabel)
		view.addSubview(emptyStatisticsImageView)
		view.addSubview(emptyStatisticsLabel)
		view.addSubview(stackView)
		
		stackView.addSubview(bestPeriodView)
		stackView.addSubview(perfectDaysView)
		stackView.addSubview(completedTrackersView)
		stackView.addSubview(averageValueView)
	}
	
	private func setupConstraints() {
		setupHeaderLabelConstraints()
		setupEmptyStatisticsImageViewConstraints()
		setupEmptyStatisticsLabelConstraints()
		setupStackViewConstraints()
		setupStatisticViewsConstraints()
	}
	
	private func setupHeaderLabelConstraints() {
		NSLayoutConstraint.activate([
			headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44)
		])
	}
	
	private func setupEmptyStatisticsImageViewConstraints() {
		NSLayoutConstraint.activate([
			emptyStatisticsImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
			emptyStatisticsImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
			emptyStatisticsImageView.widthAnchor.constraint(equalToConstant: 80),
			emptyStatisticsImageView.heightAnchor.constraint(equalToConstant: 80)
		])
	}
	
	private func setupEmptyStatisticsLabelConstraints() {
		NSLayoutConstraint.activate([
			emptyStatisticsLabel.topAnchor.constraint(equalTo: emptyStatisticsImageView.bottomAnchor, constant: 8),
			emptyStatisticsLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
		])
	}
	
	private func setupStackViewConstraints() {
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 77),
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -126),
			stackView.widthAnchor.constraint(equalToConstant: view.frame.width - 32)
		])
	}
	
	private func setupStatisticViewsConstraints() {
		setupStatisticViewConstraint(
			bestPeriodView, topAnchor: stackView.topAnchor
		)
		setupStatisticViewConstraint(
			perfectDaysView, topAnchor: bestPeriodView.bottomAnchor
		)
		setupStatisticViewConstraint(
			completedTrackersView, topAnchor: perfectDaysView.bottomAnchor
		)
		setupStatisticViewConstraint(
			averageValueView, topAnchor: completedTrackersView.bottomAnchor
		)
	}
	
	private func setupStatisticViewConstraint(
		_ view: UIView,
		topAnchor: NSLayoutYAxisAnchor
	) {
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: topAnchor, constant: 12),
			view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
			view.heightAnchor.constraint(equalToConstant: 90),
			view.widthAnchor.constraint(equalTo: stackView.widthAnchor)
		])
	}
}

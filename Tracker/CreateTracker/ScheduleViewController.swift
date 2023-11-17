import UIKit

final class ScheduleViewController: UIViewController {
	// MARK: Public properties
	
	var weekDays: Set<WeekDay> = Set()
	
	// MARK: Private properties
	
	private var weekDaysConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
	
	private let cellReuseIdentifier = "weekDayCell"
	
	// MARK: Public properties
	
	var delegate: ScheduleViewControllerDelegateProtocol?
	
	// MARK: UI properties
	
	private lazy var headerLabel = {
		let label = UILabel()
		label.text = "Расписание"
		label.textColor = .black
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	private lazy var doneButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .ypBlackButton
		button.setTitle("Готово", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
		
		return button
	}()
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		addHeaderLabel()
		addWeekDays()
		addDoneButton()
	}
	
	// MARK: UI methods
	
	private func addHeaderLabel() {
		view.addSubview(headerLabel)
		
		NSLayoutConstraint.activate([
			headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
	}
	
	private func addWeekDays() {
		let monday = createWeekDayView(day: .monday, belowView: headerLabel, withMargin: 30)
		let thuesday = createWeekDayView(day: .thuesday, belowView: monday)
		let wednesday = createWeekDayView(day: .wednesday, belowView: thuesday)
		let thursday = createWeekDayView(day: .thursday, belowView: wednesday)
		let friday = createWeekDayView(day: .friday, belowView: thursday)
		let saturday = createWeekDayView(day: .saturday, belowView: friday)
		let sunday = createWeekDayView(day: .sunday, belowView: saturday, withDivider: false)
		
		monday.layer.cornerRadius = 16
		monday.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		sunday.layer.cornerRadius = 16
		sunday.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		
		NSLayoutConstraint.activate(weekDaysConstraints)
	}
	
	private func createWeekDayView(
		day: WeekDay,
		belowView: UIView,
		withMargin: CGFloat = 0,
		withDivider: Bool = true) -> UIView {
		let weekDayView = UIView(frame: CGRect(x: 0, y: 0, width: 343, height: 75))
		weekDayView.translatesAutoresizingMaskIntoConstraints = false
		weekDayView.backgroundColor = .lightGreyBackground
		
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = weekDayName[day]
		
		let switchView = UISwitch()
		switchView.translatesAutoresizingMaskIntoConstraints = false
		switchView.onTintColor = .ypBlue
		switchView.isOn = weekDays.contains(day)
		switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
		switchView.accessibilityIdentifier = String(day.rawValue)
		
		weekDayView.addSubview(label)
		weekDayView.addSubview(switchView)
			view.addSubview(weekDayView)
		
		weekDaysConstraints.append(contentsOf: [
			weekDayView.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: withMargin),
			weekDayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			weekDayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			weekDayView.widthAnchor.constraint(equalToConstant: weekDayView.frame.width),
			weekDayView.heightAnchor.constraint(equalToConstant: weekDayView.frame.height),
			label.leadingAnchor.constraint(equalTo: weekDayView.leadingAnchor, constant: 16),
			label.centerYAnchor.constraint(equalTo: weekDayView.centerYAnchor),
			switchView.trailingAnchor.constraint(equalTo: weekDayView.trailingAnchor, constant: -16),
			switchView.centerYAnchor.constraint(equalTo: weekDayView.centerYAnchor),
		])
		
		if (withDivider) {
			let divider = UIView(frame: CGRect(x: 0, y: 0, width: 311, height: 0.5))
			divider.translatesAutoresizingMaskIntoConstraints = false
			divider.backgroundColor = .greyDividerColor
			weekDayView.addSubview(divider)
			
			weekDaysConstraints.append(contentsOf: [
				divider.centerYAnchor.constraint(equalTo: weekDayView.bottomAnchor),
				divider.heightAnchor.constraint(equalToConstant: divider.frame.height),
				divider.widthAnchor.constraint(equalToConstant: divider.frame.width),
				divider.centerXAnchor.constraint(equalTo: weekDayView.centerXAnchor)
			])
		}
		
		return weekDayView
	}
	
	private func addDoneButton() {
		view.addSubview(doneButton)
		
		NSLayoutConstraint.activate([
			doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			doneButton.heightAnchor.constraint(equalToConstant: 60),
			doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
	}
	
	// MARK: Private methods
	
	@objc private func switchChanged(sender: UISwitch) {
		guard let id = sender.accessibilityIdentifier,
			  let dayNumber = Int(id),
			  let day = WeekDay(rawValue: dayNumber) else {
			return
		}
		
		if (sender.isOn) {
			weekDays.insert(day)
		} else {
			weekDays.remove(day)
		}
	}
	
	@objc private func doneButtonDidTap() {
		delegate?.addSchedule(weekDays: weekDays)
		dismiss(animated: true)
	}
}

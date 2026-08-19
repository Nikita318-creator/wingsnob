import UIKit
import SnapKit

struct OptionItem {
    let title: String
    let subtitle: String
    let iconName: String
    let destinationVC: UIViewController.Type
}

final class OptionsViewController: UIViewController {

    private let options: [OptionItem] = [
        OptionItem(
            title: "Macro Calculator",
            subtitle: "Calculate your daily nutritional targets and calories",
            iconName: "square.split.diagonal.2x2.fill",
            destinationVC: MacroCalculatorVC.self
        ),
        OptionItem(
            title: "Store Locations",
            subtitle: "Find the nearest venues and check working hours",
            iconName: "map.fill",
            destinationVC: StoreFinderVC.self
        ),
        OptionItem(
            title: "Menu Filter",
            subtitle: "Filter dishes by ingredients, calories, and allergies",
            iconName: "slider.horizontal.3",
            destinationVC: MenuFilterVC.self
        ),
        // MARK: - Updated Title, Subtitle & Icon
        OptionItem(
            title: "Daily Food Tracker",
            subtitle: "Log meals from 300+ items database, track daily calories, and hit your goals",
            iconName: "fork.knife.circle.fill",
            destinationVC: GlobalCalorieTrackerVC.self
        )
    ]

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(OptionCell.self, forCellReuseIdentifier: OptionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Options"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension OptionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: OptionCell.reuseIdentifier,
            for: indexPath
        ) as? OptionCell else {
            return UITableViewCell()
        }
        cell.configure(with: options[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = options[indexPath.row]
        let targetVC = item.destinationVC.init()
        targetVC.title = item.title
        targetVC.hidesBottomBarWhenPushed = false
        navigationController?.pushViewController(targetVC, animated: true)
    }
}

// MARK: - Custom Option Cell

final class OptionCell: UITableViewCell {
    static let reuseIdentifier = "OptionCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .systemRed
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 2
        return label
    }()

    private let chevronImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .darkGray
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(chevronImageView)

        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 32))
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 12, height: 18))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(iconImageView.snp.trailing).offset(16)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-12)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }

    func configure(with item: OptionItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        iconImageView.image = UIImage(systemName: item.iconName)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.containerView.backgroundColor = highlighted
                ? UIColor(white: 0.22, alpha: 1.0)
                : UIColor(white: 0.15, alpha: 1.0)
        }
    }
}

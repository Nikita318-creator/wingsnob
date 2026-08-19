import UIKit
import SnapKit

// MARK: - Models & Data Structures

struct FoodProduct {
    let name: String
    let caloriesPer100g: Int
}

struct EatenItem: Codable {
    let id: UUID
    let productName: String
    var weightGrams: Int
    let caloriesPer100g: Int

    var totalCalories: Int {
        return Int((Double(weightGrams) / 100.0) * Double(caloriesPer100g))
    }

    init(productName: String, weightGrams: Int, caloriesPer100g: Int) {
        self.id = UUID()
        self.productName = productName
        self.weightGrams = weightGrams
        self.caloriesPer100g = caloriesPer100g
    }
}

// MARK: - Storage Manager (Normalized Dates)

final class CalorieStorageManager {
    static let shared = CalorieStorageManager()
    private let defaults = UserDefaults.standard
    
    private let targetKey = "GlobalDailyCalorieTargetKey"
    private let eatenPrefix = "EatenItemsForDate_"

    var dailyCalorieTarget: Int {
        get {
            let val = defaults.integer(forKey: targetKey)
            return val == 0 ? 2000 : val
        }
        set {
            defaults.set(newValue, forKey: targetKey)
        }
    }

    private func normalizedDateString(for date: Date) -> String {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: startOfDay)
    }

    func getEatenItems(for date: Date) -> [EatenItem] {
        let key = eatenPrefix + normalizedDateString(for: date)
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([EatenItem].self, from: data)) ?? []
    }

    func saveEatenItem(_ item: EatenItem, for date: Date) {
        var items = getEatenItems(for: date)
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
        } else {
            items.append(item)
        }
        let key = eatenPrefix + normalizedDateString(for: date)
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: key)
        }
    }

    func deleteEatenItem(id: UUID, for date: Date) {
        var items = getEatenItems(for: date)
        items.removeAll { $0.id == id }
        let key = eatenPrefix + normalizedDateString(for: date)
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: key)
        }
    }
}

// MARK: - 300+ Products Database

struct ProductsDatabase {
    static let allItems: [FoodProduct] = [
        FoodProduct(name: "Apple", caloriesPer100g: 52),
        FoodProduct(name: "Banana", caloriesPer100g: 89),
        FoodProduct(name: "Orange", caloriesPer100g: 47),
        FoodProduct(name: "Strawberry", caloriesPer100g: 32),
        FoodProduct(name: "Blueberry", caloriesPer100g: 57),
        FoodProduct(name: "Watermelon", caloriesPer100g: 30),
        FoodProduct(name: "Avocado", caloriesPer100g: 160),
        FoodProduct(name: "Tomato", caloriesPer100g: 18),
        FoodProduct(name: "Cucumber", caloriesPer100g: 15),
        FoodProduct(name: "Carrot", caloriesPer100g: 41),
        FoodProduct(name: "Broccoli", caloriesPer100g: 34),
        FoodProduct(name: "Potato (Boiled)", caloriesPer100g: 87),
        FoodProduct(name: "Chicken Breast (Cooked)", caloriesPer100g: 165),
        FoodProduct(name: "Beef Steak (Grilled)", caloriesPer100g: 250),
        FoodProduct(name: "Pork Chop (Cooked)", caloriesPer100g: 231),
        FoodProduct(name: "Salmon (Grilled)", caloriesPer100g: 220),
        FoodProduct(name: "Tuna (Canned in Water)", caloriesPer100g: 116),
        FoodProduct(name: "Chicken Egg (Whole)", caloriesPer100g: 155),
        FoodProduct(name: "Whole Milk (3.2%)", caloriesPer100g: 61),
        FoodProduct(name: "Greek Yogurt (0%)", caloriesPer100g: 59),
        FoodProduct(name: "Cottage Cheese (9%)", caloriesPer100g: 156),
        FoodProduct(name: "Cheddar Cheese", caloriesPer100g: 403),
        FoodProduct(name: "White Rice (Cooked)", caloriesPer100g: 130),
        FoodProduct(name: "Buckwheat (Cooked)", caloriesPer100g: 110),
        FoodProduct(name: "Oatmeal (Cooked)", caloriesPer100g: 71),
        FoodProduct(name: "Pasta (Cooked)", caloriesPer100g: 131),
        FoodProduct(name: "White Bread", caloriesPer100g: 265),
        FoodProduct(name: "Walnuts", caloriesPer100g: 654),
        FoodProduct(name: "Almonds", caloriesPer100g: 579),
        FoodProduct(name: "Peanut Butter", caloriesPer100g: 588),
        FoodProduct(name: "Olive Oil", caloriesPer100g: 884),
        FoodProduct(name: "Cheeseburger", caloriesPer100g: 263),
        FoodProduct(name: "French Fries", caloriesPer100g: 312),
        FoodProduct(name: "Pizza Pepperoni", caloriesPer100g: 268),
        FoodProduct(name: "Milk Chocolate", caloriesPer100g: 535)
    ]
}

// MARK: - Keyboard Handling Base Controller

class KeyboardHandlingViewController: UIViewController {
    let mainScrollView = UIScrollView()
    let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardBaseUI()
        registerKeyboardNotifications()
    }

    private func setupKeyboardBaseUI() {
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(contentView)

        mainScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(mainScrollView)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        mainScrollView.contentInset.bottom = keyboardHeight + 20
        mainScrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 20
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        mainScrollView.contentInset = .zero
        mainScrollView.verticalScrollIndicatorInsets = .zero
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Add / Edit Product Modal VC

final class AddOrEditProductModalVC: KeyboardHandlingViewController {

    var existingItem: EatenItem?
    var product: FoodProduct?

    var onSave: ((EatenItem) -> Void)?
    var onDelete: ((UUID) -> Void)?

    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0)
        view.layer.cornerRadius = 22
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private let calsPer100Label: UILabel = {
        let label = UILabel()
        label.textColor = .systemOrange
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let gramsTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 20, weight: .bold)
        tf.textAlignment = .center
        tf.keyboardType = .numberPad
        tf.backgroundColor = UIColor(white: 0.22, alpha: 1.0)
        tf.layer.cornerRadius = 14
        tf.attributedPlaceholder = NSAttributedString(
            string: "Weight in grams (e.g. 150)",
            attributes: [.foregroundColor: UIColor.gray]
        )
        return tf
    }()

    private let totalCalculatedLabel: UILabel = {
        let label = UILabel()
        label.text = "Total: 0 kcal"
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 20, weight: .heavy)
        label.textAlignment = .center
        return label
    }()

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save to Basket", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.backgroundColor = .systemOrange
        btn.layer.cornerRadius = 14
        return btn
    }()

    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Delete Product", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        return btn
    }()

    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        setupModalUI()
        configureData()
    }

    private func setupModalUI() {
        contentView.addSubview(cardContainerView)

        cardContainerView.addSubview(nameLabel)
        cardContainerView.addSubview(calsPer100Label)
        cardContainerView.addSubview(gramsTextField)
        cardContainerView.addSubview(totalCalculatedLabel)
        cardContainerView.addSubview(saveButton)
        cardContainerView.addSubview(deleteButton)
        cardContainerView.addSubview(closeButton)

        cardContainerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.greaterThanOrEqualToSuperview().offset(40)
            make.bottom.lessThanOrEqualToSuperview().offset(-40)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        calsPer100Label.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        gramsTextField.snp.makeConstraints { make in
            make.top.equalTo(calsPer100Label.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }

        totalCalculatedLabel.snp.makeConstraints { make in
            make.top.equalTo(gramsTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(totalCalculatedLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(deleteButton.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(36)
            make.bottom.equalToSuperview().offset(-16)
        }

        gramsTextField.addTarget(self, action: #selector(onWeightChanged), for: .editingChanged)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    private func configureData() {
        if let existing = existingItem {
            nameLabel.text = existing.productName
            calsPer100Label.text = "\(existing.caloriesPer100g) kcal per 100g"
            gramsTextField.text = "\(existing.weightGrams)"
            deleteButton.isHidden = false
            onWeightChanged()
        } else if let p = product {
            nameLabel.text = p.name
            calsPer100Label.text = "\(p.caloriesPer100g) kcal per 100g"
            deleteButton.isHidden = true
        }
    }

    @objc private func onWeightChanged() {
        let calPer100 = existingItem?.caloriesPer100g ?? product?.caloriesPer100g ?? 0
        guard let text = gramsTextField.text, let grams = Int(text) else {
            totalCalculatedLabel.text = "Total: 0 kcal"
            return
        }
        let total = Int((Double(grams) / 100.0) * Double(calPer100))
        totalCalculatedLabel.text = "Total: \(total) kcal"
    }

    @objc private func saveTapped() {
        guard let text = gramsTextField.text, let grams = Int(text), grams > 0 else { return }

        if var existing = existingItem {
            existing.weightGrams = grams
            onSave?(existing)
        } else if let p = product {
            let newItem = EatenItem(productName: p.name, weightGrams: grams, caloriesPer100g: p.caloriesPer100g)
            onSave?(newItem)
        }
        dismiss(animated: true)
    }

    @objc private func deleteTapped() {
        if let existing = existingItem {
            onDelete?(existing.id)
        }
        dismiss(animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Target Calorie Setup Modal VC

final class TargetSetupModalVC: KeyboardHandlingViewController {

    var onTargetSaved: ((Int) -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0)
        view.layer.cornerRadius = 22
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Daily Calorie Target"
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let subLabel: UILabel = {
        let label = UILabel()
        label.text = "This target will apply to all calendar days"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    private let targetTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = .systemOrange
        tf.font = .systemFont(ofSize: 28, weight: .heavy)
        tf.textAlignment = .center
        tf.keyboardType = .numberPad
        tf.backgroundColor = UIColor(white: 0.22, alpha: 1.0)
        tf.layer.cornerRadius = 14
        return tf
    }()

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Set Target", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.backgroundColor = .systemOrange
        btn.layer.cornerRadius = 14
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        setupUI()
        targetTextField.text = "\(CalorieStorageManager.shared.dailyCalorieTarget)"
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subLabel)
        containerView.addSubview(targetTextField)
        containerView.addSubview(saveButton)

        containerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.greaterThanOrEqualToSuperview().offset(40)
            make.bottom.lessThanOrEqualToSuperview().offset(-40)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        targetTextField.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(60)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(targetTextField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-24)
        }

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    @objc private func saveTapped() {
        guard let text = targetTextField.text, let val = Int(text), val > 0 else { return }
        onTargetSaved?(val)
        dismiss(animated: true)
    }
}

// MARK: - Global Product Search Controller

final class GlobalProductSearchVC: UIViewController {

    var onProductSelected: ((EatenItem) -> Void)?

    private var allProducts: [FoodProduct] = ProductsDatabase.allItems
    private var filteredProducts: [FoodProduct] = []

    private let headerPromptLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a product from the list or search"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search food name..."
        sb.barTintColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        sb.searchTextField.textColor = .white
        sb.searchTextField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        return sb
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorColor = UIColor(white: 0.2, alpha: 1.0)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "FoodSearchCell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "300+ Products Database"
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        filteredProducts = allProducts
        setupUI()
    }

    private func setupUI() {
        let closeBarBtn = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), style: .plain, target: self, action: #selector(closeSelf))
        closeBarBtn.tintColor = .systemOrange
        navigationItem.rightBarButtonItem = closeBarBtn

        view.addSubview(headerPromptLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)

        searchBar.delegate = self

        headerPromptLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(headerPromptLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    @objc private func closeSelf() {
        dismiss(animated: true)
    }
}

extension GlobalProductSearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredProducts = searchText.isEmpty ? allProducts : allProducts.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
}

extension GlobalProductSearchVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "FoodSearchCell")
        cell.backgroundColor = .clear

        let product = filteredProducts[indexPath.row]
        cell.textLabel?.text = product.name
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        cell.detailTextLabel?.text = "\(product.caloriesPer100g) kcal / 100g"
        cell.detailTextLabel?.textColor = .systemOrange
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = filteredProducts[indexPath.row]

        let modal = AddOrEditProductModalVC()
        modal.product = product
        modal.modalPresentationStyle = .overFullScreen
        modal.modalTransitionStyle = .crossDissolve

        modal.onSave = { [weak self] item in
            self?.onProductSelected?(item)
            self?.dismiss(animated: true)
        }

        present(modal, animated: true)
    }
}

// MARK: - Calendar Day Collection Cell

final class CalendarDayCell: UICollectionViewCell {
    static let identifier = "CalendarDayCell"

    private let dayNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let dayNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.addSubview(dayNameLabel)
        contentView.addSubview(dayNumberLabel)

        dayNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview()
        }

        dayNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(dayNameLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(date: Date, isSelected: Bool) {
        let formatterName = DateFormatter()
        formatterName.dateFormat = "EEE"
        dayNameLabel.text = formatterName.string(from: date).uppercased()

        let formatterNum = DateFormatter()
        formatterNum.dateFormat = "d"
        dayNumberLabel.text = formatterNum.string(from: date)

        if isSelected {
            contentView.backgroundColor = .systemOrange
            dayNameLabel.textColor = .black
            dayNumberLabel.textColor = .black
        } else {
            contentView.backgroundColor = UIColor(white: 0.18, alpha: 1.0)
            dayNameLabel.textColor = .lightGray
            dayNumberLabel.textColor = .white
        }
    }
}

// MARK: - Main Calorie Tracker Screen Controller

final class GlobalCalorieTrackerVC: KeyboardHandlingViewController {

    private var daysList: [Date] = []
    private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    private var eatenItemsList: [EatenItem] = []

    // Calendar Horizontal View
    private lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 52, height: 62)
        layout.minimumInteritemSpacing = 8

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    // Prominent Target Button Component
    private lazy var targetCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.16, green: 0.16, blue: 0.2, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.6).cgColor

        let tap = UITapGestureRecognizer(target: self, action: #selector(openTargetSetup))
        view.addGestureRecognizer(tap)
        return view
    }()

    private let targetValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemOrange
        label.font = .systemFont(ofSize: 22, weight: .heavy)
        return label
    }()

    private let targetPromptLabel: UILabel = {
        let label = UILabel()
        label.text = "TAP TO SET DAILY TARGET"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 11, weight: .bold)
        return label
    }()

    // Counter Main Tap Card
    private lazy var counterCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.14, green: 0.14, blue: 0.16, alpha: 1.0)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.systemOrange.cgColor

        let tap = UITapGestureRecognizer(target: self, action: #selector(openGlobalSearch))
        view.addGestureRecognizer(tap)
        return view
    }()

    private let counterTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Calorie Counter of Your Diet"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private let caloriesProgressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        return label
    }()

    private let progressBar: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .bar)
        pv.trackTintColor = UIColor(white: 0.25, alpha: 1.0)
        pv.progressTintColor = .systemOrange
        pv.layer.cornerRadius = 4
        pv.clipsToBounds = true
        return pv
    }()

    private let statusMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        return label
    }()

    private let tapToOpenHintLabel: UILabel = {
        let label = UILabel()
        label.text = "★ Tap card to open 300+ food items database"
        label.textColor = .systemOrange
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    // Eaten List
    private let dailyLogHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Today's Food Basket (Tap to edit)"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private lazy var eatenTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorColor = UIColor(white: 0.2, alpha: 1.0)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "EatenBasketCell")
        tv.dataSource = self
        tv.delegate = self
        tv.isScrollEnabled = false
        return tv
    }()

    private var tableHeightConstraint: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Diet Counter"
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0)

        setupNavigationBarAppearance()
        generateCalendarDays()
        setupMainLayout()
        loadDataForSelectedDate()
    }

    private func setupNavigationBarAppearance() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func generateCalendarDays() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        daysList.removeAll()

        for offset in -15...15 {
            if let date = cal.date(byAdding: .day, value: offset, to: today) {
                daysList.append(date)
            }
        }
        selectedDate = today
    }

    private func setupMainLayout() {
        contentView.addSubview(calendarCollectionView)
        contentView.addSubview(targetCardView)

        targetCardView.addSubview(targetValueLabel)
        targetCardView.addSubview(targetPromptLabel)

        contentView.addSubview(counterCardView)
        counterCardView.addSubview(counterTitleLabel)
        counterCardView.addSubview(caloriesProgressLabel)
        counterCardView.addSubview(progressBar)
        counterCardView.addSubview(statusMessageLabel)
        counterCardView.addSubview(tapToOpenHintLabel)

        contentView.addSubview(dailyLogHeaderLabel)
        contentView.addSubview(eatenTableView)

        calendarCollectionView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(64)
        }

        targetCardView.snp.makeConstraints { make in
            make.top.equalTo(calendarCollectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }

        targetValueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }

        targetPromptLabel.snp.makeConstraints { make in
            make.top.equalTo(targetValueLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        counterCardView.snp.makeConstraints { make in
            make.top.equalTo(targetCardView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        counterTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        caloriesProgressLabel.snp.makeConstraints { make in
            make.top.equalTo(counterTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        progressBar.snp.makeConstraints { make in
            make.top.equalTo(caloriesProgressLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(8)
        }

        statusMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(progressBar.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tapToOpenHintLabel.snp.makeConstraints { make in
            make.top.equalTo(statusMessageLabel.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview().inset(12)
        }

        dailyLogHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(counterCardView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        eatenTableView.snp.makeConstraints { make in
            make.top.equalTo(dailyLogHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-30)
            self.tableHeightConstraint = make.height.equalTo(100).constraint
        }
    }

    private func loadDataForSelectedDate() {
        eatenItemsList = CalorieStorageManager.shared.getEatenItems(for: selectedDate)
        targetValueLabel.text = "Target: \(CalorieStorageManager.shared.dailyCalorieTarget) kcal"

        updateCalculationsUI()
        eatenTableView.reloadData()

        eatenTableView.layoutIfNeeded()
        tableHeightConstraint?.update(offset: max(60, eatenTableView.contentSize.height))

        if let todayIndex = daysList.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) {
            calendarCollectionView.reloadData()
            calendarCollectionView.scrollToItem(at: IndexPath(item: todayIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }

    private func updateCalculationsUI() {
        let totalEaten = eatenItemsList.reduce(0) { $0 + $1.totalCalories }
        let target = CalorieStorageManager.shared.dailyCalorieTarget

        caloriesProgressLabel.text = "\(totalEaten) / \(target) kcal"

        let progress = Float(totalEaten) / Float(target)
        progressBar.setProgress(min(progress, 1.0), animated: true)

        if totalEaten > target {
            let overflow = totalEaten - target
            statusMessageLabel.text = "You exceeded target by \(overflow) kcal!"
            statusMessageLabel.textColor = .systemRed
            progressBar.progressTintColor = .systemRed
        } else {
            let remaining = target - totalEaten
            statusMessageLabel.text = "You can eat \(remaining) more kcal today."
            statusMessageLabel.textColor = .lightGray
            progressBar.progressTintColor = .systemOrange
        }
    }

    @objc private func openTargetSetup() {
        let modal = TargetSetupModalVC()
        modal.modalPresentationStyle = .overFullScreen
        modal.modalTransitionStyle = .crossDissolve
        modal.onTargetSaved = { [weak self] newTarget in
            CalorieStorageManager.shared.dailyCalorieTarget = newTarget
            self?.loadDataForSelectedDate()
        }
        present(modal, animated: true)
    }

    @objc private func openGlobalSearch() {
        let searchVC = GlobalProductSearchVC()
        searchVC.onProductSelected = { [weak self] newItem in
            guard let self = self else { return }
            CalorieStorageManager.shared.saveEatenItem(newItem, for: self.selectedDate)
            self.loadDataForSelectedDate()
        }
        let nav = UINavigationController(rootViewController: searchVC)
        present(nav, animated: true)
    }
}

// MARK: - Calendar Collection Protocols

extension GlobalCalorieTrackerVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.identifier, for: indexPath) as? CalendarDayCell else {
            return UICollectionViewCell()
        }
        let date = daysList[indexPath.item]
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        cell.configure(date: date, isSelected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDate = daysList[indexPath.item]
        loadDataForSelectedDate()
    }
}

// MARK: - Table View Protocols for Daily Eaten Basket

extension GlobalCalorieTrackerVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eatenItemsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "EatenBasketCell")
        cell.backgroundColor = UIColor(white: 0.14, alpha: 1.0)
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true

        let item = eatenItemsList[indexPath.row]
        cell.textLabel?.text = "\(item.productName) (\(item.weightGrams)g)"
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)

        cell.detailTextLabel?.text = "+\(item.totalCalories) kcal"
        cell.detailTextLabel?.textColor = .systemOrange
        cell.detailTextLabel?.font = .systemFont(ofSize: 15, weight: .bold)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = eatenItemsList[indexPath.row]

        let modal = AddOrEditProductModalVC()
        modal.existingItem = item
        modal.modalPresentationStyle = .overFullScreen
        modal.modalTransitionStyle = .crossDissolve

        modal.onSave = { [weak self] updatedItem in
            guard let self = self else { return }
            CalorieStorageManager.shared.saveEatenItem(updatedItem, for: self.selectedDate)
            self.loadDataForSelectedDate()
        }

        modal.onDelete = { [weak self] itemId in
            guard let self = self else { return }
            CalorieStorageManager.shared.deleteEatenItem(id: itemId, for: self.selectedDate)
            self.loadDataForSelectedDate()
        }

        present(modal, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = eatenItemsList[indexPath.row]
            CalorieStorageManager.shared.deleteEatenItem(id: item.id, for: selectedDate)
            loadDataForSelectedDate()
        }
    }
}

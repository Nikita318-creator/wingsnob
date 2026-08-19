import UIKit
import SnapKit
import MapKit

// MARK: - Models

enum MenuCategory: String, CaseIterable {
    case all = "All"
    case wings = "Wings"
    case chicken = "Chicken"
    case sides = "Sides"
    case sauces = "Sauces"
    case drinks = "Drinks"
}

struct WingMenuItem {
    let title: String
    let imageName: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let category: MenuCategory
    let description: String
    let allergens: String
    let isGlutenFree: Bool
    let isSpicy: Bool
    let spiceLevel: Int // 0 = none, 1 = mild, 2 = medium, 3 = atomic
    let price: Double
}

struct LocationItem {
    let city: String
    let street: String
    let phone: String
    let hours: String
    let coordinate: CLLocationCoordinate2D
}

// Recommended daily values, used purely for the in-app progress visualizations
enum DailyReference {
    static let calories: Double = 2000
    static let protein: Double = 50
    static let carbs: Double = 275
    static let fat: Double = 78
}

// MARK: - Main Container

class MainBaseVC: UIViewController {

    private let tabBarVC = UITabBarController()
    private var hasShownWelcomeAlert = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupEmbeddedTabBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showWelcomeNoticeIfNeeded()
    }

    private func setupEmbeddedTabBar() {
        let menuVC = UINavigationController(rootViewController: MenuGuideVC())
        menuVC.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(systemName: "book.fill"), tag: 0)

        let calculatorVC = UINavigationController(rootViewController: MacroCalculatorVC())
        calculatorVC.tabBarItem = UITabBarItem(title: "Calculator", image: UIImage(systemName: "square.split.diagonal.2x2.fill"), tag: 1)

        let locationsVC = UINavigationController(rootViewController: StoreFinderVC())
        locationsVC.tabBarItem = UITabBarItem(title: "Locations", image: UIImage(systemName: "map.fill"), tag: 2)

        let filterVC = UINavigationController(rootViewController: MenuFilterVC())
        filterVC.tabBarItem = UITabBarItem(title: "Filter", image: UIImage(systemName: "slider.horizontal.3"), tag: 3)

        let gameVC = GameVC()
        gameVC.tabBarItem = UITabBarItem(title: "Quest", image: UIImage(systemName: "gamecontroller.fill"), tag: 4)
        
        tabBarVC.viewControllers = [menuVC, calculatorVC, locationsVC, filterVC, gameVC]

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.iconColor = .systemRed
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemRed]
        appearance.stackedLayoutAppearance.normal.iconColor = .lightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]

        tabBarVC.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarVC.tabBar.scrollEdgeAppearance = appearance
        }

        addChild(tabBarVC)
        view.addSubview(tabBarVC.view)
        tabBarVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tabBarVC.didMove(toParent: self)
    }

    private func showWelcomeNoticeIfNeeded() {
        guard !hasShownWelcomeAlert else { return }
        hasShownWelcomeAlert = true

        let alert = UIAlertController(
            title: "Welcome to WINGSNOB",
            message: "Explore our menu items, calculate calories, check allergens, and locate our stores across IL, MI, and WI.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Get Started", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Data Source

enum MenuData {
    static let items: [WingMenuItem] = [
        WingMenuItem(title: "Boneless Wings", imageName: "BONELESSWINGS", calories: 650, protein: 42, carbs: 28, fat: 38, category: .wings, description: "Juicy tender boneless chicken bites lightly breaded and tossed in signature dry rubs.", allergens: "Gluten, Wheat", isGlutenFree: false, isSpicy: true, spiceLevel: 2, price: 10.99),
        WingMenuItem(title: "Buffalo Chicken", imageName: "BUFFALOCHICKEN", calories: 720, protein: 48, carbs: 12, fat: 52, category: .chicken, description: "Classic chicken breast tossed in traditional spicy buffalo reduction.", allergens: "Dairy, Milk", isGlutenFree: true, isSpicy: true, spiceLevel: 2, price: 11.49),
        WingMenuItem(title: "Cheese Bites", imageName: "CHEESEBITES", calories: 480, protein: 18, carbs: 32, fat: 30, category: .sides, description: "Golden crispy cheese curds melted internally with a savory herb breading.", allergens: "Dairy, Gluten", isGlutenFree: false, isSpicy: false, spiceLevel: 0, price: 6.99),
        WingMenuItem(title: "Cheese Fries", imageName: "CHEESEFRIES", calories: 530, protein: 12, carbs: 64, fat: 26, category: .sides, description: "Fresh cut potatoes topped with warm signature melted cheddar sauce.", allergens: "Dairy", isGlutenFree: true, isSpicy: false, spiceLevel: 0, price: 5.99),
        WingMenuItem(title: "Chicken Tenders", imageName: "CHICKENTENDERS", calories: 610, protein: 45, carbs: 22, fat: 36, category: .chicken, description: "Hand-breaded premium tenderloins cooked to crisp golden perfection.", allergens: "Gluten, Wheat", isGlutenFree: false, isSpicy: false, spiceLevel: 0, price: 9.99),
        WingMenuItem(title: "Dipping Sauces", imageName: "DIPPINGSAUCES", calories: 120, protein: 1, carbs: 4, fat: 11, category: .sauces, description: "Variety of house-crafted dipping sauces ranging from sweet barbecue to hot habanero.", allergens: "Varies by sauce", isGlutenFree: true, isSpicy: false, spiceLevel: 1, price: 0.99),
        WingMenuItem(title: "Lemonade", imageName: "LEMONADE", calories: 150, protein: 0, carbs: 38, fat: 0, category: .drinks, description: "Freshly squeezed lemon juice blended with pure cane sugar and chilled water.", allergens: "None", isGlutenFree: true, isSpicy: false, spiceLevel: 0, price: 2.99),
        WingMenuItem(title: "Mozzarella Sticks", imageName: "MOZZARELLASTICKS", calories: 510, protein: 22, carbs: 38, fat: 28, category: .sides, description: "Stretched mozzarella coated in Italian-seasoned breadcrumbs.", allergens: "Dairy, Gluten", isGlutenFree: false, isSpicy: false, spiceLevel: 0, price: 6.49),
        WingMenuItem(title: "Onion Rings", imageName: "ONIONRINGS", calories: 420, protein: 6, carbs: 48, fat: 22, category: .sides, description: "Thick-cut sweet onion rings fried in a light batter.", allergens: "Gluten", isGlutenFree: false, isSpicy: false, spiceLevel: 0, price: 5.49),
        WingMenuItem(title: "Traditional Wings", imageName: "TRADITIONALWINGS", calories: 780, protein: 54, carbs: 2, fat: 60, category: .wings, description: "Authentic jumbo bone-in wings tossed in custom spice blends.", allergens: "None", isGlutenFree: true, isSpicy: true, spiceLevel: 3, price: 12.99)
    ]
}

// MARK: - Shared UI helpers

/// A small rounded pill used to badge a menu item's category across the app.
final class CategoryBadge: UIView {
    private let label = UILabel()

    init(text: String) {
        super.init(frame: .zero)
        backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        layer.cornerRadius = 10
        clipsToBounds = true

        label.text = text.uppercased()
        label.font = .systemFont(ofSize: 10, weight: .heavy)
        label.textColor = .white
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8))
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

/// Horizontal labeled progress bar used to show a macro relative to a daily reference value.
final class MacroProgressRow: UIView {
    private let nameLabel = UILabel()
    private let valueLabel = UILabel()
    private let track = UIView()
    private let fill = UIView()
    private var fillWidthConstraint: Constraint?

    init(name: String, color: UIColor) {
        super.init(frame: .zero)

        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        nameLabel.textColor = .label

        valueLabel.font = .systemFont(ofSize: 12, weight: .regular)
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .right

        track.backgroundColor = .systemGray5
        track.layer.cornerRadius = 4
        track.clipsToBounds = true

        fill.backgroundColor = color
        fill.layer.cornerRadius = 4

        addSubview(nameLabel)
        addSubview(valueLabel)
        addSubview(track)
        track.addSubview(fill)

        nameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.trailing.equalToSuperview()
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(8)
        }
        track.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(8)
        }
        fill.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            fillWidthConstraint = make.width.equalToSuperview().multipliedBy(0).constraint
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(value: Int, unit: String, dailyReference: Double) {
        valueLabel.text = "\(value)\(unit) • \(Int((Double(value) / dailyReference) * 100))% DV"
        let ratio = min(Double(value) / dailyReference, 1.0)
        fillWidthConstraint?.deactivate()
        fill.snp.remakeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(ratio)
        }
        layoutIfNeeded()
    }
}

// MARK: - Tab 1: Menu Guide

class MenuGuideVC: UIViewController {

    private var displayedItems: [WingMenuItem] = MenuData.items
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshControl = UIRefreshControl()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(MenuCell.self, forCellWithReuseIdentifier: "MenuCell")
        cv.alwaysBounceVertical = true
        cv.refreshControl = refreshControl
        return cv
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No items match your search."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WINGSNOB Menu"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground

        setupSearch()
        view.addSubview(collectionView)
        view.addSubview(emptyStateLabel)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search wings, sides, drinks..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    @objc private func handleRefresh() {
        // Simulated freshness check so the menu screen feels alive rather than static.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.collectionView.reloadData()
        }
    }

    private func applyFilter(query: String) {
        if query.isEmpty {
            displayedItems = MenuData.items
        } else {
            displayedItems = MenuData.items.filter {
                $0.title.lowercased().contains(query.lowercased()) ||
                $0.category.rawValue.lowercased().contains(query.lowercased())
            }
        }
        emptyStateLabel.isHidden = !displayedItems.isEmpty
        collectionView.reloadData()
    }
}

extension MenuGuideVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        applyFilter(query: searchController.searchBar.text ?? "")
    }
}

extension MenuGuideVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.configure(with: displayedItems[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 2
        return CGSize(width: width, height: width + 72)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = MenuDetailVC(item: displayedItems[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

class MenuCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let calLabel = UILabel()
    private let priceLabel = UILabel()
    private var badge: CategoryBadge?
    private let glutenFreeIcon = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 14
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1

        calLabel.font = .systemFont(ofSize: 12, weight: .regular)
        calLabel.textColor = .secondaryLabel

        priceLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        priceLabel.textColor = .systemRed

        glutenFreeIcon.image = UIImage(systemName: "leaf.fill")
        glutenFreeIcon.tintColor = .systemGreen
        glutenFreeIcon.contentMode = .scaleAspectFit
        glutenFreeIcon.isHidden = true

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(calLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(glutenFreeIcon)

        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(contentView.snp.width)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        calLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.equalToSuperview().inset(8)
        }
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(calLabel)
            make.trailing.equalToSuperview().inset(8)
        }
        glutenFreeIcon.snp.makeConstraints { make in
            make.width.height.equalTo(14)
            make.bottom.equalTo(imageView.snp.bottom).inset(6)
            make.trailing.equalTo(imageView.snp.trailing).inset(6)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        badge?.removeFromSuperview()
        badge = nil
    }

    func configure(with item: WingMenuItem) {
        imageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        calLabel.text = "\(item.calories) kcal"
        priceLabel.text = String(format: "$%.2f", item.price)
        glutenFreeIcon.isHidden = !item.isGlutenFree

        let newBadge = CategoryBadge(text: item.category.rawValue)
        contentView.addSubview(newBadge)
        newBadge.snp.makeConstraints { make in
            make.top.leading.equalTo(imageView).inset(8)
        }
        badge = newBadge
    }
}

class MenuDetailVC: UIViewController {
    private let item: WingMenuItem
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    init(item: WingMenuItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = item.title

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareItem))

        setupScrollView()
        buildContent()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentStack.axis = .vertical
        contentStack.spacing = 16
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    private func buildContent() {
        let imageView = UIImageView(image: UIImage(named: item.imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.snp.makeConstraints { make in
            make.height.equalTo(220)
        }

        let headerRow = UIStackView()
        headerRow.axis = .horizontal
        headerRow.distribution = .equalSpacing

        let priceLabel = UILabel()
        priceLabel.text = String(format: "$%.2f", item.price)
        priceLabel.font = .systemFont(ofSize: 20, weight: .heavy)
        priceLabel.textColor = .systemRed

        let spiceLabel = UILabel()
        spiceLabel.font = .systemFont(ofSize: 16)
        spiceLabel.text = item.spiceLevel == 0 ? "No Spice" : String(repeating: "🌶️", count: item.spiceLevel)

        headerRow.addArrangedSubview(priceLabel)
        headerRow.addArrangedSubview(spiceLabel)

        let descLabel = UILabel()
        descLabel.text = item.description
        descLabel.numberOfLines = 0
        descLabel.font = .systemFont(ofSize: 15)
        descLabel.textColor = .label

        let tagsRow = UIStackView()
        tagsRow.axis = .horizontal
        tagsRow.spacing = 8
        tagsRow.addArrangedSubview(CategoryBadge(text: item.category.rawValue))
        if item.isGlutenFree {
            tagsRow.addArrangedSubview(CategoryBadge(text: "Gluten-Free"))
        }
        if item.isSpicy {
            tagsRow.addArrangedSubview(CategoryBadge(text: "Spicy"))
        }
        tagsRow.addArrangedSubview(UIView()) // spacer to keep pills left-aligned

        let nutritionCard = makeCard()
        let nutritionTitle = sectionTitle("Nutrition Facts")
        let caloriesLine = UILabel()
        caloriesLine.text = "\(item.calories) kcal per serving"
        caloriesLine.font = .systemFont(ofSize: 14, weight: .medium)
        caloriesLine.textColor = .secondaryLabel

        let proteinRow = MacroProgressRow(name: "Protein", color: .systemBlue)
        proteinRow.configure(value: item.protein, unit: "g", dailyReference: DailyReference.protein)
        let carbsRow = MacroProgressRow(name: "Carbohydrates", color: .systemOrange)
        carbsRow.configure(value: item.carbs, unit: "g", dailyReference: DailyReference.carbs)
        let fatRow = MacroProgressRow(name: "Fat", color: .systemPurple)
        fatRow.configure(value: item.fat, unit: "g", dailyReference: DailyReference.fat)
        let calRow = MacroProgressRow(name: "Calories", color: .systemRed)
        calRow.configure(value: item.calories, unit: "", dailyReference: DailyReference.calories)

        let nutritionStack = UIStackView(arrangedSubviews: [nutritionTitle, caloriesLine, calRow, proteinRow, carbsRow, fatRow])
        nutritionStack.axis = .vertical
        nutritionStack.spacing = 12
        nutritionCard.addSubview(nutritionStack)
        nutritionStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        let allergenCard = makeCard()
        let allergenTitle = sectionTitle("Allergens")
        let allergenLabel = UILabel()
        allergenLabel.text = item.allergens
        allergenLabel.font = .systemFont(ofSize: 14)
        allergenLabel.textColor = .label
        allergenLabel.numberOfLines = 0
        let allergenStack = UIStackView(arrangedSubviews: [allergenTitle, allergenLabel])
        allergenStack.axis = .vertical
        allergenStack.spacing = 8
        allergenCard.addSubview(allergenStack)
        allergenStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        let pairingsCard = makeCard()
        let pairingsTitle = sectionTitle("Pairs Well With")
        let pairingsScroll = makePairingsScroll()
        let pairingsStack = UIStackView(arrangedSubviews: [pairingsTitle, pairingsScroll])
        pairingsStack.axis = .vertical
        pairingsStack.spacing = 12
        pairingsCard.addSubview(pairingsStack)
        pairingsStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        pairingsScroll.snp.makeConstraints { make in
            make.height.equalTo(110)
        }

        [imageView, headerRow, descLabel, tagsRow, nutritionCard, allergenCard, pairingsCard].forEach {
            contentStack.addArrangedSubview($0)
        }
        contentStack.setCustomSpacing(24, after: pairingsCard)

        [imageView, headerRow, descLabel, tagsRow, nutritionCard, allergenCard, pairingsCard].forEach { view in
            view.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(20)
            }
        }
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
        }
    }

    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        return card
    }

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }

    private func makePairingsScroll() -> UIScrollView {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        scroll.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        let suggestions = MenuData.items.filter { $0.title != item.title }.shuffled().prefix(4)
        for suggestion in suggestions {
            let card = UIView()
            card.backgroundColor = .systemGroupedBackground
            card.layer.cornerRadius = 10

            let img = UIImageView(image: UIImage(named: suggestion.imageName))
            img.contentMode = .scaleAspectFill
            img.clipsToBounds = true
            img.layer.cornerRadius = 8

            let label = UILabel()
            label.text = suggestion.title
            label.font = .systemFont(ofSize: 11, weight: .semibold)
            label.numberOfLines = 2
            label.textAlignment = .center

            card.addSubview(img)
            card.addSubview(label)
            img.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview().inset(6)
                make.height.equalTo(60)
            }
            label.snp.makeConstraints { make in
                make.top.equalTo(img.snp.bottom).offset(4)
                make.leading.trailing.equalToSuperview().inset(4)
            }
            card.snp.makeConstraints { make in
                make.width.equalTo(84)
            }
            stack.addArrangedSubview(card)
        }
        return scroll
    }

    @objc private func shareItem() {
        let text = "\(item.title) — \(item.calories) kcal, $\(String(format: "%.2f", item.price)) at WINGSNOB"
        let activity = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activity, animated: true)
    }
}

// MARK: - Tab 2: Macro Calculator

private struct CalculatorRowState {
    var quantity: Int = 0
}

class MacroCalculatorVC: UIViewController {

    private var rowStates: [CalculatorRowState] = MenuData.items.map { _ in CalculatorRowState() }

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let totalsBar = UIView()
    private let totalCaloriesLabel = UILabel()
    private let totalMacrosLabel = UILabel()
    private let totalPriceLabel = UILabel()
    private let dvLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Macro Calculator"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetAll))

        setupUI()
        updateTotals()
    }

    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CalculatorCell.self, forCellReuseIdentifier: "CalculatorCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 84

        totalsBar.backgroundColor = .secondarySystemGroupedBackground
        totalsBar.layer.cornerRadius = 16
        totalsBar.layer.shadowColor = UIColor.black.cgColor
        totalsBar.layer.shadowOpacity = 0.08
        totalsBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        totalsBar.layer.shadowRadius = 8

        let titleLabel = UILabel()
        titleLabel.text = "Total Nutrition"
        titleLabel.font = .systemFont(ofSize: 13, weight: .heavy)
        titleLabel.textColor = .secondaryLabel

        totalCaloriesLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        totalCaloriesLabel.textColor = .systemRed

        totalMacrosLabel.font = .systemFont(ofSize: 13, weight: .medium)
        totalMacrosLabel.textColor = .label
        totalMacrosLabel.numberOfLines = 0

        totalPriceLabel.font = .systemFont(ofSize: 15, weight: .bold)
        totalPriceLabel.textColor = .label

        dvLabel.font = .systemFont(ofSize: 11, weight: .regular)
        dvLabel.textColor = .tertiaryLabel
        dvLabel.text = "% Daily Value based on a 2000 calorie diet"

        let topRow = UIStackView(arrangedSubviews: [titleLabel, UIView(), totalPriceLabel])
        topRow.axis = .horizontal
        topRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [topRow, totalCaloriesLabel, totalMacrosLabel, dvLabel])
        stack.axis = .vertical
        stack.spacing = 6

        view.addSubview(tableView)
        view.addSubview(totalsBar)
        totalsBar.addSubview(stack)

        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(totalsBar.snp.top).offset(-8)
        }
        totalsBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }

    @objc private func resetAll() {
        rowStates = MenuData.items.map { _ in CalculatorRowState() }
        tableView.reloadData()
        updateTotals()
    }

    private func updateTotals() {
        var cals = 0, prot = 0, carbs = 0, fat = 0
        var price: Double = 0
        for (index, state) in rowStates.enumerated() {
            guard state.quantity > 0 else { continue }
            let item = MenuData.items[index]
            cals += item.calories * state.quantity
            prot += item.protein * state.quantity
            carbs += item.carbs * state.quantity
            fat += item.fat * state.quantity
            price += item.price * Double(state.quantity)
        }
        totalCaloriesLabel.text = "\(cals) kcal"
        let dv = Int((Double(cals) / DailyReference.calories) * 100)
        totalMacrosLabel.text = "Protein \(prot)g • Carbs \(carbs)g • Fat \(fat)g  (\(dv)% daily calories)"
        totalPriceLabel.text = String(format: "$%.2f", price)
    }
}

extension MacroCalculatorVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MenuData.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalculatorCell", for: indexPath) as! CalculatorCell
        cell.configure(item: MenuData.items[indexPath.row], quantity: rowStates[indexPath.row].quantity)
        cell.onQuantityChanged = { [weak self] newQuantity in
            guard let self = self else { return }
            self.rowStates[indexPath.row].quantity = newQuantity
            self.updateTotals()
        }
        return cell
    }
}

class CalculatorCell: UITableViewCell {
    private let container = UIView()
    private let imageViewBase = UIImageView()
    private let titleLabel = UILabel()
    private let macroLabel = UILabel()
    private let stepper = UIStepper()
    private let quantityLabel = UILabel()

    var onQuantityChanged: ((Int) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12

        imageViewBase.contentMode = .scaleAspectFill
        imageViewBase.clipsToBounds = true
        imageViewBase.layer.cornerRadius = 8

        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        macroLabel.font = .systemFont(ofSize: 12)
        macroLabel.textColor = .secondaryLabel
        macroLabel.numberOfLines = 1

        stepper.minimumValue = 0
        stepper.maximumValue = 10
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)

        quantityLabel.font = .systemFont(ofSize: 14, weight: .bold)
        quantityLabel.textAlignment = .center

        contentView.addSubview(container)
        container.addSubview(imageViewBase)
        container.addSubview(titleLabel)
        container.addSubview(macroLabel)
        container.addSubview(quantityLabel)
        container.addSubview(stepper)

        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }
        imageViewBase.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview().inset(10)
            make.width.height.equalTo(56)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(imageViewBase.snp.trailing).offset(12)
        }
        macroLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.lessThanOrEqualTo(stepper.snp.leading).offset(-8)
        }
        stepper.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
        quantityLabel.snp.makeConstraints { make in
            make.trailing.equalTo(stepper.snp.leading).offset(-10)
            make.centerY.equalTo(stepper)
            make.width.equalTo(18)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(item: WingMenuItem, quantity: Int) {
        imageViewBase.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        macroLabel.text = "\(item.calories) kcal • $\(String(format: "%.2f", item.price))"
        stepper.value = Double(quantity)
        quantityLabel.text = "\(quantity)"
        quantityLabel.textColor = quantity > 0 ? .systemRed : .secondaryLabel
    }

    @objc private func stepperChanged() {
        let value = Int(stepper.value)
        quantityLabel.text = "\(value)"
        quantityLabel.textColor = value > 0 ? .systemRed : .secondaryLabel
        onQuantityChanged?(value)
    }
}

// MARK: - Tab 3: Store Finder

class StoreFinderVC: UIViewController {

    private let mapView = MKMapView()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let locations: [LocationItem] = [
        LocationItem(city: "Marengo, IL", street: "308 S State St", phone: "8154549464", hours: "11AM – 10PM Daily", coordinate: CLLocationCoordinate2D(latitude: 42.2476, longitude: -88.6083)),
        LocationItem(city: "Lansing, MI", street: "5210 S Cedar St", phone: "5175379464", hours: "11AM – 11PM Daily", coordinate: CLLocationCoordinate2D(latitude: 42.6953, longitude: -84.5381)),
        LocationItem(city: "Romeoville, IL", street: "482 N Weber Rd", phone: "8153209464", hours: "11AM – 10PM Daily", coordinate: CLLocationCoordinate2D(latitude: 41.6368, longitude: -88.1009)),
        LocationItem(city: "Tinley Park, IL", street: "16205 Harlem Ave", phone: "7088039464", hours: "11AM – 11PM Daily", coordinate: CLLocationCoordinate2D(latitude: 41.5976, longitude: -87.7944)),
        LocationItem(city: "Delavan, WI", street: "1807 E Geneva St", phone: "2629999464", hours: "11AM – 10PM Daily", coordinate: CLLocationCoordinate2D(latitude: 42.6288, longitude: -88.6022)),
        LocationItem(city: "Bolingbrook, IL", street: "155 E Boughton Rd", phone: "6309849464", hours: "11AM – 11PM Daily", coordinate: CLLocationCoordinate2D(latitude: 41.6917, longitude: -88.0645))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Locations"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupLayout()
        dropPins()
    }

    private func setupLayout() {
        mapView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.rowHeight = 88

        view.addSubview(mapView)
        view.addSubview(tableView)

        mapView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.42)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func dropPins() {
        var annotations: [MKPointAnnotation] = []
        for loc in locations {
            let pin = MKPointAnnotation()
            pin.title = loc.city
            pin.subtitle = loc.street
            pin.coordinate = loc.coordinate
            annotations.append(pin)
        }
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: false)
    }

    private func focus(on location: LocationItem) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        mapView.setRegion(region, animated: true)
        if let match = mapView.annotations.first(where: { $0.title == location.city }) {
            mapView.selectAnnotation(match, animated: true)
        }
    }

    private func call(_ phone: String) {
        guard let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    private func openDirections(to location: LocationItem) {
        let placemark = MKPlacemark(coordinate: location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.city
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

extension StoreFinderVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        let identifier = "storePin"
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        pinView.annotation = annotation
        pinView.markerTintColor = .systemRed
        pinView.canShowCallout = true
        pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let title = view.annotation?.title ?? nil,
              let location = locations.first(where: { $0.city == title }) else { return }
        openDirections(to: location)
    }
}

extension StoreFinderVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let location = locations[indexPath.row]
        cell.configure(with: location)
        cell.onCallTapped = { [weak self] in self?.call(location.phone) }
        cell.onDirectionsTapped = { [weak self] in self?.openDirections(to: location) }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        focus(on: locations[indexPath.row])
    }
}

class LocationCell: UITableViewCell {
    private let cityLabel = UILabel()
    private let addressLabel = UILabel()
    private let hoursLabel = UILabel()
    private let callButton = UIButton(type: .system)
    private let directionsButton = UIButton(type: .system)

    var onCallTapped: (() -> Void)?
    var onDirectionsTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        cityLabel.font = .systemFont(ofSize: 15, weight: .bold)
        addressLabel.font = .systemFont(ofSize: 13)
        addressLabel.textColor = .secondaryLabel
        hoursLabel.font = .systemFont(ofSize: 12)
        hoursLabel.textColor = .tertiaryLabel

        callButton.setImage(UIImage(systemName: "phone.circle.fill"), for: .normal)
        callButton.tintColor = .systemGreen
        callButton.addTarget(self, action: #selector(callTapped), for: .touchUpInside)

        directionsButton.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        directionsButton.tintColor = .systemBlue
        directionsButton.addTarget(self, action: #selector(directionsTapped), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [cityLabel, addressLabel, hoursLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let buttonStack = UIStackView(arrangedSubviews: [callButton, directionsButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 14

        contentView.addSubview(textStack)
        contentView.addSubview(buttonStack)

        textStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(buttonStack.snp.leading).offset(-8)
        }
        buttonStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        [callButton, directionsButton].forEach {
            $0.snp.makeConstraints { make in make.width.height.equalTo(30) }
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with location: LocationItem) {
        cityLabel.text = location.city
        addressLabel.text = location.street
        hoursLabel.text = location.hours
    }

    @objc private func callTapped() { onCallTapped?() }
    @objc private func directionsTapped() { onDirectionsTapped?() }
}

// MARK: - Tab 4: Menu Filter

class MenuFilterVC: UIViewController {

    private let categorySegment = UISegmentedControl(items: MenuCategory.allCases.map { $0.rawValue })
    private let glutenFreeSwitch = UISwitch()
    private var filteredItems: [WingMenuItem] = MenuData.items

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        tv.register(FilterResultCell.self, forCellReuseIdentifier: "FilterResultCell")
        tv.rowHeight = 78
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        return tv
    }()

    private let resultCountLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Filter"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground

        setupUI()
        applyFilters()
    }

    private func setupUI() {
        categorySegment.selectedSegmentIndex = 0
        categorySegment.addTarget(self, action: #selector(filtersChanged), for: .valueChanged)

        let switchLabel = UILabel()
        switchLabel.text = "Gluten-Free Only"
        switchLabel.font = .systemFont(ofSize: 15, weight: .medium)
        glutenFreeSwitch.onTintColor = .systemRed
        glutenFreeSwitch.addTarget(self, action: #selector(filtersChanged), for: .valueChanged)

        let switchRow = UIStackView(arrangedSubviews: [switchLabel, UIView(), glutenFreeSwitch])
        switchRow.axis = .horizontal
        switchRow.alignment = .center

        let switchCard = UIView()
        switchCard.backgroundColor = .secondarySystemGroupedBackground
        switchCard.layer.cornerRadius = 12
        switchCard.addSubview(switchRow)
        switchRow.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(14)
        }

        resultCountLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        resultCountLabel.textColor = .secondaryLabel

        view.addSubview(categorySegment)
        view.addSubview(switchCard)
        view.addSubview(resultCountLabel)
        view.addSubview(tableView)

        categorySegment.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        switchCard.snp.makeConstraints { make in
            make.top.equalTo(categorySegment.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        resultCountLabel.snp.makeConstraints { make in
            make.top.equalTo(switchCard.snp.bottom).offset(14)
            make.leading.equalToSuperview().inset(20)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(resultCountLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    @objc private func filtersChanged() {
        applyFilters()
    }

    private func applyFilters() {
        let selectedCategory = MenuCategory.allCases[categorySegment.selectedSegmentIndex]
        filteredItems = MenuData.items.filter { item in
            let matchesCategory = selectedCategory == .all || item.category == selectedCategory
            let matchesGlutenFree = !glutenFreeSwitch.isOn || item.isGlutenFree
            return matchesCategory && matchesGlutenFree
        }
        resultCountLabel.text = "\(filteredItems.count) item\(filteredItems.count == 1 ? "" : "s") found"
        tableView.reloadData()
    }
}

extension MenuFilterVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterResultCell", for: indexPath) as! FilterResultCell
        cell.configure(with: filteredItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = MenuDetailVC(item: filteredItems[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

class FilterResultCell: UITableViewCell {
    private let container = UIView()
    private let imageViewBase = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12

        imageViewBase.contentMode = .scaleAspectFill
        imageViewBase.clipsToBounds = true
        imageViewBase.layer.cornerRadius = 8

        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel

        chevron.tintColor = .tertiaryLabel

        contentView.addSubview(container)
        container.addSubview(imageViewBase)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(chevron)

        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }
        imageViewBase.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview().inset(10)
            make.width.height.equalTo(50)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(imageViewBase.snp.trailing).offset(12)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
        }
        chevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: WingMenuItem) {
        imageViewBase.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        var tags = ["\(item.calories) kcal", "$\(String(format: "%.2f", item.price))"]
        if item.isGlutenFree { tags.append("GF") }
        subtitleLabel.text = tags.joined(separator: " • ")
    }
}

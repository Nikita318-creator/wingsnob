import UIKit
import SnapKit

class MenuViewController: BaseStubViewController {
    
    // Структура типа элемента меню
    private typealias MenuItem = (title: String, desc: String, longDesc: String, image: String)
    
    // Исходный список элементов (15 позиций)
    private let rawMenuItems: [MenuItem] = [
        (
            title: "TRADITIONAL WINGS",
            desc: "Classic bone-in wings tossed in your favorite sauce.",
            longDesc: "Our signature traditional bone-in wings are sourced fresh and never frozen. Hand-tossed to order in your choice of 24 signature award-winning sauces and dry rubs. From mild honey barbecue to intense habanero fire, cooked to crisp perfection on the outside while remaining incredibly juicy on the inside.",
            image: "CHICKENTENDERS"
        ),
        (
            title: "BONELESS WINGS",
            desc: "All-white-meat, hand-breaded boneless wings.",
            longDesc: "Tender 100% all-white-meat chicken breasts, cut into bite-sized pieces and lightly hand-breaded in-house daily. Fried to a perfect golden crunch and tossed aggressively in your favorite signature glaze or dry seasoning. Ultimate bite, maximum flavor, no bones about it.",
            image: "BONELESSWINGS"
        ),
        (
            title: "CHICKEN TENDERS",
            desc: "Crispy, juicy all-white-meat tenders.",
            longDesc: "Premium jumbo chicken tenders marinated for 24 hours in a blend of secret spices, hand-battered and flash-fried to seal in heat and flavor. Served with dual dipping sauces on the side. Perfect balance of crunch and tender juicy chicken in every bite.",
            image: "CHICKENTENDERS"
        ),
        (
            title: "WING SNOB SAMPLER",
            desc: "A mix of traditional and boneless wings with fries.",
            longDesc: "Can't decide? Get the best of both worlds with our heavy-hitter sampler platter. Includes 6 traditional bone-in wings, 6 hand-breaded boneless wings tossed in up to 3 different sauces, accompanied by a generous portion of our fresh seasoned cut fries and dipping sauces.",
            image: "TRADITIONALWINGS"
        ),
        (
            title: "BUFFALO CHICKEN SLIDERS",
            desc: "Mini crispy chicken sandwiches tossed in spicy buffalo sauce.",
            longDesc: "Three mini brioche buns loaded with crispy hand-breaded chicken tenders coated in classic hot buffalo sauce, topped with crunchy dill pickles and cool ranch drizzle. Big flavor packed into bite-sized perfection.",
            image: "BUFFALOCHICKEN"
        ),
        (
            title: "MOZZARELLA STICKS",
            desc: "Crispy gooey fried mozzarella with warm marinara.",
            longDesc: "Thick-cut sticks of real mozzarella cheese coated in seasoned Italian breadcrumbs, fried until golden brown on the outside and melted to gooey perfection on the inside. Served with a bowl of rich, warm house-made marinara sauce.",
            image: "MOZZARELLASTICKS"
        ),
        (
            title: "MAC & CHEESE BITES",
            desc: "Golden fried bites filled with creamy cheddar mac.",
            longDesc: "Creamy elbow macaroni folded into a blend of aged cheddar and Monterey Jack cheese, rolled into bite-sized balls and deep-fried to a crunchy golden brown. Comfort food made pop-able and easy to share.",
            image: "CHEESEBITES"
        ),
        (
            title: "FRESH CUT FRIES",
            desc: "Crispy fries seasoned to perfection.",
            longDesc: "Idaho potatoes washed, sliced, and double-fried fresh in-store every single morning. Dusted while scorching hot with our proprietary Snob Seasoning blend. Crisp shell on the outside, fluffy potato texture on the inside.",
            image: "BONELESSWINGS"
        ),
        (
            title: "SWEET POTATO FRIES",
            desc: "Golden sweet potato fries with a touch of salt.",
            longDesc: "Thick-cut sweet potato fries fried until golden and crispy around the edges. Lightly sprinkled with sea salt to enhance the natural sweetness. Served hot with a side of warm maple dipping sauce upon request.",
            image: "CHEESEFRIES"
        ),
        (
            title: "LOADED CHEESE FRIES",
            desc: "Fresh cut fries smothered in cheddar, bacon, and jalapenos.",
            longDesc: "A generous bed of our signature fresh-cut fries drenched in melted aged cheddar cheese sauce, topped with crispy smoked bacon bits, fresh green onions, and pickled jalapenos for an extra kick. Served with sour cream.",
            image: "CHEESEFRIES"
        ),
        (
            title: "ONION RINGS",
            desc: "Thick-cut, beer-battered onion rings.",
            longDesc: "Thick slice sweet yellow onions dipped in handcrafted draft beer batter and breaded with panko crumbs for extreme crunchiness. Fried golden-brown and served with spicy ranch dipping sauce.",
            image: "ONIONRINGS"
        ),
        (
            title: "SIGNATURE DIPPING SAUCES",
            desc: "A trio of our famous handcrafted sauces.",
            longDesc: "Choose any 3 of our 24 award-winning signature sauces and rubs on the side. Options range from Creamy Garlic Parm, Sweet BBQ, and Mango Habanero to Spicy Ranch and Atomic Fire. Perfect for dipping fries or wings.",
            image: "DIPPINGSAUCES"
        ),
        (
            title: "CHURRO BITES",
            desc: "Warm cinnamon sugar churros with chocolate dip.",
            longDesc: "Freshly fried bite-sized dough pastry coated heavily in sweet cinnamon sugar. Crunchy on the exterior and soft on the inside. Served piping hot alongside warm Belgian chocolate dipping sauce.",
            image: "CHICKENTENDERS"
        ),
        (
            title: "FUNNEL CAKE FRIES",
            desc: "Crispy carnival-style funnel cake fries with powdered sugar.",
            longDesc: "Classic carnival funnel cake served in easy-to-share fry shapes. Fried light and airy, dusted liberally with powdered sugar, and served with caramel or strawberry dipping sauce.",
            image: "CHEESEFRIES"
        ),
        (
            title: "CRAFT LEMONADE & FOUNTAIN DRINKS",
            desc: "Refreshing hand-crafted lemonade and ice-cold sodas.",
            longDesc: "Quench your thirst with our fresh house-squeezed lemonade, available in classic lemon, strawberry, or mango flavors. We also offer a full selection of ice-cold fountain sodas and iced tea to complement your spicy wings.",
            image: "LEMONADE"
        )
    ]
    
    // Отсортированный массив элементов
    private var menuItems: [MenuItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAndSortMenuItems()
        
        if let cv = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            cv.register(MenuItemCell.self, forCellWithReuseIdentifier: "MenuItemCell")
            cv.register(MenuHeaderView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: "MenuHeaderView")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateAndSortMenuItems()
        
        if let cv = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            cv.reloadData()
        }
    }
    
    // Сортировка: элементы из UserDefaults уходят вверх
    private func updateAndSortMenuItems() {
        let favorites = UserDefaults.standard.stringArray(forKey: "favorite_items") ?? []
        
        menuItems = rawMenuItems.sorted { item1, item2 in
            let isFav1 = favorites.contains(item1.title)
            let isFav2 = favorites.contains(item2.title)
            
            if isFav1 != isFav2 {
                return isFav1 && !isFav2
            }
            return false
        }
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = menuItems[indexPath.item]
        let detailVC = ProductDetailViewController(
            title: item.title,
            longDescription: item.longDesc,
            imageName: item.image
        )
        detailVC.modalPresentationStyle = .fullScreen
        present(detailVC, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell
        let item = menuItems[indexPath.item]
        
        let favorites = UserDefaults.standard.stringArray(forKey: "favorite_items") ?? []
        let isFav = favorites.contains(item.title)
        
        cell.configure(title: item.title, description: item.desc, imageName: item.image, isFavorite: isFav)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MenuHeaderView", for: indexPath)
            return header
        }
        return UICollectionReusableView()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 110)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

// MARK: - Fullscreen Detail Controller
class ProductDetailViewController: UIViewController {
    
    private let productTitle: String
    private let longDescription: String
    private let imageName: String
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .darkGray
        return iv
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28, weight: .black)
        label.numberOfLines = 0
        return label
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.text = "SIGNATURE ITEM"
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 12, weight: .black)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        label.attributedText = NSAttributedString(string: "", attributes: [.paragraphStyle: paragraphStyle])
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("ADD TO FAVORITE", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .black)
        btn.backgroundColor = .systemRed
        btn.layer.cornerRadius = 14
        return btn
    }()
    
    init(title: String, longDescription: String, imageName: String) {
        self.productTitle = title
        self.longDescription = longDescription
        self.imageName = imageName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.08, alpha: 1.0)
        setupUI()
        configureData()
        updateButtonState()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(closeButton)
        view.addSubview(favoriteButton)
        
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(favoriteButton.snp.top).offset(-16)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(40)
        }
        
        contentView.addSubview(headerImageView)
        contentView.addSubview(badgeLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        headerImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.top.equalTo(headerImageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(badgeLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.height.equalTo(52)
        }
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }
    
    private func configureData() {
        titleLabel.text = productTitle
        headerImageView.image = UIImage(named: imageName)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        descriptionLabel.attributedText = NSAttributedString(
            string: longDescription,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.lightGray
            ]
        )
    }
    
    private func updateButtonState() {
        let favorites = UserDefaults.standard.stringArray(forKey: "favorite_items") ?? []
        let isFav = favorites.contains(productTitle)
        
        if isFav {
            favoriteButton.setTitle("REMOVE FROM FAVORITE", for: .normal)
            favoriteButton.backgroundColor = .systemGray
        } else {
            favoriteButton.setTitle("ADD TO FAVORITE", for: .normal)
            favoriteButton.backgroundColor = .systemRed
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func favoriteTapped() {
        var favorites = UserDefaults.standard.stringArray(forKey: "favorite_items") ?? []
        
        if let index = favorites.firstIndex(of: productTitle) {
            favorites.remove(at: index)
        } else {
            favorites.append(productTitle)
        }
        
        UserDefaults.standard.set(favorites, forKey: "favorite_items")
        updateButtonState()
    }
}

// MARK: - Header & Cell
class MenuHeaderView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "THE MENU"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 32, weight: .black)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Fresh, never-frozen chicken — your way."
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

class MenuItemCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let itemImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .darkGray
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .black)
        label.numberOfLines = 2
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.numberOfLines = 3
        return label
    }()
    
    private let starImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "star.fill")
        iv.tintColor = .systemYellow
        iv.isHidden = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.addSubview(itemImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(starImageView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        itemImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(containerView.snp.height)
        }
        
        starImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.size.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(itemImageView.snp.trailing).offset(16)
            make.trailing.equalTo(starImageView.snp.leading).offset(-8)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualTo(containerView.snp.bottom).offset(-16)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, description: String, imageName: String, isFavorite: Bool) {
        titleLabel.text = title
        descriptionLabel.text = description
        itemImageView.image = UIImage(named: imageName)
        
        starImageView.isHidden = !isFavorite
        containerView.layer.borderWidth = isFavorite ? 2 : 0
        containerView.layer.borderColor = isFavorite ? UIColor.systemYellow.cgColor : nil
    }
}

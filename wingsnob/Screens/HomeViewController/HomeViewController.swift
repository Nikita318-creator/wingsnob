import UIKit
import SnapKit
import AppTrackingTransparency
import AdSupport
import UserNotifications
import MapKit

// MARK: - Models
struct MenuItem {
    let title: String
    let imageName: String
    let category: String
    let calories: String
    let description: String
}

class HomeViewController: BaseStubViewController {
    
    // Структурируем секции
    enum HomeSection: Int, CaseIterable {
        case banner
        case carousel
        case locations
        case footer
    }
    
    // Данные для адресов с привязанными точными координатами
    private let addresses: [(city: String, desc: String, coordinate: CLLocationCoordinate2D)] = [
        (city: "Marengo, IL", desc: "308 S State St  •  (815) 454-WING", coordinate: CLLocationCoordinate2D(latitude: 42.2476, longitude: -88.6083)),
        (city: "Lansing, MI", desc: "5210 S Cedar St  •  (517) 537-WING", coordinate: CLLocationCoordinate2D(latitude: 42.6953, longitude: -84.5381)),
        (city: "Romeoville, IL", desc: "482 N Weber Rd  •  (815) 320-WING", coordinate: CLLocationCoordinate2D(latitude: 41.6368, longitude: -88.1009)),
        (city: "Tinley Park, IL", desc: "16205 Harlem Ave  •  (708) 803-WING", coordinate: CLLocationCoordinate2D(latitude: 41.5976, longitude: -87.7944)),
        (city: "Delavan, WI", desc: "1807 E Geneva St  •  (262) 999-WING", coordinate: CLLocationCoordinate2D(latitude: 42.6288, longitude: -88.6022)),
        (city: "Bolingbrook, IL", desc: "155 E Boughton Rd  •  (630) 984-WING", coordinate: CLLocationCoordinate2D(latitude: 41.6917, longitude: -88.0645))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Регистрируем все типы ячеек и хэдер на коллекции из базового класса
        if let cv = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            cv.delegate = self
            cv.register(BannerCell.self, forCellWithReuseIdentifier: "BannerCell")
            cv.register(CarouselContainerCell.self, forCellWithReuseIdentifier: "CarouselContainerCell")
            cv.register(AddressCell.self, forCellWithReuseIdentifier: "AddressCell")
            cv.register(FooterCell.self, forCellWithReuseIdentifier: "FooterCell")
            
            cv.register(SectionHeaderView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: "SectionHeaderView")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestATTAuthorization()
    }
    
    // MARK: - Native Permissions Sequence
    
    private func requestATTAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.requestPushNotificationsAuthorization()
            }
        }
    }
    
    private func requestPushNotificationsAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HomeSection.allCases.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let homeSection = HomeSection(rawValue: section) else { return 0 }
        switch homeSection {
        case .banner, .carousel, .footer:
            return 1
        case .locations:
            return addresses.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let homeSection = HomeSection(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch homeSection {
        case .banner:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath)
            return cell
            
        case .carousel:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselContainerCell", for: indexPath) as! CarouselContainerCell
            cell.onItemSelect = { [weak self] selectedItem in
                let detailVC = ItemDetailViewController(item: selectedItem)
                detailVC.modalPresentationStyle = .fullScreen
                self?.present(detailVC, animated: true)
            }
            return cell
            
        case .locations:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddressCell", for: indexPath) as! AddressCell
            let data = addresses[indexPath.item]
            cell.configure(city: data.city, address: data.desc)
            return cell
            
        case .footer:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FooterCell", for: indexPath) as! FooterCell
            cell.onIconTap = { socialType in
                let urlString: String
                switch socialType {
                case .instagram: urlString = "https://www.instagram.com/wingsnob"
                case .facebook: urlString = "https://www.facebook.com/thewingsnob"
                case .email: urlString = "mailto:wingsnobfranchising@gmail.com"
                }
                guard let url = URL(string: urlString) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let homeSection = HomeSection(rawValue: indexPath.section) else { return }
        if homeSection == .locations {
            let data = addresses[indexPath.item]
            let mapVC = LocationMapViewController(city: data.city, address: data.desc, coordinate: data.coordinate)
            mapVC.modalPresentationStyle = .pageSheet
            present(mapVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader && indexPath.section == HomeSection.locations.rawValue {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath)
            return header
        }
        return UICollectionReusableView()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let homeSection = HomeSection(rawValue: indexPath.section) else { return .zero }
        let screenWidth = collectionView.bounds.width
        
        switch homeSection {
        case .banner:
            let height = UIScreen.main.bounds.height * (1.0 / 2.0)
            return CGSize(width: screenWidth, height: height)
        case .carousel:
            return CGSize(width: screenWidth, height: 260)
        case .locations:
            return CGSize(width: screenWidth, height: 70)
        case .footer:
            return CGSize(width: screenWidth, height: 140)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == HomeSection.locations.rawValue {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
        return .zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

// MARK: - Banner Cell
class BannerCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "main_banner")
        iv.backgroundColor = .systemRed
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Carousel Container Cell
class CarouselContainerCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var onItemSelect: ((MenuItem) -> Void)?
    
    private let titleLabel = UILabel()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(ItemCardCell.self, forCellWithReuseIdentifier: "ItemCardCell")
        return cv
    }()
    
    // Данные карусели с текстами для Reviewer'a
    private let menuItems: [MenuItem] = [
        MenuItem(
            title: "TRADITIONAL WINGS",
            imageName: "TRADITIONALWINGS",
            category: "Classic Favorite",
            calories: "750 - 1200 kcal",
            description: "Our signature jumbo traditional chicken wings are fresh, never frozen, and tossed to perfection in your choice of 18 signature handcrafted sauces or dry rubs. Cooked to crisp perfection on the outside while remaining tender and juicy on the inside, each bite delivers an authentic flavor burst. Crafted daily using farm-fresh poultry and premium spices, our traditional wings are the ultimate indulgence for true wing connoisseurs. Pair them with our fresh celery sticks and homemade blue cheese or ranch dip for the complete Snob experience."
        ),
        MenuItem(
            title: "BONELESS WINGS",
            imageName: "BONELESSWINGS",
            category: "100% White Meat",
            calories: "650 - 1050 kcal",
            description: "Hand-cut 100% all-white meat chicken tenderloins, lightly breaded and fried to golden perfection. Our boneless wings offer all the bold flavors of our classic wings with maximum crunch and zero mess. Glazed liberally in our mouth-watering house sauces—ranging from Sweet BBQ to Hot Honey Garlic and Dragon's Breath—these tender bites provide a rich, savory experience in every mouthful. Made fresh to order to ensure maximum crispiness and optimal heat retention."
        ),
        MenuItem(
            title: "CHICKEN TENDERS",
            imageName: "CHICKENTENDERS",
            category: "Hand-Breaded",
            calories: "800 - 1300 kcal",
            description: "Premium jumbo chicken tenders hand-breaded in-house daily with our secret recipe blend of herbs and seasonings. Soaked in buttermilk marinade for ultimate tenderness, then double-fried for that extra signature crunch. Served piping hot with your favorite dipping sauce on the side or tossed directly in one of our signature glazes. A comforting classic reimagined with artisanal quality, designed to satisfy even the most discerning appetite."
        )
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupTitleLabel() {
        let fullText = "┃ FAN FAVORITES"
        let font = UIFont.systemFont(ofSize: 22, weight: .black)
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [.font: font, .foregroundColor: UIColor.white]
        )
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.systemRed,
            range: NSRange(location: 0, length: 1)
        )
        titleLabel.attributedText = attributedString
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCardCell", for: indexPath) as! ItemCardCell
        let item = menuItems[indexPath.item]
        cell.configure(with: item.title, image: UIImage(named: item.imageName))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onItemSelect?(menuItems[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

// MARK: - Item Card Cell
class ItemCardCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .darkGray
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(130)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with text: String, image: UIImage?) {
        titleLabel.text = text
        imageView.image = image
    }
}

// MARK: - Address Cell
class AddressCell: UICollectionViewCell {
    
    private let pinImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "mappin.and.ellipse")
        iv.tintColor = .systemRed
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(pinImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        pinImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(pinImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(city: String, address: String) {
        titleLabel.text = city
        subtitleLabel.text = address
    }
}

// MARK: - Footer Cell
class FooterCell: UICollectionViewCell {
    
    var onIconTap: ((SocialType) -> Void)?
    
    enum SocialType: Int {
        case facebook = 0
        case instagram = 1
        case email = 2
    }
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 20
        sv.distribution = .fillEqually
        return sv
    }()
    
    private let copyrightLabel: UILabel = {
        let label = UILabel()
        label.text = "© 2026 Wing Snob Franchising LLC"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(stackView)
        contentView.addSubview(copyrightLabel)
        
        let icons = ["f.square.fill", "camera.fill", "envelope.fill"]
        
        for (index, iconName) in icons.enumerated() {
            let button = UIButton(type: .system)
            button.backgroundColor = .systemRed
            button.layer.cornerRadius = 20
            button.tintColor = .white
            button.setImage(UIImage(systemName: iconName), for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(iconTapped(_:)), for: .touchUpInside)
            
            button.snp.makeConstraints { make in
                make.size.equalTo(40)
            }
            
            stackView.addArrangedSubview(button)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        copyrightLabel.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func iconTapped(_ sender: UIButton) {
        guard let type = SocialType(rawValue: sender.tag) else { return }
        onIconTap?(type)
    }
}

// MARK: - Section Header View
class SectionHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16))
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupTitleLabel() {
        let fullText = "┃ FIND A SNOB"
        let font = UIFont.systemFont(ofSize: 22, weight: .black)
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [.font: font, .foregroundColor: UIColor.white]
        )
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.systemRed,
            range: NSRange(location: 0, length: 1)
        )
        titleLabel.attributedText = attributedString
    }
}

// MARK: - Detail View Controller (Экран описания карточки)
class ItemDetailViewController: UIViewController {
    
    private let item: MenuItem
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .darkGray
        return iv
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: imageConfig), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    private let categoryBadge: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28, weight: .black)
        label.numberOfLines = 0
        return label
    }()
    
    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        return view
    }()
    
    private let descriptionHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "PRODUCT DETAILS"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 0.85, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        label.attributedText = NSAttributedString(string: "", attributes: [.paragraphStyle: paragraphStyle])
        return label
    }()
    
    init(item: MenuItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        configureData()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(closeButton)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(heroImageView)
        contentView.addSubview(categoryBadge)
        contentView.addSubview(titleLabel)
        contentView.addSubview(caloriesLabel)
        contentView.addSubview(dividerView)
        contentView.addSubview(descriptionHeaderLabel)
        contentView.addSubview(descriptionLabel)
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(40)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        heroImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(320)
        }
        
        categoryBadge.snp.makeConstraints { make in
            make.top.equalTo(heroImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryBadge.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        caloriesLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(caloriesLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        descriptionHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionHeaderLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    private func configureData() {
        heroImageView.image = UIImage(named: item.imageName)
        categoryBadge.text = item.category.uppercased()
        titleLabel.text = item.title
        caloriesLabel.text = "🔥 \(item.calories)"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        descriptionLabel.attributedText = NSAttributedString(
            string: item.description,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                .foregroundColor: UIColor(white: 0.85, alpha: 1.0)
            ]
        )
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Location Map View Controller (стандартная карта Apple Maps)
class LocationMapViewController: UIViewController, MKMapViewDelegate {
    
    private let city: String
    private let address: String
    private let coordinate: CLLocationCoordinate2D
    
    private let mapView = MKMapView()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        btn.layer.cornerRadius = 18
        return btn
    }()
    
    init(city: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.city = city
        self.address = address
        self.coordinate = coordinate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupCloseButton()
        addAnnotation()
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
    }
    
    private func setupCloseButton() {
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(36)
        }
    }
    
    private func addAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.title = "Wing Snob - \(city)"
        annotation.subtitle = address
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

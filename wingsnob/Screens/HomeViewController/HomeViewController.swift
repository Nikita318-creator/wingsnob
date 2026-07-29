
import UIKit
import SnapKit
import AppTrackingTransparency
import AdSupport

class HomeViewController: BaseStubViewController {
    
    // Структурируем секции
    enum HomeSection: Int, CaseIterable {
        case banner
        case carousel
        case locations
        case footer
    }
    
    // Данные для адресов
    private let addresses = [
        (city: "Marengo, IL", desc: "308 S State St  •  (815) 454-WING"),
        (city: "Lansing, MI", desc: "5210 S Cedar St  •  (517) 537-WING"),
        (city: "Romeoville, IL", desc: "482 N Weber Rd  •  (815) 320-WING"),
        (city: "Tinley Park, IL", desc: "16205 Harlem Ave  •  (708) 803-WING"),
        (city: "Delavan, WI", desc: "1807 E Geneva St  •  (262) 999-WING"),
        (city: "Bolingbrook, IL", desc: "155 E Boughton Rd  •  (630) 984-WING")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Регистрируем все типы ячеек и хэдер на коллекции из базового класса
        if let cv = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
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
    
    private func requestATTAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                // Доступ разрешен
                break
            case .denied, .restricted, .notDetermined:
                // Доступ ограничен или отклонен
                break
            @unknown default:
                break
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselContainerCell", for: indexPath)
            return cell
            
        case .locations:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddressCell", for: indexPath) as! AddressCell
            let data = addresses[indexPath.item]
            cell.configure(city: data.city, address: data.desc)
            return cell
            
        case .footer:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FooterCell", for: indexPath) as! FooterCell
            
            cell.onIconTap = { [weak self] socialType in
                let urlString: String
                
                switch socialType {
                case .instagram:
                    urlString = "https://www.instagram.com/wingsnob"
                case .facebook:
                    urlString = "https://www.facebook.com/thewingsnob"
                case .email:
                    urlString = "mailto:wingsnobfranchising@gmail.com" // Для почты используем схему mailto:
                }
                
                guard let url = URL(string: urlString) else { return }
                
                // Проверяем, можно ли открыть ссылку, и открываем её
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            return cell
        }
    }
    
    // Добавляем заголовок для секции "Find a snob"
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
            // 2/3 от высоты экрана, как просил
            let height = UIScreen.main.bounds.height * (1.0 / 2.0)
            return CGSize(width: screenWidth, height: height)
            
        case .carousel:
            // Высота заголовка карусели + самой карусели
            return CGSize(width: screenWidth, height: 260)
            
        case .locations:
            return CGSize(width: screenWidth, height: 70)
            
        case .footer:
            return CGSize(width: screenWidth, height: 140)
        }
    }
    
    // Настраиваем высоту хедера только для секции адресов
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == HomeSection.locations.rawValue {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
        return .zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero // Сбрасываем дефолтные инсеты из базового класса для точности верстки
    }
}


 

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

 

class CarouselContainerCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
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
    
    // Временные данные для карусели
    private let items = ["TRADITIONAL WINGS", "BONELESS WINGS", "CHICKEN TENDERS"]
    private let itemImages = ["TRADITIONALWINGS", "BONELESSWINGS", "CHICKENTENDERS"]

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
        
        // Красим только первый символ "┃" в красный цвет
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.systemRed,
            range: NSRange(location: 0, length: 1)
        )
        
        titleLabel.attributedText = attributedString
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCardCell", for: indexPath) as! ItemCardCell
        cell.configure(with: items[indexPath.item], image: UIImage(named: itemImages[indexPath.item]))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

// Внутренняя карточка для карусели
class ItemCardCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .darkGray // Заглушка под картинку еды
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

 

class AddressCell: UICollectionViewCell {
    
    private let pinImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "mappin.and.ellipse") // Системный пин, красим в красный
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
        
        // Иконки: Facebook (0), Instagram (1), Email (2)
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

class SectionHeaderView: UICollectionReusableView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
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

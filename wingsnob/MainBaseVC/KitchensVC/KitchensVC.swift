
import UIKit
import SnapKit

struct KitchenModel {
    let title: String
    let subtitle: String
    let descriptionText: String
    let difficulty: String
    let menuCount: String
    let imageName: String
    let primaryColor: UIColor
}

final class KitchensVC: UIViewController {
    
    // MARK: - Data
    private let kitchens: [KitchenModel] = [
        KitchenModel(
            title: "Burger Hub",
            subtitle: "Fast Food & Grills",
            descriptionText: "Master the art of smash burgers, crispy fries, and cold sodas under pressure.",
            difficulty: "Easy",
            menuCount: "8 items",
            imageName: "kitchen1",
            primaryColor: UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        ),
        KitchenModel(
            title: "Sushi Express",
            subtitle: "Japanese Cuisine",
            descriptionText: "Slice fresh sashimi, roll maki with precision, and serve green tea instantly.",
            difficulty: "Medium",
            menuCount: "12 items",
            imageName: "kitchen2",
            primaryColor: UIColor(red: 0.18, green: 0.65, blue: 0.55, alpha: 1.0)
        ),
        KitchenModel(
            title: "Pizzeria Bella",
            subtitle: "Authentic Italian",
            descriptionText: "Bake wood-fired pizzas, manage topping prep, and balance oven timers.",
            difficulty: "Hard",
            menuCount: "10 items",
            imageName: "kitchen3",
            primaryColor: UIColor(red: 0.88, green: 0.28, blue: 0.28, alpha: 1.0)
        )
    ]
    
    // MARK: - UI Components
    private let headerBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 1.0)
        return view
    }()
    
    private let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "CHEF'S CULINARY DASH"
        label.font = .systemFont(ofSize: 22, weight: .black)
        label.textColor = .white
        return label
    }()
    
    private let headerSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a kitchen to start your shift"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
        cv.showsVerticalScrollIndicator = false
        cv.register(KitchenCell.self, forCellWithReuseIdentifier: KitchenCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 1.0)
        
        view.addSubview(headerBackgroundView)
        headerBackgroundView.addSubview(headerTitleLabel)
        headerBackgroundView.addSubview(headerSubtitleLabel)
        view.addSubview(collectionView)
        
        headerBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        headerTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        headerSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(headerTitleLabel)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerBackgroundView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension KitchensVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kitchens.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KitchenCell.identifier, for: indexPath) as? KitchenCell else {
            return UICollectionViewCell()
        }
        let model = kitchens[indexPath.item]
        cell.configure(with: model)
        cell.onStartTap = { [weak self] in
            self?.openGame(for: model)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 180)
    }
    
    private func openGame(for kitchen: KitchenModel) {
        let viewModel = SingleKitchenViewModel(kitchen: kitchen)
        let singleKitchenVC = SingleKitchenVC(viewModel: viewModel)
        singleKitchenVC.modalPresentationStyle = .fullScreen
        present(singleKitchenVC, animated: true)
    }
}

// MARK: - Custom Cell
final class KitchenCell: UICollectionViewCell {
    static let identifier = "KitchenCell"
    
    var onStartTap: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()
    
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("START SHIFT", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(actionButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(14)
            make.width.height.equalTo(70)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView)
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-14)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalTo(titleLabel)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(10)
            make.leading.equalTo(iconImageView)
            make.trailing.equalToSuperview().offset(-14)
        }
        
        actionButton.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().offset(-14)
            make.width.equalTo(110)
            make.height.equalTo(34)
        }
        
        actionButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    func configure(with model: KitchenModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle.uppercased()
        subtitleLabel.textColor = model.primaryColor
        descriptionLabel.text = model.descriptionText
        iconImageView.image = UIImage(named: model.imageName)
        actionButton.backgroundColor = model.primaryColor
    }
    
    @objc private func didTapButton() {
        onStartTap?()
    }
}


import UIKit
import SnapKit

// MARK: - Card Model
struct MemoryCardModel {
    let id: UUID = UUID()
    let imageName: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

// MARK: - KitchenGame1VC
final class KitchenGame1VC: UIViewController, BaseKitchenGameProtocol {
    
    // MARK: - Properties
    let levelNumber: Int
    let difficulty: String
    var onGameCompleted: (() -> Void)?
    
    private var cards: [MemoryCardModel] = []
    private var firstSelectedIndexPath: IndexPath?
    private var isProcessingFlip: Bool = false
    private var matchedPairsCount: Int = 0
    private var totalPairsCount: Int = 0
    
    private var columns: Int = 4
    private var rows: Int = 4
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.12, green: 0.14, blue: 0.20, alpha: 0.3)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "PAIR MATCHING"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(MemoryCardCell.self, forCellWithReuseIdentifier: MemoryCardCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    // Overlay Modals
    private let overlayModalView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let modalTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let modalDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let modalActionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    // MARK: - Init
    init(levelNumber: Int, difficulty: String) {
        self.levelNumber = levelNumber
        self.difficulty = difficulty
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGridDimensions()
        setupUI()
        generateCardDeck()
        showIntroModal()
    }
    
    // MARK: - Grid Setup
    private func configureGridDimensions() {
        columns = 4
        if levelNumber <= 3 {
            rows = 4 // 16 cards (8 pairs)
        } else if levelNumber <= 7 {
            rows = 5 // 20 cards (10 pairs)
        } else {
            rows = 6 // 24 cards (12 pairs)
        }
        totalPairsCount = (rows * columns) / 2
    }
    
    private func generateCardDeck() {
        let allAssets = (1...6).map { "food\($0)" } + (1...6).map { "trash\($0)" }
        let selectedAssets = Array(allAssets.shuffled().prefix(totalPairsCount))
        
        var deck: [MemoryCardModel] = []
        for asset in selectedAssets {
            deck.append(MemoryCardModel(imageName: asset))
            deck.append(MemoryCardModel(imageName: asset))
        }
        
        cards = deck.shuffled()
        updateProgressLabel()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(headerTitleLabel)
        containerView.addSubview(progressLabel)
        containerView.addSubview(collectionView)
        containerView.addSubview(overlayModalView)
        
        overlayModalView.addSubview(modalTitleLabel)
        overlayModalView.addSubview(modalDescriptionLabel)
        overlayModalView.addSubview(modalActionButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        headerTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(headerTitleLabel)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(12)
        }
        
        overlayModalView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        modalTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        modalDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(modalTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        modalActionButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-32)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(46)
        }
        
        headerTitleLabel.text = "MEMORY RUSH - LEVEL \(levelNumber)"
    }
    
    private func updateProgressLabel() {
        progressLabel.text = "Pairs Found: \(matchedPairsCount) / \(totalPairsCount)"
    }
    
    // MARK: - Modals Logic
    private func showIntroModal() {
        overlayModalView.isHidden = false
        modalTitleLabel.text = "FLIP & MATCH!"
        modalDescriptionLabel.text = "Find all matching pairs of kitchen items before the shift ends! Grid size: \(columns)x\(rows)."
        modalActionButton.setTitle("START GAME", for: .normal)
        modalActionButton.backgroundColor = UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        
        modalActionButton.removeTarget(nil, action: nil, for: .allEvents)
        modalActionButton.addTarget(self, action: #selector(didTapStartGame), for: .touchUpInside)
    }
    
    private func showWinModal() {
        overlayModalView.isHidden = false
        modalTitleLabel.text = "STAGE CLEARED!"
        modalDescriptionLabel.text = "Great memory Chef! You matched all \(totalPairsCount) pairs successfully."
        modalActionButton.setTitle("NEXT LEVEL >", for: .normal)
        modalActionButton.backgroundColor = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        
        modalActionButton.removeTarget(nil, action: nil, for: .allEvents)
        modalActionButton.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
    }
    
    @objc private func didTapStartGame() {
        overlayModalView.isHidden = true
    }
    
    @objc private func didTapComplete() {
        onGameCompleted?()
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension KitchenGame1VC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemoryCardCell.identifier, for: indexPath) as? MemoryCardCell else {
            return UICollectionViewCell()
        }
        let model = cards[indexPath.item]
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacingHorizontal: CGFloat = 8 * CGFloat(columns - 1) + 24
        let totalSpacingVertical: CGFloat = 8 * CGFloat(rows - 1) + 80
        
        let width = (collectionView.bounds.width - totalSpacingHorizontal) / CGFloat(columns)
        let height = (collectionView.bounds.height - totalSpacingVertical) / CGFloat(rows)
        return CGSize(width: width, height: max(height, 40))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isProcessingFlip else { return }
        
        var selectedCard = cards[indexPath.item]
        guard !selectedCard.isFaceUp, !selectedCard.isMatched else { return }
        
        selectedCard.isFaceUp = true
        cards[indexPath.item] = selectedCard
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? MemoryCardCell else { return }
        cell.flip(to: selectedCard, animated: true)
        
        if let firstIndex = firstSelectedIndexPath {
            isProcessingFlip = true
            let firstCard = cards[firstIndex.item]
            
            if firstCard.imageName == selectedCard.imageName {
                // Match Found
                cards[firstIndex.item].isMatched = true
                cards[indexPath.item].isMatched = true
                matchedPairsCount += 1
                updateProgressLabel()
                
                firstSelectedIndexPath = nil
                isProcessingFlip = false
                
                if matchedPairsCount == totalPairsCount {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                        self?.showWinModal()
                    }
                }
            } else {
                // No Match -> Flip back
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    guard let self = self else { return }
                    self.cards[firstIndex.item].isFaceUp = false
                    self.cards[indexPath.item].isFaceUp = false
                    
                    let firstCell = collectionView.cellForItem(at: firstIndex) as? MemoryCardCell
                    firstCell?.flip(to: self.cards[firstIndex.item], animated: true)
                    cell.flip(to: self.cards[indexPath.item], animated: true)
                    
                    self.firstSelectedIndexPath = nil
                    self.isProcessingFlip = false
                }
            }
        } else {
            firstSelectedIndexPath = indexPath
        }
    }
}

// MARK: - Custom Card Cell with Flip Animation
final class MemoryCardCell: UICollectionViewCell {
    static let identifier = "MemoryCardCell"
    
    private let cardBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.22, green: 0.26, blue: 0.35, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        let icon = UIImageView(image: UIImage(systemName: "questionmark"))
        icon.tintColor = UIColor.white.withAlphaComponent(0.4)
        icon.contentMode = .scaleAspectFit
        view.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        return view
    }()
    
    private let cardFrontView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    private let itemImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        contentView.addSubview(cardBackView)
        contentView.addSubview(cardFrontView)
        cardFrontView.addSubview(itemImageView)
        
        cardBackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cardFrontView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        itemImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
    }
    
    func configure(with model: MemoryCardModel) {
        itemImageView.image = UIImage(named: model.imageName)
        
        if model.isFaceUp || model.isMatched {
            cardFrontView.isHidden = false
            cardBackView.isHidden = true
        } else {
            cardFrontView.isHidden = true
            cardBackView.isHidden = false
        }
    }
    
    func flip(to model: MemoryCardModel, animated: Bool) {
        guard animated else {
            configure(with: model)
            return
        }
        
        let fromView = model.isFaceUp ? cardBackView : cardFrontView
        let toView = model.isFaceUp ? cardFrontView : cardBackView
        
        UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionFlipFromLeft, .showHideTransitionViews])
    }
}

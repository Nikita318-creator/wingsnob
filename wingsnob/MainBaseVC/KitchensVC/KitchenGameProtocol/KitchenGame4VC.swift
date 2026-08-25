
import UIKit
import SnapKit

final class KitchenGame4VC: UIViewController, BaseKitchenGameProtocol {
    
    // MARK: - Properties
    let levelNumber: Int
    let difficulty: String
    var onGameCompleted: (() -> Void)?
    
    // Game Logic State
    private var cardCount: Int = 6
    private var sequenceLength: Int = 4
    private var flashDuration: Double = 0.5
    
    private var foodImages: [String] = []
    private var targetSequence: [Int] = []
    private var userStepIndex: Int = 0
    private var isUserTurn: Bool = false
    private var activeCards: [UIButton] = []
    
    // MARK: - UI Components
    private let containerCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.12, green: 0.14, blue: 0.20, alpha: 0.3)
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let statusTextLabel: UILabel = {
        let label = UILabel()
        label.text = "MEMORIZE THE PATTERN!"
        label.font = .systemFont(ofSize: 18, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // Верхняя зона, куда красивой анимацией перелетают карточки при успешных тапах
    private let targetTrayContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    // Сетка карточек внизу
    private let gridStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    // MARK: - Intro Rules Modal Overlay
    private let rulesOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let rulesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "MEMORIZE THE RECIPE!"
        label.font = .systemFont(ofSize: 22, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let rulesDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Watch the glowing cards carefully and repeat the exact ingredient pattern tap by tap!"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let startShiftButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("START PATTERN", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        btn.backgroundColor = UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 14
        return btn
    }()

    // MARK: - Init
    init(levelNumber: Int, difficulty: String) {
        self.levelNumber = levelNumber
        self.difficulty = difficulty
        super.init(nibName: nil, bundle: nil)
        
        calculateLevelDifficulty()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup Difficulty & UI
    private func calculateLevelDifficulty() {
        // Кол-во карточек снизу: от 6 до 12
        if levelNumber <= 3 {
            cardCount = 6
        } else if levelNumber <= 6 {
            cardCount = 8
        } else {
            cardCount = 12
        }
        
        // Длина запоминаемой последовательности (от 4 до 9)
        sequenceLength = min(3 + levelNumber, 9)
        
        // Скорость подсвечивания (бордера)
        flashDuration = max(0.25, 0.55 - Double(levelNumber) * 0.03)
        
        // Иконки food1 - food6 с повторениями под cardCount
        var baseImages: [String] = []
        for i in 1...6 {
            baseImages.append("food\(i)")
        }
        foodImages = []
        for i in 0..<cardCount {
            foodImages.append(baseImages[i % baseImages.count])
        }
        foodImages.shuffle()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(containerCardView)
        containerCardView.addSubview(statusTextLabel)
        containerCardView.addSubview(targetTrayContainer)
        containerCardView.addSubview(gridStackView)
        
        view.addSubview(rulesOverlayView)
        rulesOverlayView.addSubview(rulesTitleLabel)
        rulesOverlayView.addSubview(rulesDescriptionLabel)
        rulesOverlayView.addSubview(startShiftButton)
        
        containerCardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        statusTextLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        targetTrayContainer.snp.makeConstraints { make in
            make.top.equalTo(statusTextLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        gridStackView.snp.makeConstraints { make in
            make.top.equalTo(targetTrayContainer.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // Rules Modal Setup
        rulesOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rulesTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        rulesDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(rulesTitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        startShiftButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(48)
        }
        
        startShiftButton.addTarget(self, action: #selector(didTapStartGame), for: .touchUpInside)
        
        buildGrid()
    }
    
    private func buildGrid() {
        gridStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        activeCards.removeAll()
        
        let columnsCount = cardCount > 6 ? 4 : 3
        let rowsCount = Int(ceil(Double(cardCount) / Double(columnsCount)))
        
        // Меняем на .fill, чтобы ряды не растягивались вертикально на весь экран
        gridStackView.distribution = .fill
        
        var cardIndex = 0
        for _ in 0..<rowsCount {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 10
            
            for _ in 0..<columnsCount {
                if cardIndex < cardCount {
                    let cardBtn = createCardButton(index: cardIndex)
                    rowStack.addArrangedSubview(cardBtn)
                    activeCards.append(cardBtn)
                    cardIndex += 1
                } else {
                    let dummyView = UIView()
                    rowStack.addArrangedSubview(dummyView)
                }
            }
            gridStackView.addArrangedSubview(rowStack)
        }
    }
    
    private func createCardButton(index: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor(red: 0.18, green: 0.22, blue: 0.30, alpha: 1.0)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 3.0
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        btn.tag = index
        
        // Жестко фиксируем пропорцию карточки: высота = ширина * 1.5
        btn.snp.makeConstraints { make in
            make.height.equalTo(btn.snp.width).multipliedBy(1.5)
        }
        
        let imgName = foodImages[index]
        if let img = UIImage(named: imgName) {
            btn.setImage(img, for: .normal)
            btn.imageView?.contentMode = .scaleAspectFit
            btn.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }
        
        btn.addTarget(self, action: #selector(didTapCard(_:)), for: .touchUpInside)
        return btn
    }

    // MARK: - Game Flow & Sequences
    @objc private func didTapStartGame() {
        UIView.animate(withDuration: 0.3) {
            self.rulesOverlayView.alpha = 0.0
        } completion: { _ in
            self.rulesOverlayView.isHidden = true
            self.startNewRound()
        }
    }
    
    private func startNewRound() {
        isUserTurn = false
        userStepIndex = 0
        targetSequence.removeAll()
        
        // Очищаем верхний поднос
        targetTrayContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Генерируем случайную последовательность карточек
        for _ in 0..<sequenceLength {
            let randomIndex = Int.random(in: 0..<cardCount)
            targetSequence.append(randomIndex)
        }
        
        statusTextLabel.text = "WATCH CAREFULLY!"
        statusTextLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        
        // Задержка 0.6 сек перед миганием
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.playSequenceAnimation(index: 0)
        }
    }
    
    private func playSequenceAnimation(index: Int) {
        guard index < targetSequence.count else {
            // Завершили показ последовательности -> Ход юзера
            isUserTurn = true
            statusTextLabel.text = "YOUR TURN! REPEAT PATTERN"
            statusTextLabel.textColor = .white
            return
        }
        
        let cardIndex = targetSequence[index]
        let cardBtn = activeCards[cardIndex]
        
        flashCardBorder(cardBtn: cardBtn, color: UIColor(red: 0.2, green: 0.85, blue: 0.4, alpha: 1.0)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.playSequenceAnimation(index: index + 1)
            }
        }
    }
    
    // MARK: - Border Glow Animation
    private func flashCardBorder(cardBtn: UIButton, color: UIColor, completion: (() -> Void)? = nil) {
        let originalBorderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        
        UIView.animate(withDuration: flashDuration, animations: {
            cardBtn.layer.borderColor = color.cgColor
            cardBtn.layer.borderWidth = 5.0
            cardBtn.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
        }) { _ in
            UIView.animate(withDuration: self.flashDuration, animations: {
                cardBtn.layer.borderColor = originalBorderColor
                cardBtn.layer.borderWidth = 3.0
                cardBtn.transform = .identity
            }) { _ in
                completion?()
            }
        }
    }
    
    // MARK: - User Action
    @objc private func didTapCard(_ sender: UIButton) {
        guard isUserTurn else { return }
        
        let tappedIndex = sender.tag
        let expectedIndex = targetSequence[userStepIndex]
        
        if tappedIndex == expectedIndex {
            // Верный тап!
            flashCardBorder(cardBtn: sender, color: UIColor(red: 0.2, green: 0.85, blue: 0.4, alpha: 1.0))
            addFoodToTargetTray(imageName: foodImages[tappedIndex])
            
            userStepIndex += 1
            
            // Если собрали всю последовательность -> ПОБЕДА!
            if userStepIndex == targetSequence.count {
                isUserTurn = false
                statusTextLabel.text = "PERFECT RECIPE!"
                statusTextLabel.textColor = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.onGameCompleted?()
                }
            }
        } else {
            // Ошибка -> Трясем карточку, делаем красный бордер и рестартим уровень
            isUserTurn = false
            shakeCard(cardBtn: sender)
            statusTextLabel.text = "WRONG INGREDIENT! TRY AGAIN"
            statusTextLabel.textColor = UIColor(red: 0.95, green: 0.26, blue: 0.22, alpha: 1.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.startNewRound()
            }
        }
    }
    
    // Добавление собранного ингредиента в верхний рецепторный поднос
    private func addFoodToTargetTray(imageName: String) {
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: imageName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        
        iconImageView.alpha = 0
        iconImageView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        targetTrayContainer.addArrangedSubview(iconImageView)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
            iconImageView.alpha = 1.0
            iconImageView.transform = .identity
        })
    }
    
    private func shakeCard(cardBtn: UIButton) {
        cardBtn.layer.borderColor = UIColor(red: 0.95, green: 0.26, blue: 0.22, alpha: 1.0).cgColor
        cardBtn.layer.borderWidth = 5.0
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.4
        animation.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
        cardBtn.layer.add(animation, forKey: "shake")
    }
}

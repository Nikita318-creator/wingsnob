import UIKit
import SnapKit

struct GameLevel {
    let number: Int
    let targetScore: Int
    let fallSpeed: CGFloat
    let spawnInterval: TimeInterval
    let storyText: String?
}

final class LevelPickerViewController: UIViewController {

    var maxUnlockedLevel: Int = 1
    var onSelectLevel: ((Int) -> Void)?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(LevelCell.self, forCellWithReuseIdentifier: LevelCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SELECT LEVEL"
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()

    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = .lightGray
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(collectionView)

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

extension LevelPickerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 150
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LevelCell.reuseIdentifier,
            for: indexPath
        ) as? LevelCell else {
            return UICollectionViewCell()
        }
        let levelNumber = indexPath.item + 1
        let isUnlocked = levelNumber <= maxUnlockedLevel
        cell.configure(levelNumber: levelNumber, isUnlocked: isUnlocked)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 40 - 36) / 4
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedLevel = indexPath.item + 1
        if selectedLevel <= maxUnlockedLevel {
            onSelectLevel?(selectedLevel)
            dismiss(animated: true)
        }
    }
}

final class LevelCell: UICollectionViewCell {
    static let reuseIdentifier = "LevelCell"

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let lockImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock.fill"))
        iv.tintColor = .gray
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.addSubview(numberLabel)
        contentView.addSubview(lockImageView)

        numberLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        lockImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(levelNumber: Int, isUnlocked: Bool) {
        if isUnlocked {
            contentView.backgroundColor = .systemRed
            numberLabel.text = "\(levelNumber)"
            numberLabel.isHidden = false
            lockImageView.isHidden = true
        } else {
            contentView.backgroundColor = UIColor(white: 0.18, alpha: 1.0)
            numberLabel.isHidden = true
            lockImageView.isHidden = false
        }
    }
}

import UIKit
import SnapKit

final class RealGameVC: UIViewController {

    private let foodAssets: [String] = [
        "CHICKENTENDERS", "BONELESSWINGS", "TRADITIONALWINGS",
        "BUFFALOCHICKEN", "MOZZARELLASTICKS", "CHEESEBITES",
        "CHEESEFRIES", "ONIONRINGS", "DIPPINGSAUCES", "LEMONADE"
    ]

    private let storyLines: [Int: String] = [
        1: "Welcome to the Diner! The kitchen is getting chaotic. Help us sort the incoming orders correctly.",
        2: "Rush hour has started! The conveyor belt is moving faster. Stay focused on your target dish.",
        3: "The chief chef is watching you carefully. Avoid tapping wrong dishes or you'll lose health!",
        4: "Orders are stacking up! Keep your eyes on the top target card to catch the right food.",
        5: "Mid-shift madness! The speed increases further. Show your quick reflexes, chef!",
        6: "VIP customers have arrived! Precision is key — don't miss target orders.",
        7: "Night rush begins! The kitchen heat is rising. Maintain the combo and reach the quota.",
        8: "Supplies are incoming faster than ever. Prove that you can handle a high-volume diner!",
        9: "Almost at the peak of the shift! Only true master chefs can keep up with this pace.",
        10: "Grand Opening Finale! Survive this ultimate shift and unlock the endless arcade shift."
    ]

    private var levels: [GameLevel] = []
    private var currentLevelIndex = 0
    private var maxUnlockedLevel = 1
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)/\(currentLevel.targetScore)"
            checkLevelProgress()
        }
    }
    private var lives = 3 {
        didSet { livesLabel.text = String(repeating: "❤️", count: max(0, lives)) }
    }
    
    private var currentTargetFood: String = ""
    private var isGameActive = false
    private var spawnTimer: Timer?
    private var gameDisplayLink: CADisplayLink?
    
    private var activeItems: [(view: UIView, y: CGFloat, assetName: String)] = []
    
    private var currentLevel: GameLevel {
        return levels[currentLevelIndex]
    }

    // Header Controls
    private let levelSelectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("LVL 1 ▾", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        btn.layer.cornerRadius = 10
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return btn
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let livesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private let rulesButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("?", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        btn.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        btn.layer.cornerRadius = 18
        return btn
    }()

    // Pure Image Target Card (No text labels)
    private let targetContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemRed.cgColor
        return view
    }()

    private let targetImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let gameAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.08, alpha: 1.0)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()

    // FULLSCREEN OVERLAY
    private let fullScreenOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 0.98)
        return view
    }()

    private let overlayImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let overlayTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let overlayDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let startShiftButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("START SHIFT", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.backgroundColor = .systemRed
        btn.layer.cornerRadius = 14
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        generate150Levels()
        setupUI()
        setupActions()
        showStoryOverlay()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopGame()
    }

    private func generate150Levels() {
        for lvl in 1...150 {
            let story = storyLines[lvl]
            if lvl <= 10 {
                let target = 20 + (lvl * 10)
                let speed: CGFloat = CGFloat(2.0 + (Double(lvl) * 0.35))
                let interval = max(0.5, 1.3 - (Double(lvl) * 0.07))
                levels.append(GameLevel(number: lvl, targetScore: target, fallSpeed: speed, spawnInterval: interval, storyText: story))
            } else {
                levels.append(GameLevel(number: lvl, targetScore: 150, fallSpeed: 5.5, spawnInterval: 0.5, storyText: nil))
            }
        }
    }

    private func setupUI() {
        title = "Kitchen Dash"
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        view.addSubview(levelSelectButton)
        view.addSubview(scoreLabel)
        view.addSubview(livesLabel)
        view.addSubview(rulesButton)

        view.addSubview(targetContainerView)
        targetContainerView.addSubview(targetImageView)

        view.addSubview(gameAreaView)

        // Fullscreen overlay UI
        view.addSubview(fullScreenOverlay)
        fullScreenOverlay.addSubview(overlayTitleLabel)
        fullScreenOverlay.addSubview(overlayImageView)
        fullScreenOverlay.addSubview(overlayDescriptionLabel)
        fullScreenOverlay.addSubview(startShiftButton)

        levelSelectButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(20)
        }

        rulesButton.snp.makeConstraints { make in
            make.centerY.equalTo(levelSelectButton)
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }

        livesLabel.snp.makeConstraints { make in
            make.centerY.equalTo(levelSelectButton)
            make.trailing.equalTo(rulesButton.snp.leading).offset(-12)
        }

        scoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(levelSelectButton)
            make.trailing.equalTo(livesLabel.snp.leading).offset(-12)
        }

        targetContainerView.snp.makeConstraints { make in
            make.top.equalTo(levelSelectButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
        }

        targetImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        gameAreaView.snp.makeConstraints { make in
            make.top.equalTo(targetContainerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        // Fullscreen Constraints
        fullScreenOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        overlayTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(fullScreenOverlay.safeAreaLayoutGuide).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        overlayImageView.snp.makeConstraints { make in
            make.top.equalTo(overlayTitleLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 140, height: 140))
        }

        overlayDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(overlayImageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        startShiftButton.snp.makeConstraints { make in
            make.bottom.equalTo(fullScreenOverlay.safeAreaLayoutGuide).offset(-40)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(54)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGameAreaTap(_:)))
        gameAreaView.addGestureRecognizer(tapGesture)

        updateHeaderUI()
    }

    private func setupActions() {
        levelSelectButton.addTarget(self, action: #selector(openLevelGrid), for: .touchUpInside)
        rulesButton.addTarget(self, action: #selector(showRules), for: .touchUpInside)
        startShiftButton.addTarget(self, action: #selector(startCurrentLevel), for: .touchUpInside)
    }

    private func updateHeaderUI() {
        levelSelectButton.setTitle("LVL \(currentLevel.number) ▾", for: .normal)
        scoreLabel.text = "SCORE: \(score)/\(currentLevel.targetScore)"
        livesLabel.text = String(repeating: "❤️", count: max(0, lives))
    }

    private func showStoryOverlay() {
        stopGame()
        updateHeaderUI()
        updateNewTarget()

        fullScreenOverlay.isHidden = false
        overlayImageView.image = UIImage(named: currentTargetFood)

        if let story = currentLevel.storyText {
            overlayTitleLabel.text = "LEVEL \(currentLevel.number)"
            overlayDescriptionLabel.text = story
        } else {
            overlayTitleLabel.text = "LEVEL \(currentLevel.number)"
            overlayDescriptionLabel.text = "Reach target score of \(currentLevel.targetScore) points by catching correct food items!"
        }
        startShiftButton.setTitle("START SHIFT", for: .normal)
    }

    @objc private func startCurrentLevel() {
        score = 0
        lives = 3
        isGameActive = true
        fullScreenOverlay.isHidden = true
        updateHeaderUI()

        clearActiveFood()

        spawnTimer?.invalidate()
        spawnTimer = Timer.scheduledTimer(
            timeInterval: currentLevel.spawnInterval,
            target: self,
            selector: #selector(spawnFoodItem),
            userInfo: nil,
            repeats: true
        )

        gameDisplayLink?.invalidate()
        gameDisplayLink = CADisplayLink(target: self, selector: #selector(updateGameLoop))
        gameDisplayLink?.add(to: .main, forMode: .common)
    }

    private func stopGame() {
        isGameActive = false
        spawnTimer?.invalidate()
        spawnTimer = nil
        gameDisplayLink?.invalidate()
        gameDisplayLink = nil
        clearActiveFood()
    }

    @objc private func updateGameLoop() {
        guard isGameActive else { return }

        let speed = currentLevel.fallSpeed
        var itemsToRemove: [(view: UIView, assetName: String)] = []

        for index in 0..<activeItems.count {
            activeItems[index].y += speed
            let currentY = activeItems[index].y
            let view = activeItems[index].view
            
            view.frame.origin.y = currentY

            if currentY > gameAreaView.bounds.height {
                itemsToRemove.append((view, activeItems[index].assetName))
            }
        }

        for item in itemsToRemove {
            item.view.removeFromSuperview()
            activeItems.removeAll(where: { $0.view == item.view })
            handleFoodMissed(assetName: item.assetName)
        }
    }

    @objc private func spawnFoodItem() {
        guard isGameActive, let randomAsset = foodAssets.randomElement() else { return }

        let foodContainer = UIView()
        foodContainer.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        foodContainer.layer.cornerRadius = 14
        foodContainer.layer.borderWidth = 1.5
        foodContainer.layer.borderColor = UIColor(white: 0.35, alpha: 1.0).cgColor

        let imageView = UIImageView(image: UIImage(named: randomAsset))
        imageView.contentMode = .scaleAspectFit
        foodContainer.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }

        let size: CGFloat = 74
        gameAreaView.layoutIfNeeded()
        let maxX = max(0, gameAreaView.bounds.width - size)
        let randomX = CGFloat.random(in: 0...maxX)

        gameAreaView.addSubview(foodContainer)
        
        let startY: CGFloat = -size
        foodContainer.frame = CGRect(x: randomX, y: startY, width: size, height: size)

        activeItems.append((view: foodContainer, y: startY, assetName: randomAsset))
    }

    @objc private func handleGameAreaTap(_ gesture: UITapGestureRecognizer) {
        guard isGameActive else { return }
        let touchLocation = gesture.location(in: gameAreaView)

        if let matchedIndex = activeItems.firstIndex(where: { item in
            let presentationFrame = item.view.layer.presentation()?.frame ?? item.view.frame
            let hitArea = presentationFrame.insetBy(dx: -15, dy: -15)
            return hitArea.contains(touchLocation)
        }) {
            let tappedItem = activeItems[matchedIndex]
            tappedItem.view.removeFromSuperview()
            activeItems.remove(at: matchedIndex)

            if tappedItem.assetName == currentTargetFood {
                score += 10
                generateFeedback(style: .medium)
                updateNewTarget()
            } else {
                lives -= 1
                generateFeedback(style: .error)
                if lives <= 0 {
                    gameOver()
                }
            }
        }
    }

    private func handleFoodMissed(assetName: String) {
        if assetName == currentTargetFood {
            lives -= 1
            generateFeedback(style: .light)
            if lives <= 0 {
                gameOver()
            } else {
                updateNewTarget()
            }
        }
    }

    private func clearActiveFood() {
        activeItems.forEach { $0.view.removeFromSuperview() }
        activeItems.removeAll()
    }

    private func checkLevelProgress() {
        if score >= currentLevel.targetScore {
            stopGame()
            if currentLevel.number == maxUnlockedLevel && maxUnlockedLevel < 150 {
                maxUnlockedLevel += 1
            }
            
            if currentLevelIndex < 149 {
                currentLevelIndex += 1
            }
            showStoryOverlay()
        }
    }

    private func gameOver() {
        stopGame()
        fullScreenOverlay.isHidden = false
        overlayTitleLabel.text = "SHIFT FAILED"
        overlayImageView.image = UIImage(systemName: "xmark.octagon.fill")
        overlayImageView.tintColor = .systemRed
        overlayDescriptionLabel.text = "You lost all lives!\nReached score: \(score)/\(currentLevel.targetScore)"
        startShiftButton.setTitle("TRY AGAIN", for: .normal)
    }

    private func updateNewTarget() {
        guard let randomTarget = foodAssets.randomElement() else { return }
        currentTargetFood = randomTarget
        targetImageView.image = UIImage(named: randomTarget)
    }

    @objc private func openLevelGrid() {
        let picker = LevelPickerViewController()
        picker.maxUnlockedLevel = maxUnlockedLevel
        picker.onSelectLevel = { [weak self] selectedLevel in
            self?.currentLevelIndex = selectedLevel - 1
            self?.showStoryOverlay()
        }
        present(picker, animated: true)
    }

    @objc private func showRules() {
        let rulesAlert = UIAlertController(
            title: "How to Play",
            message: """
            1. Look at the TARGET DISH image at the top.
            2. Tap the matching falling dish in the kitchen area.
            3. Correct taps award +10 points and change the target dish.
            4. Tapping a wrong dish or missing a target dish costs 1 life (❤️).
            5. Clear the target score to unlock the next level!
            """,
            preferredStyle: .alert
        )
        rulesAlert.addAction(UIAlertAction(title: "Got It!", style: .default))
        present(rulesAlert, animated: true)
    }

    private func generateFeedback(style: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(style)
    }

    private func generateFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

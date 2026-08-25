import UIKit
import SnapKit

final class KitchenGame3VC: UIViewController, BaseKitchenGameProtocol {
    
    // MARK: - Properties & Protocol
    let levelNumber: Int
    let difficulty: String
    var onGameCompleted: (() -> Void)?
    
    // Game Mechanics Setup
    private struct FallingItem {
        let view: UIView
        let isFresh: Bool
        var speed: CGFloat
    }
    
    private var activeItems: [FallingItem] = []
    private var displayLink: CADisplayLink?
    
    private var score: Int = 0 {
        didSet {
            updateProgress()
        }
    }
    private var missedCount: Int = 0 {
        didSet {
            updateLives()
        }
    }
    
    private let targetScore: Int = 20
    private let maxMissedCount: Int = 3
    
    // Dynamic Level Parameters
    private var fallSpeed: CGFloat {
        // Базовая скорость растет с уровнем (от 2.5 до 6.5)
        let baseSpeed: CGFloat = 2.5 + CGFloat(levelNumber) * 0.4
        return difficulty == "Hard" ? baseSpeed * 1.3 : baseSpeed
    }
    
    private var spawnInterval: TimeInterval {
        // Спавн становится чаще с уровнем (от 1.2с до 0.4с)
        let interval = max(0.4, 1.2 - Double(levelNumber) * 0.08)
        return difficulty == "Hard" ? interval * 0.8 : interval
    }
    
    private var spawnTimer: Timer?
    
    // Asset Names
    private let foodAssets = (1...6).map { "food\($0)" }
    private let trashAssets = (1...6).map { "trash\($0)" }
    
    // MARK: - UI Elements
    private let gameAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 0.3)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    // Header UI
    private let statsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "PLATE FILL: 0%"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.progressTintColor = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        progress.trackTintColor = UIColor.white.withAlphaComponent(0.2)
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        return progress
    }()
    
    private let livesLabel: UILabel = {
        let label = UILabel()
        label.text = "❤️❤️❤️"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    // MARK: - Lifecycle
    init(levelNumber: Int, difficulty: String) {
        self.levelNumber = levelNumber
        self.difficulty = difficulty
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showRulesOverlay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopGameEngine()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(gameAreaView)
        
        gameAreaView.addSubview(statsContainer)
        statsContainer.addSubview(scoreLabel)
        statsContainer.addSubview(progressView)
        statsContainer.addSubview(livesLabel)
        
        gameAreaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        statsContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(54)
        }
        
        scoreLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(12)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(scoreLabel.snp.bottom).offset(6)
            make.leading.equalTo(scoreLabel)
            make.width.equalTo(140)
            make.height.equalTo(8)
        }
        
        livesLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Game Engine Controls
    private func startGameEngine() {
        score = 0
        missedCount = 0
        clearActiveItems()
        
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
        displayLink?.add(to: .main, forMode: .common)
        
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { [weak self] _ in
            self?.spawnFallingItem()
        }
    }
    
    private func stopGameEngine() {
        displayLink?.invalidate()
        displayLink = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
    
    private func clearActiveItems() {
        activeItems.forEach { $0.view.removeFromSuperview() }
        activeItems.removeAll()
    }
    
    // MARK: - Game Loop & Spawning
    @objc private func gameLoop() {
        let areaHeight = gameAreaView.bounds.height
        var indicesToRemove: [Int] = []
        
        for (index, item) in activeItems.enumerated() {
            var frame = item.view.frame
            frame.origin.y += item.speed
            item.view.frame = frame
            
            // Проверка: упал ли предмет ниже экрана
            if frame.origin.y > areaHeight {
                indicesToRemove.append(index)
                if item.isFresh {
                    missedCount += 1
                    if missedCount >= maxMissedCount {
                        handleGameOver(reason: "You missed too many fresh items!")
                        return
                    }
                }
            }
        }
        
        // Удаляем объекты упавшие за пределы экрана
        for index in indicesToRemove.reversed() {
            activeItems[index].view.removeFromSuperview()
            activeItems.remove(at: index)
        }
    }
    
    private func spawnFallingItem() {
        let isFresh = Bool.random()
        let imageName = isFresh ? foodAssets.randomElement()! : trashAssets.randomElement()!
        
        let size: CGFloat = 60
        let areaWidth = gameAreaView.bounds.width
        guard areaWidth > size else { return }
        
        let randomX = CGFloat.random(in: 12...(areaWidth - size - 12))
        
        let itemContainer = UIView(frame: CGRect(x: randomX, y: -size, width: size, height: size))
        
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = itemContainer.bounds
        itemContainer.addSubview(imageView)
        
        // Всплывашки на сложных уровнях (маленькое искажение/вращение)
        if levelNumber > 5 && !isFresh {
            itemContainer.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -0.3...0.3))
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapItem(_:)))
        itemContainer.addGestureRecognizer(tapGesture)
        itemContainer.isUserInteractionEnabled = true
        
        gameAreaView.addSubview(itemContainer)
        activeItems.append(FallingItem(view: itemContainer, isFresh: isFresh, speed: fallSpeed))
    }
    
    // MARK: - Interaction & Logic
    @objc private func didTapItem(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view,
              let index = activeItems.firstIndex(where: { $0.view == tappedView }) else { return }
        
        let item = activeItems[index]
        
        // Анимация тапа (увеличение и растворение)
        UIView.animate(withDuration: 0.15, animations: {
            tappedView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            tappedView.alpha = 0
        }) { _ in
            tappedView.removeFromSuperview()
        }
        
        activeItems.remove(at: index)
        
        if item.isFresh {
            score += 1
            if score >= targetScore {
                handleVictory()
            }
        } else {
            handleGameOver(reason: "You tapped on trash!")
        }
    }
    
    private func updateProgress() {
        let ratio = Float(score) / Float(targetScore)
        progressView.setProgress(ratio, animated: true)
        scoreLabel.text = "PLATE FILL: \(Int(ratio * 100))%"
    }
    
    private func updateLives() {
        let remaining = max(0, maxMissedCount - missedCount)
        livesLabel.text = String(repeating: "❤️", count: remaining) + String(repeating: "🖤", count: maxMissedCount - remaining)
    }
    
    // MARK: - Result States
    private func handleVictory() {
        stopGameEngine()
        showResultModal(
            title: "LEVEL COMPLETED!",
            message: "Great job! The plate is full of fresh food.",
            buttonTitle: "CONTINUE",
            isVictory: true
        )
    }
    
    private func handleGameOver(reason: String) {
        stopGameEngine()
        showResultModal(
            title: "GAME OVER",
            message: reason,
            buttonTitle: "TRY AGAIN",
            isVictory: false
        )
    }
    
    // MARK: - Overlays (UI Rules / Victory / Defeat)
    private func showRulesOverlay() {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        overlay.layer.cornerRadius = 20
        
        let card = UIView()
        card.backgroundColor = UIColor(red: 0.18, green: 0.20, blue: 0.26, alpha: 1.0)
        card.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "FRESH INGREDIENTS ONLY!"
        titleLabel.font = .systemFont(ofSize: 18, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        let objLabel = UILabel()
        objLabel.text = "Objective: Fill plate to 100% (\(targetScore) items)"
        objLabel.font = .systemFont(ofSize: 13, weight: .bold)
        objLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        objLabel.textAlignment = .center
        
        let bodyLabel = UILabel()
        bodyLabel.text = "Tap fresh food to put it on the plate. Tap trash or spoiled items and you lose. Don't let good food fall!"
        bodyLabel.font = .systemFont(ofSize: 13, weight: .medium)
        bodyLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center
        
        let startBtn = UIButton(type: .system)
        startBtn.setTitle("START COOKING", for: .normal)
        startBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        startBtn.backgroundColor = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        startBtn.setTitleColor(.white, for: .normal)
        startBtn.layer.cornerRadius = 10
        
        overlay.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(objLabel)
        card.addSubview(bodyLabel)
        card.addSubview(startBtn)
        
        gameAreaView.addSubview(overlay)
        
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        card.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        objLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(objLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        startBtn.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        startBtn.addAction(UIAction { [weak overlay, weak self] _ in
            overlay?.removeFromSuperview()
            self?.startGameEngine()
        }, for: .touchUpInside)
    }
    
    private func showResultModal(title: String, message: String, buttonTitle: String, isVictory: Bool) {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        overlay.layer.cornerRadius = 20
        
        let card = UIView()
        card.backgroundColor = UIColor(red: 0.18, green: 0.20, blue: 0.26, alpha: 1.0)
        card.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .black)
        titleLabel.textColor = isVictory ? UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0) : UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        titleLabel.textAlignment = .center
        
        let msgLabel = UILabel()
        msgLabel.text = message
        msgLabel.font = .systemFont(ofSize: 14, weight: .medium)
        msgLabel.textColor = .white
        msgLabel.numberOfLines = 0
        msgLabel.textAlignment = .center
        
        let actionBtn = UIButton(type: .system)
        actionBtn.setTitle(buttonTitle, for: .normal)
        actionBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        actionBtn.backgroundColor = isVictory ? UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0) : UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        actionBtn.setTitleColor(.white, for: .normal)
        actionBtn.layer.cornerRadius = 10
        
        overlay.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(msgLabel)
        card.addSubview(actionBtn)
        
        gameAreaView.addSubview(overlay)
        
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        card.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        msgLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        actionBtn.snp.makeConstraints { make in
            make.top.equalTo(msgLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        actionBtn.addAction(UIAction { [weak overlay, weak self] _ in
            overlay?.removeFromSuperview()
            if isVictory {
                self?.onGameCompleted?()
            } else {
                self?.startGameEngine()
            }
        }, for: .touchUpInside)
    }
}

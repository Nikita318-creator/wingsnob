import UIKit
import SnapKit

final class KitchenGame2VC: UIViewController, BaseKitchenGameProtocol {
    
    // MARK: - Protocol Properties
    let levelNumber: Int
    let difficulty: String
    var onGameCompleted: (() -> Void)?
    
    // MARK: - Game Settings & Logic
    private var totalGameTime: Int = 30
    private var remainingTime: Int = 30
    private var lives: Int = 3
    
    private var spawnInterval: TimeInterval = 1.0
    private var fallSpeedMin: CGFloat = 3.0
    private var fallSpeedMax: CGFloat = 5.0
    private var allowDiagonalFalling: Bool = false
    
    private var displayLink: CADisplayLink?
    private var gameTimer: Timer?
    private var lastSpawnTime: CFTimeInterval = 0
    private var isGameRunning = false
    
    // Constraint Reference for Smooth X-Positioning
    private var trayCenterXConstraint: Constraint?
    
    // Falling objects structure
    private struct HazardObject {
        let view: UIImageView
        var velocityY: CGFloat
        var velocityX: CGFloat
    }
    
    private var activeHazards: [HazardObject] = []
    private let trashImageNames = ["trash1", "trash2", "trash3", "trash4", "trash5", "trash6"]
    
    // MARK: - UI Components
    private let gameAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.12, green: 0.14, blue: 0.20, alpha: 0.3)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private let hudStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .black)
        label.textColor = .white
        return label
    }()
    
    private let livesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .black)
        label.textColor = .systemRed
        return label
    }()
    
    private let playerTrayImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        iv.image = UIImage(systemName: "tray.fill", withConfiguration: config)
        iv.tintColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    // Modals Container Overlay
    private let overlayModalView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        return view
    }()
    
    private let modalCardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let modalTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .black)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let modalSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private let modalDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let modalActionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    // MARK: - Init
    init(levelNumber: Int, difficulty: String) {
        self.levelNumber = levelNumber
        self.difficulty = difficulty
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateDifficultyParameters()
        setupUI()
        setupGesture()
        showIntroModal()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopGameEngine()
    }
    
    // MARK: - Difficulty Scaling Logic
    private func calculateDifficultyParameters() {
        totalGameTime = 30 + (levelNumber - 1) * 3
        remainingTime = totalGameTime
        
        if levelNumber <= 3 {
            lives = 3
        } else if levelNumber <= 7 {
            lives = 2
        } else {
            lives = 1
        }
        
        spawnInterval = max(0.35, 1.1 - Double(levelNumber - 1) * 0.08)
        fallSpeedMin = 3.0 + CGFloat(levelNumber) * 0.5
        fallSpeedMax = 5.0 + CGFloat(levelNumber) * 0.7
        allowDiagonalFalling = levelNumber >= 6
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(gameAreaView)
        gameAreaView.addSubview(hudStackView)
        hudStackView.addArrangedSubview(timerLabel)
        hudStackView.addArrangedSubview(livesLabel)
        
        gameAreaView.addSubview(playerTrayImageView)
        
        view.addSubview(overlayModalView)
        overlayModalView.addSubview(modalCardContainer)
        
        modalCardContainer.addSubview(modalTitleLabel)
        modalCardContainer.addSubview(modalSubtitleLabel)
        modalCardContainer.addSubview(modalDescriptionLabel)
        modalCardContainer.addSubview(modalActionButton)
        
        gameAreaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        hudStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        // Сохраняем ссылку на констрейнт центра X
        playerTrayImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-30)
            self.trayCenterXConstraint = make.centerX.equalTo(gameAreaView.snp.leading).offset(view.bounds.width / 2).constraint
            make.width.equalTo(90)
            make.height.equalTo(50)
        }
        
        overlayModalView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        modalCardContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(28)
        }
        
        modalTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        modalSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(modalTitleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        modalDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(modalSubtitleLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        modalActionButton.snp.makeConstraints { make in
            make.top.equalTo(modalDescriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(48)
        }
        
        updateHUD()
    }
    
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        gameAreaView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Smooth Gesture Handler
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard isGameRunning else { return }
        let location = gesture.location(in: gameAreaView)
        
        let halfWidth: CGFloat = 45 // 90 / 2
        let minX = halfWidth
        let maxX = gameAreaView.bounds.width - halfWidth
        
        let clampedX = min(max(location.x, minX), maxX)
        
        // Обновляем офсет сохраненного констрейнта и форсим layout
        trayCenterXConstraint?.update(offset: clampedX)
        gameAreaView.layoutIfNeeded()
    }
    
    // MARK: - Modals State
    private func showIntroModal() {
        isGameRunning = false
        overlayModalView.isHidden = false
        
        modalTitleLabel.text = "DODGE THE HAZARDS!"
        modalSubtitleLabel.text = "Objective: Survive for \(totalGameTime) seconds!"
        modalDescriptionLabel.text = "Drag the tray left and right to avoid falling knives, hot pans, and broken glass. Don't drop your guard!"
        modalActionButton.setTitle("START SHIFT", for: .normal)
        
        modalActionButton.removeTarget(nil, action: nil, for: .allEvents)
        modalActionButton.addTarget(self, action: #selector(didTapStartGame), for: .touchUpInside)
    }
    
    private func showGameOverModal() {
        stopGameEngine()
        overlayModalView.isHidden = false
        
        modalTitleLabel.text = "SHIFT FAILED!"
        modalSubtitleLabel.text = "You caught a hazard!"
        modalDescriptionLabel.text = "The kitchen was ruined! Clean up your station and try again to save the shift."
        modalActionButton.setTitle("TRY AGAIN", for: .normal)
        
        modalActionButton.removeTarget(nil, action: nil, for: .allEvents)
        modalActionButton.addTarget(self, action: #selector(didTapRestartGame), for: .touchUpInside)
    }
    
    private func showWinModal() {
        stopGameEngine()
        overlayModalView.isHidden = false
        
        modalTitleLabel.text = "SHIFT COMPLETED!"
        modalSubtitleLabel.text = "Great job chef!"
        modalDescriptionLabel.text = "You successfully dodged all the kitchen hazards and kept the station clean!"
        modalActionButton.setTitle("CONTINUE >", for: .normal)
        
        modalActionButton.removeTarget(nil, action: nil, for: .allEvents)
        modalActionButton.addTarget(self, action: #selector(didTapClaimWin), for: .touchUpInside)
    }
    
    // MARK: - Game Engine Controls
    @objc private func didTapStartGame() {
        overlayModalView.isHidden = true
        startGameEngine()
    }
    
    @objc private func didTapRestartGame() {
        clearHazards()
        calculateDifficultyParameters()
        updateHUD()
        
        // Сброс подноса по центру
        let initialX = gameAreaView.bounds.width / 2
        trayCenterXConstraint?.update(offset: initialX)
        gameAreaView.layoutIfNeeded()
        
        overlayModalView.isHidden = true
        startGameEngine()
    }
    
    @objc private func didTapClaimWin() {
        onGameCompleted?()
    }
    
    private func startGameEngine() {
        isGameRunning = true
        lastSpawnTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
        displayLink?.add(to: .main, forMode: .common)
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickTimer()
        }
    }
    
    private func stopGameEngine() {
        isGameRunning = false
        displayLink?.invalidate()
        displayLink = nil
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func tickTimer() {
        guard isGameRunning else { return }
        remainingTime -= 1
        updateHUD()
        
        if remainingTime <= 0 {
            showWinModal()
        }
    }
    
    private func updateHUD() {
        timerLabel.text = "TIME: \(remainingTime)s"
        
        var heartsStr = ""
        for _ in 0..<lives {
            heartsStr += "❤️ "
        }
        livesLabel.text = heartsStr.trimmingCharacters(in: .whitespaces)
    }
    
    // MARK: - CADisplayLink Loop
    @objc private func gameLoop(displayLink: CADisplayLink) {
        guard isGameRunning else { return }
        
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastSpawnTime >= spawnInterval {
            spawnHazard()
            lastSpawnTime = currentTime
        }
        
        var remainingHazards: [HazardObject] = []
        // Беру актуальный presentation layer frame чтобы коллизия всегда была точной при анимациях
        let playerFrame = playerTrayImageView.layer.presentation()?.frame ?? playerTrayImageView.frame
        
        for var hazard in activeHazards {
            var frame = hazard.view.frame
            frame.origin.y += hazard.velocityY
            frame.origin.x += hazard.velocityX
            
            if frame.minX <= 0 || frame.maxX >= gameAreaView.bounds.width {
                hazard.velocityX *= -1
            }
            
            hazard.view.frame = frame
            
            let hazardHitbox = frame.insetBy(dx: 6, dy: 6)
            if hazardHitbox.intersects(playerFrame) {
                hazard.view.removeFromSuperview()
                handleHazardHit()
                continue
            }
            
            if frame.minY > gameAreaView.bounds.height {
                hazard.view.removeFromSuperview()
                continue
            }
            
            remainingHazards.append(hazard)
        }
        
        activeHazards = remainingHazards
    }
    
    private func spawnHazard() {
        let size: CGFloat = 44
        let maxX = gameAreaView.bounds.width - size
        guard maxX > 0 else { return }
        
        let randomX = CGFloat.random(in: 10...maxX)
        let hazardView = UIImageView(frame: CGRect(x: randomX, y: -size, width: size, height: size))
        
        let randomImageName = trashImageNames.randomElement() ?? "trash1"
        hazardView.image = UIImage(named: randomImageName)
        hazardView.contentMode = .scaleAspectFit
        
        gameAreaView.addSubview(hazardView)
        
        let velocityY = CGFloat.random(in: fallSpeedMin...fallSpeedMax)
        let velocityX = allowDiagonalFalling ? CGFloat.random(in: -1.5...1.5) : 0.0
        
        let hazard = HazardObject(view: hazardView, velocityY: velocityY, velocityX: velocityX)
        activeHazards.append(hazard)
    }
    
    private func handleHazardHit() {
        lives -= 1
        updateHUD()
        
        // Без багов через UIView.transition
        UIView.transition(with: playerTrayImageView, duration: 0.15, options: .transitionCrossDissolve, animations: {
            self.playerTrayImageView.tintColor = .systemRed
        }) { _ in
            UIView.transition(with: self.playerTrayImageView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                self.playerTrayImageView.tintColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            })
        }
        
        if lives <= 0 {
            showGameOverModal()
        }
    }
    
    private func clearHazards() {
        for hazard in activeHazards {
            hazard.view.removeFromSuperview()
        }
        activeHazards.removeAll()
    }
}

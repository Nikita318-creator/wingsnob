
import UIKit
import SnapKit

// MARK: - 1. Story & Level Models

struct ComicSlideModel {
    let imageName: String
    let characterName: String
    let speechBubbleText: String
}

struct LevelStoryModel {
    let levelNumber: Int
    let slides: [ComicSlideModel] // Strictly 4 slides per level
}

// MARK: - 2. ViewModel
final class SingleKitchenViewModel {
    
    let kitchen: KitchenModel
    private(set) var levels: [LevelStoryModel] = []
    private(set) var gameSequence: [KitchenGameType] = []
    
    private(set) var currentLevelIndex: Int = 0
    private(set) var currentSlideIndex: Int = 0
    
    var onSlideUpdated: ((ComicSlideModel, _ pageText: String, _ isLastSlide: Bool) -> Void)?
    var onGameStarted: ((_ gameVC: BaseKitchenGameProtocol) -> Void)?
    var onAllKitchenLevelsCompleted: (() -> Void)?
    
    private var userDefaultsKey: String {
        return "completed_level_\(kitchen.title.replacingOccurrences(of: " ", with: "_"))"
    }
    
    init(kitchen: KitchenModel) {
        self.kitchen = kitchen
        setupGameSequence()
        generateMockLevels()
        loadCompletedLevelProgress()
    }
    
    // MARK: - Progress Tracking (UserDefaults)
    
    var completedLevelsCount: Int {
        return UserDefaults.standard.integer(forKey: userDefaultsKey)
    }
    
    private func loadCompletedLevelProgress() {
        let completedCount = completedLevelsCount
        if completedCount >= levels.count {
            // Если все 10 уровней пройдены, сбрасываем на последний или даем играть заново
            currentLevelIndex = 0
        } else {
            currentLevelIndex = completedCount
        }
    }
    
    private func saveProgress(levelNumber: Int) {
        if levelNumber > completedLevelsCount {
            UserDefaults.standard.set(levelNumber, forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Game Sequence Config
    
    private func setupGameSequence() {
        // Задаем уникальную последовательность из 4 мини-игр на 10 уровней для каждой кухни
        switch kitchen.title {
        case "Burger Hub":
            gameSequence = [.game1, .game4, .game2, .game3, .game1, .game3, .game4, .game2, .game1, .game4]
        case "Sushi Express":
            gameSequence = [.game2, .game1, .game3, .game4, .game2, .game4, .game1, .game3, .game2, .game1]
        default: // Pizzeria Bella
            gameSequence = [.game3, .game2, .game4, .game1, .game3, .game1, .game2, .game4, .game3, .game2]
        }
    }
    
    var currentLevel: LevelStoryModel {
        return levels[currentLevelIndex]
    }
    
    var currentSlide: ComicSlideModel {
        return currentLevel.slides[currentSlideIndex]
    }
    
    func startLevelStory() {
        currentSlideIndex = 0
        notifySlideUpdate()
    }
    
    func advanceSlide() {
        if currentSlideIndex < currentLevel.slides.count - 1 {
            currentSlideIndex += 1
            notifySlideUpdate()
        } else {
            // Все 4 слайда комикса прочитаны -> Запускаем мини-игру
            let gameType = gameSequence[currentLevelIndex]
            let gameVC = gameType.makeViewController(
                levelNumber: currentLevel.levelNumber,
                difficulty: kitchen.difficulty
            )
            onGameStarted?(gameVC)
        }
    }
    
    /// Вызывается ТОЛЬКО при успешном прохождении самой мини-игры
    func completeCurrentLevel() {
        saveProgress(levelNumber: currentLevel.levelNumber)
        
        if currentLevelIndex < levels.count - 1 {
            currentLevelIndex += 1
            startLevelStory()
        } else {
            // Все 10 уровней кухни пройдены
            onAllKitchenLevelsCompleted?()
        }
    }
    
    private func notifySlideUpdate() {
        let slide = currentSlide
        let pageText = "STORY \(currentSlideIndex + 1)/4"
        let isLast = (currentSlideIndex == currentLevel.slides.count - 1)
        onSlideUpdated?(slide, pageText, isLast)
    }
    
    // MARK: - Mock Generator
    private func generateMockLevels() {
        var generatedLevels: [LevelStoryModel] = []
        
        let characterName: String
        let defaultBg: String
        
        switch kitchen.title {
        case "Burger Hub":
            characterName = "Chef Marco"
            defaultBg = "bg_burger_kitchen"
        case "Sushi Express":
            characterName = "Master Kenji"
            defaultBg = "bg_sushi_kitchen"
        default:
            characterName = "Mama Rosa"
            defaultBg = "bg_pizza_kitchen"
        }
        
        for level in 1...10 {
            let stories = getStoryTexts(for: kitchen.title, level: level)
            let slides = stories.map { text in
                ComicSlideModel(
                    imageName: defaultBg,
                    characterName: characterName,
                    speechBubbleText: text
                )
            }
            generatedLevels.append(LevelStoryModel(levelNumber: level, slides: slides))
        }
        
        self.levels = generatedLevels
    }
    
    private func getStoryTexts(for kitchenTitle: String, level: Int) -> [String] {
        switch kitchenTitle {
        case "Burger Hub":
            return [
                "Emergency at Level \(level)! The lunch rush just slammed us and lines are out the door!",
                "The fryers are smoking, burgers are burning, and customers are getting impatient!",
                "I've been flipping patties for 5 hours non-stop and my hands are completely numb!",
                "Please, step in right now! Take the spatula and help me serve these hungry orders!"
            ]
        case "Sushi Express":
            return [
                "Attention Level \(level)! A VIP food critic just sat down at table five!",
                "We are out of pre-sliced salmon and the rice cooker is overflowing!",
                "The order tickets are piling up and my sushi roll technique is falling apart!",
                "Grab your knife and step up to the station! We need perfect rolls right now!"
            ]
        default: // Pizzeria Bella
            return [
                "Mamma Mia! Level \(level) is a total disaster in the main dining room!",
                "The wood-fired oven is way too hot and the dough is expanding out of control!",
                "Ten tables just ordered custom pepperoni pizzas with double extra cheese!",
                "Hurry up! Help me stretch the dough and toss pizzas before everything burns!"
            ]
        }
    }
}

// MARK: - 3. SingleKitchenVC
final class SingleKitchenVC: UIViewController {
    
    private let viewModel: SingleKitchenViewModel
    private var currentActiveGameVC: BaseKitchenGameProtocol?
    
    // MARK: - UI Components
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let dimOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()
    
    // Top Bar
    private let topBarContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        return btn
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .black)
        label.textColor = .white
        return label
    }()
    
    private let levelBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .black
        label.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    // Comic Overlay View
    private let comicCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 12
        return view
    }()
    
    private let characterBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let speechBubbleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let pageIndicatorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .gray
        return label
    }()
    
    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("NEXT >", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    // Dynamic Game Content Host Container
    private let gameHostContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    // MARK: - Init
    init(viewModel: SingleKitchenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        viewModel.startLevelStory()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(backgroundImageView)
        view.addSubview(dimOverlayView)
        
        view.addSubview(topBarContainer)
        topBarContainer.addSubview(closeButton)
        topBarContainer.addSubview(titleLabel)
        topBarContainer.addSubview(levelBadgeLabel)
        
        view.addSubview(comicCardView)
        comicCardView.addSubview(characterBadgeLabel)
        comicCardView.addSubview(speechBubbleLabel)
        comicCardView.addSubview(pageIndicatorLabel)
        comicCardView.addSubview(nextButton)
        
        view.addSubview(gameHostContainerView)
        
        // SnapKit Constraints
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dimOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        topBarContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        closeButton.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(closeButton.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        levelBadgeLabel.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(28)
        }
        
        // Comic Card Positioning at Bottom
        comicCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.height.equalTo(210)
        }
        
        characterBadgeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.width.equalTo(120)
            make.height.equalTo(24)
        }
        
        speechBubbleLabel.snp.makeConstraints { make in
            make.top.equalTo(characterBadgeLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        pageIndicatorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(36)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(140)
            make.height.equalTo(40)
        }
        
        // Game Host Container Positioning
        gameHostContainerView.snp.makeConstraints { make in
            make.top.equalTo(topBarContainer.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        // Configure Initial Visuals
        titleLabel.text = viewModel.kitchen.title.uppercased()
        backgroundImageView.image = UIImage(named: viewModel.kitchen.imageName)
        characterBadgeLabel.backgroundColor = viewModel.kitchen.primaryColor
        nextButton.backgroundColor = viewModel.kitchen.primaryColor
        
        // Actions
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.onSlideUpdated = { [weak self] slide, pageText, isLast in
            guard let self = self else { return }
            self.removeCurrentGameChild()
            self.gameHostContainerView.isHidden = true
            self.comicCardView.isHidden = false
            
            self.characterBadgeLabel.text = slide.characterName.uppercased()
            self.speechBubbleLabel.text = "\"\(slide.speechBubbleText)\""
            self.pageIndicatorLabel.text = pageText
            
            let btnTitle = isLast ? "START GAME" : "NEXT >"
            self.nextButton.setTitle(btnTitle, for: .normal)
            
            self.levelBadgeLabel.text = "LEVEL \(self.viewModel.currentLevel.levelNumber)/100"
            self.levelBadgeLabel.isHidden = false
        }
        
        viewModel.onGameStarted = { [weak self] gameVC in
            guard let self = self else { return }
            self.comicCardView.isHidden = true
            self.gameHostContainerView.isHidden = false
            
            self.embedGameViewController(gameVC)
        }
        
        viewModel.onAllKitchenLevelsCompleted = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    // MARK: - Child Controller Handling
    private func embedGameViewController(_ gameVC: BaseKitchenGameProtocol) {
        removeCurrentGameChild()
        
        var mutGameVC = gameVC
        mutGameVC.onGameCompleted = { [weak self] in
            self?.viewModel.completeCurrentLevel()
        }
        
        addChild(gameVC)
        gameHostContainerView.addSubview(gameVC.view)
        gameVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        gameVC.didMove(toParent: self)
        
        currentActiveGameVC = gameVC
    }
    
    private func removeCurrentGameChild() {
        guard let child = currentActiveGameVC else { return }
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        currentActiveGameVC = nil
    }
    
    // MARK: - Actions
    @objc private func didTapNext() {
        viewModel.advanceSlide()
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

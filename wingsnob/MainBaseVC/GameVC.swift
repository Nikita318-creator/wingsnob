
import SnapKit
import PhotosUI

// MARK: - Models

struct Quest: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let imageName: String
    let targetCount: Int
    var currentCount: Int
    let rewardXP: Int
    var isCompleted: Bool
    var isClaimed: Bool
    var photoData: Data?
    var noteText: String?
    
    var progressText: String {
        "\(currentCount)/\(targetCount)"
    }
    
    var progress: Float {
        guard targetCount > 0 else { return 0 }
        return min(Float(currentCount) / Float(targetCount), 1.0)
    }
}

// MARK: - QuestManager

final class QuestManager {
    
    static let shared = QuestManager()
    private let key = "saved_quests_v2"
    private let xpKey = "user_total_xp_v2"
    
    private init() {}
    
    func loadQuests() -> [Quest] {
        if let data = UserDefaults.standard.data(forKey: key),
           let quests = try? JSONDecoder().decode([Quest].self, from: data) {
            return quests
        }
        return defaultQuests()
    }
    
    func saveQuests(_ quests: [Quest]) {
        if let data = try? JSONEncoder().encode(quests) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    var totalXP: Int {
        get { UserDefaults.standard.integer(forKey: xpKey) }
        set { UserDefaults.standard.set(newValue, forKey: xpKey) }
    }
    
    var level: Int {
        max(1, totalXP / 500 + 1)
    }
    
    private func defaultQuests() -> [Quest] {
        [
            Quest(id: "1",  title: "Tender Master",       description: "Try 3 different kinds of Chicken Tenders and capture your experience.",           imageName: "CHICKENTENDERS",     targetCount: 1, currentCount: 0, rewardXP: 150, isCompleted: false, isClaimed: false),
            Quest(id: "2",  title: "Wing Warrior",        description: "Try both Traditional and Boneless Wings and post a proof photo.",                imageName: "TRADITIONALWINGS",   targetCount: 1, currentCount: 0, rewardXP: 200, isCompleted: false, isClaimed: false),
            Quest(id: "3",  title: "Boneless Beast",      description: "Enjoy Boneless Wings and share your review.",                                    imageName: "BONELESSWINGS",      targetCount: 1, currentCount: 0, rewardXP: 180, isCompleted: false, isClaimed: false),
            Quest(id: "4",  title: "Cheese Lover",        description: "Try Cheese Fries, Mozzarella Sticks or Cheese Bites.",                            imageName: "CHEESEFRIES",        targetCount: 1, currentCount: 0, rewardXP: 220, isCompleted: false, isClaimed: false),
            Quest(id: "5",  title: "Mozzarella Madness",  description: "Eat Mozzarella Sticks and attach a photo.",                                      imageName: "MOZZARELLASTICKS",   targetCount: 1, currentCount: 0, rewardXP: 160, isCompleted: false, isClaimed: false),
            Quest(id: "6",  title: "Cheese Bites Hunt",   description: "Find and try Cheese Bites with your favorite sauce.",                            imageName: "CHEESEBITES",        targetCount: 1, currentCount: 0, rewardXP: 140, isCompleted: false, isClaimed: false),
            Quest(id: "7",  title: "Onion Ring Challenge",description: "Eat Onion Rings and submit a photo proof.",                                      imageName: "ONIONRINGS",         targetCount: 1, currentCount: 0, rewardXP: 120, isCompleted: false, isClaimed: false),
            Quest(id: "8",  title: "Sauce Explorer",      description: "Try 5 different dipping sauces and rate them.",                                  imageName: "DIPPINGSAUCES",      targetCount: 1, currentCount: 0, rewardXP: 200, isCompleted: false, isClaimed: false),
            Quest(id: "9",  title: "Buffalo King",        description: "Try Buffalo Chicken and share your thoughts.",                                   imageName: "BUFFALOCHICKEN",     targetCount: 1, currentCount: 0, rewardXP: 170, isCompleted: false, isClaimed: false),
            Quest(id: "10", title: "Lemonade Refresh",    description: "Drink Lemonade and capture the moment.",                                         imageName: "LEMONADE",           targetCount: 1, currentCount: 0, rewardXP: 100, isCompleted: false, isClaimed: false),
            Quest(id: "11", title: "Full Combo",          description: "Build a full combo: Tenders + Fries + Sauce + Drink.",                           imageName: "CHICKENTENDERS",    targetCount: 1, currentCount: 0, rewardXP: 300, isCompleted: false, isClaimed: false),
            Quest(id: "12", title: "Fries Addict",        description: "Order Cheese Fries and post your review.",                                       imageName: "CHEESEFRIES",        targetCount: 1, currentCount: 0, rewardXP: 190, isCompleted: false, isClaimed: false),
            Quest(id: "13", title: "Photo Hunter",        description: "Take a photo of any dish and attach a detailed note.",                           imageName: "CHICKENTENDERS",     targetCount: 1, currentCount: 0, rewardXP: 130, isCompleted: false, isClaimed: false),
            Quest(id: "14", title: "Weekend Warrior",     description: "Complete a delicious meal challenge during the weekend.",                        imageName: "BONELESSWINGS",      targetCount: 1, currentCount: 0, rewardXP: 250, isCompleted: false, isClaimed: false),
            Quest(id: "15", title: "All Wings",           description: "Try our signature wings and submit your entry.",                                 imageName: "TRADITIONALWINGS",   targetCount: 1, currentCount: 0, rewardXP: 210, isCompleted: false, isClaimed: false)
        ]
    }
}

// MARK: - QuestCell

final class QuestCell: UICollectionViewCell {
    
    static let reuseId = "QuestCell"
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor(white: 0.15, alpha: 1)
        iv.isUserInteractionEnabled = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 2
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let statusBadge: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let rewardLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemYellow
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = .gray
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()
    
    override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? 0.7 : 1.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor(white: 0.12, alpha: 1)
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
        contentView.isUserInteractionEnabled = true
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(statusBadge)
        contentView.addSubview(rewardLabel)
        contentView.addSubview(chevronImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(64)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(14)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        rewardLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        statusBadge.snp.makeConstraints { make in
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            make.centerY.equalTo(rewardLabel)
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(70)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with quest: Quest) {
        iconImageView.image = UIImage(named: quest.imageName)
        titleLabel.text = quest.title
        descriptionLabel.text = quest.description
        rewardLabel.text = "+\(quest.rewardXP) XP"
        
        if quest.isClaimed {
            statusBadge.text = " Completed "
            statusBadge.textColor = .lightGray
            statusBadge.backgroundColor = UIColor(white: 0.2, alpha: 1)
        } else if quest.isCompleted {
            statusBadge.text = " Claim XP "
            statusBadge.textColor = .black
            statusBadge.backgroundColor = .systemOrange
        } else {
            statusBadge.text = " In Progress "
            statusBadge.textColor = .systemOrange
            statusBadge.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
        }
    }
}

// MARK: - GameVC

final class GameVC: UIViewController {
    
    private let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.1, alpha: 1)
        return v
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let xpLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let xpProgress: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.trackTintColor = UIColor(white: 0.25, alpha: 1)
        pv.progressTintColor = .systemOrange
        pv.layer.cornerRadius = 3
        pv.clipsToBounds = true
        return pv
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 30, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.register(QuestCell.self, forCellWithReuseIdentifier: QuestCell.reuseId)
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    private var quests: [Quest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Quests"
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(levelLabel)
        headerView.addSubview(xpLabel)
        headerView.addSubview(xpProgress)
        view.addSubview(collectionView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }
        
        levelLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(16)
        }
        
        xpLabel.snp.makeConstraints { make in
            make.leading.equalTo(levelLabel)
            make.top.equalTo(levelLabel.snp.bottom).offset(4)
        }
        
        xpProgress.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(6)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func loadData() {
        quests = QuestManager.shared.loadQuests()
        updateHeader()
        collectionView.reloadData()
    }
    
    private func updateHeader() {
        let manager = QuestManager.shared
        levelLabel.text = "Level \(manager.level)"
        let currentLevelXP = manager.totalXP % 500
        xpLabel.text = "\(manager.totalXP) XP  •  \(currentLevelXP)/500 to next level"
        xpProgress.progress = Float(currentLevelXP) / 500.0
    }
}

extension GameVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        quests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuestCell.reuseId, for: indexPath) as! QuestCell
        cell.configure(with: quests[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width - 32, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let quest = quests[indexPath.item]
        let detailVC = QuestDetailVC(quest: quest) { [weak self] updatedQuest in
            self?.quests[indexPath.item] = updatedQuest
            QuestManager.shared.saveQuests(self?.quests ?? [])
            self?.loadData()
        }
        
        if let nav = navigationController {
            nav.pushViewController(detailVC, animated: true)
        } else {
            present(detailVC, animated: true)
        }
    }
}

// MARK: - QuestDetailVC

final class QuestDetailVC: UIViewController {
    
    private var quest: Quest
    private var onUpdate: (Quest) -> Void
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(white: 0.6, alpha: 1)
        return btn
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.backgroundColor = UIColor(white: 0.15, alpha: 1)
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let rewardBadge: UILabel = {
        let label = UILabel()
        label.textColor = .systemYellow
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private let proofContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.12, alpha: 1)
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
        return v
    }()
    
    private let proofTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Submission Proof"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let proofImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor(white: 0.2, alpha: 1)
        return iv
    }()
    
    private let proofNoteLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 14
        return btn
    }()
    
    init(quest: Quest, onUpdate: @escaping (Quest) -> Void) {
        self.quest = quest
        self.onUpdate = onUpdate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Task Details"
        
        setupUI()
        renderQuest()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(closeButton)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(rewardBadge)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(proofContainerView)
        contentView.addSubview(actionButton)
        
        proofContainerView.addSubview(proofTitleLabel)
        proofContainerView.addSubview(proofImageView)
        proofContainerView.addSubview(proofNoteLabel)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(32)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        rewardBadge.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(rewardBadge.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        proofContainerView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        proofTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(14)
        }
        
        proofImageView.snp.makeConstraints { make in
            make.top.equalTo(proofTitleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(14)
            make.size.equalTo(80)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        proofNoteLabel.snp.makeConstraints { make in
            make.top.equalTo(proofImageView)
            make.leading.equalTo(proofImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.lessThanOrEqualToSuperview().offset(-14)
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(proofContainerView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }
    
    @objc private func closeTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    private func renderQuest() {
        imageView.image = UIImage(named: quest.imageName)
        titleLabel.text = quest.title
        rewardBadge.text = "Reward: +\(quest.rewardXP) XP"
        descriptionLabel.text = quest.description
        
        if let photoData = quest.photoData, let image = UIImage(data: photoData) {
            proofContainerView.isHidden = false
            proofImageView.image = image
            proofNoteLabel.text = quest.noteText ?? "No commentary attached."
        } else {
            proofContainerView.isHidden = true
        }
        
        if quest.isClaimed {
            actionButton.setTitle("Task Completed", for: .normal)
            actionButton.backgroundColor = UIColor(white: 0.2, alpha: 1)
            actionButton.setTitleColor(.gray, for: .normal)
            actionButton.isEnabled = false
        } else if quest.isCompleted {
            actionButton.setTitle("Claim Reward (+\(quest.rewardXP) XP)", for: .normal)
            actionButton.backgroundColor = .systemOrange
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.isEnabled = true
        } else {
            actionButton.setTitle("Submit Proof & Complete", for: .normal)
            actionButton.backgroundColor = .systemOrange
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.isEnabled = true
        }
    }
    
    @objc private func actionTapped() {
        if quest.isClaimed { return }
        
        if quest.isCompleted {
            quest.isClaimed = true
            QuestManager.shared.totalXP += quest.rewardXP
            onUpdate(quest)
            renderQuest()
            
            let alert = UIAlertController(title: "Congratulations!", message: "You received +\(quest.rewardXP) XP", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Awesome", style: .default, handler: { [weak self] _ in
                self?.closeTapped()
            }))
            present(alert, animated: true)
        } else {
            let submissionVC = QuestSubmissionVC(quest: quest) { [weak self] photoData, noteText in
                guard let self = self else { return }
                self.quest.photoData = photoData
                self.quest.noteText = noteText
                self.quest.currentCount = self.quest.targetCount
                self.quest.isCompleted = true
                self.onUpdate(self.quest)
                self.renderQuest()
            }
            present(submissionVC, animated: true)
        }
    }
}

// MARK: - QuestSubmissionVC

final class QuestSubmissionVC: UIViewController {
    
    private var quest: Quest
    private var completion: (Data, String) -> Void
    private var selectedImageData: Data?
    
    private let placeholderNote = "Write a short comment on how you completed this task..."
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(white: 0.6, alpha: 1)
        return btn
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Proof of Completion"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 14
        iv.backgroundColor = UIColor(white: 0.15, alpha: 1)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to attach photo proof"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private lazy var noteTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tv.textColor = .lightGray
        tv.text = placeholderNote
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.layer.cornerRadius = 12
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        return tv
    }()
    
    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit Task", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.backgroundColor = .systemOrange
        btn.layer.cornerRadius = 14
        btn.alpha = 0.5
        btn.isEnabled = false
        return btn
    }()
    
    init(quest: Quest, completion: @escaping (Data, String) -> Void) {
        self.quest = quest
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        
        setupUI()
        setupKeyboardObservers()
        setupDismissKeyboardGesture()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
        contentView.addSubview(photoImageView)
        photoImageView.addSubview(placeholderLabel)
        contentView.addSubview(noteTextView)
        contentView.addSubview(submitButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(30)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(180)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        noteTextView.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(120)
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(noteTextView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectPhoto))
        photoImageView.addGestureRecognizer(tap)
        
        closeButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        noteTextView.delegate = self
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
        let rect = noteTextView.convert(noteTextView.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func selectPhoto() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func submitTapped() {
        guard let data = selectedImageData,
              let text = noteTextView.text,
              text != placeholderNote,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        dismiss(animated: true) { [weak self] in
            self?.completion(data, text)
        }
    }
    
    private func validateForm() {
        let hasValidNote = noteTextView.text != placeholderNote && !(noteTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasPhoto = selectedImageData != nil
        
        let isValid = hasValidNote && hasPhoto
        submitButton.isEnabled = isValid
        submitButton.alpha = isValid ? 1.0 : 0.5
    }
}

extension QuestSubmissionVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderNote {
            textView.text = ""
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholderNote
            textView.textColor = .lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        validateForm()
    }
}

extension QuestSubmissionVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self = self,
                  let image = object as? UIImage,
                  let data = image.jpegData(compressionQuality: 0.7) else { return }
            
            DispatchQueue.main.async {
                self.selectedImageData = data
                self.photoImageView.image = image
                self.placeholderLabel.isHidden = true
                self.validateForm()
            }
        }
    }
}

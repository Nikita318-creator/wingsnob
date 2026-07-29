
import UIKit
import SnapKit

class FAQViewController: BaseStubViewController {
    
    private var faqItems = [
        FAQItem(question: "How do I place an order?",
                answer: "You can easily place an order right here in our app! Just browse the menu, select your favorite wings and sauces, choose pickup or delivery, and complete your checkout seamlessly."),
        FAQItem(question: "Do you offer pickup and delivery?",
                answer: "Yes, we offer both fast delivery options and convenient in-store pickup. Select your preference at the top of the menu screen before building your perfect basket."),
        FAQItem(question: "Where can I find a Wing Snob?",
                answer: "Check our Locations tab! We have multiple stores across Illinois, Michigan, and Wisconsin, and we are constantly expanding to bring our fresh wings closer to you."),
        FAQItem(question: "What makes your wings different?",
                answer: "We only serve premium, fresh, never-frozen chicken. Every single wing is tossed in our signature, chef-crafted sauces exactly the way you want it. No shortcuts, just pure flavor."),
        FAQItem(question: "Do you have vegetarian options?",
                answer: "Absolutely! We offer delicious plant-based cauliflower wings and premium sides so that everyone can enjoy the authentic Wing Snob flavor experience."),
        FAQItem(question: "How spicy are your sauces?",
                answer: "Our sauces range from mild and sweet to extremely hot! Check the heat meter next to each sauce name on the menu to find your perfect spice level match."),
        FAQItem(question: "Do you cater large orders?",
                answer: "Yes, we love parties! We offer custom catering packages featuring massive wing platters, perfect for game days, corporate events, and big family celebrations.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cv = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            cv.register(FAQCollectionViewCell.self, forCellWithReuseIdentifier: "FAQCollectionViewCell")
            cv.register(FAQHeaderView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: "FAQHeaderView")
        }
    }
    
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return faqItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FAQCollectionViewCell", for: indexPath) as! FAQCollectionViewCell
        cell.configure(with: faqItems[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FAQHeaderView", for: indexPath)
            return header
        }
        return UICollectionReusableView()
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Переключаем состояние конкретной ячейки
        faqItems[indexPath.item].isExpanded.toggle()
        
        // Красиво и анимированно пересчитываем высоту контента
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: [indexPath])
        }, completion: nil)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        let item = faqItems[indexPath.item]
        
        if item.isExpanded {
            // Динамический расчёт высоты раскрытой ячейки на основе длины текста
            let approxTextWidth = width - 32
            let questionSize = CGSize(width: approxTextWidth, height: .greatestFiniteMagnitude)
            let answerSize = CGSize(width: approxTextWidth, height: .greatestFiniteMagnitude)
            
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: .bold)]
            let answerAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]
            
            let estimatedQuestionHeight = item.question.boundingRect(with: questionSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).height
            let estimatedAnswerHeight = item.answer.boundingRect(with: answerSize, options: .usesLineFragmentOrigin, attributes: answerAttributes, context: nil).height
            
            // Вся высота = отступы (20 + 12 + 20) + высота текста вопроса + высота ответа
            return CGSize(width: width, height: estimatedQuestionHeight + estimatedAnswerHeight + 52)
        } else {
            // Фиксированная высота в закрытом состоянии
            return CGSize(width: width, height: 64)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 110)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

// Модель для раскрывающихся ячеек
struct FAQItem {
    let question: String
    let answer: String
    var isExpanded: Bool = false
}

class FAQHeaderView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "FAQ"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 32, weight: .black)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Everything you need to know before you order."
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

class FAQCollectionViewCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.down"))
        iv.tintColor = .lightGray
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let answerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.addSubview(questionLabel)
        containerView.addSubview(arrowImageView)
        containerView.addSubview(answerLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(18)
        }
        
        questionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-16)
        }
        
        answerLabel.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with item: FAQItem) {
        questionLabel.text = item.question
        answerLabel.text = item.answer
        
        // Переключаем видимость текста ответа и поворот стрелки в зависимости от состояния
        answerLabel.isHidden = !item.isExpanded
        
        if item.isExpanded {
            arrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
            arrowImageView.tintColor = .systemRed
        } else {
            arrowImageView.transform = .identity
            arrowImageView.tintColor = .lightGray
        }
    }
}

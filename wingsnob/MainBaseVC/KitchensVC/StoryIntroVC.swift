import UIKit
import SnapKit

struct IntroSlideModel {
    let title: String
    let text: String
    let imageName: String
    let isFoodIcon: Bool
    let accentColor: UIColor
}

final class StoryIntroVC: UIViewController {
    
    // MARK: - Slide Models (26 Slides)
    private let slides: [IntroSlideModel] = [
        // PART 1: The Legend Begins
        IntroSlideModel(
            title: "THE CULINARY KINGDOM",
            text: "Once upon a time, Culinary City was the most famous food capital in the world, renowned for its legendary flavors.",
            imageName: "kitchen1", isFoodIcon: false,
            accentColor: UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "THREE SACRED PILLARS",
            text: "The city's reputation rested on three master kitchens, each specializing in a unique masterpiece of comfort food.",
            imageName: "food1", isFoodIcon: true,
            accentColor: UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "BURGER HUB",
            text: "First was Burger Hub — famous for smoking smash burgers, crispy golden fries, and ice-cold sodas.",
            imageName: "kitchen1", isFoodIcon: false,
            accentColor: UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "SUSHI EXPRESS",
            text: "Second was Sushi Express — a peaceful sanctuary where master chefs sliced fresh sashimi with absolute precision.",
            imageName: "kitchen2", isFoodIcon: false,
            accentColor: UIColor(red: 0.18, green: 0.65, blue: 0.55, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "PIZZERIA BELLA",
            text: "And third was Pizzeria Bella — home to wood-fired ovens, stretching dough, and secret heirloom sauce recipes.",
            imageName: "kitchen3", isFoodIcon: false,
            accentColor: UIColor(red: 0.88, green: 0.28, blue: 0.28, alpha: 1.0)
        ),
        
        // PART 2: The Golden Era
        IntroSlideModel(
            title: "THE MASTER CHEFS",
            text: "Chef Marco, Master Kenji, and Mama Rosa ran these kitchens in perfect harmony for over twenty years.",
            imageName: "food2", isFoodIcon: true,
            accentColor: UIColor(red: 0.95, green: 0.60, blue: 0.10, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "PERFECT INGREDIENTS",
            text: "Every morning, trucks delivered prime beef, fresh ocean salmon, and ripe vine tomatoes to the city docks.",
            imageName: "food3", isFoodIcon: true,
            accentColor: UIColor(red: 0.18, green: 0.65, blue: 0.55, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "HAPPY CUSTOMERS",
            text: "Lines of hungry tourists stretched around the block from dawn until late at night.",
            imageName: "kitchen1", isFoodIcon: false,
            accentColor: UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "SECRET RECIPES",
            text: "Each kitchen kept a hand-written recipe book locked inside an ancient iron safe.",
            imageName: "food4", isFoodIcon: true,
            accentColor: UIColor(red: 0.88, green: 0.28, blue: 0.28, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "A GROWING EMPIRE",
            text: "Food critics awarded all three restaurants top honors five years in a row!",
            imageName: "kitchen2", isFoodIcon: false,
            accentColor: UIColor(red: 0.18, green: 0.65, blue: 0.55, alpha: 1.0)
        ),

        // PART 3: The Crisis Strikes
        IntroSlideModel(
            title: "THE GREAT RUSH HOUR",
            text: "Then came the day of the International Food Festival. Thousands of visitors flooded the city at once!",
            imageName: "kitchen3", isFoodIcon: false,
            accentColor: UIColor(red: 0.88, green: 0.28, blue: 0.28, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "CHAOS IN THE KITCHEN",
            text: "Order tickets began printing without stopping. The machines overheated and spat paper everywhere!",
            imageName: "food5", isFoodIcon: true,
            accentColor: UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "MARCO'S BURNOUT",
            text: "Chef Marco slipped on grease, dropped his spatulas, and burnt three dozen patties at once!",
            imageName: "kitchen1", isFoodIcon: false,
            accentColor: UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "KENJI'S MISTAKE",
            text: "Master Kenji's sharp knives got dull, his rice overflowed, and raw fish was left out in the heat!",
            imageName: "kitchen2", isFoodIcon: false,
            accentColor: UIColor(red: 0.18, green: 0.65, blue: 0.55, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "ROSA'S OVERFLOW",
            text: "Mama Rosa's wood-fired oven caught fire, filled the dining room with smoke, and ruined the pizza dough!",
            imageName: "kitchen3", isFoodIcon: false,
            accentColor: UIColor(red: 0.88, green: 0.28, blue: 0.28, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "TOTAL DISASTER",
            text: "The three masters realized they were too old and exhausted to handle modern rush hours alone.",
            imageName: "food6", isFoodIcon: true,
            accentColor: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        ),

        // PART 4: The Search for a Hero
        IntroSlideModel(
            title: "A CALL FOR HELP",
            text: "They put up a giant poster in the main square: 'HEAD CHEF NEEDED URGENTLY TO SAVE OUR KITCHENS!'",
            imageName: "kitchen1", isFoodIcon: false,
            accentColor: UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "APPLICANTS FAILED",
            text: "Dozens of amateur cooks tried their hand, but they panicked under pressure and quit after 5 minutes.",
            imageName: "food1", isFoodIcon: true,
            accentColor: UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "REPUTATION AT RISK",
            text: "If the kitchens fail to serve orders today, Culinary City will be shut down forever!",
            imageName: "kitchen2", isFoodIcon: false,
            accentColor: UIColor(red: 0.18, green: 0.65, blue: 0.55, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "A CHANCE ARRIVAL",
            text: "Just as hope was fading, a talented young chef stepped off the train with a knife roll and ambition...",
            imageName: "food2", isFoodIcon: true,
            accentColor: UIColor(red: 0.95, green: 0.60, blue: 0.10, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "THAT HERO IS YOU!",
            text: "Yes, YOU! You are the legendary prodigy everyone has been waiting for!",
            imageName: "kitchen3", isFoodIcon: false,
            accentColor: UIColor(red: 0.88, green: 0.28, blue: 0.28, alpha: 1.0)
        ),

        // PART 5: The Mission
        IntroSlideModel(
            title: "YOUR FIRST SHIFT",
            text: "You must take control of all three kitchens, master their unique mini-games, and restore order.",
            imageName: "food3", isFoodIcon: true,
            accentColor: UIColor(red: 0.18, green: 0.65, blue: 0.55, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "DODGE & CATCH",
            text: "Catch fresh ingredients on the fly, dodge burning pans, and flip burgers with lightning speed!",
            imageName: "food4", isFoodIcon: true,
            accentColor: UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "BEAT THE TIMER",
            text: "Complete 10 challenging shifts for each kitchen to prove your mastery.",
            imageName: "food5", isFoodIcon: true,
            accentColor: UIColor(red: 0.88, green: 0.28, blue: 0.28, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "MASTERS ARE WATCHING",
            text: "Marco, Kenji, and Rosa are counting on you. Don't let their lifetime legacy crumble!",
            imageName: "food6", isFoodIcon: true,
            accentColor: UIColor(red: 0.95, green: 0.60, blue: 0.10, alpha: 1.0)
        ),
        IntroSlideModel(
            title: "READY FOR ACTION",
            text: "Put on your chef's hat, step into the kitchen, and start your shift right now!",
            imageName: "kitchen1", isFoodIcon: false,
            accentColor: UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        )
    ]
    
    private var currentIndex = 0
    var onIntroFinished: (() -> Void)?
    
    // MARK: - UI Components
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let dimOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    private let floatingIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 36
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 8
        view.isHidden = true
        return view
    }()
    
    private let floatingImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private let comicCardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 28
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.35
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 14
        return view
    }()
    
    private let titleBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .black)
        label.textColor = .white
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let speechBubbleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1.0)
        label.numberOfLines = 0
        return label
    }()
    
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .black)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 6
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateSlide(animated: false)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(backgroundImageView)
        view.addSubview(dimOverlayView)
        
        view.addSubview(comicCardContainer)
        comicCardContainer.addSubview(titleBadgeLabel)
        comicCardContainer.addSubview(speechBubbleLabel)
        comicCardContainer.addSubview(actionButton)
        
        view.addSubview(floatingIconContainer)
        floatingIconContainer.addSubview(floatingImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dimOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        comicCardContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
            make.height.equalTo(230)
        }
        
        floatingIconContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(comicCardContainer.snp.top)
            make.width.height.equalTo(72)
        }
        
        floatingImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        titleBadgeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        speechBubbleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleBadgeLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        actionButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        actionButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
    }
    
    // MARK: - Slide Logic
    private func updateSlide(animated: Bool = true) {
        let slide = slides[currentIndex]
        
        let updateContent = {
            self.titleBadgeLabel.text = "  \(slide.title.uppercased())  "
            self.titleBadgeLabel.backgroundColor = slide.accentColor
            self.speechBubbleLabel.text = slide.text
            self.actionButton.backgroundColor = slide.accentColor
            self.actionButton.layer.shadowColor = slide.accentColor.cgColor
            
            let isLast = (self.currentIndex == self.slides.count - 1)
            self.actionButton.setTitle(isLast ? "LET'S AGAIN" : "NEXT", for: .normal)
            
            if slide.isFoodIcon {
                self.floatingIconContainer.isHidden = false
                self.floatingImageView.image = UIImage(named: slide.imageName)
                
                self.titleBadgeLabel.snp.updateConstraints { make in
                    make.top.equalToSuperview().offset(42)
                }
            } else {
                self.floatingIconContainer.isHidden = true
                self.backgroundImageView.image = UIImage(named: slide.imageName)
                
                self.titleBadgeLabel.snp.updateConstraints { make in
                    make.top.equalToSuperview().offset(20)
                }
            }
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.15, animations: {
                self.comicCardContainer.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                if slide.isFoodIcon {
                    self.floatingIconContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            }) { _ in
                updateContent()
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                    self.comicCardContainer.transform = .identity
                    self.floatingIconContainer.transform = .identity
                })
            }
        } else {
            updateContent()
        }
    }
    
    @objc private func didTapAction() {
        if currentIndex < slides.count - 1 {
            currentIndex += 1
            updateSlide(animated: true)
        } else {
            // Перезапуск комиссии с 1-го слайда
            currentIndex = 0
            updateSlide(animated: true)
        }
    }
}

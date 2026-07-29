
import UIKit
import SnapKit

class BaseStubViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Закрепленный кастомный хедер сверху (без учета Safe Area)
    private let topHeaderView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "main_header")
        iv.contentMode = .scaleAspectFill // Или .scaleAspectFit, в зависимости от того, как нарезана картинка
        iv.clipsToBounds = true
        return iv
    }()
    
    // Коллекшн вью для контента
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.bounces = false
        cv.dataSource = self
        cv.delegate = self
        // Регистрируем дефолтную ячейку для заглушки
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    // Красная кнопка снизу "START ORDER →"
    private let startOrderButton: UIButton = {
        let button = UIButton(type: .system)
        
        // Настройка текста со стрелочкой
        let title = "START ORDER  →"
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .black) // Жирный шрифт как на скрине
        button.setTitleColor(.white, for: .normal)
        
        // Визуал кнопки
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 12
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // Общий фон экрана
        
        setupSubviews()
        setupConstraints()
    }
    
    private func setupSubviews() {
        view.addSubview(collectionView)
        view.addSubview(topHeaderView) // Добавляем поверх коллекции, либо коллекцию крепим снизу
        view.addSubview(startOrderButton)
        
        startOrderButton.addTarget(self, action: #selector(startOrderTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        // Закрепленная плашка в самом топе экрана (игнорируем safeArea, идем в упор к экрану)
        topHeaderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            // Высоту регулируй по макету. Обычно с учетом статус-бара ставят в районе 90-110 поинтов, либо делай динамическую под картинку
            make.height.equalTo(100)
        }
        
        // Кнопка прибита к низу над таббаром
        startOrderButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.height.equalTo(55)
        }
        
        // Коллекция теперь начинается ровно ПОД закрепленным хедером и идет до кнопки
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(startOrderButton.snp.top).offset(-12)
        }
    }
    
    @objc private func startOrderTapped() {
        print("Start Order tapped from \(String(describing: self))")
        
        guard let url = URL(string: TestAB.shared.configVersion) else { return }
        
        let vc = OrderViewController(url: url)
        // Открываем модально на весь экран поверх текущего
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 // Пока просто 10 пустых ячеек для демонстрации скролла
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor(white: 0.15, alpha: 1.0) // Серые карточки-заглушки
        cell.layer.cornerRadius = 8
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

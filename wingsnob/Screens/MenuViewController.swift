//
//  MenuViewController.swift
//  wingsnob
//
//  Created by Mikita on 19/07/2026.
//

import UIKit
import SnapKit

import UIKit
import SnapKit

class MenuViewController: BaseStubViewController {
    
    // Структура данных для меню
    private let menuItems = [
        (title: "TRADITIONAL WINGS", desc: "Classic bone-in wings tossed in your favorite sauce.", image: "TRADITIONALWINGS"),
        (title: "BONELESS WINGS", desc: "All-white-meat, hand-breaded boneless wings.", image: "BONELESSWINGS"),
        (title: "CHICKEN TENDERS", desc: "Crispy, juicy all-white-meat tenders.", image: "CHICKENTENDERS"),
        (title: "WING SNOB SAMPLER", desc: "A mix of traditional and boneless wings with fries.", image: "TRADITIONALWINGS"),
        (title: "FRESH CUT FRIES", desc: "Crispy fries seasoned to perfection.", image: "BONELESSWINGS"),
        (title: "SWEET POTATO FRIES", desc: "Golden sweet potato fries with a touch of salt.", image: "CHICKENTENDERS"),
        (title: "ONION RINGS", desc: "Thick-cut, beer-battered onion rings.", image: "TRADITIONALWINGS")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Регистрируем ячейку и хедер на коллекции базового класса
        if let cv = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            cv.register(MenuItemCell.self, forCellWithReuseIdentifier: "MenuItemCell")
            cv.register(MenuHeaderView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: "MenuHeaderView")
        }
    }
    
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell
        let item = menuItems[indexPath.item]
        cell.configure(title: item.title, description: item.desc, imageName: item.image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MenuHeaderView", for: indexPath)
            return header
        }
        return UICollectionReusableView()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32 // Отступы слева и справа по 16
        return CGSize(width: width, height: 130)    // Фиксированная высота карточки
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 110) // Размеры под текст хедера
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
    }
    
    // Расстояние между карточками меню
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

class MenuHeaderView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "THE MENU"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 32, weight: .black) // Крупный шрифт
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Fresh, never-frozen chicken — your way."
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

class MenuItemCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.12, alpha: 1.0) // Темно-серый фон карточки
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let itemImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .darkGray // Заглушка, если нет картинки
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .black)
        label.numberOfLines = 2
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.numberOfLines = 3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.addSubview(itemImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Картинка занимает левую часть карточки (квадратная)
        itemImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(containerView.snp.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(itemImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.bottom.lessThanOrEqualTo(containerView.snp.bottom).offset(-16)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, description: String, imageName: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        itemImageView.image = UIImage(named: imageName)
    }
}

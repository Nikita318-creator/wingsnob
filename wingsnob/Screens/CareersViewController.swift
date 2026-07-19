//
//  CareersViewController.swift
//  wingsnob
//
//  Created by Mikita on 19/07/2026.
//

import UIKit
import SnapKit

class CareersViewController: BaseStubViewController {
    
    enum CareersSection: Int, CaseIterable {
        case topInfo
        case vacancies
    }
    
    private let vacancies = [
        (title: "CREW MEMBER", desc: "The face of the Snob. Greet guests, build orders and keep the energy high."),
        (title: "LINE COOK", desc: "Bring the heat. Fry, sauce and plate up the wings our fans crave."),
        (title: "SHIFT LEAD", desc: "Run the floor, coach the crew and keep service fast and friendly."),
        (title: "GENERAL MANAGER", desc: "Own the store. Lead the team, hit the numbers and grow the brand.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cv = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
            cv.register(CareersTopInfoCell.self, forCellWithReuseIdentifier: "CareersTopInfoCell")
            cv.register(JobVacancyCell.self, forCellWithReuseIdentifier: "JobVacancyCell")
            cv.register(CareersHeaderView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: "CareersHeaderView")
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return CareersSection.allCases.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let careersSection = CareersSection(rawValue: section) else { return 0 }
        switch careersSection {
        case .topInfo: return 1
        case .vacancies: return vacancies.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let careersSection = CareersSection(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch careersSection {
        case .topInfo:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareersTopInfoCell", for: indexPath)
            return cell
        case .vacancies:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JobVacancyCell", for: indexPath) as! JobVacancyCell
            let data = vacancies[indexPath.item]
            cell.configure(title: data.title, desc: data.desc)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader && indexPath.section == CareersSection.vacancies.rawValue {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CareersHeaderView", for: indexPath)
            return header
        }
        return UICollectionReusableView()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let careersSection = CareersSection(rawValue: indexPath.section) else { return .zero }
        let width = collectionView.bounds.width
        
        switch careersSection {
        case .topInfo:
            let text = "We are growing fast and looking for people who love great food and great vibes. Build your career with one of the fastest-growing wing brands around."
            let availableWidth = width - 32 - 40 // Минус внешние и внутренние отступы
            
            let titleHeight = "JOIN THE\nSNOB SQUAD".boundingRect(
                with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .black)],
                context: nil
            ).height
            
            let descHeight = text.boundingRect(
                with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium)],
                context: nil
            ).height
            
            return CGSize(width: width, height: titleHeight + descHeight + 16 + 24 + 24 + 16 + 10)
            
        case .vacancies:
            let data = vacancies[indexPath.item]
            let cellWidth = width - 32
            let labelWidth = cellWidth - 16 - 24 - 12 - 16 // Доступная ширина для текста с учетом иконки
            
            let descHeight = data.desc.boundingRect(
                with: CGSize(width: labelWidth, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)],
                context: nil
            ).height
            
            // 20 (top) + 24 (icon/title height) + 8 (offset) + descHeight + 20 (bottom)
            return CGSize(width: cellWidth, height: 20 + 24 + 8 + descHeight + 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == CareersSection.vacancies.rawValue {
            return CGSize(width: collectionView.bounds.width, height: 60)
        }
        return .zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

// MARK: - Top Info Cell
class CareersTopInfoCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "JOIN THE\nSNOB SQUAD"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 32, weight: .black)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "We are growing fast and looking for people who love great food and great vibes. Build your career with one of the fastest-growing wing brands around."
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Job Vacancy Cell
class JobVacancyCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "vcard.fill") ?? UIImage(systemName: "person.badge.key.fill")
        iv.tintColor = .systemRed
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let jobTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .black)
        label.numberOfLines = 0
        return label
    }()
    
    private let jobDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(jobTitleLabel)
        containerView.addSubview(jobDescriptionLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(24)
        }
        
        jobTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView.snp.centerY)
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        jobDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(jobTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(iconImageView.snp.trailing).offset(12) // Позиционируем ровно под тайтлом от иконки
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, desc: String) {
        jobTitleLabel.text = title
        jobDescriptionLabel.text = desc
    }
}

// MARK: - Header View
class CareersHeaderView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "OPEN ROLES"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 26, weight: .black)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 16, bottom: 8, right: 16))
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

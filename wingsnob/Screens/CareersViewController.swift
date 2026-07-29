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
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = CareersSection(rawValue: indexPath.section), section == .vacancies else { return }
        
        let selectedJob = vacancies[indexPath.item].title
        let applicationVC = JobApplicationViewController(jobTitle: selectedJob)
        let navController = UINavigationController(rootViewController: applicationVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
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
            let availableWidth = width - 32 - 40
            
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
            let labelWidth = cellWidth - 16 - 24 - 12 - 16
            
            let descHeight = data.desc.boundingRect(
                with: CGSize(width: labelWidth, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium)],
                context: nil
            ).height
            
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

class JobApplicationViewController: UIViewController {
    
    private let jobTitle: String
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    
    private let firstNameField = createTextField(placeholder: "First Name *")
    private let lastNameField = createTextField(placeholder: "Last Name *")
    private let emailField = createTextField(placeholder: "Email Address *", keyboardType: .emailAddress)
    private let phoneField = createTextField(placeholder: "Phone Number *", keyboardType: .phonePad)
    private let locationField = createTextField(placeholder: "Preferred Location * (e.g. Marengo, IL)")
    private let experienceField = createTextField(placeholder: "Years of Experience *", keyboardType: .numberPad)
    
    private let aboutTextView = createTextView(placeholder: "Tell us about yourself and past experience... *")
    private let fitTextView = createTextView(placeholder: "Why do you think you're a good fit for Wing Snob? *")
    
    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("SUBMIT APPLICATION", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .black)
        btn.backgroundColor = .systemRed
        btn.layer.cornerRadius = 14
        return btn
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(jobTitle: String) {
        self.jobTitle = jobTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        setupNavbar()
        setupUI()
        setupKeyboardObservers()
        setupTapToDismiss()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavbar() {
        title = "Apply for Position"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        navigationController?.navigationBar.tintColor = .systemRed
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        titleLabel.text = "APPLYING FOR:\n\(jobTitle.uppercased())"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 22, weight: .black)
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        let fieldsStack = UIStackView(arrangedSubviews: [
            firstNameField,
            lastNameField,
            emailField,
            phoneField,
            locationField,
            experienceField,
            createLabel(text: "APPLICANT BIO *"),
            aboutTextView,
            createLabel(text: "WHY WING SNOB? *"),
            fitTextView
        ])
        
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 14
        
        contentView.addSubview(fieldsStack)
        fieldsStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        aboutTextView.snp.makeConstraints { make in make.height.equalTo(90) }
        fitTextView.snp.makeConstraints { make in make.height.equalTo(90) }
        
        contentView.addSubview(submitButton)
        submitButton.addSubview(activityIndicator)
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(fieldsStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }
    
    // MARK: - Validation Logic
    private func validateForm() -> (isValid: Bool, errorMessage: String?) {
        resetFieldBorders()
        
        var invalidViews: [UIView] = []
        var errorMessage: String? = nil
        
        let firstName = firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lastName = lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let location = locationField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let experience = experienceField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let about = aboutTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let fit = fitTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if firstName.isEmpty { invalidViews.append(firstNameField) }
        if lastName.isEmpty { invalidViews.append(lastNameField) }
        if location.isEmpty { invalidViews.append(locationField) }
        if experience.isEmpty { invalidViews.append(experienceField) }
        if about.isEmpty { invalidViews.append(aboutTextView) }
        if fit.isEmpty { invalidViews.append(fitTextView) }
        
        if !isValidEmail(email) {
            invalidViews.append(emailField)
            if errorMessage == nil { errorMessage = "Please enter a valid email address." }
        }
        
        if phone.count < 7 {
            invalidViews.append(phoneField)
            if errorMessage == nil { errorMessage = "Please enter a valid phone number." }
        }
        
        if !invalidViews.isEmpty {
            highlightInvalidViews(invalidViews)
            return (false, errorMessage ?? "Please fill in all required fields.")
        }
        
        return (true, nil)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func resetFieldBorders() {
        let allViews: [UIView] = [
            firstNameField, lastNameField, emailField, phoneField,
            locationField, experienceField, aboutTextView, fitTextView
        ]
        allViews.forEach {
            $0.layer.borderWidth = 0
            $0.layer.borderColor = nil
        }
    }
    
    private func highlightInvalidViews(_ views: [UIView]) {
        views.forEach { v in
            v.layer.borderWidth = 1.5
            v.layer.borderColor = UIColor.systemRed.cgColor
            v.shake()
        }
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setupTapToDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let bottomPadding = keyboardFrame.height - view.safeAreaInsets.bottom
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func submitTapped() {
        view.endEditing(true)
        
        let validation = validateForm()
        guard validation.isValid else {
            let alert = UIAlertController(
                title: "Incomplete Application",
                message: validation.errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        submitButton.isEnabled = false
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.submitButton.isEnabled = true
            
            let alert = UIAlertController(
                title: "Application Sent!",
                message: "Thank you for applying. We have received your submission and will review your qualifications. If your experience matches our requirements, our hiring manager will reach out to you.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismiss(animated: true)
            }))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Factory Helpers
    private static func createTextField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 15)
        tf.keyboardType = keyboardType
        tf.backgroundColor = UIColor(white: 0.18, alpha: 1.0)
        tf.layer.cornerRadius = 10
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.leftViewMode = .always
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.gray]
        )
        tf.snp.makeConstraints { make in make.height.equalTo(46) }
        return tf
    }
    
    private static func createTextView(placeholder: String) -> UITextView {
        let tv = UITextView()
        tv.textColor = .white
        tv.font = .systemFont(ofSize: 15)
        tv.backgroundColor = UIColor(white: 0.18, alpha: 1.0)
        tv.layer.cornerRadius = 10
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        return tv
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13, weight: .bold)
        return label
    }
}

// MARK: - Shake Animation Extension
private extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-8.0, 8.0, -6.0, 6.0, -3.0, 3.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
}

// MARK: - Existing Top Info & Job Cell Declarations (Без изменений)
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
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
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

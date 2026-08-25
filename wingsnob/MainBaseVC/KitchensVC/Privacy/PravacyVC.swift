import UIKit
import SnapKit
import MessageUI

final class PrivacyVC: UIViewController {

    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Privacy Policy"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.isSelectable = true
        tv.showsVerticalScrollIndicator = true
        tv.textColor = UIColor.white.withAlphaComponent(0.9)
        return tv
    }()

    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Close", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.18, green: 0.22, blue: 0.30, alpha: 1.0)
        btn.layer.cornerRadius = 12
        btn.isHidden = true
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPrivacyText()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.10, green: 0.12, blue: 0.16, alpha: 1.0)

        view.addSubview(titleLabel)
        view.addSubview(textView)
        view.addSubview(closeButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        closeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(44)
        }

        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(closeButton.snp.top).offset(-16)
        }

        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        textView.delegate = self
    }

    private func setupPrivacyText() {
        let fullText = """
        Privacy Policy

        Last updated: August 2026

        Welcome to our application. We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we handle your information when you interact with our app.

        1. Information Collection and Use
        We strictly value user privacy. Our application does not collect, store, transmit, or process any personal identification data, location information, contacts, or financial details. All gameplay state, user preferences, and local settings are processed exclusively on your local device.

        2. Data Storage and Processing
        No personal data is collected or transferred to external servers or third-party cloud analytics services. Any game progress saved is stored strictly within the local secure sandbox environment of your device.

        3. Third-Party Services & Analytics
        Our application operates independently without utilizing tracking tools, analytics SDKs, or third-party behavioral monitoring frameworks. Your usage habits remain entirely private to you.

        4. Children's Privacy
        Our application is designed for a general audience and does not intentionally gather or request personal information from children under the age of 13.

        5. Security
        Since we do not collect or store personal data over remote servers, your information is naturally protected against unauthorized access, leaks, or external data breaches.

        6. Changes to This Privacy Policy
        We may update our Privacy Policy from time to time to reflect changes in functionality or legal regulations. You are advised to review this page periodically for any updates.

        7. Contact Us
        If you have any questions, feedback, or inquiries regarding this Privacy Policy or app security, please contact us at: 
        vladamalej@gmail.com
        """

        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85)
            ]
        )

        // Bolding sections for high-end look
        let boldHeaders = [
            "Privacy Policy",
            "1. Information Collection and Use",
            "2. Data Storage and Processing",
            "3. Third-Party Services & Analytics",
            "4. Children's Privacy",
            "5. Security",
            "6. Changes to This Privacy Policy",
            "7. Contact Us"
        ]

        for header in boldHeaders {
            let range = (fullText as NSString).range(of: header)
            if range.location != NSNotFound {
                attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: range)
                attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: range)
            }
        }

        // Highlight & Link target email (vladamalej@gmail.com)
        let emailStr = "vladamalej@gmail.com"
        let emailRange = (fullText as NSString).range(of: emailStr)
        if emailRange.location != NSNotFound {
            attributedString.addAttribute(.link, value: "mailto:\(emailStr)", range: emailRange)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: emailRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.25, green: 0.60, blue: 1.0, alpha: 1.0), range: emailRange)
        }

        textView.attributedText = attributedString
        textView.linkTextAttributes = [
            .foregroundColor: UIColor(red: 0.25, green: 0.60, blue: 1.0, alpha: 1.0),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }

    @objc private func didTapClose() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - UITextViewDelegate & MFMailComposeViewControllerDelegate
extension PrivacyVC: UITextViewDelegate, MFMailComposeViewControllerDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "mailto" {
            let email = URL.absoluteString.replacingOccurrences(of: "mailto:", with: "")
            sendEmail(to: email)
            return false
        }
        return true
    }

    private func sendEmail(to targetEmail: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([targetEmail])
            mail.setSubject("App Inquiry & Support")
            present(mail, animated: true)
        } else if let mailtoURL = URL(string: "mailto:\(targetEmail)"), UIApplication.shared.canOpenURL(mailtoURL) {
            UIApplication.shared.open(mailtoURL)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

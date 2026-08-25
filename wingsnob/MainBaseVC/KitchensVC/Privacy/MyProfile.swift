import UIKit
import SnapKit
import AVFoundation
import StoreKit

final class MyProfileVC: UIViewController {

    // MARK: - Keys for UserDefaults
    private enum Keys {
        static let userImage = "profile_user_avatar"
        static let username = "profile_user_nickname"
        static let isAudioMuted = "profile_is_audio_muted"
    }

    // MARK: - Audio Player State
    private static var audioPlayer: AVAudioPlayer?

    // MARK: - UI Components
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(red: 0.18, green: 0.22, blue: 0.30, alpha: 1.0)
        iv.layer.borderColor = UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0).cgColor
        iv.layer.borderWidth = 3.0
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let cameraBadgeView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "camera.fill")
        iv.tintColor = .white
        iv.backgroundColor = UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        iv.layer.cornerRadius = 14
        iv.clipsToBounds = true
        iv.contentMode = .center
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "nikname314"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()

    private let editNameIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "pencil")
        iv.tintColor = UIColor.white.withAlphaComponent(0.6)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()

    // Card Container for Settings
    private let settingsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.15, green: 0.18, blue: 0.25, alpha: 1.0)
        view.layer.cornerRadius = 18
        return view
    }()

    // Audio Row
    private let audioTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Mute Audio"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()

    private let audioSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = UIColor(red: 0.95, green: 0.36, blue: 0.22, alpha: 1.0)
        return sw
    }()

    // Rate Us Row Button
    private let rateUsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Rate Us", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.backgroundColor = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        btn.layer.cornerRadius = 14
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        setupGestures()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }

    // MARK: - Setup Layout
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.10, green: 0.12, blue: 0.16, alpha: 1.0)

        view.addSubview(avatarImageView)
        view.addSubview(cameraBadgeView)
        
        nameStackView.addArrangedSubview(nameLabel)
        nameStackView.addArrangedSubview(editNameIcon)
        view.addSubview(nameStackView)

        view.addSubview(settingsContainerView)
        settingsContainerView.addSubview(audioTitleLabel)
        settingsContainerView.addSubview(audioSwitch)

        view.addSubview(rateUsButton)

        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(110)
        }

        cameraBadgeView.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(avatarImageView)
            make.width.height.equalTo(28)
        }

        editNameIcon.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }

        nameStackView.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        settingsContainerView.snp.makeConstraints { make in
            make.top.equalTo(nameStackView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }

        audioTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }

        audioSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }

        rateUsButton.snp.makeConstraints { make in
            make.top.equalTo(settingsContainerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        audioSwitch.addTarget(self, action: #selector(didToggleAudioSwitch(_:)), for: .valueChanged)
        rateUsButton.addTarget(self, action: #selector(didTapRateUs), for: .touchUpInside)
    }

    // MARK: - Load & Save User Data
    private func loadUserData() {
        // Avatar
        if let data = UserDefaults.standard.data(forKey: Keys.userImage), let image = UIImage(data: data) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
            avatarImageView.tintColor = .lightGray
        }

        // Nickname
        if let name = UserDefaults.standard.string(forKey: Keys.username), !name.isEmpty {
            nameLabel.text = name
        } else {
            nameLabel.text = "nikname314"
        }

        if UserDefaults.standard.object(forKey: Keys.isAudioMuted) == nil {
            UserDefaults.standard.set(true, forKey: Keys.isAudioMuted)
        }
        
        let isMuted = UserDefaults.standard.bool(forKey: Keys.isAudioMuted)
        audioSwitch.isOn = isMuted
        
        // Включаем звук ТОЛЬКО если тумблер выключен (Mute = false)
        if !isMuted {
            playBackgroundAudio()
        }
    }

    // MARK: - Gestures Setup
    private func setupGestures() {
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar))
        avatarImageView.addGestureRecognizer(avatarTap)

        let nameTap = UITapGestureRecognizer(target: self, action: #selector(didTapEditName))
        nameStackView.addGestureRecognizer(nameTap)
    }

    // MARK: - Actions
    @objc private func didTapAvatar() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @objc private func didTapEditName() {
        let alert = UIAlertController(title: "Edit Nickname", message: "Enter your preferred nickname:", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = self.nameLabel.text
            textField.placeholder = "Nickname"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self, let text = alert.textFields?.first?.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            self.nameLabel.text = text
            UserDefaults.standard.set(text, forKey: Keys.username)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    @objc private func didToggleAudioSwitch(_ sender: UISwitch) {
        let isMuted = sender.isOn
        UserDefaults.standard.set(isMuted, forKey: Keys.isAudioMuted)

        if isMuted {
            stopBackgroundAudio()
        } else {
            playBackgroundAudio()
        }
    }

    @objc private func didTapRateUs() {
        if let scene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    // MARK: - Audio Handling
    private func playBackgroundAudio() {
        guard MyProfileVC.audioPlayer == nil || MyProfileVC.audioPlayer?.isPlaying == false else { return }

        guard let url = Bundle.main.url(forResource: "main_audio", withExtension: "mp3") else {
            print("Audio file 'main_audio.mp3' not found in bundle.")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            MyProfileVC.audioPlayer = try AVAudioPlayer(contentsOf: url)
            MyProfileVC.audioPlayer?.numberOfLoops = -1 // Бесконечный повтор
            MyProfileVC.audioPlayer?.prepareToPlay()
            MyProfileVC.audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }

    private func stopBackgroundAudio() {
        MyProfileVC.audioPlayer?.stop()
        MyProfileVC.audioPlayer = nil
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension MyProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let editedImage = info[.editedImage] as? UIImage {
            avatarImageView.image = editedImage
            saveImageToUserDefaults(image: editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            avatarImageView.image = originalImage
            saveImageToUserDefaults(image: originalImage)
        }
    }

    private func saveImageToUserDefaults(image: UIImage) {
        if let data = image.pngData() {
            UserDefaults.standard.set(data, forKey: Keys.userImage)
        }
    }
}

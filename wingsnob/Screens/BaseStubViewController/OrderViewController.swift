

import UIKit
import WebKit
import SnapKit

class OrderViewController: UIViewController, WKNavigationDelegate {
    
    private let url: URL
    
    private lazy var mainView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let wv = WKWebView(frame: .zero, configuration: configuration)
        wv.navigationDelegate = self
        wv.backgroundColor = .black
        wv.scrollView.backgroundColor = .black
        wv.isOpaque = false // Защита от белой вспышки при старте загрузки
        wv.allowsBackForwardNavigationGestures = true // Разрешаем свайпы назад/вперед для удобства
        return wv
    }()
    
    // Кастомный красный лоадер
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemRed
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // Минималистичный крестик для закрытия экрана
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 0.1, alpha: 0.7) // Полупрозрачный темный круг
        button.layer.cornerRadius = 18
        
        // Немного увеличим вес иконки крестика, чтобы смотрелось аккуратно
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        return button
    }()
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupSubviews()
        setupConstraints()
        
        // Загружаем целевой URL
        let request = URLRequest(url: url)
        mainView.load(request)
    }
    
    private func setupSubviews() {
        view.addSubview(mainView)
        view.addSubview(activityIndicator)
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        // Растягиваем на абсолютно весь экран, игнорируя Safe Area
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Центрируем индикатор на экране
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // Крестик позиционируем с учетом Safe Area, чтобы он не залез под челку / остров
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(36)
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
        activityIndicator.alpha = 1.0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoader()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Ошибка загрузки вебвьюхи: \(error.localizedDescription)")
        hideLoader()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Ошибка навигации вебвьюхи: \(error.localizedDescription)")
        hideLoader()
    }
    
    private func hideLoader() {
        UIView.animate(withDuration: 0.25, animations: {
            self.activityIndicator.alpha = 0.0
        }) { _ in
            self.activityIndicator.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        // Проверяем, является ли схема телефонным звонком или почтой
        if url.scheme == "tel" || url.scheme == "mailto" {
            // Просим систему открыть урл (запустится звонилка или почтовое приложение)
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            // Блокируем этот переход внутри самой веб-вьюхи, так как мы его уже обработали
            decisionHandler(.cancel)
            return
        }
        
        // Все остальные стандартные ссылки (http/https) разрешаем
        decisionHandler(.allow)
    }
}


import Foundation

struct TestABModel: Decodable {
    let configVersion: String
}

class TestAB {
    static let shared = TestAB()
    
    private(set) var configVersion = ""
    
    private let configURL = URL(string: "https://raw.githubusercontent.com/uvarovn771-blip/testAB/main/testAB")
    
    private init() {}
    
    func fetchConfig(completion: ((Bool) -> Void)? = nil) {
        guard let configURL = configURL else {
            completion?(false)
            return
        }
        
        let request = URLRequest(url: configURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            
            guard let data = data, error == nil,
                  let remoteConfig = try? JSONDecoder().decode(TestABModel.self, from: data) else {
                DispatchQueue.main.async {
                    completion?(false)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.configVersion = remoteConfig.configVersion
                completion?(true)
            }
        }.resume()
    }
}

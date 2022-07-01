//
//  ApiService.swift
//  HkGeek
//
//  Created by 吴非 on 2022/7/1.
//

import Combine
import SwiftUI


public class ApiService: ObservableObject {
    
    private var subscribers = Set<AnyCancellable>()
    
    public init () {}
    
    // @Published var items: [AddressModel] = []
    
    //  "https://api.caiyunapp.com/v2/place?query=%E6%B3%89%E5%B7%9E"
    public func ask<T: Decodable>(apiURL: String, completion: @escaping (Result<[T], Error>)-> Void) {
        
        guard let rkURL = URL(string: apiURL) else { return }
        var request = URLRequest(url: rkURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 30
        request.httpMethod = "GET"
        URLSession.shared.dataTaskPublisher(for: request)
            .map{ ApiService.analysisByItems(r: $0.data) }
            .decode(type: [T].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { resultArray in
                completion(.success(resultArray))
                // print("respose => \(String.init(data: respose.data, encoding: .utf8) ?? "")")
            }).store(in: &subscribers)
    }
    
    // 解析response => items
    static func analysisByItems(r: Data) -> Data {
        guard let dict = try? JSONSerialization.jsonObject(with: r, options: .mutableContainers) as? NSDictionary else { return Data() }
        guard let items = dict.object(forKey: "places") as? NSArray else { return Data() }
        guard let jsonData = ApiService.stringByForm(array: items).data(using: String.Encoding.utf8) else { return Data() }
        return jsonData
    }
    
    // 数组转换字符串
    static func stringByForm(array: NSArray) -> String {
        guard JSONSerialization.isValidJSONObject(array) else { return "" }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: array, options: []) else { return "" }
        return (NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) ?? "") as String
    }
}

//
//  AddressModel.swift
//  HkGeek
//
//  Created by 吴非 on 2022/7/1.
//

import Foundation

public struct AddressModel: Codable, Identifiable {
    
    public var name: String?
    public var formatted_address: String?
    public var cId: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case formatted_address
        case cId = "id"
    }
    
    // Identifiable
    public var id: String { cId ?? UUID().uuidString }
}

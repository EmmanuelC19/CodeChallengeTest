//
//  ResposeModel.swift
//  CodeChallegeTest
//
//  Created by Emmanuel Casañas Cruz on 20/02/24.
//

import Foundation

struct ResponseModel: Codable {
    let id : Int?
    let productId : String?
    let productName : String?
    let productImage : String?
    let storeName : String?
    let transactionDateTime : Int?
    let transactionType : String?
    let unitPrice : String?
    let unitQuantity : Double?
    let associateRef : String?
    let productPosRefNum : String?
}

extension ResponseModel {
    static var mockData: [ResponseModel] {
        return [.init(id: 12345,
                      productId: "test-id-1",
                      productName: "test-item-1",
                      productImage: nil,
                      storeName: "test-store-1",
                      transactionDateTime: 20240101120000,
                      transactionType: "ST",
                      unitPrice: "10.00",
                      unitQuantity: 5,
                      associateRef: nil,
                      productPosRefNum: "001-096-1008278"),
                .init(id: 67890,
                      productId: "test-id-2",
                      productName: "test-item-2",
                      productImage: nil,
                      storeName: "test-store-2",
                      transactionDateTime: 20240101120000,
                      transactionType: "ST",
                      unitPrice: "15.00",
                      unitQuantity: 1,
                      associateRef: nil,
                      productPosRefNum: "001-096-1008290"),
                
        ]
    }
}

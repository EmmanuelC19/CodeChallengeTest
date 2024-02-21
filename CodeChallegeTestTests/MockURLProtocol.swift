//
//  MockURLProtocol.swift
//  CodeChallegeTestTests
//
//  Created by Emmanuel Casañas Cruz on 21/02/24.
//

import Foundation
@testable import CodeChallegeTest

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    var useMockData = true

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard !useMockData else {
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = encodeMockData() 
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data!)
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
    }

    func encodeMockData() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(ResponseModel.mockData)
            return data
        } catch {
            print("Error encoding mock data: \(error)")
            return nil
        }
    }
}


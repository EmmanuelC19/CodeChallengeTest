//
//  ViewControllerTests.swift
//  CodeChallegeTestTests
//
//  Created by Emmanuel Casañas Cruz on 20/02/24.
//

import XCTest
@testable import CodeChallegeTest

final class ViewControllerTests: XCTestCase {

    var viewController: ViewController!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        viewController = ViewController(customSession: URLSession(configuration: config))

    }

    override func tearDown() {
        viewController = nil
        super.tearDown()
    }

    func testFetchPurchaseHistorySuccess() {
        MockURLProtocol.requestHandler = { request in
            guard let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                  let data = MockURLProtocol().encodeMockData() else {
                XCTFail("expected mockProtocol to be implemented")
                return (HTTPURLResponse(), Data())
            }
            return (response, data)
        }

        let expectation = self.expectation(description: "FetchPurchaseHistory succeeds")
        Task {
            do {
                let result = try await viewController.fetchPurchaseHistory()
                XCTAssertEqual(result.count, 2)
                XCTAssertEqual(result.first?.productName, "test-item-1")
                expectation.fulfill()
            } catch {
                XCTFail("Expected successful fetch, but failed with error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchPurchaseHistoryFailed() {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 403, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let expectation = self.expectation(description: "FetchPurchaseHistory fails")

        Task {
            do {
                _ = try await viewController.fetchPurchaseHistory()
                XCTFail("Expected fetch to fail with error, but succeeded")
            } catch {
                if let someError = error as? ViewController.SomeError {
                    switch someError {
                    case .responseError:
                        break
                    default:
                        XCTFail("Received unexpected error type: \(someError)")
                    }
                } else {
                    XCTFail("Received unexpected error: \(error)")
                }
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testNumberOfRowsInTableViewMatchesPurchaseHistory() {
        MockURLProtocol.requestHandler = { request in
            guard let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
                  let data = MockURLProtocol().encodeMockData() else {
                XCTFail("expected mockProtocol to be implemented")
                return (HTTPURLResponse(), Data())
            }
            return (response, data)
        }

        let expectation = self.expectation(description: "Data showing")

        Task {
            await MainActor.run {
                viewController.viewDidLoad()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    XCTAssertEqual(self.viewController.tableView.numberOfRows(inSection: 0), self.viewController.purchaseHistory.count)
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testNumberOfRowsInTableViewMatchesPurchaseHistoryOnFailure() {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let expectation = self.expectation(description: "Data failed to load")

        Task {
            await MainActor.run {
                self.viewController.viewDidLoad()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    XCTAssertEqual(self.viewController.tableView.numberOfRows(inSection: 0), 0, "Table view should have 0 rows after a failed fetch")
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

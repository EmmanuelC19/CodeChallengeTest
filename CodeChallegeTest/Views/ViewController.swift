//
//  ViewController.swift
//  CodeChallegeTest
//
//  Created by Emmanuel Casañas Cruz on 20/02/24.
//

import UIKit

class ViewController: UIViewController {

    static let endpointURL: String = "https://devapi.clbk.app/v1/client/64965641/purchaseHistory"

    lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = .lightGray
        return tableview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureActivityIndicator()
        retrieveInformation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    var purchaseHistory: [ResponseModel] = []

    private var activityIndicator: UIActivityIndicatorView!

    let urlSession: URLSession?

    init(customSession: URLSession?) {
        self.urlSession = customSession ?? URLSession(configuration: .default)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.urlSession = URLSession(configuration: .default)
        super.init(coder: coder)
    }

    func configureView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.reuseIdentifier)
    }

    func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Tableview DataSource and Delegate

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchaseHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.reuseIdentifier, for: indexPath) as? CustomCell
        let cellModel = purchaseHistory[indexPath.row]
        cell?.configure(with: cellModel)
        return cell ?? UITableViewCell()
    }
}

// MARK: - Fetch Methods
extension ViewController {

    enum SomeError: Error {
        case singleError
        case urlError
        case responseError
        case serializationError
    }

    func fetchPurchaseHistory() async throws -> [ResponseModel] {
        guard let url = URL(string: ViewController.endpointURL),
              let urlSession else {
            throw SomeError.urlError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.addValue("148", forHTTPHeaderField: "X-Clientbook-User-Id")
        request.addValue("CE99C2E9-928D-444B-B132-C99865338897", forHTTPHeaderField: "X-Clientbook-Device-Id")
        request.addValue("90745dca68d5fa5506d14001d75086b8", forHTTPHeaderField: "X-Clientbook-Token")
        request.addValue("4", forHTTPHeaderField: "X-Clientbook-Merchant-Id")
        request.addValue("3655", forHTTPHeaderField: "X-Clientbook-Store-Id")
        request.addValue("ios", forHTTPHeaderField: "X-Clientbook-Device-Type")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw SomeError.responseError
        }

        do {
            let result = try JSONDecoder().decode([ResponseModel].self, from: data)
            return result
        } catch {
            throw SomeError.serializationError
        }
    }

    func retrieveInformation() {
        showLoader()
        Task {
            do {
                purchaseHistory =  try await fetchPurchaseHistory()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.hideLoader()
                }

            } catch {
                debugPrint(error)
                self.hideLoader()
            }
        }
    }

    func showLoader() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }

    func hideLoader() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
}

/*curl -v \
 -X GET \
 -H "x-clientbook-user-id: 148" \
 -H "x-clientbook-device-id: CE99C2E9-928D-444B-B132-C99865338897" \
 -H "x-clientbook-token: 90745dca68d5fa5506d14001d75086b8" \
 -H "x-clientbook-merchant-id: 4" \
 -H "x-clientbook-store-id: 3655" \
 -H "x-clientbook-device-type: ios" \
 "https://devapi.clbk.app/v1/client/64965641/purchaseHistory"
 */


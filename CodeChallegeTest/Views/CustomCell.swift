//
//  CustomCell.swift
//  CodeChallegeTest
//
//  Created by Emmanuel Casañas Cruz on 20/02/24.
//

import UIKit

class CustomCell: UITableViewCell {

    static let reuseIdentifier: String = "customCell"

    lazy var productNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var storeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var transactionTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        let labels = [productNameLabel, storeNameLabel, dateLabel, transactionTypeLabel, priceLabel, quantityLabel]
        for label in labels {
            label.text = ""
        }
    }

    func setupView() {
        contentView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor,
                                           constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor,
                                            constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.topAnchor,
                                       constant: 15).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.bottomAnchor,
                                          constant: -15).isActive = true

        stackView.addArrangedSubview(productNameLabel)
        stackView.addArrangedSubview(storeNameLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(transactionTypeLabel)
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(quantityLabel)
    }

    func configure(with model: ResponseModel) {
        productNameLabel.text = "Product Name: \(model.productName ?? "-")"
        storeNameLabel.text = "Store Name: \(model.storeName ?? "-")"
        dateLabel.text = "Date: \(formatTransactionDateTime(model.transactionDateTime)) "
        transactionTypeLabel.text = "Transaction Type: \(model.transactionType ?? "-")"
        priceLabel.text = "Price: $\(model.unitPrice ?? "-")"
        quantityLabel.text = "Quantity: \(model.unitQuantity ?? 0)"
    }
}

extension CustomCell {

    func formatTransactionDateTime(_ transactionDateTime: Int?) -> String {
        guard let transactionDateTime else { return "-" }
        let transactionDateTimeString = String(transactionDateTime)

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMddHHmmss"

        if let date = inputFormatter.date(from: transactionDateTimeString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

            return outputFormatter.string(from: date)
        } else {
            return "-"
        }
    }
}

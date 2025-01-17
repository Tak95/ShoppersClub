//
//  DetailViewController.swift
//  ShoppersClub
//
//  Created by Tak on 2022/01/15.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - DetailView Property
    var item: Item? {
        didSet {
            guard let item = item, let images = item.images else { return }
            self.configureItemImages(with: images)
        }
    }
    let networkManager = NetworkManager()
    let networkItem = NetworkItem()
    
    // MARK: - Parent DetailView
    let detailScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    let detailContentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    // MARK: - Image ScrollView
    let imageScrollView: UIScrollView = {
        let imageScrollView = UIScrollView()
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        return imageScrollView
    }()
    let imageContentView: UIView = {
        let imageContentView = UIView()
        imageContentView.translatesAutoresizingMaskIntoConstraints = false
        return imageContentView
    }()
    let imageScrollPage: UIPageControl = {
        let imageScrollPage = UIPageControl()
        imageScrollPage.translatesAutoresizingMaskIntoConstraints = false
        imageScrollPage.currentPageIndicatorTintColor = .purple
        imageScrollPage.pageIndicatorTintColor = .systemGray
        return imageScrollPage
    }()
    let itemImages: UIImageView = {
        let itemImages = UIImageView()
        itemImages.translatesAutoresizingMaskIntoConstraints = false
        itemImages.contentMode = .scaleAspectFit
        return itemImages
    }()
    
    // MARK: - DetailView Contents
    let itemTitleLabel: UILabel = {
        let itemTitleLabel = UILabel()
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemTitleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        itemTitleLabel.textAlignment = .left
        return itemTitleLabel
    }()
    let itemStockLabel: UILabel = {
        let itemStockLabel = UILabel()
        itemStockLabel.translatesAutoresizingMaskIntoConstraints = false
        itemStockLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        itemStockLabel.textAlignment = .left
        return itemStockLabel
    }()
    let itemPriceLabel: UILabel = {
        let itemPriceLabel = UILabel()
        itemPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        itemPriceLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        return itemPriceLabel
    }()
    let itemDiscountedPriceLabel: UILabel? = {
        let itemDiscountedPriceLabel = UILabel()
        itemDiscountedPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        itemDiscountedPriceLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        return itemDiscountedPriceLabel
    }()
    let itemPriceStackView: UIStackView = {
        let itemPriceStackView = UIStackView()
        itemPriceStackView.translatesAutoresizingMaskIntoConstraints = false
        itemPriceStackView.distribution = .fill
        itemPriceStackView.spacing = 5
        return itemPriceStackView
    }()
    let itemDescription: UILabel = {
        let itemDescription = UILabel()
        itemDescription.translatesAutoresizingMaskIntoConstraints = false
        itemDescription.font = UIFont.preferredFont(forTextStyle: .title2)
        itemDescription.numberOfLines = 0
        return itemDescription
    }()
    let itemRegistrationDateLabel: UILabel = {
        let itemRegistrationDateLabel = UILabel()
        itemRegistrationDateLabel.translatesAutoresizingMaskIntoConstraints = false
        itemRegistrationDateLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        itemRegistrationDateLabel.textColor = .systemGray
        return itemRegistrationDateLabel
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        showDetailInfo()
        navigationController?.navigationBar.topItem?.backButtonTitle = "상품 목록"
        self.title = "\(itemTitleLabel.text!)"
    }
    
    // MARK: - DetailView Network
    func configureItemImages(with path: [String]) {
        for url in path {
            let url = URL(string: url)!
            let request = URLRequest(url: url)
            networkManager.fetchData(request: request) { [weak self] result in
                switch result {
                case .success(let item):
                    let image = UIImage(data: item)!
                    DispatchQueue.main.async {
                        self?.itemImages.image = image
                    }
                case .failure(_):
                    fatalError()
                }
            }
        }
    }
    
    func fetchIDItem(id: UInt) {
        guard let request = networkItem.loadItemIdRequest(id) else { return }
        networkItem.fetchItem(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                self?.item = data
                DispatchQueue.main.async {
                    self?.itemDescription.text = self?.item?.descriptions
                }
            case .failure(_):
                fatalError()
            }
        }
    }
    
    // MARK: - View Update
    func configureDetailInfo(item: Item) {
        fetchIDItem(id: item.id)
        let date = Date(timeIntervalSince1970: item.registrationDate)
        let dateString = date.formatDate(date: date, dateFormat: "yyyy.MM.dd")
        itemRegistrationDateLabel.text = dateString
        itemTitleLabel.text = item.title
        itemStockUpdate(item: item)
        itemPriceUpdate(item: item)
    }
    
    func itemStockUpdate(item: Item) {
        if item.stock == 0 {
            itemStockLabel.text = "품절"
            itemStockLabel.textColor = .orange
        } else {
            itemStockLabel.text = "재고 : \(String(item.stock))"
        }
    }
    
    func itemPriceUpdate(item: Item) {
        itemPriceLabel.text = "\(item.currency) \(String(item.price))"
        if let itemDiscountedPrice = item.discountedPrice {
            itemDiscountedPriceLabel?.text = "\(item.currency) \(String(itemDiscountedPrice))"
            itemPriceLabel.textColor = .red
            let strikeOutItemPrice: NSMutableAttributedString = NSMutableAttributedString(string: (itemPriceLabel.text)!)
            strikeOutItemPrice.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, strikeOutItemPrice.length))
            itemPriceLabel.attributedText = strikeOutItemPrice
        }
    }
    // MARK: - DetailView Autolayout
    func showDetailInfo() {
        detailScrollViewLayout()
        detailConstraints()
    }
    
    func detailScrollViewLayout() {
        view.addSubview(detailScrollView)
        detailScrollViewConstraints()
        detailScrollView.addSubview(detailContentView)
        detailContentViewConstraints()
        detailContentView.addSubview(imageScrollView)
        imageScrollViewLayout()
        detailContentViewLayout()
    }
    
    func imageScrollViewLayout() {
        imageScrollView.addSubview(imageContentView)
        imageScrollViewConstraints()
        imageContentView.addSubview(itemImages)
        imageContentViewConstraints()
        itemImagesConstraints()
    }
    
    func detailScrollViewConstraints() {
        NSLayoutConstraint.activate([
            detailScrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            detailScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            detailScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            detailScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    func detailContentViewConstraints() {
        NSLayoutConstraint.activate([
            detailContentView.topAnchor.constraint(equalTo: self.detailScrollView.topAnchor),
            detailContentView.leadingAnchor.constraint(equalTo: self.detailScrollView.leadingAnchor),
            detailContentView.trailingAnchor.constraint(equalTo: self.detailScrollView.trailingAnchor),
            detailContentView.bottomAnchor.constraint(equalTo: self.detailScrollView.bottomAnchor),
            detailContentView.widthAnchor.constraint(equalTo: self.detailScrollView.widthAnchor)
        ])
    }
    
    func imageScrollViewConstraints() {
        NSLayoutConstraint.activate([
            imageScrollView.topAnchor.constraint(equalTo: self.detailContentView.topAnchor),
            imageScrollView.leadingAnchor.constraint(equalTo: self.detailContentView.leadingAnchor),
            imageScrollView.trailingAnchor.constraint(equalTo: self.detailContentView.trailingAnchor),
            imageScrollView.heightAnchor.constraint(equalTo: imageScrollView.widthAnchor)
        ])
    }
    
    func imageContentViewConstraints() {
        NSLayoutConstraint.activate([
            imageContentView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            imageContentView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor),
            imageContentView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor),
            imageContentView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor)
        ])
    }
    
    func itemImagesConstraints() {
        NSLayoutConstraint.activate([
            itemImages.topAnchor.constraint(equalTo: imageContentView.topAnchor),
            itemImages.leadingAnchor.constraint(equalTo: imageContentView.leadingAnchor),
            itemImages.trailingAnchor.constraint(equalTo: imageContentView.trailingAnchor),
            itemImages.bottomAnchor.constraint(equalTo: imageContentView.bottomAnchor),
            itemImages.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            itemImages.heightAnchor.constraint(equalTo: self.view.widthAnchor)
        ])
    }
    
    func detailContentViewLayout() {
        detailContentView.addSubview(itemTitleLabel)
        detailContentView.addSubview(itemStockLabel)
        detailContentView.addSubview(itemPriceStackView)
        detailContentView.addSubview(itemDescription)
        detailContentView.addSubview(itemRegistrationDateLabel)
    }
    
    func detailConstraints() {
        itemTitleConstraints()
        itemStockConstraints()
        itemPriceStackViewConstraints()
        itemDescriptionConstraints()
        itemRegistrationConstraints()
    }
    
    func itemTitleConstraints() {
        NSLayoutConstraint.activate([
            itemTitleLabel.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: 15),
            itemTitleLabel.leadingAnchor.constraint(equalTo: detailContentView.leadingAnchor, constant: 25),
            itemTitleLabel.trailingAnchor.constraint(equalTo: detailContentView.trailingAnchor)
        ])
    }
    
    func itemStockConstraints() {
        NSLayoutConstraint.activate([
            itemStockLabel.topAnchor.constraint(equalTo: itemTitleLabel.bottomAnchor, constant: 15),
            itemStockLabel.leadingAnchor.constraint(equalTo: detailContentView.leadingAnchor, constant: 10),
            itemStockLabel.trailingAnchor.constraint(equalTo: detailContentView.trailingAnchor)
        ])
    }
    
    func itemPriceStackViewConstraints() {
        NSLayoutConstraint.activate([
            itemPriceStackView.topAnchor.constraint(equalTo: itemStockLabel.bottomAnchor, constant: 15),
            itemPriceStackView.leadingAnchor.constraint(equalTo: detailContentView.leadingAnchor, constant: 10),
            itemPriceStackView.trailingAnchor.constraint(equalTo: detailContentView.trailingAnchor),
            itemPriceStackView.widthAnchor.constraint(equalToConstant: detailContentView.frame.width - 10)
        ])
        itemPriceStackView.addArrangedSubview(itemPriceLabel)
        itemPriceStackView.addArrangedSubview(itemDiscountedPriceLabel!)
    }
    
    func itemDescriptionConstraints() {
        NSLayoutConstraint.activate([
            itemDescription.topAnchor.constraint(equalTo: itemPriceStackView.bottomAnchor, constant: 20),
            itemDescription.leadingAnchor.constraint(equalTo: detailContentView.leadingAnchor, constant: 10),
            itemDescription.trailingAnchor.constraint(equalTo: detailContentView.trailingAnchor)
            ])
    }
    
    func itemRegistrationConstraints() {
        NSLayoutConstraint.activate([
            itemRegistrationDateLabel.topAnchor.constraint(equalTo: itemDescription.bottomAnchor, constant: 10),
            itemRegistrationDateLabel.leadingAnchor.constraint(equalTo: detailContentView.leadingAnchor, constant: 30),
            itemRegistrationDateLabel.trailingAnchor.constraint(equalTo: detailContentView.trailingAnchor),
            itemRegistrationDateLabel.bottomAnchor.constraint(equalTo: detailContentView.bottomAnchor, constant: -15)
        ])
    }
}

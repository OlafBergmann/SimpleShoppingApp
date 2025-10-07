import UIKit
import RxSwift
import RxCocoa

final class BasketViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel: BasketViewModel
    
    private let currencyPicker = UIPickerView()
    private let tableView = UITableView()
    private let summaryButton = UIButton()
    private let summaryLabel = UILabel()
    
    private let emptyView = UIView()
    private let emptyLabel = UILabel()
    private let emptyImageView = UIImageView()
    private let mainStack = UIStackView()
    
    
    init(viewModel: BasketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Basket"
        view.backgroundColor = .systemBackground
        
        // Summary label
        summaryLabel.font = UIFont.boldSystemFont(ofSize: 22)
        summaryLabel.textAlignment = .center
        summaryLabel.textColor = .white
        
        summaryButton.backgroundColor = .systemBlue
        summaryButton.addSubview(summaryLabel)
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            summaryLabel.leadingAnchor.constraint(equalTo: summaryButton.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: summaryButton.trailingAnchor),
            summaryLabel.topAnchor.constraint(equalTo: summaryButton.topAnchor, constant: 8),
            summaryLabel.bottomAnchor.constraint(equalTo: summaryButton.bottomAnchor, constant: -8)
        ])
        
        tableView.register(BasketItemCell.self, forCellReuseIdentifier: "BasketItemCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(tableView)
        mainStack.addArrangedSubview(currencyPicker)
        mainStack.addArrangedSubview(summaryButton)
        
        view.addSubview(mainStack)
        view.addSubview(emptyView)
        
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.image = UIImage(systemName: "cart")?.withRenderingMode(.alwaysTemplate)
        emptyImageView.tintColor = .lightGray
        emptyImageView.contentMode = .scaleAspectFit
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "Your basket is empty"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .lightGray
        emptyLabel.font = UIFont.systemFont(ofSize: 18)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyView.addSubview(emptyImageView)
        emptyView.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20),
            emptyImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyImageView.heightAnchor.constraint(equalToConstant: 100),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 16),
            emptyLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor)
        ])
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        viewModel.items
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
                let hasItems = !items.isEmpty
                self.currencyPicker.isHidden = !hasItems
                self.summaryButton.isHidden = !hasItems
                self.emptyView.isHidden = hasItems
            })
            .disposed(by: disposeBag)
        
        viewModel.currencyService.ratesLoaded
            .filter { $0 }
            .map { [weak self] _ -> [String] in
                self?.viewModel.currencyService.availableCurrencies ?? []
            }
            .bind(to: currencyPicker.rx.itemTitles) { _, item in item }
            .disposed(by: disposeBag)
        
        currencyPicker.rx.modelSelected(String.self)
            .compactMap { $0.first }
            .bind(to: viewModel.selectedCurrency)
            .disposed(by: disposeBag)
        
        viewModel.currencyService.ratesLoaded
            .filter { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self,
                      let usdIndex = self.viewModel.currencyService.availableCurrencies.firstIndex(of: "USD")
                else { return }
                self.currencyPicker.selectRow(usdIndex, inComponent: 0, animated: false)
                self.viewModel.selectedCurrency.accept("USD")
            })
            .disposed(by: disposeBag)
        
        viewModel.items
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "BasketItemCell", cellType: BasketItemCell.self)) { [weak self] _, basketItem, cell in
                guard let self = self else { return }
                cell.disposeBag = DisposeBag()
                self.configure(cell: cell, with: basketItem, currency: "USD")
            }
            .disposed(by: disposeBag)
        
        viewModel.totalInSelectedCurrency
            .map { "PAY: \($0)" }
            .bind(to: summaryLabel.rx.text)
            .disposed(by: disposeBag)
        
        summaryButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                viewModel.coordinator?.showPaymentConfrimation()
                viewModel.clear()
            })
            .disposed(by: disposeBag)
        
    }
    
    
    private func configure(cell: BasketItemCell, with basketItem: BasketItem, currency: String) {
        let convertedTotal = viewModel.currencyService.convert(amountUSD: basketItem.totalUSD, to: currency)
        
        cell.nameLabel.text = basketItem.product.name
        cell.quantityLabel.text = "\(basketItem.quantity) x \(String(format: "%.2f", convertedTotal)) \(currency)"
        cell.disposeBag = DisposeBag()
        cell.plusButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.addProduct.accept(basketItem.product)
            })
            .disposed(by: cell.disposeBag)
        cell.minusButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.removeProduct.accept(basketItem.product)
            })
            .disposed(by: cell.disposeBag)
    }
    
}

import UIKit
import RxSwift
import RxCocoa

final class CatalogViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel: CatalogViewModel
    private let basketVM: BasketViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: CatalogViewModel, basketVM: BasketViewModel) {
        self.viewModel = viewModel
        self.basketVM = basketVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        title = "Catalog"
        view.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        tableView.rowHeight = 80
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        viewModel.load()
        
        viewModel.products
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: ProductCell.identifier, cellType: ProductCell.self)) { [weak self] _, product, cell in
                guard let self = self else { return }
                // Update quantity badge based on current basket
                let quantity = self.basketVM.items.value.first(where: { $0.product == product })?.quantity ?? 0
                cell.configure(with: product, quantity: quantity)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Product.self)
            .subscribe(onNext: { [weak self] product in
                self?.basketVM.addProduct.accept(product)
            })
            .disposed(by: disposeBag)
        
        // Reload only affected rows on basket changes
        basketVM.items
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
                
                // Get currently visible indexPaths
                let visibleIndexPaths = self.tableView.indexPathsForVisibleRows ?? []
                
                for indexPath in visibleIndexPaths {
                    let product = self.viewModel.products.value[indexPath.row]
                    
                    // Find quantity in basket
                    let newQuantity = items.first(where: { $0.product == product })?.quantity ?? 0
                    
                    // Get the cell
                    if let cell = self.tableView.cellForRow(at: indexPath) as? ProductCell {
                        // Only update if quantity changed
                        if cell.quantity != newQuantity {
                            cell.configure(with: product, quantity: newQuantity)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
}

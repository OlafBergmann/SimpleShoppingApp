import UIKit
import RxSwift
import RxCocoa

final class PaymentConfirmationViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let confirmationLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    var basketVM: BasketViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        confirmationLabel.text = "Payment Successful!"
        confirmationLabel.font = UIFont.boldSystemFont(ofSize: 24)
        confirmationLabel.textAlignment = .center
        confirmationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(confirmationLabel)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            confirmationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmationLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: confirmationLabel.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.basketVM?.clear()
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

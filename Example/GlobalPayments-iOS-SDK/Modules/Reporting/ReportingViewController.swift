import UIKit

final class ReportingViewController: BaseViewController<ReportingViewModel> {
    
    private lazy var customView = {
        let view = ReportingView()
        view.delegate = self
        view.delegateView = self
        return view
    }()
    
    override func loadView() {
        view = customView
    }
    
    override func fillUI() {
        super.fillUI()
        
        viewModel?.loadSingleItems.bind { [weak self] items in
            self?.customView.setItems(items)
        }
        
        viewModel?.paymentProcessItemAction.bind { [weak self] vc in
            guard let vc = vc else { return }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ReportingViewController: ReportingViewDelegate {
    
    func menuItemAction(_ index: Int) {
        viewModel?.singleItemAction(index: index)
    }
}

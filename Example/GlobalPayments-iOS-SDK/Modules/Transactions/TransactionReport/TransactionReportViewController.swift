import UIKit

final class TransactionReportViewController: BaseViewController<BaseViewModel> {
    
    private lazy var pageViewController = ReportingPageViewController()
    
    private lazy var customView = {
        let view = GpBaseReportingView()
        view.title = "reporting.transaction.view.title".localized()
        view.delegateView = self
        view.delegate = self
        return view
    }()
    
    override func loadView() {
        view = customView
        viewModel = BaseViewModel()
    }
    
    override func fillUI() {
        super.fillUI()
        var pages: [UIViewController] = []
        pages.append(TransactionByIDFormBuilder.build())
        pages.append(TransactionListFormBuilder.build())
        pageViewController.setPages(pages)
        addChild(pageViewController)
        customView.setPageView(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
}

extension TransactionReportViewController: ReportingControlDelegate {
    
    func didPageChange(_ index: PageIndex) {
        pageViewController.currentIndex = index.rawValue
    }
}

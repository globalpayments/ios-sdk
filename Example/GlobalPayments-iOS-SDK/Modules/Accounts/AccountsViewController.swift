import UIKit
import GlobalPayments_iOS_SDK

final class AccountsViewController: BaseViewController<BaseViewModel> {
    
    private lazy var pageViewController = ReportingPageViewController()
    
    private lazy var customView = {
        let view = GpBaseReportingView()
        view.title = "reporting.accounts.title".localized()
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
        pages.append(AccountByIdBuilder.build())
        pages.append(AccountsListFormBuilder.build())
        pageViewController.setPages(pages)
        addChild(pageViewController)
        customView.setPageView(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
}

extension AccountsViewController: ReportingControlDelegate {
    
    func didPageChange(_ index: PageIndex) {
        pageViewController.currentIndex = index.rawValue
    }
}

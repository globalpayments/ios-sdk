import UIKit
import GlobalPayments_iOS_SDK

final class ActionsViewViewController: BaseViewController<BaseViewModel> {
    
    private lazy var pageViewController = ReportingPageViewController()
    
    private lazy var customView = {
        let view = GpBaseReportingView()
        view.title = "reporting.actions.title".localized()
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
        pages.append(ActionByIdBuilder.build())
        pages.append(ActionsListBuilder.build())
        pageViewController.setPages(pages)
        addChild(pageViewController)
        customView.setPageView(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
}

extension ActionsViewViewController: ReportingControlDelegate {
    
    func didPageChange(_ index: PageIndex) {
        pageViewController.currentIndex = index.rawValue
    }
}

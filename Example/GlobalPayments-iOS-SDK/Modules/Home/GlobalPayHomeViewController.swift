import UIKit

final class GlobalPayHomeViewController: BaseViewController<GlobalPayHomeViewModel> {
    
    private lazy var customView = {
        let view = GlobalPayHomeView()
        view.delegate = self
        return view
    }()
    
    private var items: [HomeItemEntity] = []
    
    override func loadView() {
        view = customView
    }
    
    override func fillUI() {
        super.fillUI()
        viewModel?.loadHomeItems.bind { [weak self] items in
            self?.customView.setItems(items)
        }
        
        viewModel?.homeItemAction.bind { [weak self] vc in
            guard let vc = vc else { return }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension GlobalPayHomeViewController: GlobalPayHomeDelegate {
    
    func onSettingsButtonPressed() {
        viewModel?.settingsAction()
    }
    
    func homeItemAction(_ index: Int) {
        viewModel?.homeItemAction(index: index)
    }
}

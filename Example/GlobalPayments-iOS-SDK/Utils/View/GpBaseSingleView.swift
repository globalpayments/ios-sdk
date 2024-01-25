import UIKit

class GpBaseSingleView: View {
    
    internal struct DimensKeys {
        static let margin: CGFloat = 10
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let marginBig: CGFloat = 20
        static let buttonSize: CGFloat = 48.0
    }
    
    internal lazy var separatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.872883141, green: 0.8896381259, blue: 0.905549109, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        loadingView.stopAnimating()
        loadingView.backgroundColor = #colorLiteral(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.2041597682)
        return loadingView
    }()
    
    internal lazy var separatorBottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.872883141, green: 0.8896381259, blue: 0.905549109, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    internal lazy var codeResponseView: CodeExampleResponseView = {
        let codeResponseView = CodeExampleResponseView()
        codeResponseView.exampleCodeImage = #imageLiteral(resourceName: "unified_payments_code")
        codeResponseView.defaultTabClicked()
        codeResponseView.translatesAutoresizingMaskIntoConstraints = false
        return codeResponseView
    }()
    
    override init() {
        super.init()
        setUpSeparatorLineConstraints()
    }
    
    private func setUpSeparatorLineConstraints() {
        addSubview(separatorLineView)
        NSLayoutConstraint.activating([
            separatorLineView.relativeTo(self, positioned: .top() + .constantHeight(1) + .width())
        ])
    }
    
    public func setUpLoadingViewConstraints() {
        addSubview(loadingView)
        NSLayoutConstraint.activating([
            loadingView.relativeTo(self, positioned: .allAnchors())
        ])
    }
    
    internal func setUpSeparatorBottomLineConstraints(_ containerView: UIView, belowView: UIView) {
        containerView.addSubview(separatorBottomLineView)
        NSLayoutConstraint.activating([
            separatorBottomLineView.relativeTo(containerView, positioned: .width() + .constantHeight(1)),
            separatorBottomLineView.relativeTo(belowView, positioned: .below(spacing: DimensKeys.marginMedium))
        ])
    }
    
    internal func setUpCodeResponseViewConstraints(_ containerView: UIView) {
        containerView.addSubview(codeResponseView)
        NSLayoutConstraint.activating([
            codeResponseView.relativeTo(separatorBottomLineView, positioned: .belowWidth(spacing: DimensKeys.marginMedium, margin: DimensKeys.marginSmall)),
            codeResponseView.relativeTo(containerView, positioned: .bottom())
        ])
    }
    
    func setResponseData(_ type: ResponseViewType, data: Any) {
        codeResponseView.defaultTabClicked()
        codeResponseView.setResponseData(type, data: data)
    }
    
    public func showLoading(_ show: Bool) {
        if show {
            loadingView.startAnimating()
        }else {
            loadingView.stopAnimating()
        }
    }
    
    internal func datePicker(_ type: GpFieldsEnum) -> UIDatePicker{
        let datePickerView = UIDatePicker()
        datePickerView.tag = type.rawValue
        datePickerView.datePickerMode = .date
        if #available(iOS 14, *) {
            datePickerView.preferredDatePickerStyle = .inline
        }
        datePickerView.addTarget(self, action: #selector(handleChange(sender:)), for: .valueChanged)
        return datePickerView
    }
    
    @objc func handleChange(sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        setDateFromPicker(date: dateFormatter.string(from: sender.date), field: GpFieldsEnum(value: sender.tag) ?? .amount)
    }
    
    func setDateFromPicker(date: String, field: GpFieldsEnum){}
}


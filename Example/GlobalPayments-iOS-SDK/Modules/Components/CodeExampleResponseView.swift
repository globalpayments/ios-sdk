import UIKit

enum ResponseViewType {
    case error
    case success
}

final class CodeExampleResponseView: View {
    
    private struct DimensKeys {
        static let margin: CGFloat = 10
        static let marginSmall: CGFloat = 5
        static let marginMedium: CGFloat = 15
        static let marginBig: CGFloat = 20
        static let cellId: String = "titleCell"
    }
    
    private var hasResponse: Bool = false
    private var dataResponseDict: [(key: String, value: String)] = []
    var locationLabel: String?
    var fileLabel: String?
    var exampleCodeImage: UIImage? {
        didSet{
            codeExampleImage.image = exampleCodeImage
        }
    }
    var titleResponseDataView: String? {
        didSet{
            titleResponseTableLabel.text = titleResponseDataView
        }
    }
    
    private lazy var segmentedControlView: SegmentedControlView = {
        let controlView = SegmentedControlView()
        controlView.delegate = self
        controlView.translatesAutoresizingMaskIntoConstraints = false
        return controlView
    }()
    
    private lazy var containerDataView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var containerResponseDataView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var titleResponseLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Make a request to see the response"
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var titleResponseTableLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private lazy var containerResponseTableView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.cornerRadius = 10
        container.backgroundColor = #colorLiteral(red: 0.762173593, green: 0.1921957731, blue: 0.0952751264, alpha: 1)
        return container
    }()
    
    private lazy var tableViewResponseView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.cornerRadius = 10
        container.backgroundColor = .white
        return container
    }()
    
    private lazy var dataResponseTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TitleSubtitleCell.self, forCellReuseIdentifier: DimensKeys.cellId)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var containerCodeExampleDataView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var titleCodeExampleView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = formatedDescriptionLabel()
        return label
    }()
    
    private lazy var codeExampleImage: UIImageView = {
        let image = UIImageView()
        image.sizeToFit()
        image.cornerRadius = 5
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init() {
        super.init()
        setUpControlViewConstraints()
        setUpContainerDataViewConstraints()
    }
    
    private func setUpControlViewConstraints() {
        addSubview(segmentedControlView)
        NSLayoutConstraint.activating([
            segmentedControlView.relativeTo(self, positioned: .width() + .top())
        ])
    }
    
    private func setUpContainerDataViewConstraints() {
        addSubview(containerDataView)
        NSLayoutConstraint.activating([
            containerDataView.relativeTo(segmentedControlView, positioned: .belowWidth(spacing: DimensKeys.marginMedium)),
            containerDataView.relativeTo(self, positioned: .bottom())
        ])
    }
    
    private func setUpResponseDataViewConstraints() {
        containerDataView.addSubview(containerResponseDataView)
        if !hasResponse {
            containerResponseDataView.addSubview(titleResponseLabel)
            NSLayoutConstraint.activating([
                containerResponseDataView.relativeTo(containerDataView, positioned: .allAnchors()),
                titleResponseLabel.relativeTo(containerResponseDataView, positioned: .top() + .width() + .bottom(margin: DimensKeys.marginSmall)),
            ])
        } else {
            setUpTableViewResponseConstraints()
        }
    }
    
    private func setUpTableViewResponseConstraints() {
        titleResponseLabel.removeFromSuperview()
        containerResponseDataView.addSubview(containerResponseTableView)
        containerResponseTableView.addSubview(titleResponseTableLabel)
        containerResponseTableView.addSubview(tableViewResponseView)
        tableViewResponseView.addSubview(dataResponseTableView)
        
        NSLayoutConstraint.activating([
            containerResponseDataView.relativeTo(containerDataView, positioned: .allAnchors()),
            containerResponseTableView.relativeTo(containerResponseDataView, positioned: .top() + .width()),
            containerResponseTableView.relativeTo(containerDataView, positioned: .bottom(margin: DimensKeys.marginSmall)),
            titleResponseTableLabel.relativeTo(containerResponseTableView, positioned: .top(margin: DimensKeys.marginMedium) + .left(margin: DimensKeys.marginMedium) + .right(margin: DimensKeys.marginMedium)),
            tableViewResponseView.relativeTo(titleResponseTableLabel, positioned: .below(spacing: DimensKeys.margin)),
            tableViewResponseView.relativeTo(containerResponseTableView, positioned: .width(DimensKeys.marginSmall) + .bottom(margin: DimensKeys.marginSmall) + .constantHeight(200)),
            dataResponseTableView.relativeTo(tableViewResponseView, positioned: .top(margin: DimensKeys.marginMedium) + .width() + .bottom(margin: DimensKeys.marginMedium))
        ])
    }
    
    private func setUpCodeExampleDataViewConstraints() {
        containerDataView.addSubview(containerCodeExampleDataView)
        containerCodeExampleDataView.addSubview(titleCodeExampleView)
        containerCodeExampleDataView.addSubview(codeExampleImage)
        NSLayoutConstraint.activating([
            containerCodeExampleDataView.relativeTo(containerDataView, positioned: .allAnchors()),
            titleCodeExampleView.relativeTo(containerCodeExampleDataView, positioned: .top() + .width()),
            codeExampleImage.relativeTo(titleCodeExampleView, positioned: .below(spacing: DimensKeys.marginMedium)),
            codeExampleImage.relativeTo(containerCodeExampleDataView, positioned: .width() + .bottom())
        ])
    }
    
    func defaultTabClicked() {
        segmentedControlView.selectResponseTab()
    }
    
    func setResponseData(_ type: ResponseViewType, data: Any) {
        switch type {
        case .error:
            containerResponseTableView.backgroundColor = #colorLiteral(red: 0.762173593, green: 0.1921957731, blue: 0.0952751264, alpha: 1)
        case .success:
            containerResponseTableView.backgroundColor = #colorLiteral(red: 0, green: 0.5019607843, blue: 0.3098039216, alpha: 1)
        }
        
        hasResponse = true
        setUpTableViewResponseConstraints()
        
        let requestedDictionary = toDict(data: data)
        let filterData = requestedDictionary.filter { $1 != nil }
        dataResponseDict = filterData.map{ (key: $0.key, value: "\($0.value ?? "nil")")  }
        dataResponseTableView.reloadData()
    }
    
    func toDict(data: Any) -> [String: Any?] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: data)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
    
    private func formatedDescriptionLabel() -> NSAttributedString {
        let firstAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 16)]
        let secondAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.boldSystemFont(ofSize: 16)]

        let firstString = NSMutableAttributedString(string: "Find the code below in this file: \(locationLabel ?? "")/", attributes: firstAttributes)
        let secondString = NSAttributedString(string: fileLabel ?? "", attributes: secondAttributes)
        firstString.append(secondString)
        return firstString
    }
}

extension CodeExampleResponseView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataResponseDict.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DimensKeys.cellId, for: indexPath) as! TitleSubtitleCell
        let item = dataResponseDict[indexPath.row]
        cell.title = item.key
        cell.subTitle = item.value
        cell.selectionStyle = .none
        return cell
    }
}

extension CodeExampleResponseView: SegmentedControlProtocol {
    
    func onFirstTab() {
        containerCodeExampleDataView.removeFromSuperview()
        setUpResponseDataViewConstraints()
        layoutIfNeeded()
    }
    
    func onSecondTab() {
        containerResponseDataView.removeFromSuperview()
        setUpCodeExampleDataViewConstraints()
        layoutIfNeeded()
    }
}

import UIKit
import GlobalPayments_iOS_SDK

protocol DisputeListFormDelegate: class {
    func onSubmitForm(_ form: DisputeListForm)
}

final class DisputeListFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Disputes"
    
    private let defaultDisputeId = "DIS_SAND_abcd1235"
    private let defaultPage = "1"
    private let defaultPageSize = "5"

    weak var delegate: DisputeListFormDelegate?

    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var pageLabel: UILabel!
    @IBOutlet private weak var pageTextField: UITextField!
    @IBOutlet private weak var pageSizeLabel: UILabel!
    @IBOutlet private weak var pageSizeTextField: UITextField!
    @IBOutlet private weak var orderByLabel: UILabel!
    @IBOutlet private weak var orderByTextField: UITextField!
    @IBOutlet private weak var orderLabel: UILabel!
    @IBOutlet private weak var orderTextField: UITextField!
    @IBOutlet private weak var arnLabel: UILabel!
    @IBOutlet private weak var arnTextField: UITextField!
    @IBOutlet private weak var brandLabel: UILabel!
    @IBOutlet private weak var brandTextField: UITextField!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusTextField: UITextField!
    @IBOutlet private weak var stageLabel: UILabel!
    @IBOutlet private weak var stageTextField: UITextField!
    @IBOutlet private weak var fromStageTimeCreatedLabel: UILabel!
    @IBOutlet private weak var fromStageTimeCreatedTextField: UITextField!
    @IBOutlet private weak var toStageTimeCreatedLabel: UILabel!
    @IBOutlet private weak var toStageTimeCreatedTextField: UITextField!
    @IBOutlet private weak var systemMIDLabel: UILabel!
    @IBOutlet private weak var systemMIDTextField: UITextField!
    @IBOutlet private weak var systemHierarchyLabel: UILabel!
    @IBOutlet private weak var systemHierarchyTextField: UITextField!
    @IBOutlet private weak var settlementsLabel: UILabel!
    @IBOutlet private weak var disputeIdLabel: UILabel!
    @IBOutlet private weak var disputeIdTextField: UITextField!
    @IBOutlet private weak var startDateLabel: UILabel!
    @IBOutlet private weak var startDateTextField: UITextField!
    @IBOutlet private weak var endDateLabel: UILabel!
    @IBOutlet private weak var endDateTextField: UITextField!
    @IBOutlet private weak var settlementsSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "dispute.list.form.title".localized()
        navigationItem.rightBarButtonItem = NavigationItems.cancel(self, #selector(onCancelAction)).button
        submitButton.apply(style: .globalPayStyle, title: "dispute.list.form.submit".localized())
        pageLabel.text = "dispute.list.form.page".localized()
        pageTextField.text = defaultPage
        pageSizeLabel.text = "dispute.list.form.page.size".localized()
        pageSizeTextField.text = defaultPageSize
        orderByLabel.text = "dispute.list.form.order.by".localized()
        orderByTextField.loadDropDownData(DisputeSortProperty.allCases.map { $0.rawValue })
        orderLabel.text = "dispute.list.form.order".localized()
        orderTextField.loadDropDownData(SortDirection.allCases.map { $0.rawValue.uppercased() })
        arnLabel.text = "dispute.list.form.arn".localized()
        arnTextField.placeholder = "generic.empty".localized()
        brandLabel.text = "dispute.list.form.brand".localized()
        let brandData = ["NONE"] + CardBrand.allCases.map { $0.rawValue.uppercased() }
        brandTextField.loadDropDownData(brandData)
        statusLabel.text = "dispute.list.form.status".localized()
        let disputeStatusData = ["NONE"] + DisputeStatus.allCases.map { $0.rawValue.uppercased() }
        statusTextField.loadDropDownData(disputeStatusData)
        stageLabel.text = "dispute.list.form.stage".localized()
        let disputeStageData = ["NONE"] + DisputeStage.allCases.map { $0.rawValue.uppercased() }
        stageTextField.loadDropDownData(disputeStageData)
        fromStageTimeCreatedLabel.text = "dispute.list.form.from.stage.time.created".localized()
        fromStageTimeCreatedTextField.loadDate()
        fromStageTimeCreatedTextField.placeholder = "generic.empty".localized()
        toStageTimeCreatedLabel.text = "dispute.list.form.to.stage.time.created".localized()
        toStageTimeCreatedTextField.loadDate()
        toStageTimeCreatedTextField.placeholder = "generic.empty".localized()
        systemMIDLabel.text = "dispute.list.form.system.mid".localized()
        systemMIDTextField.placeholder = "generic.empty".localized()
        systemHierarchyLabel.text = "dispute.list.form.system.hierarchy".localized()
        systemHierarchyTextField.placeholder = "generic.empty".localized()
        disputeIdLabel.text = "dispute.by.id".localized()
        disputeIdTextField.text = defaultDisputeId
        startDateLabel.text = "transaction.report.list.start.date".localized()
        startDateTextField.placeholder = "generic.empty".localized()
        startDateTextField.loadDate()
        endDateLabel.text = "transaction.report.list.end.date".localized()
        endDateTextField.placeholder = "generic.empty".localized()
        endDateTextField.loadDate()
        settlementsLabel.text = "dispute.list.form.settlements".localized()
    }

    // MARK: - Actions

    @objc private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let pageValue = pageTextField.text, !pageValue.isEmpty, let page = Int(pageValue) else { return }
        guard let pageSizeValue = pageSizeTextField.text, !pageSizeValue.isEmpty, let pageSize = Int(pageSizeValue) else { return }
        guard let sortProperty = DisputeSortProperty(value: orderByTextField.text) else { return }
        guard let sortOrder = SortDirection(value: orderTextField.text) else { return }
        guard let stage = DisputeStage(value: stageTextField.text) else { return }
        guard let brand = CardBrand(value: brandTextField.text?.lowercased()) else {return}
        let source: DisputeListForm.Source = settlementsSwitch.isOn ? .settlement : .regular

        let form = DisputeListForm(
            page: page,
            pageSize: pageSize,
            sortProperty: sortProperty,
            sordOrder: sortOrder,
            arn: arnTextField.text,
            brand: brand.rawValue.uppercased(),
            status: DisputeStatus(value: statusTextField.text),
            stage: stage,
            fromStageTimeCreated: fromStageTimeCreatedTextField.text?.formattedDate(),
            toStageTimeCreated: toStageTimeCreatedTextField.text?.formattedDate(),
            systemMID: systemMIDTextField.text,
            systemHierarchy: systemHierarchyTextField.text,
            disputeId: disputeIdTextField.text,
            fromTimeCreated: startDateTextField.text?.formattedDate(),
            toTimeCreated: endDateTextField.text?.formattedDate(),
            source: source
        )

        delegate?.onSubmitForm(form)
        dismiss(animated: true, completion: nil)
    }
}

import UIKit
import GlobalPayments_iOS_SDK

protocol DepositsListFormDelegate: class {
    func onSubmitForm(_ form: DepositsListForm)
}

final class DepositsListFormViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Deposits"

    weak var delegate: DepositsListFormDelegate?

    private let defaultPage = "1"
    private let defaultPageSize = "5"

    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var pageLabel: UILabel!
    @IBOutlet private weak var pageTextField: UITextField!
    @IBOutlet private weak var pageSizeLabel: UILabel!
    @IBOutlet private weak var pageSizeTextField: UITextField!
    @IBOutlet private weak var orderyByLabel: UILabel!
    @IBOutlet private weak var orderyByTextField: UITextField!
    @IBOutlet private weak var orderLabel: UILabel!
    @IBOutlet private weak var orderTextField: UITextField!
    @IBOutlet private weak var accountNameLabel: UILabel!
    @IBOutlet private weak var accountNameTextField: UITextField!
    @IBOutlet private weak var fromTimeCreatedLabel: UILabel!
    @IBOutlet private weak var fromTimeCreatedTextField: UITextField!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var idTextField: UITextField!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusTextField: UITextField!
    @IBOutlet private weak var toTimeCretedLabel: UILabel!
    @IBOutlet private weak var toTimeCretedTextField: UITextField!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var maskedNumberLabel: UILabel!
    @IBOutlet private weak var maskedNumberTextField: UITextField!
    @IBOutlet private weak var systemMIDLabel: UILabel!
    @IBOutlet private weak var systemMIDTextField: UITextField!
    @IBOutlet private weak var systemHierarchyLabel: UILabel!
    @IBOutlet private weak var systemHierarchyTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        navigationBar.topItem?.title = "deposits.list.form.title".localized()
        submitButton.apply(style: .globalPayStyle, title: "deposits.list.form.submit".localized())
        pageLabel.text = "deposits.list.form.page".localized()
        pageTextField.text = defaultPage
        pageSizeLabel.text = "deposits.list.form.page.size".localized()
        pageSizeTextField.text = defaultPageSize
        orderyByLabel.text = "deposits.list.form.order.by".localized()
        orderyByTextField.loadDropDownData(DepositSortProperty.allCases.map { $0.rawValue })
        orderLabel.text = "deposits.list.form.order".localized()
        orderTextField.loadDropDownData(SortDirection.allCases.map { $0.rawValue.uppercased() })
        accountNameLabel.text = "deposits.list.form.account.name".localized()
        accountNameTextField.placeholder = "generic.empty".localized()
        fromTimeCreatedLabel.text = "deposits.list.form.from.time.created".localized()
        fromTimeCreatedTextField.placeholder = "generic.empty".localized()
        fromTimeCreatedTextField.loadDate()
        idLabel.text = "deposits.list.form.id".localized()
        idTextField.placeholder = "generic.empty".localized()
        statusLabel.text = "deposits.list.form.status".localized()
        let depositStatusData = ["NONE"] + DepositStatus.allCases.map { $0.rawValue.uppercased() }
        statusTextField.loadDropDownData(depositStatusData)
        toTimeCretedLabel.text = "deposits.list.form.to.time.created".localized()
        toTimeCretedTextField.placeholder = "generic.empty".localized()
        toTimeCretedTextField.loadDate()
        amountLabel.text = "deposits.list.form.amount".localized()
        amountTextField.placeholder = "generic.empty".localized()
        maskedNumberLabel.text = "deposits.list.form.masked.number".localized()
        maskedNumberTextField.placeholder = "generic.empty".localized()
        systemMIDLabel.text = "deposits.list.form.system.mid".localized()
        systemMIDTextField.placeholder = "generic.empty".localized()
        systemHierarchyLabel.text = "deposits.list.form.system.hierarchy".localized()
        systemHierarchyTextField.placeholder = "generic.empty".localized()
    }

    // MARK: - Actions

    @IBAction private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onSubmitAction() {
        guard let orderBy = DepositSortProperty(value: orderyByTextField.text) else { return }
        guard let order = SortDirection(value: orderTextField.text) else { return }
        let form = DepositsListForm(
            page: Int(pageTextField.text ?? defaultPage)!,
            pageSize: Int(pageSizeTextField.text ?? defaultPageSize)!,
            orderBy: orderBy,
            order: order,
            accountName: accountNameTextField.text,
            fromTimeCreated: fromTimeCreatedTextField.text?.formattedDate(),
            id: idTextField.text,
            status: DepositStatus(value: statusTextField.text),
            toTimeCreated: toTimeCretedTextField.text?.formattedDate(),
            amount: NSDecimalNumber(string: amountTextField.text),
            maskedNumber: maskedNumberTextField.text,
            systemMID: systemMIDTextField.text,
            systemHierarchy: systemHierarchyTextField.text
        )
        delegate?.onSubmitForm(form)
        dismiss(animated: true, completion: nil)
    }

    func generateDate() {

    }
}

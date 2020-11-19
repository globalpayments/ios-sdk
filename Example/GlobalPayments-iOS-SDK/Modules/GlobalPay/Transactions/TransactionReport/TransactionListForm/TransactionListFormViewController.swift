import UIKit
import GlobalPayments_iOS_SDK

protocol TransactionListFormDelegate: class {
    func onSubmitForm(form: TransactionListForm)
}

final class TransactionListFormViewController: UIViewController, StoryboardInstantiable {

    private let defaultPage = "1"
    private let defaultPageSize = "5"

    static var storyboardName = "Transactions"

    weak var delegate: TransactionListFormDelegate?

    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var sortByPropertyLabel: UILabel!
    @IBOutlet private weak var sortByPropertyTextField: UITextField!
    @IBOutlet private weak var sortOrderLabel: UILabel!
    @IBOutlet private weak var sortOrderTextField: UITextField!
    @IBOutlet private weak var pageLabel: UILabel!
    @IBOutlet private weak var pageTextField: UITextField!
    @IBOutlet private weak var pageSizeLabel: UILabel!
    @IBOutlet private weak var pageSizeTextField: UITextField!
    @IBOutlet private weak var transactionIdLabel: UILabel!
    @IBOutlet private weak var transactionIdTextField: UITextField!
    @IBOutlet private weak var accountNameLabel: UILabel!
    @IBOutlet private weak var accountNameTextField: UITextField!
    @IBOutlet private weak var cardBrandLabel: UILabel!
    @IBOutlet private weak var cardBrandTextField: UITextField!
    @IBOutlet private weak var maskedCardNumberLabel: UILabel!
    @IBOutlet private weak var maskedCardNumberTextField: UITextField!
    @IBOutlet private weak var arnLabel: UILabel!
    @IBOutlet private weak var arnTextField: UITextField!
    @IBOutlet private weak var brandReferenceLabel: UILabel!
    @IBOutlet private weak var brandReferenceTextField: UITextField!
    @IBOutlet private weak var authCodeLabel: UILabel!
    @IBOutlet private weak var authCodeTextField: UITextField!
    @IBOutlet private weak var referenceNumberLabel: UILabel!
    @IBOutlet private weak var referenceNumberTextField: UITextField!
    @IBOutlet private weak var transactionStatusLabel: UILabel!
    @IBOutlet private weak var transactionStatusTextField: UITextField!
    @IBOutlet private weak var startDateLabel: UILabel!
    @IBOutlet private weak var startDateTextField: UITextField!
    @IBOutlet private weak var endDateLabel: UILabel!
    @IBOutlet private weak var endDateTextField: UITextField!
    @IBOutlet private weak var depositReferenceLabel: UILabel!
    @IBOutlet private weak var depositReferenceTextField: UITextField!
    @IBOutlet private weak var startDepositDateLabel: UILabel!
    @IBOutlet private weak var startDepositDateTextField: UITextField!
    @IBOutlet private weak var endDepositDateLabel: UILabel!
    @IBOutlet private weak var endDepositDateTextField: UITextField!
    @IBOutlet private weak var startBatchDateLabel: UILabel!
    @IBOutlet private weak var startBatchDateTextField: UITextField!
    @IBOutlet private weak var endBatchDateLabel: UILabel!
    @IBOutlet private weak var endBatchDateTextField: UITextField!
    @IBOutlet private weak var merchantIdLabel: UILabel!
    @IBOutlet private weak var merchantIdTextField: UITextField!
    @IBOutlet private weak var systemHierarchyLabel: UILabel!
    @IBOutlet private weak var systemHierarchyTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        submitButton.apply(style: .globalPayStyle)
        submitButton.setTitle("transaction.report.list.submit".localized(), for: .normal)
        navigationBar.topItem?.title = "transaction.report.list.title".localized()
        sortByPropertyLabel.text = "transaction.report.list.sort.by.property".localized()
        sortByPropertyTextField.loadDropDownData(TransactionSortProperty.allCases.map { $0.rawValue.uppercased() })
        sortOrderLabel.text = "transaction.report.list.sort.order".localized()
        sortOrderTextField.loadDropDownData(SortDirection.allCases.map { $0.rawValue.uppercased() })
        pageLabel.text = "transaction.report.list.page".localized()
        pageTextField.text = defaultPage
        pageSizeLabel.text = "transaction.report.list.page.size".localized()
        pageSizeTextField.text = defaultPageSize
        transactionIdLabel.text = "transaction.report.list.transaction.id".localized()
        transactionIdTextField.placeholder = "generic.empty".localized()
        accountNameLabel.text = "transaction.report.list.account.name".localized()
        accountNameTextField.placeholder = "generic.empty".localized()
        cardBrandLabel.text = "transaction.report.list.card.brand".localized()
        cardBrandTextField.placeholder = "generic.empty".localized()
        maskedCardNumberLabel.text = "transaction.report.list.masked.card.number".localized()
        maskedCardNumberTextField.placeholder = "generic.empty".localized()
        arnLabel.text = "transaction.report.list.arn".localized()
        arnTextField.placeholder = "generic.empty".localized()
        brandReferenceLabel.text = "transaction.report.list.brand.reference".localized()
        brandReferenceTextField.placeholder = "generic.empty".localized()
        authCodeLabel.text = "transaction.report.list.auth.code".localized()
        authCodeTextField.placeholder = "generic.empty".localized()
        referenceNumberLabel.text = "transaction.report.list.reference.number".localized()
        referenceNumberTextField.placeholder = "generic.empty".localized()
        transactionStatusLabel.text = "transaction.report.list.transaction.status".localized()
        let transactionStatusData = ["NONE"] + TransactionStatus.allCases.map { $0.rawValue.uppercased() }
        transactionStatusTextField.loadDropDownData(transactionStatusData)
        startDateLabel.text = "transaction.report.list.start.date".localized()
        startDateTextField.placeholder = "generic.empty".localized()
        startDateTextField.loadDate()
        endDateLabel.text = "transaction.report.list.end.date".localized()
        endDateTextField.placeholder = "generic.empty".localized()
        endDateTextField.loadDate()
        depositReferenceLabel.text = "transaction.report.list.deposit.reference".localized()
        depositReferenceTextField.placeholder = "generic.empty".localized()
        startDepositDateLabel.text = "transaction.report.list.start.deposit.date".localized()
        startDepositDateTextField.placeholder = "generic.empty".localized()
        startDepositDateTextField.loadDate()
        endDepositDateLabel.text = "transaction.report.list.end.deposit.date".localized()
        endDepositDateTextField.placeholder = "generic.empty".localized()
        endDepositDateTextField.loadDate()
        startBatchDateLabel.text = "transaction.report.list.start.batch.date".localized()
        startBatchDateTextField.placeholder = "generic.empty".localized()
        startBatchDateTextField.loadDate()
        endBatchDateLabel.text = "transaction.report.list.end.batch.date".localized()
        endBatchDateTextField.placeholder = "generic.empty".localized()
        endBatchDateTextField.loadDate()
        merchantIdLabel.text = "transaction.report.list.merchant.id".localized()
        merchantIdTextField.placeholder = "generic.empty".localized()
        systemHierarchyLabel.text = "transaction.report.list.system.hierarchy".localized()
        systemHierarchyTextField.placeholder = "generic.empty".localized()
    }

    // MARK: - Actions

    @IBAction private func onSubmitAction() {
        let form = TransactionListForm(
            sortProperty: TransactionSortProperty(value: sortByPropertyTextField.text) ?? .timeCreated,
            sordOrder: SortDirection(value: sortOrderTextField.text) ?? .descending,
            page: Int(pageTextField.text ?? defaultPage)!,
            pageSize: Int(pageSizeTextField.text ?? defaultPageSize)!,
            transactionId: transactionIdTextField.text,
            accountName: accountNameTextField.text,
            cardBrand: cardBrandTextField.text,
            maskedCardNumber: maskedCardNumberTextField.text,
            arn: arnTextField.text,
            brandReference: brandReferenceTextField.text,
            authCode: authCodeTextField.text,
            referenceNumber: referenceNumberTextField.text,
            transactionStatus: TransactionStatus(value: transactionStatusTextField.text),
            startDate: startDateTextField.text?.formattedDate(),
            endDate: endDateTextField.text?.formattedDate(),
            depositReference: depositReferenceTextField.text,
            startDepositDate: startDepositDateTextField.text?.formattedDate(),
            endDepositDate: endDepositDateTextField.text?.formattedDate(),
            startBatchDate: startBatchDateTextField.text?.formattedDate(),
            endBatchDate: endBatchDateTextField.text?.formattedDate(),
            merchantId: merchantIdTextField.text,
            systemHierarchy: systemHierarchyTextField.text
        )
        delegate?.onSubmitForm(form: form)
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }
}

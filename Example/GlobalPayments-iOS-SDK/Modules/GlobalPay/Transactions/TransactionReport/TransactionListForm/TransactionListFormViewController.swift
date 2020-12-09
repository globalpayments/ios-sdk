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

    @IBOutlet private weak var pageLabel: UILabel!
    @IBOutlet private weak var pageTextField: UITextField!
    @IBOutlet private weak var pageSizeLabel: UILabel!
    @IBOutlet private weak var pageSizeTextField: UITextField!
    @IBOutlet private weak var sortByPropertyLabel: UILabel!
    @IBOutlet private weak var sortByPropertyTextField: UITextField!
    @IBOutlet private weak var sortOrderLabel: UILabel!
    @IBOutlet private weak var sortOrderTextField: UITextField!
    @IBOutlet private weak var transactionIdLabel: UILabel!
    @IBOutlet private weak var transactionIdTextField: UITextField!
    @IBOutlet private weak var paymentTypeLabel: UILabel!
    @IBOutlet private weak var paymentTypeTextField: UITextField!
    @IBOutlet private weak var channelLabel: UILabel!
    @IBOutlet private weak var channelTextField: UITextField!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var currencyTextField: UITextField!
    @IBOutlet private weak var numberFirstSixLabel: UILabel!
    @IBOutlet private weak var numberFirstSixTextField: UITextField!
    @IBOutlet private weak var numberLastFourLabel: UILabel!
    @IBOutlet private weak var numberLastFourTextField: UITextField!
    @IBOutlet private weak var tokenFirstSixLabel: UILabel!
    @IBOutlet private weak var tokenFirstSixTextField: UITextField!
    @IBOutlet private weak var tokenLastFourLabel: UILabel!
    @IBOutlet private weak var tokenLastFourTextField: UITextField!
    @IBOutlet private weak var accountNameLabel: UILabel!
    @IBOutlet private weak var accountNameTextField: UITextField!
    @IBOutlet private weak var cardBrandLabel: UILabel!
    @IBOutlet private weak var cardBrandTextField: UITextField!
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
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var countryTextField: UITextField!
    @IBOutlet private weak var batchReferenceLabel: UILabel!
    @IBOutlet private weak var batchReferenceTextField: UITextField!
    @IBOutlet private weak var entryModeLabel: UILabel!
    @IBOutlet private weak var entryModeTextField: UITextField!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        submitButton.apply(style: .globalPayStyle, title: "transaction.report.list.submit".localized())
        navigationBar.topItem?.title = "transaction.report.list.title".localized()

        pageLabel.text = "transaction.report.list.page".localized()
        pageTextField.text = defaultPage
        pageSizeLabel.text = "transaction.report.list.page.size".localized()
        pageSizeTextField.text = defaultPageSize
        sortByPropertyLabel.text = "transaction.report.list.sort.by.property".localized()
        sortByPropertyTextField.loadDropDownData(TransactionSortProperty.allCases.map { $0.rawValue.uppercased() })
        sortOrderLabel.text = "transaction.report.list.sort.order".localized()
        sortOrderTextField.loadDropDownData(SortDirection.allCases.map { $0.rawValue.uppercased() })
        transactionIdLabel.text = "transaction.report.list.transaction.id".localized()
        transactionIdTextField.placeholder = "generic.empty".localized()
        paymentTypeLabel.text = "transaction.report.list.payment.type".localized();
        let paymentTypeData = ["NONE"] + PaymentType.allCases.map { $0.rawValue.uppercased() }
        paymentTypeTextField.loadDropDownData(paymentTypeData)
        channelLabel.text = "transaction.report.list.channel".localized()
        let channelData = ["NONE"] + Channel.allCases.map { $0.rawValue.uppercased() }
        channelTextField.loadDropDownData(channelData)
        amountLabel.text = "transaction.report.list.amount".localized()
        amountTextField.placeholder = "generic.empty".localized()
        currencyLabel.text = "transaction.report.list.currency".localized()
        currencyTextField.placeholder = "generic.empty".localized()
        numberFirstSixLabel.text = "transaction.report.list.number.first.6".localized()
        numberFirstSixTextField.placeholder = "generic.empty".localized()
        numberLastFourLabel.text = "transaction.report.list.number.last.4".localized()
        numberLastFourTextField.placeholder = "generic.empty".localized()
        tokenFirstSixLabel.text = "transaction.report.list.token.first.6".localized()
        tokenFirstSixTextField.placeholder = "generic.empty".localized()
        tokenLastFourLabel.text = "transaction.report.list.token.last.4".localized()
        tokenLastFourTextField.placeholder = "generic.empty".localized()
        accountNameLabel.text = "transaction.report.list.account.name".localized()
        accountNameTextField.placeholder = "generic.empty".localized()
        cardBrandLabel.text = "transaction.report.list.card.brand".localized()
        cardBrandTextField.placeholder = "generic.empty".localized()
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
        countryLabel.text = "transaction.report.list.country".localized()
        countryTextField.placeholder = "generic.empty".localized()
        batchReferenceLabel.text = "transaction.report.list.batch.id".localized()
        batchReferenceTextField.placeholder = "generic.empty".localized()
        entryModeLabel.text = "transaction.report.list.entry.mode".localized()
        let entryModeData = ["NONE"] + PaymentEntryMode.allCases.map { $0.rawValue.uppercased() }
        entryModeTextField.loadDropDownData(entryModeData)
        nameLabel.text = "transaction.report.list.name".localized()
        nameTextField.placeholder = "generic.empty".localized()
    }

    // MARK: - Actions

    @IBAction private func onSubmitAction() {
        let form = TransactionListForm(
            page: Int(pageTextField.text ?? defaultPage)!,
            pageSize: Int(pageSizeTextField.text ?? defaultPageSize)!,
            sortProperty: TransactionSortProperty(value: sortByPropertyTextField.text) ?? .timeCreated,
            sordOrder: SortDirection(value: sortOrderTextField.text) ?? .descending,
            transactionId: transactionIdTextField.text,
            type: PaymentType(value: paymentTypeTextField.text),
            channel: Channel(value: channelTextField.text),
            amount: NSDecimalNumber(string: amountTextField.text),
            currency: currencyTextField.text,
            numberFirst6: numberFirstSixTextField.text,
            numberLast4: numberLastFourTextField.text,
            tokenFirst6: tokenFirstSixTextField.text,
            tokenLast4: tokenLastFourTextField.text,
            accountName: accountNameTextField.text,
            cardBrand: cardBrandTextField.text,
            brandReference: brandReferenceTextField.text,
            authCode: authCodeTextField.text,
            referenceNumber: referenceNumberTextField.text,
            transactionStatus: TransactionStatus(value: transactionStatusTextField.text),
            startDate: startDateTextField.text?.formattedDate(),
            endDate: endDateTextField.text?.formattedDate(),
            country: countryTextField.text,
            batchId: batchReferenceTextField.text,
            entryMode: PaymentEntryMode(value: entryModeTextField.text)
        )
        delegate?.onSubmitForm(form: form)
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func onCancelAction() {
        dismiss(animated: true, completion: nil)
    }
}

import UIKit
import PDFKit
import GlobalPayments_iOS_SDK

final class DisputeReportViewController: UIViewController, StoryboardInstantiable {

    static var storyboardName = "Disputes"

    var viewModel: DisputeReportViewInput!

    @IBOutlet private weak var disputeListButton: UIButton!
    @IBOutlet private weak var disputeIdButton: UIButton!
    @IBOutlet private weak var documentIdButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = "disputes.report.title".localized()
        disputeListButton.apply(style: .globalPayStyle, title: "disputes.report.dispute.list".localized())
        disputeIdButton.apply(style: .globalPayStyle, title: "disputes.report.dispute.by.id".localized())
        documentIdButton.apply(style: .globalPayStyle, title: "disputes.report.document.by.id".localized())
        activityIndicator.stopAnimating()

        setupTable()
    }

    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: DisputeSummaryTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: DisputeSummaryTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }

    // MARK: - Actions

    @IBAction private func onDisputeListAction() {
        let form = DisputeListFormBuilder.build(with: self)
        present(form, animated: true, completion: nil)
    }

    @IBAction private func onGetDisputeByIdAction() {
        let form = DisputeByIDFormBuilder.build(with: self)
        present(form, animated: true, completion: nil)
    }

    @IBAction private func onGetDocumentByIdAction() {
        let form = DisputeDocumentFormBuilder.build(with: self)
        present(form, animated: true, completion: nil)
    }

    private func onShowDisputeDocuments(_ documents: [DisputeDocument]?) {
        let module = DisputeDocumentBuilder.build(with: documents)
        present(module, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension DisputeReportViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.disputes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DisputeSummaryTableViewCell.identifier, for: indexPath) as! DisputeSummaryTableViewCell
        cell.setup(viewModel: viewModel.disputes[indexPath.row])
        cell.onSelectDocuments = onShowDisputeDocuments
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DisputeReportViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - DisputeReportViewOutput

extension DisputeReportViewController: DisputeReportViewOutput {

    func showErrorView(error: Error?) {
        activityIndicator.stopAnimating()
        let errorView = ErrorView.instantiateFromNib()
        errorView.display(error)
        tableView.backgroundView = errorView
    }

    func showPDF(_ data: Data) {
        activityIndicator.stopAnimating()
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        tableView.backgroundView = pdfView
    }

    func reloadData() {
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }

    func displayEmptyView() {
        tableView.backgroundView = EmptyView.instantiateFromNib()
    }
}

// MARK: - DisputeDocumentFormDelegate

extension DisputeReportViewController: DisputeDocumentFormDelegate {

    func onComletedForm(_ form: DisputeDocumentForm) {
        tableView.backgroundView?.clearSubviews()
        viewModel.clearDisputes()
        activityIndicator.startAnimating()
        viewModel.getDocument(form: form)
    }
}

// MARK: - DisputeByIDFormDelegate

extension DisputeReportViewController: DisputeByIDFormDelegate {

    func onComletedForm(_ form: DisputeByIDForm) {
        tableView.backgroundView?.clearSubviews()
        viewModel.clearDisputes()
        activityIndicator.startAnimating()
        viewModel.getDisputeDetails(form: form)
    }
}

// MARK: - DisputeListFormDelegate

extension DisputeReportViewController: DisputeListFormDelegate {

    func onSubmitForm(_ form: DisputeListForm) {
        tableView.backgroundView?.clearSubviews()
        viewModel.clearDisputes()
        activityIndicator.startAnimating()
        viewModel.getDusputeList(form: form)
    }
}

import XCTest
import GlobalPayments_iOS_SDK

class GpApiReportingDisputesTests: XCTestCase {

    override class func setUp() {
        super.setUp()

        try? ServicesContainer.configureService(config: GpApiConfig(
            appId: "GkwdYGzQrEy1SdTz7S10P8uRjFMlEsJg",
            appKey: "zvXE2DmmoxPbQ6d0",
            channel: .cardNotPresent
        ))
    }

    // MARK: - DISPUTES

    func test_report_find_disputes_without_criteria() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 50)
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .toAdjustmentTimeCreated, .descending)
            .where(.startStageDate, startStageDate)
            .execute {
                disputeSummaryList = $0?.results
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_disputes_with_multiple_criteria() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let expectedDisputeStage = DisputeStage.compliance
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 30)
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .brand, .ascending)
            .withDisputeStage(expectedDisputeStage)
            .where(.startStageDate, startStageDate)
            .execute {
                disputeSummaryList = $0?.results
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let caseStage = dispute.caseStage else {
                    XCTFail("caseStage cannot be nil")
                    return
                }
                XCTAssertEqual(caseStage, expectedDisputeStage)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func report_find_disputes_by_status() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let expectedDisputeStatus: DisputeStatus = .underReview
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        reportingService
            .where(.startStageDate, startStageDate)
            .and(disputeStatus: expectedDisputeStatus)
            .execute {
                disputeSummaryList = $0?.results
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let caseStatus = dispute.caseStatus else {
                    XCTFail("caseStatus cannot be nil")
                    return
                }
                XCTAssertEqual(caseStatus, expectedDisputeStatus.mapped(for: .gpApi))
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_disputes_by_arn() {
        guard let aquirerReferenceNumber = try? awaitResponse(getDisputeSummary, calledWith: .underReview)?.transactionARN else {
            XCTFail("aquirerReferenceNumber cannot be nil")
            return
        }

        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        reportingService
            .where(.startStageDate, startStageDate)
            .and(searchCriteria: .aquirerReferenceNumber, value: aquirerReferenceNumber)
            .execute {
                disputeSummaryList = $0?.results
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let transactionARN = dispute.transactionARN else {
                    XCTFail("caseStatus cannot be nil")
                    return
                }
                XCTAssertEqual(transactionARN, aquirerReferenceNumber)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_disputes_by_stage() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let expectedDisputeStage = DisputeStage.chargeback
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        reportingService
            .where(.startStageDate, startStageDate)
            .and(disputeStage: expectedDisputeStage)
            .execute {
                disputeSummaryList = $0?.results
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let caseStage = dispute.caseStage else {
                    XCTFail("caseStage cannot be nil")
                    return
                }
                XCTAssertEqual(caseStage, expectedDisputeStage)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_disputes_by_merchantId_and_systemHierarchy() {
        guard let disputeSummary = try? awaitResponse(getDisputeSummary, calledWith: .underReview),
              let expectedMerchantId = disputeSummary.caseMerchantId,
              let expectedSystemHierarchy = disputeSummary.merchantHierarchy else {
            XCTFail("caseMerchantId & merchantHierarchy cannot be nil")
            return
        }

        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        reportingService
            .where(.startStageDate, startStageDate)
            .and(dataServiceCriteria: .merchantId, value: expectedMerchantId)
            .and(dataServiceCriteria: .systemHierarchy, value: expectedSystemHierarchy)
            .execute {
                disputeSummaryList = $0?.results
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let caseMerchantId = dispute.caseMerchantId else {
                    XCTFail("caseMerchantId cannot be nil")
                    return
                }
                guard let merchantHierarchy = dispute.merchantHierarchy else {
                    XCTFail("merchantHierarchy cannot be nil")
                    return
                }
                XCTAssertEqual(caseMerchantId, expectedMerchantId)
                XCTAssertEqual(merchantHierarchy, expectedSystemHierarchy)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_disputes_order_by_id() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryIds: [String]?
        var disputeSummaryError: Error?
        var expectedSortedIds: [String]?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .id, .descending)
            .where(.startStageDate, startStageDate)
            .execute {
                disputeSummaryIds = $0?.results.compactMap { $0.caseId }
                expectedSortedIds = $0?.results.compactMap { $0.caseId }.sorted(by: >)
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryIds, expectedSortedIds)
    }

    func test_report_find_disputes_order_by_brand() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryTypes: [String]?
        var disputeSummaryError: Error?
        var expectedSortedTypes: [String]?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .brand, .descending)
            .where(.startStageDate, startStageDate)
            .execute {
                disputeSummaryTypes = $0?.results.compactMap { $0.transactionCardType }
                expectedSortedTypes = $0?.results.compactMap { $0.transactionCardType }.sorted(by: >)
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryTypes, expectedSortedTypes)
    }

    func test_report_find_disputes_order_by_status() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryStatuses: [String]?
        var disputeSummaryError: Error?
        var expectedSortedStatuses: [String]?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .status, .descending)
            .where(.startStageDate, startStageDate)
            .execute {
                disputeSummaryStatuses = $0?.results.compactMap { $0.caseStatus }
                expectedSortedStatuses = $0?.results.compactMap { $0.caseStatus }.sorted(by: >)
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryStatuses, expectedSortedStatuses)
    }

    func test_report_find_disputes_order_by_stage() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryStages: [String]?
        var disputeSummaryError: Error?
        var expectedSortedStages: [String]?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .stage, .descending)
            .where(.startStageDate, startStageDate)
            .execute {
                disputeSummaryStages = $0?.results.compactMap { $0.caseStage?.rawValue }
                expectedSortedStages = $0?.results.compactMap { $0.caseStage?.rawValue }.sorted(by: >)
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryStages, expectedSortedStages)
    }

    func test_report_find_disputes_order_by_arn() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let endStageDate = Date().addMonths(-1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 40)
        var disputeSummaryArns: [String]?
        var disputeSummaryError: Error?
        var expectedSortedArns: [String]?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .arn, .descending)
            .where(.startStageDate, startStageDate)
            // EndStageDate must be set in order to be able to sort by ARN
            .and(dataServiceCriteria: .endStageDate, value: endStageDate)
            .execute {
                disputeSummaryArns = $0?.results.compactMap { $0.transactionARN }
                expectedSortedArns = $0?.results.compactMap { $0.transactionARN }.sorted(by: >)
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryArns, expectedSortedArns)
    }

    func test_report_find_disputes_order_by_from_stage_time_created() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 40)
        var disputeSummaryDates: [Date]?
        var disputeSummaryError: Error?
        var expectedSortedDates: [Date]?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .fromStageTimeCreated, .descending)
            .where(.startStageDate, startStageDate)
            .execute {
                disputeSummaryDates = $0?.results.compactMap { $0.caseIdTime }
                expectedSortedDates = $0?.results.compactMap { $0.caseIdTime }
                                                 .sorted(by: { $0.compare($1) == .orderedAscending })
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertEqual(disputeSummaryDates, expectedSortedDates)
    }

    func test_report_find_disputes_order_by_to_stage_time_created() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 100)
        var disputeSummaryList: [Date]?
        var sortedDisputeSummaryList: [Date]?
        var disputeSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .toStageTimeCreated, .ascending)
            .where(.startStageDate, startStageDate)
            .execute {
                disputeSummaryList = $0?.results.compactMap { $0.caseIdTime }
                sortedDisputeSummaryList = $0?.results.compactMap { $0.caseIdTime }.sorted(by: <)
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        XCTAssertNotNil(sortedDisputeSummaryList)
        XCTAssertEqual(disputeSummaryList, sortedDisputeSummaryList)
    }

    func test_report_find_disputes_order_by_id_with_brand_visa() {
        guard let transactionCardType = try? awaitResponse(getDisputeSummary, calledWith: .underReview)?.transactionCardType else {
            XCTFail("transactionCardType cannot be nil")
            return
        }

        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .id, .ascending)
            .where(.startStageDate, startStageDate)
            .and(searchCriteria: .cardBrand, value: transactionCardType)
            .execute {
                disputeSummaryList = $0?.results
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        if let disputeSummaryList = disputeSummaryList {
            XCTAssertFalse(disputeSummaryList.isEmpty)
            for dispute in disputeSummaryList {
                XCTAssertEqual(dispute.transactionCardType, transactionCardType)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_disputes_order_by_id_with_status_under_review() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .id, .ascending)
            .where(.startStageDate, startStageDate)
            .and(disputeStatus: .underReview)
            .execute {
                disputeSummaryList = $0?.results
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
    }

    func test_report_find_disputes_order_by_id_with_stage_chargeback() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let expectedStage = DisputeStage.chargeback
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .id, .ascending)
            .where(.startStageDate, startStageDate)
            .and(disputeStage: .chargeback)
            .execute {
                disputeSummaryList = $0?.results
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
        if let disputeSummaryList = disputeSummaryList {
            for dispute in disputeSummaryList {
                XCTAssertEqual(dispute.caseStage, expectedStage)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_dispute_by_given_id() {
        guard let caseId = try? awaitResponse(getDisputeSummary, calledWith: .underReview)?.caseId else {
            XCTFail("caseId cannot be nil")
            return
        }

        // GIVEN
        let summaryExpectation = expectation(description: "Find Dispute By Given ID")
        var disputeSummary: DisputeSummary?
        var disputeSummaryError: Error?

        // WHEN
        ReportingService
            .disputeDetail(disputeId: caseId)
            .execute {
                disputeSummary = $0
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummary)
    }

    func test_report_accept_dispute_success() {
        guard let caseId = try? awaitResponse(getDisputeSummary, calledWith: .withMerchant)?.caseId else {
            XCTFail("caseId cannot be nil")
            return
        }

        // GIVEN
        let summaryExpectation = expectation(description: "Accept Dispute")
        var disputeAction: DisputeAction?
        var disputeActionError: Error?

        // WHEN
        ReportingService
            .acceptDispute(id: caseId)
            .execute {
                disputeAction = $0
                disputeActionError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNotNil(disputeAction)
        XCTAssertNil(disputeActionError)
    }

    func test_report_accept_dispute_failure() {
        // GIVEN
        let summaryExpectation = expectation(description: "Accept Dispute")
        let disputeId = "UNKNOWN"
        var disputeAction: DisputeAction?
        var disputeActionError: GatewayException?

        // WHEN
        ReportingService
            .acceptDispute(id: disputeId)
            .execute { action, error in
                disputeAction = action
                if let gatewayError = error as? GatewayException {
                    disputeActionError = gatewayError
                }
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 20.0)
        XCTAssertNil(disputeAction)
        XCTAssertNotNil(disputeActionError)
        XCTAssertEqual(disputeActionError?.responseCode, "INVALID_DISPUTE_ACTION")
    }

    func test_report_challange_dispute_success() {
        guard let caseId = try? awaitResponse(getDisputeSummary, calledWith: .withMerchant)?.caseId else {
            XCTFail("caseId cannot be nil")
            return
        }

        // GIVEN
        let challangeExpectation = expectation(description: "Challange Expectation")
        let bundle = Bundle(for: type(of: self))
        let disputeDocuments = [
            DocumentInfo(
                type: .proofOfDelivery,
                b64Content: ResourceLoader.loadFile(name: "gp_logo", extension: .pdf, bundle: bundle)
            )
        ]
        var disputeAction: DisputeAction?
        var disputeActionError: Error?

        // WHEN
        ReportingService
            .challangeDispute(id: caseId, documents: disputeDocuments)
            .execute { action, error in
                disputeAction = action
                disputeActionError = error
                challangeExpectation.fulfill()
            }

        // THEN
        wait(for: [challangeExpectation], timeout: 20.0)
        XCTAssertNotNil(disputeAction)
        XCTAssertNil(disputeActionError)
    }

    func test_report_find_dispute_document_success() {
        // GIVEN
        let documetExpectation = expectation(description: "Find document expectation")
        let disputeId = "DIS_SAND_abcd1235"
        let documentId = "DOC_MyEvidence_234234AVCDE-1"
        var documentMetadata: DocumentMetadata?
        var documentError: Error?

        // WHEN
        ReportingService
            .findDisputeDocument(id: documentId, disputeId: disputeId)
            .execute { metadata, error in
                documentMetadata = metadata
                documentError = error
                documetExpectation.fulfill()
            }

        // THEN
        wait(for: [documetExpectation], timeout: 10.0)
        XCTAssertNil(documentError)
        XCTAssertNotNil(documentMetadata)
        XCTAssertEqual(documentMetadata?.id, documentId)
    }

    func test_report_find_dispute_document_failure() {
        // GIVEN
        let documetExpectation = expectation(description: "Find document expectation")
        let disputeId = "UNKNOWN"
        let documentId = "UNKNOWN"
        var documentMetadata: DocumentMetadata?
        var documentError: GatewayException?

        // WHEN
        ReportingService
            .findDisputeDocument(id: documentId, disputeId: disputeId)
            .execute { metadata, error in
                documentMetadata = metadata
                if let gatewayException = error as? GatewayException {
                    documentError = gatewayException
                }
                documetExpectation.fulfill()
            }

        // THEN
        wait(for: [documetExpectation], timeout: 10.0)
        XCTAssertNil(documentMetadata)
        XCTAssertNotNil(documentError)
        XCTAssertEqual(documentError?.responseCode, "INVALID_REQUEST_DATA")
    }

    // MARK: - Settlement Disputes

    func test_report_settlement_dispute_detail() {
        guard let caseId = try? awaitResponse(getSettlementDisputeSummary)?.caseId else {
            XCTFail("caseId cannot be nil")
            return
        }

        // GIVEN
        let disputeDetailExpectation = expectation(description: "Dispute Detail Expectation")
        var disputeSummary: DisputeSummary?
        var disputeError: Error?

        // WHEN
        ReportingService
            .settlementDisputeDetail(disputeId: caseId)
            .execute {
                disputeSummary = $0
                disputeError = $1
                disputeDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [disputeDetailExpectation], timeout: 10.0)
        XCTAssertNil(disputeError)
        XCTAssertNotNil(disputeSummary)
        XCTAssertEqual(disputeSummary?.caseId, caseId)
    }

    func test_report_find_settlement_disputes_order_by_id() {
        // GIVEN
        let disputeDetailExpectation = expectation(description: "Dispute Detail Expectation")
        let startDate = Date().addYears(-2).addMonths(1)
        let reportingService = ReportingService.findSettlementDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryListIds: [String]?
        var expectedDisputeSummaryListIds: [String]?
        var disputeError: Error?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .id, .descending)
            .where(.startStageDate, startDate)
            .execute {
                disputeSummaryListIds = $0?.results.compactMap { $0.caseId }
                expectedDisputeSummaryListIds = $0?.results.compactMap { $0.caseId }.sorted(by: > )
                disputeError = $1
                disputeDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [disputeDetailExpectation], timeout: 10.0)
        XCTAssertNil(disputeError)
        XCTAssertNotNil(disputeSummaryListIds)
        XCTAssertEqual(disputeSummaryListIds, expectedDisputeSummaryListIds)
    }

    func test_report_find_settlement_disputes_order_by_arn() {
        // GIVEN
        let disputeDetailExpectation = expectation(description: "Dispute Detail Expectation")
        let startDate = Date().addYears(-2).addMonths(1)
        let reportingService = ReportingService.findSettlementDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryList: [DisputeSummary]?
        var disputeError: Error?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .arn, .descending)
            .where(.startStageDate, startDate)
            .execute {
                disputeSummaryList = $0?.results
                disputeError = $1
                disputeDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [disputeDetailExpectation], timeout: 10.0)
        XCTAssertNil(disputeError)
        XCTAssertNotNil(disputeSummaryList)
    }

    func test_report_find_settlement_disputes_paged_by_merchant_id() {
        guard let expectedCaseMerchantId = try? awaitResponse(getSettlementDisputeSummary)?.caseMerchantId else {
            XCTFail("caseMerchantId cannot be nil")
            return
        }

        // GIVEN
        let executeExpectation = expectation(description: "Execute Expectation")
        let startStageDate = Date().addYears(-2).addMonths(1)
        let reportingService = ReportingService.findSettlementDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryList: [DisputeSummary]?
        var disputeError: Error?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .id, .descending)
            .where(.startStageDate, startStageDate)
            .and(dataServiceCriteria: .merchantId, value: expectedCaseMerchantId)
            .execute {
                disputeSummaryList = $0?.results
                disputeError = $1
                executeExpectation.fulfill()
            }

        // THEN
        wait(for: [executeExpectation], timeout: 10.0)
        XCTAssertNil(disputeError)
        if let disputeSummaryList = disputeSummaryList {
            XCTAssertFalse(disputeSummaryList.isEmpty)
            for dispute in disputeSummaryList {
                XCTAssertEqual(dispute.caseMerchantId, expectedCaseMerchantId)
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func report_find_settlement_disputes_order_by_id_with_status_underReview() {
        // GIVEN
        let disputeDetailExpectation = expectation(description: "Dispute Detail Expectation")
        let startDate = Date().addYears(-2).addMonths(1)
        let expectedDisputeStatus: DisputeStatus = .underReview
        let reportingService = ReportingService.findSettlementDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryList: [DisputeSummary]?
        var disputeError: Error?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .id, .ascending)
            .where(.startStageDate, startDate)
            .and(disputeStatus: expectedDisputeStatus)
            .execute {
                disputeSummaryList = $0?.results
                disputeError = $1
                disputeDetailExpectation.fulfill()
            }

        // THEN
        wait(for: [disputeDetailExpectation], timeout: 10.0)
        XCTAssertNil(disputeError)
        XCTAssertNotNil(disputeSummaryList)
        if let responseList = disputeSummaryList {
            XCTAssertFalse(responseList.isEmpty)
            for dispute in responseList {
                guard let caseStatus = dispute.caseStatus else {
                    XCTFail("caseStatus cannot be nil")
                    return
                }
                XCTAssertEqual(caseStatus, expectedDisputeStatus.mapped(for: .gpApi))
            }
        } else {
            XCTFail("disputeSummaryList cannot be nil")
        }
    }

    func test_report_find_settlement_disputes_with_criteria() {
        // GIVEN
        let summaryExpectation = expectation(description: "Report Find Settlement Disputes With Criteria")
        let startStageDate = Date().addYears(-2).addDays(1)
        let reportingService = ReportingService.findSettlementDisputesPaged(page: 1, pageSize: 10)
        var disputeSummaryList: [DisputeSummary]?
        var disputeSummaryError: Error?

        // WHEN
        reportingService
            .orderBy(disputeOrderBy: .brand, .ascending)
            .withDisputeStatus(.underReview)
            .withDisputeStage(.chargeback)
            .where(.startStageDate, startStageDate)
            .execute {
                disputeSummaryList = $0?.results
                disputeSummaryError = $1
                summaryExpectation.fulfill()
            }

        // THEN
        wait(for: [summaryExpectation], timeout: 10.0)
        XCTAssertNil(disputeSummaryError)
        XCTAssertNotNil(disputeSummaryList)
    }

    // MARK: - Other

    func test_load_test_resources() {
        // GIVEN
        let bundle = Bundle(for: type(of: self))

        // WHEN
        let pdfData = ResourceLoader.loadFile(
            name: "gp_logo",
            extension: .pdf,
            bundle: bundle
        )
        let pngData = ResourceLoader.loadFile(
            name: "gp_logo",
            extension: .png,
            bundle: bundle
        )

        // THEN
        XCTAssertNotNil(pdfData)
        XCTAssertNotNil(pngData)
    }

    // MARK: - Utils

    private func getDisputeSummary(_ status: DisputeStatus, _ completion: @escaping ((DisputeSummary?) -> Void)) {
        let reportingService = ReportingService.findDisputesPaged(page: 1, pageSize: 100)
        reportingService
            .orderBy(disputeOrderBy: .toAdjustmentTimeCreated, .descending)
            .withDisputeStatus(status)
            .where(.startStageDate, Date().addYears(-2).addDays(1))
            .execute { pagedResult, _ in
                let results = pagedResult?.results
                    .filter {
                        !$0.caseId.isNilOrEmpty &&
                            !$0.transactionARN.isNilOrEmpty &&
                            !$0.caseMerchantId.isNilOrEmpty &&
                            !$0.merchantHierarchy.isNilOrEmpty &&
                            !$0.transactionCardType.isNilOrEmpty &&
                            $0.caseStatus == status.rawValue
                    }

                completion(results?.first)
            }
    }

    private func getSettlementDisputeSummary(_ completion: @escaping ((DisputeSummary?) -> Void)) {
        let reportingService = ReportingService.findSettlementDisputesPaged(page: 1, pageSize: 100)
        reportingService
            .orderBy(disputeOrderBy: .toAdjustmentTimeCreated, .descending)
            .where(.startStageDate, Date().addYears(-2).addDays(1))
            .execute { pagedResult, _ in
                let results = pagedResult?.results.filter {
                    !$0.caseId.isNilOrEmpty &&
                        !$0.caseMerchantId.isNilOrEmpty
                }

                completion(results?.first)
            }
    }
}

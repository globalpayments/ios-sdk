import Foundation

private typealias ValidationRules = [RuleType: [ValidationTarget]]

class Validations {

    private var rules = ValidationRules()

    public func of(ruleType: RuleType) -> ValidationTarget? {
        if let transactionType = ruleType.transactionType {
            return of(transactionType: transactionType)
        }
        if let paymentMethodType = ruleType.paymentMethodType {
            return of(paymentMethodType: paymentMethodType)
        }
        if let reportType = ruleType.reportType {
            return of(reportType: reportType)
        }
        return nil
    }

    func of(transactionType: TransactionType) -> ValidationTarget {
        let ruleType = RuleType(
            value: transactionType.rawValue,
            transactionType: transactionType
        )
        return addRule(ruleType)
    }

    func of(paymentMethodType: PaymentMethodType) -> ValidationTarget {
        let ruleType = RuleType(
            value: paymentMethodType.rawValue,
            paymentMethodType: paymentMethodType
        )
        return addRule(ruleType)
    }

    func of(reportType: ReportType) -> ValidationTarget {
        let ruleType = RuleType(
            value: reportType.rawValue,
            reportType: reportType
        )
        return addRule(ruleType)
    }

    private func addRule(_ rule: RuleType) -> ValidationTarget {
        if !rules.keys.contains(rule) {
            rules[rule] = [ValidationTarget]()
        }

        let target = ValidationTarget(parent: self, type: rule)
        rules[rule]?.append(target)

        return target
    }

    func validate<T>(builder: BaseBuilder<T>) throws {

        for key in rules.keys {
            var value: Any? = Validations.propertyValue(in: builder, for: key.name)

            if value == nil && builder is TransactionBuilder<T> {
                if let transactionBuilder = builder as? TransactionBuilder<T>,
                    let paymentMethod = transactionBuilder.paymentMethod {
                    value = Validations.propertyValue(in: paymentMethod, for: key.name)
                    if value == nil { continue }
                }
            }

            guard key.contains(value: value) else { continue }
            guard let validations = rules[key] else { continue }

            for validation in validations {
                if validation.clause == nil { continue }

                // Modifier
                if validation.modifier != nil {
                    let modifier = Validations.transactionModifier(in: builder)
                    if validation.modifier != modifier {
                        continue
                    }
                }

                // Check precondition
                if let callback = validation.precondition?.callback {
                    if !callback(builder) {
                        continue
                    }
                }

                if let result = validation.clause?.callback?(builder) {
                    if !result {
                        throw BuilderException.generic(
                            message: validation.clause?.message
                        )
                    }
                }
            }
        }
    }
}

extension Validations {

    private static func propertyValue<T: NSObject>(in object: T?, for key: String) -> Any? {
        return object?.value(for: key)
    }

    private static func transactionModifier<T>(in baseBuilder: BaseBuilder<T>) -> TransactionModifier? {
        return baseBuilder.value(for: "transactionModifier") as? TransactionModifier
    }
}

struct RuleType: Hashable {
    let value: Int
    let transactionType: TransactionType?
    let paymentMethodType: PaymentMethodType?
    let reportType: ReportType?

    init(value: Int,
         transactionType: TransactionType? = nil,
         paymentMethodType: PaymentMethodType? = nil,
         reportType: ReportType? = nil) {

        self.value = value
        self.transactionType = transactionType
        self.paymentMethodType = paymentMethodType
        self.reportType = reportType
    }

    static func == (lhs: RuleType, rhs: RuleType) -> Bool {
        return lhs.value == rhs.value
    }

    func contains(value: Any?) -> Bool {

        if let transactionType = transactionType,
            let selectedOption = value as? TransactionType {
            return transactionType.contains(selectedOption)
        }

        if let paymentMethodType = paymentMethodType,
            let selectedOption = value as? PaymentMethodType {
            return paymentMethodType.contains(selectedOption)
        }

        if let reportType = reportType,
            let selectedOption = value as? ReportType {
            return reportType.contains(selectedOption)
        }

        return false
    }

    var name: String {
        if transactionType   != nil { return "transactionType" }
        if paymentMethodType != nil { return "paymentMethodType" }
        if reportType        != nil { return "reportType" }
        return .empty
    }
}

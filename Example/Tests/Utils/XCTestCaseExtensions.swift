import XCTest

/// Credits: https://www.swiftbysundell.com/articles/asyncawait-in-swift-unit-tests

extension XCTestCase {

    struct AwaitError: Error { }

    typealias Function<T> = (T) -> Void

    func await<T>(_ function: (@escaping (T) -> Void) -> Void) throws -> T {
        let expectation = self.expectation(description: "Async call")
        var result: T?

        function { value in
            result = value
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 20)

        guard let unwrappedResult = result else {
            throw AwaitError()
        }

        return unwrappedResult
    }

    func await<A, R>(_ function: @escaping Function<(A, Function<R>)>,
                     calledWith argument: A) throws -> R {
        return try await { handler in
            function((argument, handler))
        }
    }
}

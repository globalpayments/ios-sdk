import Foundation

class Dynamic<T> {
    typealias Execute = () -> Void
    typealias Listener = (T) -> ()
    var executer: Execute = { }
    private var listener: Listener?
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    func bind(executer: @escaping Execute) {
        self.executer = executer
    }
    
    func executeMain() {
        DispatchQueue.main.async { [weak self] in
            self?.executer()
        }
    }

    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ v: T) {
        value = v
    }
}

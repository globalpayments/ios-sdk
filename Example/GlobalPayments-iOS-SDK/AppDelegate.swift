import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        setupNavigationBarAppearance()
        setupWindow()

        return true
    }

    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = GlobalPayListBuilder.build()
        window?.makeKeyAndVisible()
    }

    private func setupNavigationBarAppearance() {
        UINavigationBar.appearance().barTintColor = Theme.navigationBarColor
        UINavigationBar.appearance().tintColor = Theme.titleColor
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.titleColor
        ]
    }
}


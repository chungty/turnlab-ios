import SwiftUI

@main
struct TurnLabApp: App {
    @StateObject private var container = DIContainer()
    @StateObject private var router = NavigationRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environmentObject(container.appState)
                .environmentObject(router)
                .environment(\.managedObjectContext, container.coreDataStack.viewContext)
        }
    }
}

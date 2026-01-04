import CoreData
import Foundation

/// Core Data persistence controller for Turn Lab.
/// Supports App Groups for widget data sharing.
final class CoreDataStack {
    static let shared = CoreDataStack()

    // MARK: - Container
    let container: NSPersistentContainer

    // MARK: - Contexts
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Initialization
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TurnLab")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure for App Group (widget sharing)
            if let appGroupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.turnlab.app"
            ) {
                let storeURL = appGroupURL.appendingPathComponent("TurnLab.sqlite")
                container.persistentStoreDescriptions.first?.url = storeURL
            }
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }

        // Configure view context
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Background Context
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    // MARK: - Save
    func save() {
        guard viewContext.hasChanges else { return }

        do {
            try viewContext.save()
        } catch {
            print("Core Data save error: \(error.localizedDescription)")
        }
    }

    func saveBackground(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            print("Core Data background save error: \(error.localizedDescription)")
        }
    }

    // MARK: - Perform Background Task
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
}

// MARK: - Preview Support
extension CoreDataStack {
    static var preview: CoreDataStack {
        let stack = CoreDataStack(inMemory: true)
        // Add preview data here if needed
        return stack
    }
}

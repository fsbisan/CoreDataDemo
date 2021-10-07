//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Александр Макаров on 06.10.2021.
//

import CoreData

class StorageManager {
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private init() {}

    func fetchData(completion: @escaping ([Task]) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let taskList = try persistentContainer.viewContext.fetch(fetchRequest)
            DispatchQueue.global().async {
                completion(taskList)
            }
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    
    // MARK: - Core Data Editing support
    func saveContext() {
        if self.context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save(_ taskName: String)  {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: self.context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: self.context) as? Task else { return }
        task.title = taskName
        saveContext()
    }
    
    func update(_ taskName: String, task: Task )  {
        task.title = taskName
        self.context.refresh(task, mergeChanges: true)
        saveContext()
    }
    
    func delete(removingTask: Task )  {
        self.context.delete(removingTask)
        saveContext()
    }
    
}

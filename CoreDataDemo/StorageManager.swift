//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Александр Макаров on 06.10.2021.
//

import CoreData

class StorageManager {
    
    var taskList: [Task] = []
    
    static let shared = StorageManager()
    
    private init() {}
    
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

    func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    
    // MARK: - Core Data Editing support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save(_ taskName: String, context: NSManagedObjectContext)  {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.title = taskName
        taskList.append(task)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    func update(_ taskName: String, context: NSManagedObjectContext, removeIndex: Int )  {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.title = taskName
        taskList.remove(at: removeIndex)
        taskList.insert(task, at: removeIndex)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    func delete(context: NSManagedObjectContext, removeIndex: Int )  {
        context.delete(taskList[removeIndex])
        taskList.remove(at: removeIndex)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
    
}

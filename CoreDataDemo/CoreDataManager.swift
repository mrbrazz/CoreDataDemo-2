//
//  CoreDataManager.swift
//  CoreDataDemo
//
//  Created by Сергей Ушаков on 18.08.2021.
//

import UIKit
import CoreData

class CoreDataManager {
	static let shared = CoreDataManager()
	
	lazy var persistentContainer: NSPersistentContainer = {

		let container = NSPersistentContainer(name: "CoreDataDemo")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {

				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()

	// MARK: - Core Data Saving support

	
	private lazy var context = persistentContainer.viewContext
	
	func save(_ taskName: String) -> Task? {
		guard let entiyDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
			return nil
		}
		guard let task = NSManagedObject(entity: entiyDescription, insertInto: context) as? Task else {
			return nil
		}
		task.name = taskName
		if context.hasChanges {
			do {
				try context.save()
			} catch let error {
				print(error.localizedDescription)
			}
		}
		return task
	}
	
	
	func saveContext () {
		if context.hasChanges {
			do {
				try context.save()
			} catch {

				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}


}

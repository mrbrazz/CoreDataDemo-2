//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by brubru on 16.08.2021.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
	
	//MARK: - Private Properties
	private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	private let cellID = "cell"
	private var taskList: [Task] = []
	
	//MARK: - Life Cycle Method
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.leftBarButtonItem = self.editButtonItem
		view.backgroundColor = .white
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
		setupNavigationBar()
		fetchData()
	}
	
	//MARK: - Public Methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let task = taskList[indexPath.row]
			showUpdateAlert(title: "Edit your Task", massage: "what do you want to change?", taskName: task.name)
	}
		
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .delete
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			deleteTask(task: taskList[indexPath.row].name ?? "")
			taskList.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		true
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let deleteRow = taskList.remove(at: sourceIndexPath.row)
		taskList.insert(deleteRow, at: destinationIndexPath.row)
		tableView.reloadData()
	}
	
	
	//MARK: - Private Methods
	private func setupNavigationBar() {
		title = "Task List"
		navigationController?.navigationBar.prefersLargeTitles = true
		
		let navBarAppearence = UINavigationBarAppearance()
		
		navBarAppearence.configureWithOpaqueBackground()
		navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
		navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
		
		navBarAppearence.backgroundColor = UIColor(
			red: 21/255,
			green: 101/255,
			blue: 192/255,
			alpha: 194/255
		)
		
		navigationController?.navigationBar.standardAppearance = navBarAppearence
		navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .add,
			target: self,
			action: #selector(addNewTask)
		)
		
		navigationController?.navigationBar.tintColor = .white
	}
	
	
	
	
	@objc private func addNewTask() {
		showAlert(with: "New Task", and: "What do you want to do?")
	}
	
	private func fetchData() {
		let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
		
		do {
			taskList = try context.fetch(fetchRequest)
		} catch let error {
			print(error.localizedDescription)
		}
	}
	 
	
	private func showUpdateAlert(title: String, massage: String, taskName: String?) {
		let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.placeholder = "enter new task name"
			textField.text = taskName
		}
		
		let saveAction = UIAlertAction(
			title: "Save",
			style: .default) { _ in
			guard let updatedTaskName = alert.textFields?.first?.text else {
				return
			}
			self.update(oldTask: taskName ?? "", newTask: updatedTaskName)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
		alert.addAction(saveAction)
		alert.addAction(cancelAction)
		present(alert, animated: true)
	}
	

	
	private func showAlert(with title: String, and massage: String) {
		let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
		let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
			guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
			self.save(task)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
		alert.addAction(saveAction)
		alert.addAction(cancelAction)
		alert.addTextField { textField in
			textField.placeholder = "New Task"
		}
		present(alert, animated: true)
	}
	
	private func deleteTask(task: String) {
		let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
		let taskList = try? context.fetch(fetchRequest)
		guard let oldTaskFromBD = taskList?.first(where: { $0.name == task }) else {
			return
		}
		context.delete(oldTaskFromBD)
		if context.hasChanges {
			do {
				try context.save()
			} catch let error {
				print(error.localizedDescription)
			}
		}
	}
	
	private func update(oldTask: String, newTask: String) {
		let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
		let taskListFromBD = try? context.fetch(fetchRequest)
		guard let oldTaskFromBD = taskListFromBD?.first(where: { $0.name == oldTask }) else {
			return
		}
		context.delete(oldTaskFromBD)
		if let taskDeleteIndex = taskListFromBD?.firstIndex(of: oldTaskFromBD) {
			taskList.remove(at: taskDeleteIndex)
			tableView.deleteRows(at: [IndexPath(row: taskDeleteIndex, section: 0)], with: .fade)
		}
		save(newTask)
	}
	
	private func save(_ taskName: String) {
		guard let entiyDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
			return
		}
		guard let task = NSManagedObject(entity: entiyDescription, insertInto: context) as? Task else { return
		}
		task.name = taskName
		taskList.append(task)
		
		let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
		tableView.insertRows(at: [cellIndex], with: .automatic)
		
		if context.hasChanges {
			do {
				try context.save()
			} catch let error {
				print(error.localizedDescription)
			}
		}
	}
	
//	private func delete(_ taskName: String) {
//		guard let entiyDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
//			return
//		}
//		guard let task = NSManagedObject(entity: entiyDescription, insertInto: context) as? Task else { return
//		}
//		task.name = taskName
//		taskList.remove(at: <#T##Int#>)
//
//		let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
//		tableView.insertRows(at: [cellIndex], with: .automatic)
//
//		if context.hasChanges {
//			do {
//				try context.save()
//			} catch let error {
//				print(error.localizedDescription)
//			}
//		}
//	}
}

extension TaskListViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		taskList.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
		let task = taskList[indexPath.row]
		var content = cell.defaultContentConfiguration()
		content.text = task.name
		cell.contentConfiguration = content
		return cell
	}
}


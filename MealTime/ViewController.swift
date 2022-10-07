//
//  ViewController.swift
//  MealTime
//
//  Created by Ivan Akulov on 10/02/2020.
//  Copyright © 2020 Ivan Akulov. All rights reserved.
//


import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var context: NSManagedObjectContext!
    
    var user: User!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // создали обьект let meal
        let meal = Meal(context: context)
        // Присвоили ей текущую дату
        meal.date = Date()
        
        // as? NSMutableOrderedSet - указываем что наш user.meals? имеет такой тип, иначе он будет у нас как Any
        //  let meals - мы создаем копию нашего user.meals? для того чтобы добавить meals?.add(meal)
        let meals = user.meals?.mutableCopy() as? NSMutableOrderedSet
        meals?.add(meal)
        // И присвоили нашему user.meals новый массив
        user.meals = meals
        
        do {
            try context.save()
            tableView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
        // Проверка данных есть ли у нас данные. Если есть то отобразить их
        let userName = "Max"
        let fetchReguest: NSFetchRequest<User> = User.fetchRequest()
        fetchReguest.predicate = NSPredicate(format: "name == %@", userName)
        
        do {
            let results = try context.fetch(fetchReguest)
            if results.isEmpty {
                user = User(context: context)
                user.name = userName
                try context.save()
            } else {
                user = results.first
            }
        } catch  let error as NSError {
            print(error.localizedDescription)
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My happy meal time"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.meals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        guard let meal = user.meals?[indexPath.row] as? Meal,
              let mealDate = meal.date
        else { return cell}
        
        cell.textLabel!.text = dateFormatter.string(from: mealDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let meal = user.meals?[indexPath.row] as? Meal, editingStyle == .delete else { return }
         
        context.delete(meal)
        
        do {
            try context.save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}


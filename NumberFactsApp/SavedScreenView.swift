//
//  SavedScreenView.swift
//  NumberFactsApp
//
//  Created by Hashir Khan on 12/4/20.
//

import UIKit

class SavedScreenView: UIViewController {
    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Data for the table
    var items:[Fact]?
    var filtered:[Fact] = []
    
    //Outlets
    @IBOutlet weak var triviaButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var mathButton: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        //gets items from core data
        fetchFacts()
        filtered = items!
    }
    
    //Gets data from Coredata
    func fetchFacts(){
        do{
            self.items = try context.fetch(Fact.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch{
            print("Error fetching data")
        }
    }
    
    @IBAction func triviaButtonPress(_ sender: Any) {
        if triviaButton.isSelected{
            triviaButton.isSelected = false
            yearButton.isSelected = false
            dateButton.isSelected = false
            mathButton.isSelected = false
        }
        else{
            triviaButton.isSelected = true
            yearButton.isSelected = false
            dateButton.isSelected = false
            mathButton.isSelected = false
        }
        updateArray()
        tableView.reloadData()
    }
    
    @IBAction func yearButtonPress(_ sender: Any) {
        if yearButton.isSelected{
            triviaButton.isSelected = false
            yearButton.isSelected = false
            dateButton.isSelected = false
            mathButton.isSelected = false
        }
        else{
            yearButton.isSelected = true
            triviaButton.isSelected = false
            dateButton.isSelected = false
            mathButton.isSelected = false
        }
        updateArray()
        tableView.reloadData()
    }
    
    @IBAction func dateButtonPress(_ sender: Any) {
        if dateButton.isSelected{
            triviaButton.isSelected = false
            yearButton.isSelected = false
            dateButton.isSelected = false
            mathButton.isSelected = false
        }
        else {
            dateButton.isSelected = true
            triviaButton.isSelected = false
            yearButton.isSelected = false
            mathButton.isSelected = false
        }
        updateArray()
        tableView.reloadData()
    }
    
    @IBAction func mathButtonPress(_ sender: Any) {
        if mathButton.isSelected{
            triviaButton.isSelected = false
            yearButton.isSelected = false
            dateButton.isSelected = false
            mathButton.isSelected = false
        }
        else{
            mathButton.isSelected = true
            triviaButton.isSelected = false
            yearButton.isSelected = false
            dateButton.isSelected = false
        }
        updateArray()
        tableView.reloadData()
    }
    

    
    func filterButtonSelect(index:Int){
        triviaButton.isSelected = false
        yearButton.isSelected = false
        dateButton.isSelected = false
        mathButton.isSelected = false
        
        switch index {
        case 0:
            triviaButton.isSelected = true
        case 1:
            yearButton.isSelected = true
        case 2:
            dateButton.isSelected = true
        case 3:
            mathButton.isSelected = true
        default:
            print("Default")
        }
    }
    
    //updates filtered data
    func updateArray() {
        filtered = []
        if triviaButton.isSelected{
            for fact in items!{
                if fact.genre == "Trivia"{
                    filtered.append(fact)
                }
            }
        }
        else if yearButton.isSelected{
            for fact in items!{
                if fact.genre == "Year"{
                    filtered.append(fact)
                }
            }
        }
        else if dateButton.isSelected{
            for fact in items!{
                if fact.genre == "Date"{
                    filtered.append(fact)
                }
            }
        }
        else if mathButton.isSelected{
            for fact in items!{
                if fact.genre == "Math"{
                    filtered.append(fact)
                }
            }
        }
        else {
            filtered = items!
        }
    }
}

extension SavedScreenView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        let fact = self.filtered[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.text = fact.factText
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, MTLNewLibraryCompletionHandler) in
            let factToRemove = self.filtered[indexPath.row]
            
            self.context.delete(factToRemove)
            
            do{
                try self.context.save()
            } catch{
                print("Error deleting")
            }
            
            self.fetchFacts()
            self.updateArray()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}

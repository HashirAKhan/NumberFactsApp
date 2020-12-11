//
//  SettingsScreen.swift
//  NumberFactsApp
//
//  Created by Hashir Khan on 12/4/20.
//

import UIKit

class SettingsScreen: UIViewController {
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var vibrationSwitch: UISwitch!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items:[Fact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let sound = UDM.shared.defaults.value(forKey: "sound") as? Bool {
            soundSwitch.isOn = sound
        }
        if let vibration = UDM.shared.defaults.value(forKey: "vibration") as? Bool{
            vibrationSwitch.isOn = vibration
        }
        // Do any additional setup after loading the view.
    }
    
    func fetchFacts(){
        do{
            self.items = try context.fetch(Fact.fetchRequest())
        } catch{
            print("Error fetching data")
        }
    }
    
    @IBAction func soundSwitchChange(_ sender: Any) {
        if soundSwitch.isOn{
            UDM.shared.defaults.setValue(true, forKey: "sound")
        }
        else{
            UDM.shared.defaults.setValue(false, forKey: "sound")
        }
    }
    @IBAction func vibrationSwitchChange(_ sender: Any) {
        if vibrationSwitch.isOn{
            UDM.shared.defaults.setValue(true, forKey: "vibration")
        }
        else{
            UDM.shared.defaults.setValue(false, forKey: "vibration")
        }
    }
    
    @IBAction func deleteButtonPress(_ sender: Any) {
        showAlert()
    }
    
    
    func showAlert(){
        let alert = UIAlertController(title: "Caution", message: "You are about to delete all your saved facts", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("dismissed alert")
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            print("delete alert")
            self.fetchFacts()
            
            for i in 0...self.items.count-1{
                self.context.delete(self.items[i])
            }
            do{
                try self.context.save()
            } catch{
                print("failed delete")
            }
        }))
        
        present(alert, animated: true)

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

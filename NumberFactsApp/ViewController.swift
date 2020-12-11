//
//  ViewController.swift
//  NumberFactsApp
//
//  Created by Hashir Khan on 12/4/20.
//

import UIKit
import AVFoundation

//Structs

struct Response: Codable {
    var text:String
}

struct FactGenre {
    var factText:String
    var genre:String
}

//Class for user defulats
class UDM {
    static let shared = UDM()
    let defaults = UserDefaults(suiteName: "appData")!
}

class ViewController: UIViewController {

//User Defaults
    var soundEnabled = true
    var vibrationEnabled = true
    

//Class variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var player: AVAudioPlayer?
    var currentGenre = "Trivia"
    var genreURL = "http://numbersapi.com/random/trivia?json"
    var currentFact:FactGenre?
    var liked = false
    var lastSaved:Fact?
    
//Outlets For UI
    //outlet for Genre Buttons
    @IBOutlet weak var triviaButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var mathButton: UIButton!
    
    //outlet for Text that displays the fact
    @IBOutlet weak var factTextField: UILabel!
    
    //outlet for toolbar buttons
    @IBOutlet weak var savedFactsButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    //oulet for like button
    @IBOutlet weak var likeButton: UIButton!
    
    
    
//Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        genreSelect(index: 0)
        likeButton.isEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUserSettings()
    }
    
    
//Functions
    
    //Loads user defualt settings
    func loadUserSettings(){
        if let sound = UDM.shared.defaults.value(forKey: "sound") as? Bool {
            soundEnabled = sound
        }
        if let vibration = UDM.shared.defaults.value(forKey: "vibration") as? Bool{
            vibrationEnabled = vibration
        }

    }
    
    //Function for selecting a genre
    func genreSelect(index: Int){
        switch index {
        case 0:
            triviaButton.isSelected = true
            yearButton.isSelected = false
            dateButton.isSelected = false
            mathButton.isSelected = false
            currentGenre = "Trivia"
            genreURL = "http://numbersapi.com/random/trivia?json"
        case 1:
            triviaButton.isSelected = false
            yearButton.isSelected = true
            dateButton.isSelected = false
            mathButton.isSelected = false
            currentGenre = "Year"
            genreURL = "http://numbersapi.com/random/year?json"
        case 2:
            triviaButton.isSelected = false
            yearButton.isSelected = false
            dateButton.isSelected = true
            mathButton.isSelected = false
            currentGenre = "Date"
            genreURL = "http://numbersapi.com/random/date?json"
        case 3:
            triviaButton.isSelected = false
            yearButton.isSelected = false
            dateButton.isSelected = false
            mathButton.isSelected = true
            currentGenre = "Math"
            genreURL = "http://numbersapi.com/random/math?json"
        default:
            triviaButton.isSelected = true
            yearButton.isSelected = false
            dateButton.isSelected = false
            mathButton.isSelected = false
            currentGenre = "Trivia"
            genreURL = "http://numbersapi.com/random/trivia?json"
        }
    }
    
    //API CALL
    private func getData(urlString:String, completionHandler: @escaping (Response?) ->Void){
        guard let url = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, res, err in
            if let data = data {
                print("decoder")
                print(data)
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(Response.self, from: data) {
                    completionHandler(json)
                }
            }
        }.resume()
    }
    
    
    
    
//IBActions
    
    //Actions for genre buttons
    @IBAction func triviaButtonPress(_ sender: Any) {
        genreSelect(index: 0)
    }
    
    @IBAction func yearButtonPress(_ sender: Any) {
        genreSelect(index: 1)
    }
    
    @IBAction func dateButtonPress(_ sender: Any) {
        genreSelect(index: 2)
    }
    
    @IBAction func mathButtonPress(_ sender: Any) {
        genreSelect(index: 3)
    }
    
    
    //Actions for toolbar buttons
    @IBAction func savedFactsScreenButton(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "savedScreen") as? SavedScreenView else{
            print("Did not load saved screen view")
            return
        }
        present(vc, animated: true)
    }
    
    @IBAction func settingsScreenButton(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "settings") as? UIViewController {
                self.present(viewController, animated: true, completion: nil)
            }
    }
    
    //Actions for fact buttons
    
    @IBAction func refreshFactButton(_ sender: Any) {
        let dispatch = DispatchGroup()
        dispatch.enter()
        getData(urlString: genreURL){ (data) in
            print(data as Any)
            self.currentFact = FactGenre(factText: data?.text ?? "", genre: self.currentGenre)
            dispatch.leave()
        }
        
        dispatch.notify(queue: .main){
            self.factTextField.text = self.currentFact?.factText
        }
        likeButton.isEnabled = true
        let config = UIImage.SymbolConfiguration(scale: .large)
        likeButton.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        likeButton.scalesLargeContentImage = true
        liked = false
    }
    
    @IBAction func likeFactPress(_ sender: Any) {
        loadUserSettings()
        let config = UIImage.SymbolConfiguration(scale: .large)
        
        if liked {
            liked = false
            likeButton.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
            self.context.delete(lastSaved!)
            do{
                try self.context.save()
            }
            catch{
                print("Error Deleting")
            }
        }
        else{
            liked = true
            likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: config), for: .normal)
            let fact = Fact(context: context)
            fact.factText = currentFact?.factText
            fact.genre = currentFact?.genre
            lastSaved = fact
            do{
                try self.context.save()
            }
            catch{
                print("Error Saving")
            }
            if soundEnabled{
                guard let url = Bundle.main.url(forResource: "Bloop", withExtension: "mp3") else { return }
                do {
                        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                        try AVAudioSession.sharedInstance().setActive(true)

                        player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

                        guard let player = player else { return }

                        player.play()

                    } catch let error {
                        print(error.localizedDescription)
                }
            }
            if vibrationEnabled{
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    
}


//
//  ViewController.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/2/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import UIKit
import CoreData

//      PROMPT TYPE DEF

enum PromptType {
    case search, saved, searchFailed, noJSON, noResults, noHistory, alreadySaved, newUser, saveInstruction, username
}

class MainViewController: UIViewController {
    
    //      MEMBER DEF
    
    let model = DataModel()
    
    let context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
    
    var tap: UITapGestureRecognizer = UITapGestureRecognizer()
    
    var retrievedJSON = ""
    var processing = false
    
    @IBOutlet weak var usernameEntry: UITextField!
    @IBOutlet weak var resultTable: UITableView!
    @IBOutlet weak var loadProgress: UIActivityIndicatorView!
    
    //      INITIALIZATION
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDisplay()
    }
    
    func initializeDisplay() {
        loadProgress.isHidden = true
        usernameEntry.delegate = self
        usernameEntry.keyboardType = .alphabet
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        tap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.establish))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        if let un = UserDefaults.standard.string(forKey: "username") {
            usernameEntry.text = un
        }
        if !UserDefaults.standard.bool(forKey: "returning") {
            prompt(type: .newUser)
            UserDefaults.standard.set(true, forKey: "returning")
        }
    }
    
    @IBAction func search(_ sender: UIBarButtonItem) {
        establish()
        prompt(type: .search)
    }
    
    //      MODEL CALLS AND COMPLETION HANDLING
    
    func searchCall(_ searchterm: String) {
        self.processing = true
        self.loadProgress.hidesWhenStopped = true
        self.loadProgress.startAnimating()
        let queue = DispatchQueue(label: "JSON_PROCESS", attributes: .concurrent)
        queue.async {
            self.loadDataAsync(searchterm)
        }
    }
    
    func loadDataAsync(_ searchterm: String) {
        let queue = DispatchGroup()
        var username = usernameEntry.text!
        if username == "" {
            username = "demo"
        }
        var success = false
        queue.enter()
        let result = self.model.fetchJSON(term: searchterm, username: username)
        success = result.success
        queue.leave()
        queue.notify(queue: .main) {
            self.processResults(success, res: result.results)
        }
    }
    
    func processResults(_ s: Bool, res: String) {
        resultTable.reloadData()
        processing = false
        loadProgress.stopAnimating()
        if !s {
            prompt(type: .searchFailed)
        } else {
            if model.results.count == 0 {
                prompt(type: .noResults)
                retrievedJSON = ""
            } else {
                retrievedJSON = res
            }
        }
        if !UserDefaults.standard.bool(forKey: "searchedBefore") {
            prompt(type: .saveInstruction)
            UserDefaults.standard.set(true, forKey: "searchedBefore")
        }
    }
    
    //      SEGUE DEF
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if processing {
            return false
        }
        if let id = identifier {
            switch id {
            case "JSON":
                if retrievedJSON == "" {
                    prompt(type: .noJSON)
                    return false
                }
                break
            case "history":
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cache")
                let fetchCache = ((try? context.fetch(fetchRequest)) as? [Cache])!
                if fetchCache.count == 0 {
                    prompt(type: .noHistory)
                    return false
                }
                break
            default:
                break
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "result":
            let selectedIndex: IndexPath = self.resultTable.indexPath(for: sender as! ResultTableViewCell)!
            if let detailVC: DetailViewController = segue.destination as? DetailViewController {
                detailVC.result = model.results[selectedIndex.row];
            }
            break
        case "JSON":
            if let jsonVC: JSONViewController = segue.destination as? JSONViewController {
                jsonVC.JSON = retrievedJSON
            }
            break
        default:
            break
        }
    }
    
    @IBAction func returnedToTable(segue: UIStoryboardSegue)
    {
    }
    
    //      ALERT PROMPT DEF
    
    func prompt(type: PromptType) {
        var buttontext = ""
        var searchAction: UIAlertAction? = nil
        let alert = UIAlertController(title: "Default alert", message: "You shouldn't be seeing this", preferredStyle: .alert)
        switch type {
        case .noJSON:
            alert.title = "No JSON data to show"
            alert.message = "Try searching for something"
            buttontext = "Okay"
            break
        case .noResults:
            alert.title = "No results"
            alert.message = "Looks like your search came up empty"
            buttontext = "Okay"
            break
        case .search:
            alert.title = "New Search"
            alert.message = "Enter the name of a location"
            buttontext = "Cancel"
            searchAction = UIAlertAction(title: "Search", style: .default) { [unowned self] action in
                guard let textField = alert.textFields?.first,
                    let searchterm = textField.text
                    else { return }
                self.searchCall(searchterm)
            }
            break
        case.searchFailed:
            alert.title = "Search Failed"
            alert.message = "Check your username or internet connection"
            buttontext = "Okay"
            break
        case .noHistory:
            alert.title = "No history"
            alert.message = "Swipe left on a search result to save"
            buttontext = "Okay"
            break
        case .alreadySaved:
            alert.title = "Result already saved"
            alert.message = "No need to save this again, silly"
            buttontext = "Okay"
            break
        case .saved:
            alert.title = "Result saved"
            alert.message = "You can come back to this in your history"
            buttontext = "Okay"
            break
        case .newUser:
            alert.title = "Welcome to Lokate!"
            alert.message = "Lokate is a utility app for researching locations. Try searching for the name of a place you know up in the top right corner!"
            buttontext = "Let's do it!"
            break
        case .saveInstruction:
            alert.title = "Nice search!"
            alert.message = "Try swiping left on a search result to save, then check out your history"
            buttontext = "Okay"
            break
        case .username:
            alert.title = "GeoNames Username"
            alert.message = "Here you can enter your username for the GeoNames WebService. If left blank, it will attempt to search with the demo username, however this may fail.\n If you are having trouble, you can use mine: ckharrl"
            buttontext = "Okay"
            break
        }
        let cancelAction = UIAlertAction(title: buttontext, style: .default)
        if let s = searchAction {
            alert.addTextField() {
                textfield in
                textfield.keyboardType = .alphabet
            }
            alert.addAction(cancelAction)
            alert.addAction(s)
        } else {
            alert.addAction(cancelAction)
        }
        present(alert, animated: true)
    }
    
    //      COREDATA SAVE
    
    func saveRow(_ indexPath: IndexPath) {
        let ent = NSEntityDescription.entity(forEntityName: "Cache", in: context)
        let newItem = Cache(entity: ent!, insertInto: context)
        newItem.title = self.model.results[indexPath.row].title
        newItem.summary = self.model.results[indexPath.row].summary
        newItem.feature = self.model.results[indexPath.row].feature
        newItem.url = self.model.results[indexPath.row].url
        newItem.thumbnail = UIImagePNGRepresentation(self.model.results[indexPath.row].thumbnail) as NSData?
        newItem.longitude = self.model.results[indexPath.row].longitude
        newItem.latitude = self.model.results[indexPath.row].latitude
        newItem.added = NSDate.init()
        
        do {
            try context.save()
            print("Saved.")
        } catch _ {
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    //      TABLEVIEW DEF
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as! ResultTableViewCell
        cell.title.text = model.results[indexPath.row].title
        cell.thumbnail.image = model.results[indexPath.row].thumbnail
        cell.desc.text = model.results[indexPath.row].feature
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resultTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let save = UITableViewRowAction(style: .default, title: "Save") {
            (rowAction, indexPath) in
            if !self.model.results[indexPath.row].saved {
                self.model.results[indexPath.row].saved = true
                self.saveRow(indexPath)
            } else {
                self.prompt(type: .alreadySaved)
            }
            self.resultTable.setEditing(false, animated: true)
        }
        save.backgroundColor = UIColor.lightGray
        return [save]
    }
}

extension MainViewController: UITextFieldDelegate {
    
    //      TEXTFIELD/KEYBOARD DEF
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        establish()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !UserDefaults.standard.bool(forKey: "triedUsername") {
            prompt(type: .username)
            UserDefaults.standard.set(true, forKey: "triedUsername")
        }
    }
    
    func establish() {
        view.endEditing(true)
        usernameEntry.resignFirstResponder()
        usernameEntry.text = usernameEntry.text!.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces).joined()
        UserDefaults.standard.set(usernameEntry.text!, forKey: "username")
        
    }
}

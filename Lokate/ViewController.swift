//
//  ViewController.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/2/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import UIKit

enum PromptType {
    case search, searchFailed, noJSON, noResults
}

class MainViewController: UIViewController {
    
    //      MEMBER DEF
    
    let model = DataModel()
    
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
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        tap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.establish))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        if let un = UserDefaults.standard.string(forKey: "username") {
            if un == "" {
                usernameEntry.text = "demo"
            } else {
                usernameEntry.text = un
            }
        }
    }
    
    @IBAction func search(_ sender: UIBarButtonItem) {
        establish()
        prompt(type: .search)
    }
    
    //      MODEL CALLS AND COMPLETION HANDLING
    
    func loadDataAsync(_ searchterm: String) {
        let queue = DispatchGroup()
        let username = usernameEntry.text!
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
            } else {
                retrievedJSON = res
            }
        }
    }
    
    //      SEGUE DEF
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if processing {
            return false
        }
        if identifier! == "JSON" && retrievedJSON == "" {
            prompt(type: .noJSON)
            return false
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
        
        if segue.identifier == "result"{
            
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
                self.processing = true
                self.loadProgress.hidesWhenStopped = true
                self.loadProgress.startAnimating()
                let queue = DispatchQueue(label: "JSON_PROCESS", attributes: .concurrent)
                queue.async {
                    self.loadDataAsync(searchterm)
                }
            }
            break
        case.searchFailed:
            alert.title = "Search Failed"
            alert.message = "Check your username and try again"
            buttontext = "Okay"
            break
        }
        let cancelAction = UIAlertAction(title: buttontext, style: .default)
        if let s = searchAction {
            alert.addTextField()
            alert.addAction(cancelAction)
            alert.addAction(s)
        } else {
            alert.addAction(cancelAction)
        }
        present(alert, animated: true)
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
}

extension MainViewController: UITextFieldDelegate {
    
    //      TEXTFIELD/KEYBOARD DEF
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        establish()
        return true
    }
    
    func establish() {
        view.endEditing(true)
        usernameEntry.resignFirstResponder()
        usernameEntry.text = usernameEntry.text!.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces).joined()
        UserDefaults.standard.set(usernameEntry.text!, forKey: "username")
        
    }
}

//
//  ViewController.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/2/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    let model = DataModel()
    
    var tap: UITapGestureRecognizer = UITapGestureRecognizer()
    
    var retrievedJSON = ""
    
    var processing = false
    
    @IBOutlet weak var usernameEntry: UITextField!
    @IBOutlet weak var resultTable: UITableView!
    @IBOutlet weak var loadProgress: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadProgress.isHidden = true
        usernameEntry.delegate = self
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        tap = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
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
        let alert = UIAlertController(title: "New Search", message: "Enter location name", preferredStyle: .alert)
        let searchAction = UIAlertAction(title: "Search", style: .default) { [unowned self] action in
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(searchAction)
        present(alert, animated: true)
    }
    
    func loadDataAsync(_ searchterm: String) {
        let queue = DispatchGroup()
        let username = usernameEntry.text!
        var success = false
        queue.enter()
        let result = self.model.fetchJSON(term: searchterm, username: username)
        success = result.success
        queue.leave()
        queue.notify(queue: .main) {
            self.resultTable.reloadData()
            self.processing = false
            self.loadProgress.stopAnimating()
            if !success {
                let alert = UIAlertController(title: "Search Failed", message: "Check username and try again", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .default)
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
            } else {
                self.retrievedJSON = result.results
            }
        }
    }
    
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
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if processing {
            return false
        }
        if identifier! == "JSON" && retrievedJSON == "" {
            let alert = UIAlertController(title: "No JSON data to show", message: "Try searching for something!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .default)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        establish()
        return true
    }

    func dismissKeyboard() {
        establish()
    }
    
    func establish() {
        view.endEditing(true)
        usernameEntry.resignFirstResponder()
        usernameEntry.text = usernameEntry.text!.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces).joined()
        UserDefaults.standard.set(usernameEntry.text!, forKey: "username")
        
    }
}


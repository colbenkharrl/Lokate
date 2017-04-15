//
//  ViewController.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/2/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let model = DataModel()
    
    var processing = false
    
    @IBOutlet weak var resultTable: UITableView!
    @IBOutlet weak var loadProgress: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadProgress.isHidden = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    @IBAction func search(_ sender: UIBarButtonItem) {
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
        queue.enter()
        self.model.fetchJSON(term: searchterm)
        queue.leave()
        queue.notify(queue: .main) {
            self.resultTable.reloadData()
            self.processing = false
            self.loadProgress.stopAnimating()
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
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "result" {
                if processing {
                    return false
                }
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "result"{
            let selectedIndex: IndexPath = self.resultTable.indexPath(for: sender as! ResultTableViewCell)!
            if let detailVC: DetailViewController = segue.destination as? DetailViewController {
                detailVC.result = model.results[selectedIndex.row];
            }
        }
    }
}


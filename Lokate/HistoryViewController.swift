//
//  HistoryViewController.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/17/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var cacheTable: UITableView!
    
    let context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext

    var fetchCache = [Cache]()
    
    //      INITIALIZATION
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeDisplay()
        if !UserDefaults.standard.bool(forKey: "viewedHistory") {
            let alert = UIAlertController(title: "Pro tip", message: "You can delete items in your history by swiping them to the left.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .default)
            alert.addAction(cancelAction)
            present(alert, animated: true)
            UserDefaults.standard.set(true, forKey: "viewedHistory")
        }
    }
    
    func initializeDisplay() {
        navigationItem.title = "History"
    }
    
    func fetchHistory() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cache")
        fetchCache = ((try? context.fetch(fetchRequest)) as? [Cache])!
        return fetchCache.count
    }
    
    //      SEGUE DEF
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "result":
            let selectedIndex: IndexPath = cacheTable.indexPath(for: sender as! ResultTableViewCell)!
            if let detailVC: DetailViewController = segue.destination as? DetailViewController {
                detailVC.result = Result(t: fetchCache[selectedIndex.row].title!, s: fetchCache[selectedIndex.row].summary!, f: fetchCache[selectedIndex.row].feature!, u: fetchCache[selectedIndex.row].url!, th: nil, lon: fetchCache[selectedIndex.row].longitude, lat: fetchCache[selectedIndex.row].latitude)
            }
            break
        default:
            break
        }
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    //      TABLEVIEW DEF
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchHistory()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as! ResultTableViewCell
        cell.title.text = fetchCache[indexPath.row].title
        cell.thumbnail.image = UIImage(data: fetchCache[indexPath.row].thumbnail as! Data)
        cell.desc.text = fetchCache[indexPath.row].feature
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cacheTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(fetchCache[indexPath.row])
            cacheTable.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

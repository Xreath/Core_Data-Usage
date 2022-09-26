//
//  ViewController.swift
//  Alisveris
//
//  Created by Fazlı Koç on 26.09.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectName = ""
    var selectUUID :UUID?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: NSNotification.Name(rawValue: "insert"), object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate=self
        tableView.dataSource=self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        
        fetchData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=UITableViewCell()
        cell.textLabel?.text=nameArray[indexPath.row]
        return cell
    }
    
    @objc func addButton(){
        
        selectName = ""
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    @objc func fetchData(){
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context=appDelegate.persistentContainer.viewContext
        
        let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName: "Shop")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try  context.fetch(fetchRequest)
            if results.count > 0 {
                for i in results as! [NSManagedObject]{
                    if  let name = i.value(forKey: "name") as? String{
                        nameArray.append(name)
                    }
                    
                    if  let id = i.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }
                    
                }}
            
            tableView.reloadData()
        }
        catch{
            print("Hata Oluştu")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectName=nameArray[indexPath.row]
        selectUUID=idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC"{
            let destinationVC=segue.destination as! DetailViewController
            destinationVC.selectedName=selectName
            destinationVC.selectedUUID=selectUUID
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shop")
            
            let deleteID=idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", deleteID)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let result = try context.fetch(fetchRequest)
                
                if result.count > 0 {
                    for i in result as! [NSManagedObject]{

                        context.delete(i)
                        nameArray.remove(at: indexPath.row)
                        idArray.remove(at: indexPath.row)
                        
                        self.tableView.reloadData()
                        
                        do{
                            try  context.save()
                        }
                        catch{
                            print("Savelerken Hata oldu")
                        }
                        
                        }
                        
                    
                    
                    
                }
            }
            catch{
                print("ID'den çekerken hata oldu")
            }
            
        }
    }
}
//Hello everybody



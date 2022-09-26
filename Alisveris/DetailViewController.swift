//
//  DetailViewController.swift
//  Alisveris
//
//  Created by Fazlı Koç on 26.09.2022.
//

import UIKit
import CoreData

class DetailViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var productSize: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedName =  ""
    var selectedUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(selectedName)
        if selectedName != "" {
            
            saveButton.isHidden = true
            
            
            if let UUIDString = selectedUUID?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shop")
                fetchRequest.predicate = NSPredicate(format: "id = %@", UUIDString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let result = try context.fetch(fetchRequest)
                    if result.count > 0 {
                        for i in result as! [NSManagedObject]{
                            if  let name = i.value(forKey: "name") as? String{
                                productName.text=name
                            }
                            
                            if  let price = i.value(forKey: "price") as? Int{
                                
                                productPrice.text = String(price)
                            }
                            
                            if  let size = i.value(forKey: "size") as? String{
                                productSize.text = String(size)
                            }
                            
                            if  let imageData = i.value(forKey: "image") as? Data{
                                let uiImage=UIImage(data: imageData)
                                imageView.image = uiImage
                            }
                            
                        }
                        
                        
                    }
                }
                catch{
                    print("ID'den çekerken hata oldu")
                }
                
            }
        }
        else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            productName.text=""
            productSize.text=""
            productPrice.text=""
        }
        
        let gestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(keybordClose))
        
        view.addGestureRecognizer(gestureRecognizer)
        
        view.isUserInteractionEnabled = true
        let imageRecognizer=UITapGestureRecognizer(target: self, action: #selector(imageSelector))
        
        view.addGestureRecognizer(imageRecognizer)
    }
    @objc func imageSelector(){
        let picker=UIImagePickerController()
        picker.delegate=self
        picker.sourceType = .photoLibrary
        picker.allowsEditing=false
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image=info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
    }
    
    @objc func keybordClose(){
        view.endEditing(true)
    }
    
    
    
    @IBAction func saveAction(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context=appDelegate.persistentContainer.viewContext
        
        let shop = NSEntityDescription.insertNewObject(forEntityName: "Shop", into: context)
        
        shop.setValue(productName.text!, forKey:"name")
        
        shop.setValue(productSize.text!, forKey:"size")
        
        
        if let priceInt = Int(productPrice.text!){
            shop.setValue(priceInt, forKey:"price")
        }
        
        shop.setValue(UUID(), forKey: "id")
        
        
        let binaryImage = imageView.image!.jpegData(compressionQuality: 0.5)
        
        shop.setValue(binaryImage, forKey: "image")
        
        
        do{
            
            try
            context.save()
            print("Save Process Complate")
            
        }
        catch{print("OPSS a error")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "insert"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

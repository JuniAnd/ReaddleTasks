//
//  ViewController.swift
//  testSheets
//
//  Created by developer on 6/9/18.
//  Copyright © 2018 developer. All rights reserved.

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var choiceButton: UIButton!
    @IBOutlet weak var colectionMenu: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    private let service = GTLRSheetsService()
    let signInButton = GIDSignInButton()
    
    var selectedFood = ["1":"Не выбрано","2":"Не выбрано","3":"Не выбрано","4":"Не выбрано"]
    let imageFood = [#imageLiteral(resourceName: "salat"),#imageLiteral(resourceName: "supe"),#imageLiteral(resourceName: "otbivnaya"),#imageLiteral(resourceName: "pure")]
    var typeFood = [String]()
    var namesArray = [String]()
    var arrayData = [[Any]]()
    var userName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        signInButton.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        view.addSubview(signInButton)
        
        let bgImage = UIImageView.init(image: UIImage(named: "officeTable"))
        bgImage.contentMode = .scaleAspectFill
        self.colectionMenu.backgroundView = bgImage
        
        if let name = UserDefaults.standard.string(forKey: "UserName") {
            self.userName = name
            self.signInButton.isHidden = true
        }

        nameField.isHidden = true
        doneButton.isHidden = true
        choiceButton.isHidden = true
        tableView.isHidden = true
        colectionMenu.isHidden = true
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            self.signInButton.isHidden = true
            
            if UserDefaults.standard.string(forKey: "UserName") == nil {
                self.userName = user.profile.name
            }
            sendRequest()
        }
    }
    
    func sendRequest() {
        let spreadsheetId = "1NrPDjp80_7venKB0OsIqZLrq47jbx9c-lrWILYJPS88"
        let range = Date().dayOfWeek()
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(receivingData(ticket:finishedWithObject:error:))
        )
    }
    
    @objc func receivingData(ticket: GTLRServiceTicket, finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        
        if let error = error {
            if Date().dayOfWeek() == "Выходной" {
                showAlert(title: "Таблица пустая", message: "Сегодня выходной")
                self.colectionMenu.isHidden = false
                return
            } else {
                showAlert(title: "Error", message: error.localizedDescription)
                return
            }
        } else {
            guard let tableData = result.values else {
                showAlert(title: "", message: "Таблица пустая")
                return
            }
            self.arrayData = tableData
            self.dataHandler()
        }
    }
    
    func dataHandler () {
        
        var nameIsExistInTable = false
        var count = 0
        
        for element in self.arrayData {
            
            // add all names to array
            if let name = element[0] as? String {
                if count > 1 {
                    self.namesArray.append(name)
                }
                count += 1
            }
            
            // searching our name
            if element[0] as? String == self.userName {
                nameIsExistInTable = true
                
                // save name in userDefaults
                let saveName = UserDefaults()
                saveName.set(self.userName, forKey: "UserName")
                saveName.synchronize()
                
                //add all type of Food in array
                for i in 2...self.arrayData[0].count {
                    if let typeMenu = self.arrayData[0][i-1] as? String {
                        if typeMenu != "" {
                            self.typeFood.append(typeMenu)
                        }
                    }
                }
                //add all selected Food in array
                for (index,value) in element.enumerated() {
                    if let v = value as? String {
                        if v == "1" {
                            switch index {
                            case 1,2,3: self.selectedFood["1"] = self.arrayData[1][index] as? String ?? ""
                            case 4,5,6: self.selectedFood["2"] = self.arrayData[1][index] as? String ?? ""
                            case 7,8,9: self.selectedFood["3"] = self.arrayData[1][index] as? String ?? ""
                            case 10,11,12: self.selectedFood["4"] = self.arrayData[1][index] as? String ?? ""
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
        
        if !nameIsExistInTable  {
            showAlert(title: "", message: "Имя \"\(self.userName)\" не найденно в таблице.\nВведите другое имя.")
            self.doneButton.isHidden = false
            self.nameField.isHidden = false
            self.choiceButton.isHidden = false
            return
        }
    
        self.colectionMenu.reloadData()
        self.colectionMenu.isHidden = false
    }
    
    //MARK: Button
    
    @IBAction func showMenu(_ sender: Any) {
        if nameField.text == "" {
            showAlert(title: "Пустое поле", message:"Введите имя" )
        } else {
            self.userName = self.nameField.text ?? ""
            self.doneButton.isHidden = true
            self.choiceButton.isHidden = true
            self.nameField.isHidden = true
            self.dataHandler()
        }
    }
    
    @IBAction func showTableOfName(_ sender: Any) {
        let cancelButton = UIButton()
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.addTarget(self, action: #selector(self.cancelButton(sender:)), for: .touchUpInside)
        cancelButton.frame.size = CGSize(width: 100, height: 30)
        cancelButton.center = CGPoint(x: self.view.center.x, y: self.tableView.frame.maxY + 30)
        cancelButton.tag = 1
        self.view.addSubview(cancelButton)
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    @objc func cancelButton(sender: UIButton!) {
        self.tableView.isHidden = true
        sender.removeFromSuperview()
    }
    
    
    //MARK: Alert
    
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Date().dayOfWeek() != "Выходной" ? self.typeFood.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MenuCell

        cell.nameFood.text = self.selectedFood["\(indexPath.row + 1)"]
        cell.nameFood.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.typeFood.text = self.typeFood[indexPath.row] + ":"
        cell.imageFood.image = self.imageFood[indexPath.row]
        return cell
    }
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.namesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = self.namesArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.userName = self.namesArray[indexPath.row]
        self.tableView.isHidden = true
        self.doneButton.isHidden = true
        self.choiceButton.isHidden = true
        self.nameField.isHidden = true
        self.view.viewWithTag(1)?.removeFromSuperview()
        self.dataHandler()
    }
    
}

extension Date {
    func dayOfWeek() -> String {
        
        switch Calendar.current.dateComponents([.weekday], from: self).weekday {
        case 2?:
            return "Понедельник "
        case 3?:
            return "Вторник"
        case 4?:
            return "Среда "
        case 5?:
            return "Четверг "
        case 6?:
            return "Пятница "
        default:
            //TODO: if weekend (for test)
            //return "Вторник"
            return "Выходной"
        }
    }
}



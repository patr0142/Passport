//
//  PassportTableViewController.swift
//  Final_Project_Passport
//
//  Created by Katelyn Patrick on 2020-12-06.
//  Copyright © 2020 Katelyn Patrick. All rights reserved.
//

import UIKit

class PassportTableViewController: UITableViewController {

    //json object
    var jsonObject: [String:[[String:Any]]]?
    
    
    // properties
    let authKey = "patr0142"
    var index: Int?
    
    
    // action controls
    @IBAction func AddButton(_ sender: Any) {
        performSegue(withIdentifier: "addPage", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //optional binding to return json and handle errors
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = jsonObject {
            return data ["locations"]!.count
        }else{
           return 0
        }
    }
    
    // override of table functions to display stored object, then use optional binding to check if the object exists and update the cell to show event
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            if let jsonArray = jsonObject {
              let object = jsonArray["locations"]!
              let objectData = object[indexPath.row]
              cell.textLabel?.text = "\(objectData["title"]!)"
            }
        return cell
    }
    
    
    //make url request to provided url, create the request, session, add authorization, create task and execute
    override func viewWillAppear(_ animated: Bool) {
        let url: URL = URL(string: "http://lenczes.edumedia.ca/mad9137/final_api/passport/read/")!
        var request: URLRequest = URLRequest(url:url)
        let session: URLSession = URLSession.shared
        request.addValue(authKey, forHTTPHeaderField: "my-authentication")
        let task = session.dataTask(with: request, completionHandler: requestTask )
        task.resume()
    }
    
    
    //process server data and check errors and pass data to  callback function
    func requestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        if serverError != nil {
            self.callBack(responseString: "", error: serverError?.localizedDescription)
        }else{
            let response = String(data: serverData!, encoding: String.Encoding.utf8)!
            self.callBack(responseString: response as String, error: nil)
        }
    }
    
    //processes errors and sterialize response then reloads the tableview data
    func callBack(responseString:String, error: String?){
        if error != nil {
            print(error!)
        } else {
            if let locationData: Data = responseString.data(using: String.Encoding.utf8){
                do{
                    jsonObject = try JSONSerialization.jsonObject(with: locationData, options:  []) as? [String:[[String:Any]]]
                } catch let Error{
                    print(Error.localizedDescription)
                }
            }
            DispatchQueue.main.async{
                self.tableView?.reloadData()
            }
        }
    }
    
     //make url delete request to provided url, create the request, session, add authorization, create task and execute
    func delete(id:Int?){
        let deleteUrl: URL = URL(string: "http://lenczes.edumedia.ca/mad9137/final_api/passport/delete/?id=\(id!)")!
        var deleteURLRequest: URLRequest = URLRequest(url: deleteUrl)
        let deleteSession: URLSession = URLSession.shared
        deleteURLRequest.addValue(authKey, forHTTPHeaderField: "my-authentication")
        let deleteTask = deleteSession.dataTask(with: deleteURLRequest, completionHandler: deleteRequestTask )
        deleteTask.resume()
    }
        
   //process server data and check errors and pass data to  callback function
   func deleteRequestTask(_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void {
        if let serverError = serverError{
            self.deleteCallBack(responseString: "", error: serverError.localizedDescription)
        }else{
            let response = String(data: serverData!, encoding: String.Encoding.utf8)!
            self.deleteCallBack(responseString: response as String, error: nil)
        }
   }
    
        
   //processes errors and sterialize response then reloads the tableview data
   func deleteCallBack(responseString:String, error:String?) {
       if let myError = error
        {
            print (myError)
        } else {
            DispatchQueue.main.async{
                if let indexPathToDelete = self.indexPathToDelete {
                    self.jsonObject?["locations"]!.remove(at: indexPathToDelete.row)
                    self.tableView.deleteRows(at: [indexPathToDelete], with: .fade)
                    self.indexPathToDelete = nil
                    self.tableView?.reloadData()
                }
            }
        }
    }
    
    
   // override  of tableview, deletes the data from the tableview
    var indexPathToDelete: IndexPath?
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
              if let reloadDataArray = jsonObject {
                //getting the current dictionary with indexPath.row
                let reloadDataItem = reloadDataArray["locations"]!
                let dataItem = reloadDataItem[indexPath.row]
                if let index = dataItem["id"] as? Int {
                    self.indexPathToDelete = indexPath
                    if let indexPathToDelete = self.indexPathToDelete {
                        print(indexPathToDelete)
                        delete(id: index)
                    }
                }
            }
         }
   }
    
    //when clicked triggers segue to info page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "info"{
            let viewController = segue.destination as? InfoViewController
            let index = tableView.indexPathForSelectedRow
            if let segueArray = jsonObject{
                let reloadDataArray = segueArray["locations"]!
                    let dataItem = reloadDataArray[index!.row]
                    viewController?.jsonObj = dataItem
                    viewController?.identifier = dataItem["id"] as? Int
            }
        }
    }
    
    
    
}


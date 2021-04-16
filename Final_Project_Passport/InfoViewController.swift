//
//  InfoViewController.swift
//  Final_Project_Passport
//
//  Created by Katelyn Patrick on 2020-12-06.
//  Copyright © 2020 Katelyn Patrick. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    // outlets
    @IBOutlet weak var infoView: UITextView!
    
    //json object dictionary
    var jsonObj: [String:Any]?
    var identifier:Int?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // creating adding and updating a data request and session
     override func viewWillAppear(_ animated: Bool) {
            let detailsUrl: URL = URL(string: "http://lenczes.edumedia.ca/mad9137/final_api/passport/read/?id=\(identifier!)")!
            
            var infoURLRequest: URLRequest = URLRequest(url: detailsUrl)
            
            let infoSession: URLSession = URLSession.shared
            
        // 8 characater key value
            let infoAuthKey = "patr0142"
            
        // adding key value to url for "My authentication
            infoURLRequest.addValue(infoAuthKey, forHTTPHeaderField: "my-authentication")
           
        // getting session info and passing the request to the completion handler
            let infoTask = infoSession.dataTask(with: infoURLRequest, completionHandler: inforequestTask )
            
        // tells the task to run
            infoTask.resume()
        }
        
       //processes server data and errors before passing them to callback fucntion
        func inforequestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
            
            // checks foe and handles errors 
            if let serverError = serverError{

                self.infoCallBack(responseString: "", error: serverError.localizedDescription)
            }else{
                
                let response = String(data: serverData!, encoding: String.Encoding.utf8)!
                
                self.infoCallBack(responseString: response as String, error: nil)
                
            }
        }
        
    //processes errors if any then processes the response and updates the view
        func infoCallBack(responseString:String, error:String?) {
            
            if let myError = error
            { print (myError)
                
            }else {
                print(responseString)
               
                // encodes respomse data 
                if let infoData:Data = responseString.data(using: String.Encoding.utf8){
                    
                    do{
                        
                        jsonObj = try JSONSerialization.jsonObject(with: infoData, options: []) as? [String:Any]
                        print("\(jsonObj!)");
                        
                    }catch let Error {
                        
                        print(Error.localizedDescription)
                    }
                }
                
                // uses the created dictionary and updates the data and displays on the infoView controller
                DispatchQueue.main.async {
                           if let data = self.jsonObj{
                                                    
                                                     self.infoView.text = "Title: \(data["title"]!) \n\n Location Id: \(data["id"]!) \n\n Description: \(data["description"]!) \n\n Latitude: \(data["latitude"]!) \n\n Longitude: \(data["longitude"]!)  \n\n Arrival Date: \(data["arrival"]!)  \n\n Departure Date: \(data["departure"]!)"
                                                         }
                                                
                }
                       }
                
                }
                
            }
        
    
        
    
    
    


//
//  AddViewController.swift
//  Final_Project_Passport
//
//  Created by Katelyn Patrick on 2020-12-06.
//  Copyright © 2020 Katelyn Patrick. All rights reserved.
//

import UIKit
import CoreLocation

// imported corelocation and created a CL object
class AddViewController: UIViewController, CLLocationManagerDelegate {

    // outlets
    @IBOutlet weak var PosTitle: UITextField!
    @IBOutlet weak var PosDescription: UITextView!
    @IBOutlet weak var Arrive: UIDatePicker!
    @IBOutlet weak var Depart: UIDatePicker!
    
    //properties
    var geoManager = CLLocationManager()
    var newDictionary : [String : Any] = [:]
    var newData : Data?
    var newJsonString : String?
    var latitude : Double?
    var long : Double?
    
    override func viewDidLoad() {
           super.viewDidLoad()
        geoManager.delegate = self
        geoManager.requestWhenInUseAuthorization()
        geoManager.requestLocation()
           }
    
    // get location manager function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitude = locations[locations.count - 1].coordinate.latitude
        long = locations[locations.count - 1].coordinate.longitude
    }
    
    // location manager error function
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // when textfield has been filled, the action will make the request and convert the values to json string and add the string to the url. if url request fails catch the error.
    @IBAction func saveBtn(_ sender: Any) {
        guard let POSTitle = PosTitle.text, !POSTitle.isEmpty else {
                     return
                 }
        // hide keyboard on save
            view.endEditing(true)
        
        //create a dictionary to display data from json
                
                newDictionary ["title"] = POSTitle
                newDictionary ["description"] = PosDescription.text
                newDictionary ["arrival"] = String(Arrive.date.description.dropLast(9))
            newDictionary ["departure"] = String(Depart.date.description.dropLast(9))
                newDictionary ["latitude"] = latitude
                newDictionary ["longitude"] = long
                
                // encodes the json data and return encoded string to add to url
                do {
                    newData = try JSONSerialization.data(withJSONObject: newDictionary, options: [])
                    newJsonString = String(data: newData!, encoding: .utf8)
                    
                    // prints encoded json string to be added to url
                    let encodedJSONString = newJsonString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    print(encodedJSONString!)
                    
                    // creating adding and updating a data request and session
                    let addUrl: URL = URL(string: "http://lenczes.edumedia.ca/mad9137/final_api/passport/create/?data=\(encodedJSONString!)")!
                    
                    var addURlRequest: URLRequest = URLRequest(url: addUrl)
                    
                    let addSession: URLSession = URLSession.shared
                    
                    // 8 character key value
                    let addAuthKey = "patr0142"
                    
                    // adding key value to url for "My authentication
                    addURlRequest.addValue(addAuthKey , forHTTPHeaderField: "my-authentication")
                   // getting session info and passing the request to the completion handler
                    let addTask = addSession.dataTask(with: addURlRequest, completionHandler: addRequestTask)
                    
                    // tells the task to run
                    addTask.resume()
                }
                   // catches errors
                catch {
                    print ("error = \(error.localizedDescription)")
                }
                
            }
        
    // used to process the data returned from the server as well as any errors and call the callback function.
    func addRequestTask(_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void {
         
         // catchs errors
         if let serverError = serverError{
             
             self.addCallBack(responseString: "", error: serverError.localizedDescription)
         }else{
            
            // converting data to string
             let response = String(data: serverData!, encoding: String.Encoding.utf8)!
             
             self.addCallBack(responseString: response as String, error: nil)
         }
         
         
     }
    
    // callback will catch errors or allow the request to fufill
    func addCallBack(responseString:String, error:String?) {
        
        if let myError = error
        { print (myError)
            }else{
            print(responseString)
            
            DispatchQueue.main.async {
        self.navigationController?.popToRootViewController(animated: true) 
            }
        }
        
    }
    
    // dismisses keyboard when return key is clicked
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                    PosTitle.resignFirstResponder()
                    PosDescription.resignFirstResponder()
                    return false
                }
    
    // hides keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
    
    


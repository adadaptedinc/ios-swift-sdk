//
//  ViewController.swift
//  SwiftExampleApp
//
//  Created by Brett Clifton on 8/10/20.
//  Copyright © 2020 AdAdapted. All rights reserved.
//

import UIKit
import AASwiftSDK

class ViewController:
    UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchTextFieldDelegate,
    AAZoneViewOwner,
    AASDKContentDelegate
{
    
    @IBOutlet weak var adAdaptedZoneView: AdAdaptedZoneView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var searchTextField: SearchTextField!
    
    var listData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        listTableView.delegate = self
        listTableView.dataSource = self
        adAdaptedZoneView.setZoneOwner(self)
        AASDK.registerContentListeners(for: self)
        
        listData = ["Eggs", "Bread"]
        searchTextField.theme.font = UIFont.systemFont(ofSize: 15)
        searchTextField.minCharactersNumberToStartFiltering = 3
        searchTextField.filterStrings(getListItems())
    }
    
    //MARK: AA SDK Calls
    
    func viewControllerForPresentingModalView() -> UIViewController? {
        return self
    }
    
    func aaContentNotification(_ notification: Notification) {
        print("In-app content available")
        
        guard let userinfo = notification.userInfo else {
            print("userinfo is nil")
            return
        }
        
        guard let adContent = userinfo[AASDK.KEY_AD_CONTENT] as? AdContent else {
            print("userinfo[AASDK.KEY_AD_CONTENT] is nil")
            return
        }

        for item in adContent.detailedListItems {
            print("AADetailedListItem: \(item.productTitle), \(String(describing: item.productBrand)), \(String(describing: item.productUpc)), \(String(describing: item.retailerId)), \(String(describing: item.productCategory)), \(String(describing: item.productDescription))")
            appendListItem(itemName: item.productTitle)
        }

        // Acknowledge the items were added to the list
        adContent.acknowledge()
    }

    func zoneViewDidLoadZone(_ view: AAZoneView?) {
        if let zoneId = view?.zoneId {
            print("Zone " + zoneId + " loaded")
        }
    }

    func zoneViewDidFail(toLoadZone view: AAZoneView?) {
        print("Zone failed to load")
    }
    
    //Out of App AddIt
    func aaPayloadNotification(_ notification: Notification) {
        print("Out-of-app content available")
        guard let userinfo = notification.userInfo else { return }
        guard let adPayload = userinfo[AASDK.KEY_CONTENT_PAYLOADS] as? [AAContentPayload] else { return }

        for payload in adPayload {
            for item in payload.detailedListItems {
                print("AADetailedListItem: ", item.productTitle)
                appendListItem(itemName: item.productTitle)
            }

            payload.acknowledge()
        }
    }
    
    //MARK: Other Calls
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        addItemToList(addButton)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item = listData[indexPath.row]
        cell.textLabel?.text = item
        
        return cell
    }

    @IBAction func textFieldChanged(_ sender: UITextField) {
        searchTextField.filterStrings(getListItems())
    }
    
    @IBAction func addItemToList(_ sender: UIButton) {
        //test call to get recipe ads
        adAdaptedZoneView.setAdZoneContext(contextID: "RecipeID")
        //
        if searchTextField.text != nil && !searchTextField.text!.isEmpty {
            appendListItem(itemName: searchTextField.text!)
        }
    }
    
    private func getListItems(suggestion: String = String()) -> [String] {
        guard let path = Bundle.main.url(forResource: "DefaultListItems", withExtension: "plist") else {return []}
        let data = try! Data(contentsOf: path)
        
        guard var plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String] else {return []}
        
        if !suggestion.isEmpty {
            plist.append(suggestion)
        }
        
        return plist
    }
    
    private func appendListItem(itemName: String = "") {
        listData.append(itemName)
        listTableView.reloadData()
        searchTextField.text = ""
    }
}

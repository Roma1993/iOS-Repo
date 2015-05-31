//
//  TViewController.swift
//  MyApp
//
//  Created by Romashka on 4/24/15.
//  Copyright (c) 2015 Romashka. All rights reserved.
//

import UIKit

class MyTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

 
    
       
    var table : MSTable?
    var tableData = [NSDictionary]()
    var client : MSClient?
    
    var editedIndexPath = NSIndexPath(index: 0)
    var refreshControl:UIRefreshControl!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        self.logoffButton.tintColor = UIColor(red: 245.2/255.0, green: 168.2/255.0, blue: 20.0/255.0, alpha: 1.0)

        
        self.client = MSClient(applicationURLString: "https://gurmobileservice.azure-mobile.net/", applicationKey: "uCoNNbKWrxtMBRiudfWNbeZacjjbPa61")
        
        self.table = client!.tableWithName("Item")!
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        //self.onRefresh(self.refreshControl)
        self.loginAndGetData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    //refresh function
    func onRefresh(sender: AnyObject) {
        let predicate = NSPredicate(value: true)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
 
        self.table!.readWithPredicate(predicate) {
            result, error  in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
                println("Error: " + error.description)
                return
            }
            let resultCount = result.items.count
            self.tableData = result.items as! [NSDictionary]
            println("Information: retrieved \(result.items.count) records")
            
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    //authentication method
    func loginAndGetData(){
        if let tempclient = self.client{
            if tempclient.currentUser != nil{
                return
            }
            tempclient.loginWithProvider("facebook", controller: self, animated: true){
                user, error in
                if error != nil {
                    println("Error: " + error.description)
                    return
                }
                self.onRefresh(self.refreshControl)

            }
        }
    }
    //accessory button segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "editSegue" {
            let cell = sender as! TableViewCell
            self.editedIndexPath = tableView.indexPathForCell(cell)!
            let DateVC = segue.destinationViewController as! DatePickerViewController
            DateVC.editedText = cell.eventName.text!
            DateVC.editedDate = cell.eventDate.text!
            DateVC.editedPriority = count(cell.priority.text!)
            DateVC.editingFlag = true
        }
//        if segue.identifier == "logoffSegue" {
//            self.client!.logout()
//
//        }
    }
//    //saves indexPath which is about to undergo editing
//    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
//        self.editedIndexPath = indexPath
//    }
    //pressing cancel button shouldnt change anything
    @IBOutlet weak var logoffButton: UIBarButtonItem!
    
    @IBAction func logoff(sender: UIBarButtonItem) {
        var cookie : NSHTTPCookie = NSHTTPCookie()
        var cookieJar : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in cookieJar.cookies as! [NSHTTPCookie]{
            println ("hollo")
            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
        }
        println("hello")
        self.client!.logout()
        self.viewDidLoad()
        
    }
    @IBAction func cancel(segue:UIStoryboardSegue) {
        
    }
    //pressing done button edits the row or adss a new one depending on how the datePickerView was reached
    @IBAction func done(segue:UIStoryboardSegue) {
        var eventDetailVC = segue.sourceViewController as! DatePickerViewController
        
        if (eventDetailVC.name != ""){
            if eventDetailVC.editingFlag == false{
                let itemToInsert = ["text": eventDetailVC.name, "date": eventDetailVC.date, "completed": false, "priority" : eventDetailVC.priority]
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                self.table!.insert(itemToInsert as [NSObject : AnyObject]) {
                    (item, error) in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if error != nil {
                        println("Error: " + error.description)
                    } else {
                        //let item = myType(name: carDetailVC.name, date: carDetailVC.date)
                        self.tableData.append(item)
                        self.tableView.reloadData()
                    }
                
                }
            }
            else {
                let item = self.tableData[editedIndexPath.row]
                let editedItem = item.mutableCopy() as! NSMutableDictionary
                editedItem["text"] = eventDetailVC.name
                editedItem["date"] = eventDetailVC.date
                editedItem["priority"] = eventDetailVC.priority
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                self.table!.update(editedItem as [NSObject : AnyObject]) {
                    (result, error) in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if error != nil {
                        println("Error: " + error.description)
                        return
                    }
                    
                    self.tableData.removeAtIndex(self.editedIndexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([self.editedIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    self.onRefresh(self.refreshControl)
                }
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //block of functions to implement tableview editing
       func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String!
    {
        return "Deletacion"
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
          //deletion of the row function
        var deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            tableView.editing = false
            let record = self.tableData[indexPath.row]
            let completedItem = record.mutableCopy() as! NSMutableDictionary
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.table!.delete(completedItem as [NSObject : AnyObject]) {
                (result, error) in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if error != nil {
                    println("Error: " + error.description)
                    return
                }
                
                self.tableData.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
        }
        
        
        //complete and uncomplete functions
        if self.tableData[indexPath.row]["completed"] as? Bool == false {
            
            var completeAction = UITableViewRowAction(style: .Normal, title: "Complete") { (action, indexPath) -> Void in
                tableView.editing = false
                let record = self.tableData[indexPath.row]
                let editedItem = record.mutableCopy() as! NSMutableDictionary
                editedItem["completed"] = true
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                self.table!.update(editedItem as [NSObject : AnyObject]) {
                    (result, error) in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if error != nil {
                        println("Error: " + error.description)
                        return
                    }
                    
                    self.tableData.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    self.onRefresh(self.refreshControl)
                }
                
                println("completeAction")
            }
            completeAction.backgroundColor = UIColor.grayColor()
            return [deleteAction, completeAction]

        }
        else {
            var uncompleteAction = UITableViewRowAction(style: .Normal, title: "Uncomplete") { (action, indexPath) -> Void in
                tableView.editing = false
                let record = self.tableData[indexPath.row]
                let editedItem = record.mutableCopy() as! NSMutableDictionary
                editedItem["completed"] = false
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                self.table!.update(editedItem as [NSObject : AnyObject]) {
                    (result, error) in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if error != nil {
                        println("Error: " + error.description)
                        return
                    }
                    
                    self.tableData.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    self.onRefresh(self.refreshControl)
                }
                
                println("uncompleteAction")
            }
            uncompleteAction.backgroundColor = UIColor(red: 69.2/255.0, green: 177.2/255.0, blue: 255.0/255.0, alpha: 1.0)
            return [deleteAction, uncompleteAction]
        }
        
        
        
    }
    
    
  
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return tableData.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! TableViewCell
        
        cell.eventName.text = tableData[indexPath.row]["text"] as? String
        cell.eventDate.text = tableData[indexPath.row]["date"] as? String
        cell.constText.text = "estimated date: "
        let thisPriority = tableData[indexPath.row]["priority"] as? Int
        switch thisPriority! {
        case 0:
           cell.priority.text = ""
        case 1:
            cell.priority.text = "!"
        case 2:
            cell.priority.text = "!!"
        case 3:
            cell.priority.text = "!!!"
        default:
            cell.priority.text = "error"
        }
        
        let curDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay, fromDate: curDate)
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        //        println (formatter.stringFromDate(curDate))
                println(components.hour)
        println(cell.eventDate.text!)
        let cellDate = formatter.dateFromString(cell.eventDate.text!)!
        if self.tableData[indexPath.row]["completed"] as? Bool != false {
            cell.statusImage.image = UIImage(named: "grey.gif")
        }
        else {
            if curDate.compare(cellDate) == NSComparisonResult.OrderedDescending {
                cell.statusImage.image = UIImage(named: "red.gif")
            } else if curDate.compare(cellDate) == NSComparisonResult.OrderedAscending
            {
                cell.statusImage.image = UIImage(named: "blue.gif")
            }
        }

        
        return cell
        
    }
    
    //implementing cell selection
//    var selectedIndexPath: NSIndexPath? = nil
//    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
//        println("didSelectRowAtIndexPath was called")
//        var cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
//        cell.statusImage.image = UIImage(named: "grey.png")

//        switch selectedIndexPath {
//        case nil:
//            selectedIndexPath = indexPath
//        default:
//            if selectedIndexPath! == indexPath {
//                selectedIndexPath = nil
//            } else {
//                selectedIndexPath = indexPath
//            }
//        }
//        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
//    
//    
//    //delete this later on
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let smallHeight: CGFloat = 82.0
//        let expandedHeight: CGFloat = 200.0
//        let ip = indexPath
//        if selectedIndexPath != nil {
//            if ip == selectedIndexPath! {
//                return expandedHeight
//            } else {
//                return smallHeight
//            }
//        } else {
//            return smallHeight
//        }
//    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}

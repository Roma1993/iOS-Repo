//
//  ViewController.swift
//  MyApp
//
//  Created by Romashka on 4/23/15.
//  Copyright (c) 2015 Romashka. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
    
//    @IBOutlet weak var myDatePicker: UIDatePicker!
//    @IBOutlet weak var dateTextField: UITextField!
//    @IBAction func textFieldEditing(sender: UITextField) {
//        var datePickerView:UIDatePicker = UIDatePicker()
//        datePickerView.datePickerMode = UIDatePickerMode.Date
//        sender.inputView = datePickerView
//        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
//    }
//    
//    func datePickerValueChanged(sender: UIDatePicker) {
//        var dateformatter = NSDateFormatter()
//        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
//        dateTextField.text = dateformatter.stringFromDate(sender.date)
//    }
    
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var priorityPicker: UISegmentedControl!
    
    var dateFormatter = NSDateFormatter()
    
    var editingFlag = false
    
    var name: String = ""
    var date: String = ""
    var priority: Int = 0
    
    var editedText: String = ""
    var editedDate: String = ""
    var editedPriority: Int = 0
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "doneSegue" {
            
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            
            name = eventName.text
            date = dateFormatter.stringFromDate(datePicker.date)
            priority = priorityPicker.selectedSegmentIndex

        }
    }
    
        override func viewDidLoad() {
        super.viewDidLoad()
            if editingFlag {
                println(editedText + " " + editedDate)
                dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
                
                datePicker.date = dateFormatter.dateFromString(editedDate)!
                eventName.text = editedText
                priorityPicker.selectedSegmentIndex = editedPriority
            }
            
            
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


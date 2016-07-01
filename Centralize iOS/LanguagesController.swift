//
//  LanguagesController.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 26/03/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

class LanguagesController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var menuBar: UINavigationItem!

    @IBOutlet weak var select: UIPickerView!
    @IBOutlet weak var chooseBtn: UIButton!
    
    let languagesFull = ["English", "Français"]
    let languagesCode = ["en", "fr"]
    var choosenLanguage = "en"
    
    @IBAction func saveLanguage(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(self.choosenLanguage, forKey: "language")
        let i18n = I18n()
        t = i18n.load_locales()
        self.loadI18n()
        simpleAlert((t.valueForKey("LANGUAGE_SAVED")! as? String)!, message: (t.valueForKey("LANGUAGE_SAVED_DESC")! as? String)!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        select.delegate = self
        select.dataSource = self
        let i18n = I18n()
        select.selectRow(languagesCode.indexOf(i18n.current_language)!, inComponent: 0, animated: false)
        
        self.loadI18n()
        if self.revealViewController() != nil {
            menuBtn.target = self.revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func loadI18n() {
        self.menuBar.title = t.valueForKey("LANGUAGES")! as? String
        self.chooseBtn.setTitle(t.valueForKey("SAVE")! as? String, forState: .Normal)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languagesFull.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languagesFull[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        choosenLanguage = languagesCode[row]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  SearchViewController.swift
//  FlickrDemo
//
//  Created by Finn on 2020/5/29.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    
// MARK: - View Cycle Life
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
    }
    
// MARK:  - UI Fuctions
    
    fileprivate func setupUI() {
        
        navigationItem.title = "輸入搜尋頁"
        
        setupTextfields()
        
        searchBtn.setTitle("搜尋", for: .normal)
        switchBtnState(btn: searchBtn, isAble: false)
        
        let tap = UITapGestureRecognizer(target: self.view,
                                         action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    fileprivate func setupTextfields() {
        
        nameTextField.placeholder   = "欲搜尋內容"
        amountTextField.placeholder = "每頁呈現數量"
        
        nameTextField.delegate   = self
        amountTextField.delegate = self
        
        nameTextField.tag   = 0
        amountTextField.tag = 1
        
        nameTextField.addTarget(self,
                                action: #selector(textFieldDidChange(_:)),
                                for: .editingChanged)
        amountTextField.addTarget(self,
                                  action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
    }

    fileprivate func switchBtnState(btn:UIButton, isAble:Bool) {
        
        if isAble {
            btn.isEnabled = true
            btn.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        } else {
            btn.isEnabled = false
            btn.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
    }
    
    fileprivate func isTextfieldsIsEmpty() -> Bool{
        
        if nameTextField.text == "" || amountTextField.text == "" {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func isSearchable() -> Bool {
        
        guard let okName   = nameTextField.text,
              let okAmount = amountTextField.text else { return false }
        
        if okName.replace(target: " ", withString: "") == ""{
            popAlert(title: "資料輸入錯誤", message: "請檢查搜尋名稱是否有輸入字元(不含空白)。")
            return false
        } else if !okAmount.isNumber {
            popAlert(title: "顯示數量輸入錯誤", message: "顯示數量只能由數字組成。")
            return false
        } else {
            return true
        }
    }
    
    fileprivate func popAlert(title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
// MARK: - Button Actions
    
    @IBAction func searchBtnAction(_ sender: UIButton) {
        
        if isSearchable() {
            performSegue(withIdentifier: "goToTabBar", sender: nil)
        }
    }
    
// MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToTabBar" {
            if let dvc = segue.destination as? TabBarViewController {
                if let resultVC = dvc.viewControllers?.first as? ResultViewController {
                    
                    guard let okText       = nameTextField.text,
                          let okPerPageStr = amountTextField.text,
                          let okPerPage    = Int(okPerPageStr)    else {
                            fatalError("Get Search text, amount Error")
                    }
                    
                    resultVC.text    = okText
                    resultVC.perPage = okPerPage
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switchBtnState(btn: searchBtn, isAble: !isTextfieldsIsEmpty())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

// MARK: - String Extension

extension String {
    
    func replace(target: String, withString: String) -> String {
        
        return self.replacingOccurrences(of: target,
                                         with: withString,
                                         options: NSString.CompareOptions.literal,
                                         range: nil)
    }
    
    var isNumber: Bool {
        guard !self.isEmpty else { return false }
        return !self.contains(where: { Int( String($0) ) == nil })
    }
}

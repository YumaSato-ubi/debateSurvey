//
//  SetupViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import Eureka

class SetupViewController: FormViewController {

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ラベリング"
        
        form
            +++ Section(header:"接続先", footer:"InfluxDBへの接続先情報を入力してください")
            
            <<< TextRow() {
                $0.tag = Config.host
                $0.title = "IP/ホスト名"
                $0.value = defaults.string(forKey: Config.host)
                }.onChange { row in
                    self.defaults.set(row.value, forKey: Config.host)
            }
            
            +++ Section(header:"行動ラベル", footer:"")
            
            <<< ButtonRow(){
                $0.title = "対象行動の確認/変更"
                $0.presentationMode = .segueName(segueName: "ActivitySelectViewControllerControllerSegue", onDismiss: nil)
            }
            
            +++ Section(header:"ラベリング周期", footer:"")
            
            <<< IntRow() {
                $0.tag = Config.period
                $0.title = "周期(s)"
                $0.value = defaults.integer(forKey: Config.period)
                }.onChange { row in
                    self.defaults.set(row.value, forKey: Config.period)
            }
            
            +++ Section(header:"", footer:"")
            
            <<< ButtonRow() {
                $0.title = "ラベリング開始"
                }.onCellSelection { _, _ in
                    self.performSegue(withIdentifier: "LabelingViewControllerSegue", sender: nil)
            }
        
    }
    
    @IBAction func reset(_ sender: Any) {
        let alert = UIAlertController(title: "設定の初期化", message: "本当に初期化してよろしいですか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.resetConfig()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func resetConfig() {
        DefaultConfig().reset()
        
        let host = form.rowBy(tag: Config.host) as! TextRow
        host.value = defaults.string(forKey: Config.host)
        host.reload()
        
        let period = form.rowBy(tag: Config.period) as! IntRow
        period.value = defaults.integer(forKey: Config.period)
        period.reload()
    }
    
}


class ActivitySelectViewController: FormViewController {
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "行動ラベル"
        
        let activityList = defaults.stringArray(forKey: Config.activityList)
        
        form +++
            MultivaluedSection(multivaluedOptions:[.Insert, .Delete], footer: "") {
                
                $0.tag = Config.activityList
                $0.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "行動ラベルを追加"
                        }.cellUpdate { cell, row in
                            cell.textLabel?.textAlignment = .left
                    }
                }
                $0.multivaluedRowToInsertAt = { index in
                    return TextRow() {
                        $0.placeholder = "行動名"
                    }
                }
                
                for activity in activityList! {
                    $0 <<< TextRow {
                        $0.placeholder = "行動名"
                        $0.value = activity
                    }
                }
                
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let section = form.sectionBy(tag: Config.activityList) as! MultivaluedSection
        defaults.set(section.values(), forKey: Config.activityList)
    }
    
}
//
//  SetupViewController.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/11.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift
import APIKit


/// ラベリングの設定を行うViewController
class SetupViewController: FormViewController {

    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ラベリング"
        
        form
            +++ Section("ラベルデータを保存するデータベースの設定")
            
            <<< TextRow() {
                $0.tag = Config.host
                $0.title = "接続先"
                $0.value = defaults.string(forKey: Config.host)
                
            }.onChange {row in
                // 内容が変更されたらUserdefaultsに書き込む
                self.defaults.set(row.value, forKey: Config.host)
            }
            
            <<< ButtonRow() {
                $0.title = "接続テスト"
                
            }.onCellSelection {_, _ in
                self.ping()
            }
            
            
            +++ Section("ラベリングする行動")
            
            <<< ButtonRow() {
                $0.title = "対象行動の確認"
                $0.presentationMode = .segueName(segueName: "ActivityTableViewControllerControllerSegue", onDismiss: nil)
            }
            
            
            +++ Section()
            
            <<< ButtonRow() {
                $0.title = "ラベリング開始"
                
            }.onCellSelection {_, _ in
                self.labelingStart()
            }
        
    }
    
    
    /// DBサーバへの接続テストを行う
    func ping() {
        let host = self.defaults.string(forKey: Config.host)
        let influxdb = InfluxDBClient(host: URL(string: host!)!)
        let request = PingRequest(influxdb: influxdb)
        
        Session.send(request) { result in
            switch result {
            case .success:
                let alert = UIAlertController(title: "通信成功",
                                              message: "正常に通信ができることを確認しました",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            case .failure(let error):
                let alert = UIAlertController(title: "通信エラー",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            }
        }
    }
    
    
    // ラベリングを開始する
    func labelingStart() {
        let host = defaults.string(forKey: Config.host)!
        let activityDict = defaults.dictionary(forKey: Config.activityDict)!
        
        var message = "接続先：\(host) \n\n"
        message = message + "対象行動\n"
        for (_, activity) in activityDict {
            message = message + "・\(activity)\n"
        }
        
        let alert = UIAlertController(title: "ラベリング開始", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開始", style: .default, handler: { action in
            // ラベリング画面に遷移
            self.performSegue(withIdentifier: "LabelingViewControllerSegue", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    
    @IBAction func reset(_ sender: Any) {
        let alert = UIAlertController(title: "設定の初期化", message: "本当に初期化してよろしいですか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            // 初期設定に戻す
            DefaultConfig().reset()
            
            // 入力エリアの表示も更新する
            let host = self.form.rowBy(tag: Config.host) as! TextRow
            host.value = self.defaults.string(forKey: Config.host)
            host.reload()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}


/// ラベリング行動確認画面
class ActivityTableViewController: UITableViewController {
    
    let activityDict = UserDefaults.standard.dictionary(forKey: Config.activityDict)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "行動ラベル"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityDict.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let key = Array(activityDict.keys)[indexPath.row]
        let activity = activityDict[key] as! String
        cell.textLabel?.text = activity
        
        return cell
    }

}

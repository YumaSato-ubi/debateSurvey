//
//  APIManager.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/07/24.
//  Copyright © 2018 Wataru Sasaki. All rights reserved.
//

import Foundation
import APIKit

class APIManager: NSObject {
    static let shared = APIManager()
    
    var user = ""
    var password = ""
    var database = ""
    var measurement = ""
    var ssl = false
    var host = ""
    var port = 0
    let unit = "s"
    
    
    /// KeyChainとUserDefaultsに保存されているパラメータを読み込む
    func paramLoad() {
        user = Keychain.user.value()!
        password = Keychain.password.value()!
        database = UserDefaults.standard.string(forKey: Config.database)!
        measurement = UserDefaults.standard.string(forKey: Config.measurement)!
        ssl = UserDefaults.standard.bool(forKey: Config.ssl)
        host = UserDefaults.standard.string(forKey: Config.host)!
        port = UserDefaults.standard.integer(forKey: Config.port)
    }
    
    /// DBへの接続テスト
    ///
    /// - Parameters:
    ///   - handler: 送信結果を返却する
    func test(handler: @escaping (Error?) -> ()) {
        
        paramLoad()
        
        let query = " SHOW MEASUREMENTS"
        let influxdb = InfluxDBClient(host: host, port: port, user: user, password: password, ssl: ssl)
        let request = QueryRequest(influxdb: influxdb, query: query, database: database)
        
        Session.send(request) { result in
            switch result {
            case .success:
                handler(nil)
                
            case .failure(let error):
                handler(error)
            }
        }
    }
    
    /// DBにラベルデータを書き込む
    ///
    /// - Parameters:
    ///   - time: 時間
    ///   - user: 被験者
    ///   - emotion: 感情
    ///   - handler: 送信結果を返却する
    func write(time: Date, users: String, emotion: Double, handler: @escaping (Error?) -> ()) {
        paramLoad()
        
        var tags: [String: String] = [:]
        tags["users"] = users
        var fields: [String: Any] = [:]
        fields["emotion"] = emotion
        let timeInterval = time.timeIntervalSince1970
        
        let influxdb = InfluxDBClient(host: host, port: port, user: user, password: password, ssl: ssl)
        let request = WriteRequest(influxdb: influxdb, precision: unit, database: database, measurement: measurement, tags: tags, fields: fields, time: timeInterval)
        
        Session.send(request) { result in
            switch result {
            case .success:
                handler(nil)
                
            case .failure(let error):
                handler(error)
            }
        }
    }
    
    func writeTime(time: Date, users: String, movieTime: Double, handler: @escaping (Error?) -> ()) {
        paramLoad()
        
        var tags: [String: String] = [:]
        tags["users"] = users
        var fields: [String: Any] = [:]
        fields["movieTime"] = movieTime
        let timeInterval = time.timeIntervalSince1970
        
        let influxdb = InfluxDBClient(host: host, port: port, user: user, password: password, ssl: ssl)
        let request = WriteRequest(influxdb: influxdb, precision: unit, database: database, measurement: measurement, tags: tags, fields: fields, time: timeInterval)
        
        Session.send(request) { result in
            switch result {
            case .success:
                handler(nil)
                
            case .failure(let error):
                handler(error)
            }
        }
    }
    
    func writeStar(time: Date, status: Double, handler: @escaping (Error?) -> ()) {
        
        paramLoad()
        measurement = "Satisfaction"
        
        var tags: [String: String] = [:]
        tags["user"] = user
        tags["satisfaction"] = "satisfaction"
        var fields: [String: Any] = [:]
        fields["level"] = status
        let timeInterval = time.timeIntervalSince1970
        
        let influxdb = InfluxDBClient(host: host, port: port, user: user, password: password, ssl: ssl)
        let request = WriteRequest(influxdb: influxdb, precision: unit, database: database, measurement: measurement, tags: tags, fields: fields, time: timeInterval)
        
        Session.send(request) { result in
            switch result {
            case .success:
                handler(nil)
                
            case .failure(let error):
                handler(error)
            }
        }
    }
    
    /// DBからラベルデータを削除する
    ///
    /// - Parameters:
    ///   - time: 時間
    ///   - handler: 送信結果を返却する
    func delete(time: String, handler: @escaping (Error?) -> ()) {
        
        paramLoad()
        
        let query = "DELETE FROM \(measurement) WHERE \"user\"='\(user)' and \"time\"=\(time)\(unit)"
        let influxdb = InfluxDBClient(host: host, port: port, user: user, password: password, ssl: ssl)
        let request = QueryRequest(influxdb: influxdb, query: query, database: database)
        
        Session.send(request) { result in
            switch result {
            case .success:
                handler(nil)
                
            case .failure(let error):
                handler(error)
            }
        }
    }
    
    /// DBからデータを全削除する
    ///
    /// - Parameters:
    ///   - handler: 送信結果を返却する
    
    func destroyActivity(handler: @escaping (Error?) -> ()) {
        
        paramLoad()
        
        let query = "DELETE FROM \(measurement) WHERE \"user\"='\(user)'"
        let influxdb = InfluxDBClient(host: host, port: port, user: user, password: password, ssl: ssl)
        let request = QueryRequest(influxdb: influxdb, query: query, database: database)
        
        Session.send(request) { result in
            switch result {
            case .success:
                handler(nil)
                
            case .failure(let error):
                handler(error)
            }
        }
    }
    func destroySatisfaction(handler: @escaping (Error?) -> ()) {
        
        paramLoad()
        measurement = "Satisfaction"
        
        let query = "DELETE FROM \(measurement) WHERE \"user\"='\(user)'"
        let influxdb = InfluxDBClient(host: host, port: port, user: user, password: password, ssl: ssl)
        let request = QueryRequest(influxdb: influxdb, query: query, database: database)
        
        Session.send(request) { result in
            switch result {
            case .success:
                handler(nil)
                
            case .failure(let error):
                handler(error)
            }
        }
    }
    
    
    /// DBからラベルデータを取得する
        ///
        /// - Parameters:
        ///   - handler: 送信結果を返却する
        func select(handler: @escaping ([[String: Any]]?, Error?) -> ()) {
             
             paramLoad()
             
             var list = [[String: Any]]()
             let query = "SELECT * FROM \(measurement)"
             let influxdb = InfluxDBClient(host: host, port: port, user: user, password: password, ssl: ssl)
             let request = QueryRequest(influxdb: influxdb, query: query, database: database, epoch: unit)
             
             Session.send(request) { result in
                 switch result {
                 case let .success(.results(value)):

                     if let results = value.results {
                         for result in results {
                             if let series = result.series {
                                 for s in series {
                                     for v in s.values {
                                         list.append(zip(s.columns, v).reduce(into: [String: Any]()) { $0[$1.0] = $1.1 })
                                     }
                                 }
                             }
                         }
                     }

    //                 print(list.last!["status"]!)
    //                 let bathActive = list.last!["status"]! as? StringOrIntType
    //                 let bathStr = bathActive?.string()
    //                 if bathStr == "1" {
    //                     print("Bathing")
    //                 }
                     handler(list, nil)
                 
                 case .success(.noContent):
                     print("noContent")
                     handler(nil, nil)
                 
                 case .success(.unknown(_)):
                     print("unknown")
                     handler(nil, nil)
                 
                 case .failure(let error):
                     print("failure")
                     handler(nil, error)
                 }
             }

         }
        
    }

//
//  DibalCom.swift
//  DibalTesteIOS
//
//  Created by Jorge Monteiro on 04/05/18.
//  Copyright © 2018 Jorge Monteiro. All rights reserved.
//

import Foundation
import SwiftSocket

class DibalCom {
    var IP_Adress = String()
    var TX_Port = Int32()
    
    init() {
        IP_Adress = "192.168.1.7"
        TX_Port = 3001
    }
    
    func sendData(data: String) {
        let client = TCPClient(address: IP_Adress, port: TX_Port)
        switch client.connect(timeout: 1) {
        case .success:
            switch client.send(string: data) {
            case .success:
                
                guard let data = client.read(1024*10) else { return }
                
                if let response = String(bytes: data, encoding: .utf8) {
                    print(response)
                }
            case .failure(let error):
                print(error)
            }
        case .failure(let error):
            print(error)
        }
    }
    
    func startLabeling(article: Artigo) {
        if let art_cod = (article.campos["codigo"] as? NSString)?.intValue {
            
            sendData(data: "4A500\(String(format: "%06d", art_cod))" )
        }
      
    }
    
    
}

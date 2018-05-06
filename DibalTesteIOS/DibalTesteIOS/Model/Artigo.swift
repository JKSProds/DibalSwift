//
//  Artigo.swift
//  DibalTesteIOS
//
//  Created by Jorge Monteiro on 01/05/18.
//  Copyright © 2018 Jorge Monteiro. All rights reserved.
//

import Foundation

struct Artigo {
    
    var campos: [String: String] = [
        "codigo": "",
        "nome": "",
        "tipo": "",
        "cod_rapido": "",
        "preço": "0.00",
        "validade": "",
        "tara": "0.000",
        "formato": "21",
        "nome2": ""
    ]
    
    
    init (campos: [String: Any]) {
        for (key, value) in campos {
            if let value = value as? String { self.campos[key] = value }
        }

    }
    
    init() {
        
    }
    
}

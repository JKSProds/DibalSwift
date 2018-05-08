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
        ] { didSet {
            campos["tara"] = weightConverter(string: campos["tara"]!)
            campos["preço"] = currencyConverterwithoutSymbol(string: campos["preço"]!)
    }
    }
    
    init (campos: [String: Any]) {
        for (key, value) in campos {
            if let value = value as? String { self.campos[key] = value }
        }

    }
    
    init() {
        
    }
    
    // MARK: All value conversions
    
    static func currencyConverter(string: String) -> String {
        let value = (string.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil) as NSString).doubleValue
       
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
            formatter.locale = Locale(identifier: Locale.current.identifier)
        return formatter.string(from: value as NSNumber)!
    }
    
    static func leadingZeros(numberOf zeros: Int, for string: String) -> String {
        let value = (string.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil) as NSString).doubleValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = zeros
        formatter.maximumIntegerDigits = zeros
        
        return formatter.string(from: value as NSNumber)!
    }
    
     func currencyConverterwithoutSymbol(string: String) -> String {
        let value = (string.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil) as NSString).doubleValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = ","
    formatter.locale = Locale(identifier: Locale.current.identifier)
        return formatter.string(from: value as NSNumber)!
    }
  
     func weightConverter(string: String) -> String {
        let value = (string as NSString).doubleValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
        formatter.decimalSeparator = "."
           formatter.locale = Locale(identifier: Locale.current.identifier)
        return formatter.string(from: value as NSNumber)!
    }
    
}

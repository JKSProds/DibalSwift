//
//  Artigo.swift
//  DibalTesteIOS
//
//  Created by Jorge Monteiro on 01/05/18.
//  Copyright © 2018 Jorge Monteiro. All rights reserved.
//

import Foundation

struct Artigo {
    
    var campos: [String: String] = ["Cod_Articulo": "","Cod_Familia": "","Cod_Subfamilia": "","Tipo": "","Cod_Rapido": "","Precio": "","Caducidad": "","IVA": "","Departamento": "","Seccion": "","Tara": "","Formato": "","Nombre": "","Nombre2": "","Texto1": "","Texto2": "","Texto3": "","Texto4": "","Texto5": "","Texto6": "","Texto7": "","Texto8": "","Texto9": "","Texto10": "","Precio_Oferta": "","Fecha_Extra": "","Formato_EAN": "","Rentabilidad": "","Promocion": "","Precio_Promocion": "","Com_Promocion": "","Fin_Promocion": "","Stock": "","Existencias": "","Perdidas": "","Stock_Min": "","Stock_Max": "","Aviso": "","Num_Oper": "","Importe": "","Peso": "","Margen_Objetivo": "","Precio_Anterior": "","Promocion_Actualizada": "","Precio_Costo": "","Cantidad_Comprada": "","Precio_Ultima_Compra": "","Precio_Medio_Venta": "","Cantidad_Vendida": "","Precio_Ultima_Venta": "","EAN_Scanner": "","Peso_Tramo1": "","Precio_Tramo1": "","Peso_Tramo2": "","Precio_Tramo2": "","Peso_Tramo3": "","Precio_Tramo3": "","Oper_temp": "","Num_Oper_Ult": "","Peso_Ult": "","Importe_Ult": "","Carne": "","Cod_Vacuno": "","Fecha_Envasado": "","Tara_Porcentual": "","Formato_EAN128": "","Receta": "","Logo": "","Nombre3": "","Texto4_LP2500": "","Texto4_2_LP2500": "","Precio_Libre": "","Clase": "","PrecioTarifa1": "","PrecioTarifa2": "","PrecioTarifa3": "","Ndespiece": "","CodigoCompra": "","TextoG": "","TipoOferta": "","Codigo_Conad": "","EAN13_14": "","TipoEan": "","PesoPieza": "","Conservacion": "","NumeroUnidades": "","Nivel1": "","Nivel2": "","Nivel3": "","UmbralTrigger": "","TiempoEstablecimiento": "","TiempoMedida": "","VelocidadCintas": "","Centrado": "","Texto4_K": "","Texto5_K": "","Glaseado": "","PesoMinimo": "","PesoMaximo": "","EAN13_14_2": "","TipoEan_2": "","Formato_EAN128_2": "","Formato_EAN_2": "","TipoCW": "","PesoObjetivo": "","PorcPesoMinimo": "","PorcPesoMaximo": "","NRechazosMin": "","NRechazosMax": "","NMedias": "","ModoPesaje": "","PesoClasificacion1": "","NRechazos1": "","NSalida1": "","PesoClasificacion2": "","NRechazos2": "","NSalida2": "","PesoClasificacion3": "","NRechazos3": "","NSalida3": "","PesoClasificacion4": "","NRechazos4": "","NSalida4": "","PesoClasificacion5": "","NRechazos5": "","NSalida5": "","PesoClasificacion6": "","NRechazos6": "","NSalida6": "","PesoClasificacion7": "","NRechazos7": "","NSalida7": "","PesoClasificacion8": "","NRechazos8": "","NSalida8": "","SimboloPeso": "","SimboloPrecio": "","SimboloImporte": "","Logo1": "","Logo2": "","Logo3": "","Logo4": "","Logo5": "","NumeroLote": "","FormatoFechaEnvasado": "","FormatoFechaCaducidad": "","FormatoFechaExtra": "","FormatoFechaCongelacion": "","TotalPeso": "","MargenPeso": "","TiempoDeCoccion": "","TiempoFijo": "","ControlStock": "","EtiquetasStock": "","PesoStock": "","FtoConsumo": "","Clasificacion1": "","Salida1": "","Clasificacion2": "","Salida2": "","Clasificacion3": "","Salida3": "","Clasificacion4": "","Salida4": "","CodIngredientes": "","CodTara": "","ModoEquipo": "","FormatoEtiquetaE1": "","FormatoEtiquetaE2": "","FormatoTotales": "","FormatoNivel1": "","FormatoNivel2": "","FormatoNivel3": "","DiaSemanaOferta": "","Longitud": "","CentradoE1": "","CentradoE2": "","EAN_Scanner1": "","EAN_Scanner2": "","TextoClasif": "","ValorT1": "","ValorT2": "","ValorNominal": "","Opt_CE": "","ImpSoloTot": "","MinimoON": "","MinimoOFF": "","PaqueteMin": "","EAN13_14_3": "","TipoEan_3": "","Formato_EAN128_3": "","Formato_EAN_3": "","EAN13_14_4": "","TipoEan_4": "","Formato_EAN128_4": "","Formato_EAN_4": "","Texto12": "","Texto13": "","Texto14": "","Texto15": "","Texto16": "","Texto17": "","Texto18": "","Texto19": "","Texto20": "","PesoMinimo2CW": "","PorcenAceptacionCW": "","PesoEmbalaje": "","Precio2": "","CentradoDiscriminador1": "","CentradoDiscriminador2": "","CentradoDiscriminador3": "","CentradoCinta1": "","Espera": "","Texto21": "","Texto22": "","Texto23": "","Texto24": "","Texto25": "","Texto26": "","Texto27": "","Texto28": "","Texto29": "","Texto30": ""]
    
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
    
     static func currencyConverterwithoutSymbol(string: String) -> String {
        let value = (string.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil) as NSString).doubleValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = ","
    formatter.locale = Locale(identifier: Locale.current.identifier)
        return formatter.string(from: value as NSNumber)!
    }
  
     static func weightConverter(string: String) -> String {
        let value = (string as NSString).doubleValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
        formatter.decimalSeparator = "."
           formatter.locale = Locale(identifier: Locale.current.identifier)
        return formatter.string(from: value as NSNumber)!
    }
    
    
    static func dateConverter (string: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"
        let date = dateFormatter.date(from: string)
        dateFormatter.dateFormat = "yyMMdd"
        return  date != nil ? dateFormatter.string(from: date!) : ""
        
    }
    
    static func dateConverterVisualy (string: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let date = dateFormatter.date(from: string)
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return  date != nil ? dateFormatter.string(from: date!) : ""
        
    }
    
    
    static func percentConverter(string: String) -> String {
        let value = (string.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil) as NSString).doubleValue
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.maximum = 99.99
        formatter.locale = Locale(identifier: Locale.current.identifier)
        return formatter.string(from: value as NSNumber)!
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

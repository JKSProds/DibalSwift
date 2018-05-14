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
    
    private func sendData(data: String) {
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
        client.close()
    }
    
    private func register4A(article: Artigo) {
        let codArticle = Artigo.leadingZeros(numberOf: 6, for: article.campos["Cod_Articulo"]!)
        
        sendData(data: "\(Constants.ID)4A\(Constants.Grupo)0\(codArticle)" )
    }
    
    private func registerL2(article: Artigo) {
        let codArticle = Artigo.leadingZeros(numberOf: 6, for: article.campos["Cod_Articulo"]!)
        let codRapido = Artigo.leadingZeros(numberOf: 3, for: article.campos["Cod_Rapido"]!)
        let nome1 = article.campos["Nombre"]?.padding(toLength: 24, withPad: " ", startingAt: 0)
        let nome2 = article.campos["Nombre2"]?.padding(toLength: 24, withPad: " ", startingAt: 0)
        let nome3 = article.campos["Nombre3"]?.padding(toLength: 24, withPad: " ", startingAt: 0)
        let preco = Artigo.leadingZeros(numberOf: 8, for: article.campos["Precio"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let precoOferta = Artigo.leadingZeros(numberOf: 8, for: article.campos["Precio_Oferta"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let precoCusto = Artigo.leadingZeros(numberOf: 8, for: article.campos["Precio_Costo"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let libres = Artigo.leadingZeros(numberOf: 18, for: "0")
        
        sendData(data: "\(Constants.ID)L2\(Constants.Grupo)M\(codArticle)\(codRapido)\(nome1!)\(nome2!)\(nome3!)\(preco)\(precoOferta)\(precoCusto)\(libres)")
        
    }

    private func registerL3(article: Artigo) {

        let codArticle = Artigo.leadingZeros(numberOf: 6, for: article.campos["Cod_Articulo"]!)
        let tipo = Artigo.leadingZeros(numberOf: 1, for: article.campos["Tipo"]!)
        let validade = Artigo.leadingZeros(numberOf: 6, for: article.campos["Caducidad"]!)
        let fechaExtra = Artigo.leadingZeros(numberOf: 6, for: article.campos["Fecha_Extra"]!)
        let fechaEnvasado = Artigo.leadingZeros(numberOf: 6, for: article.campos["Fecha_Envasado"]!)
        let tara = Artigo.leadingZeros(numberOf: 5, for: article.campos["Tara"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let taraPercentual = Artigo.leadingZeros(numberOf: 2, for: article.campos["Tara_Porcentual"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let formatoEtiqueta = Artigo.leadingZeros(numberOf: 2, for: article.campos["Formato"]!)
        let formatoEAN13 = Artigo.leadingZeros(numberOf: 2, for: article.campos["Formato_EAN"]!)
        let formatoEAN128 = Artigo.leadingZeros(numberOf: 2, for: article.campos["Formato_EAN128"]!)
        let seccao = Artigo.leadingZeros(numberOf: 4, for: article.campos["Seccion"]!)
        let iva = Artigo.leadingZeros(numberOf: 2, for: article.campos["IVA"]!)
        let smiley = Artigo.leadingZeros(numberOf: 1, for: "0")
        let codClasse = Artigo.leadingZeros(numberOf: 2, for: article.campos["Clase"]!)
        let codLote = Artigo.leadingZeros(numberOf: 3, for: article.campos["Ndespiece"]!)
        let receitaLXXX = Artigo.leadingZeros(numberOf: 2, for: article.campos["Receta"]!)
        let logoLXXX = Artigo.leadingZeros(numberOf: 2, for: article.campos["Logo"]!)
        let departamento = Artigo.leadingZeros(numberOf: 4, for: article.campos["Departamento"]!)
        let rastreabilidade = Artigo.leadingZeros(numberOf: 1, for: article.campos["Carne"]!)
        let receitaLP = Artigo.leadingZeros(numberOf: 3, for: article.campos["Receta"]!)
        let conservarcaoLP = Artigo.leadingZeros(numberOf: 3, for: article.campos["Conservacion"]!)
        let pesoPeça = Artigo.leadingZeros(numberOf: 6, for: article.campos["PesoPieza"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let posicaoDecimal = Artigo.leadingZeros(numberOf: 1, for: "0")
        let nivel1 = Artigo.leadingZeros(numberOf: 4, for: article.campos["Nivel1"]!)
        let nivel2 = Artigo.leadingZeros(numberOf: 3, for: article.campos["Nivel2"]!)
        let nivel3 = Artigo.leadingZeros(numberOf: 3, for: article.campos["Nivel3"]!)
        let umbralTrigger = Artigo.leadingZeros(numberOf: 5, for: article.campos["UmbralTrigger"]!)
        let tempoEstabelecido = Artigo.leadingZeros(numberOf: 3, for: article.campos["TiempoEstablecimiento"]!)
        let tempoMedida = Artigo.leadingZeros(numberOf: 3, for: article.campos["TiempoMedida"]!)
        let velocidadeCintas = Artigo.leadingZeros(numberOf: 1, for: article.campos["VelocidadCintas"]!)
        let centrado = Artigo.leadingZeros(numberOf: 3, for: article.campos["Centrado"]!)
        let glaseado = Artigo.leadingZeros(numberOf: 4, for: article.campos["Glaseado"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let pesoMinimo = Artigo.leadingZeros(numberOf: 6, for: article.campos["PesoMinimo"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let pesoMaximo = Artigo.leadingZeros(numberOf: 6, for: article.campos["PesoMaximo"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let formatoEAN2 = Artigo.leadingZeros(numberOf: 2, for: article.campos["Formato_EAN_2"]!)
        let controlCoccion = Artigo.leadingZeros(numberOf: 1, for: "1")
        let tempoCoccion = Artigo.leadingZeros(numberOf: 2, for: article.campos["TiempoDeCoccion"]!)
        let tempoFixo = Artigo.leadingZeros(numberOf: 2, for: article.campos["TiempoFijo"]!)
        let soloTotais = Artigo.leadingZeros(numberOf: 1, for: "0")
        let controlSoloTotais = Artigo.leadingZeros(numberOf: 1, for: "1")
        let libres = Artigo.leadingZeros(numberOf: 2, for: "0")
        
        sendData(data: "\(Constants.ID)L3\(Constants.Grupo)\(codArticle)\(tipo)\(validade)\(fechaExtra)\(fechaEnvasado)\(tara)\(taraPercentual)\(formatoEtiqueta)\(formatoEAN13)\(formatoEAN128)\(seccao)\(iva)\(smiley)\(codClasse)\(String(codLote.dropFirst(1)))\(receitaLXXX)\(logoLXXX)\(departamento)\(rastreabilidade)\(receitaLP)\(conservarcaoLP)\(pesoPeça)\(posicaoDecimal)\(String(nivel1.dropFirst(1)))\(nivel2)\(nivel3)\(umbralTrigger)\(tempoEstabelecido)\(tempoMedida)\(velocidadeCintas)\(centrado)\(glaseado)\(pesoMinimo)\(pesoMaximo)\(String(codLote.first!))\(formatoEAN2)\(controlCoccion)\(tempoCoccion)\(tempoFixo)\(soloTotais)\(controlSoloTotais)\(String(nivel1.first!))\(libres)")
    }
    
    private func registerTA(article: Artigo) {
        
        let codArticle = Artigo.leadingZeros(numberOf: 6, for: article.campos["Cod_Articulo"]!)
        let formatoTotais = Artigo.leadingZeros(numberOf: 3, for: article.campos["FormatoTotales"]!)
        let formatoNivel1 = Artigo.leadingZeros(numberOf: 3, for: article.campos["FormatoNivel1"]!)
        let formatoNivel2 = Artigo.leadingZeros(numberOf: 3, for: article.campos["FormatoNivel2"]!)
        let formatoNivel3 = Artigo.leadingZeros(numberOf: 3, for: article.campos["FormatoNivel3"]!)
        let controlLongitude = Artigo.leadingZeros(numberOf: 1, for: "1")
        let longitude = Artigo.leadingZeros(numberOf: 4, for: article.campos["Longitud"]!)
        let controlCentrado = Artigo.leadingZeros(numberOf: 1, for: "1")
        let centradoE1 = Artigo.leadingZeros(numberOf: 3, for: article.campos["CentradoE1"]!)
        let centradoE2 = Artigo.leadingZeros(numberOf: 3, for: article.campos["CentradoE2"]!)
        let minimoON = Artigo.leadingZeros(numberOf: 4, for: article.campos["MinimoON"]!)
        let minimoOFF = Artigo.leadingZeros(numberOf: 4, for: article.campos["MinimoOFF"]!)
        let paqueteMin = Artigo.leadingZeros(numberOf: 4, for: article.campos["PaqueteMin"]!)
        let controlMinimos = Artigo.leadingZeros(numberOf: 1, for: "1")
        let controlEmbalagem = Artigo.leadingZeros(numberOf: 1, for: "1")
        let pesoEmbalagem = Artigo.leadingZeros(numberOf: 5, for: article.campos["PesoEmbalaje"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let controlSeguinte = Artigo.leadingZeros(numberOf: 1, for: "1")
        let formatoEtiqueta = Artigo.leadingZeros(numberOf: 3, for: article.campos["Formato"]!)
        let libres = Artigo.leadingZeros(numberOf: 73, for: "0")
        
        sendData(data: "\(Constants.ID)TA\(Constants.Grupo)\(codArticle)\(String(formatoTotais.dropFirst(1)))\(String(formatoNivel1.dropFirst(1)))\(String(formatoNivel2.dropFirst(1)))\(String(formatoNivel3.dropFirst(1)))\(controlLongitude)\(longitude)\(controlCentrado)\(centradoE1)\(centradoE2)\(minimoON)\(minimoOFF)\(paqueteMin)\(controlMinimos)\(controlEmbalagem)\(pesoEmbalagem)\(controlSeguinte)\(String(formatoEtiqueta.first!))\(String(formatoTotais.first!))\(String(formatoNivel1.first!))\(String(formatoNivel2.first!))\(String(formatoNivel3.first!))\(libres)")
    }
    
    private func registerMG(article: Artigo) {
        
        let codArticle = Artigo.leadingZeros(numberOf: 6, for: article.campos["Cod_Articulo"]!)
        let controlStock = Artigo.leadingZeros(numberOf: 1, for: article.campos["ControlStock"]!)
        let etiquetasStock = Artigo.leadingZeros(numberOf: 6, for: article.campos["EtiquetasStock"]!)
        let pesoStock = Artigo.leadingZeros(numberOf: 8, for: article.campos["PesoStock"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let numeroLote = article.campos["NumeroLote"]?.padding(toLength: 24, withPad: " ", startingAt: 0)
        let controlFormatos = Artigo.leadingZeros(numberOf: 1, for: "1")
        let formatoFechaEnvasado = Artigo.leadingZeros(numberOf: 2, for: article.campos["FormatoFechaEnvasado"]!)
        let formatoFechaValidade = Artigo.leadingZeros(numberOf: 2, for: article.campos["FormatoFechaCaducidad"]!)
        let formatoFechaExtra = Artigo.leadingZeros(numberOf: 2, for: article.campos["FormatoFechaExtra"]!)
        let formatoFecha = Artigo.leadingZeros(numberOf: 2, for: article.campos["FormatoFechaCongelacion"]!)
        let controlClassificacao = Artigo.leadingZeros(numberOf: 1, for: "1")
        let classificacao0 = Artigo.leadingZeros(numberOf: 6, for: article.campos["Clasificacion1"]!)
        let saida0 = Artigo.leadingZeros(numberOf: 1, for: article.campos["Salida1"]!)
        let classificacao1 = Artigo.leadingZeros(numberOf: 6, for: article.campos["Clasificacion2"]!)
        let saida1 = Artigo.leadingZeros(numberOf: 1, for: article.campos["Salida2"]!)
        let classificacao2 = Artigo.leadingZeros(numberOf: 6, for: article.campos["Clasificacion3"]!)
        let saida2 = Artigo.leadingZeros(numberOf: 1, for: article.campos["Salida3"]!)
        let classificacao3 = Artigo.leadingZeros(numberOf: 6, for: article.campos["Clasificacion4"]!)
        let saida3 = Artigo.leadingZeros(numberOf: 1, for: article.campos["Salida4"]!)
        let controlSimbolos = Artigo.leadingZeros(numberOf: 1, for: "1")
        let simboloPeso = Artigo.leadingZeros(numberOf: 1, for: article.campos["SimboloPeso"]!)
        let simboloPreço = Artigo.leadingZeros(numberOf: 1, for: article.campos["SimboloPrecio"]!)
        let simboloImporte = Artigo.leadingZeros(numberOf: 1, for: article.campos["SimboloImporte"]!)
        let totalPesoNivel1 = Artigo.leadingZeros(numberOf: 8, for: article.campos["TotalPeso"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let margemPeso = Artigo.leadingZeros(numberOf: 5, for: article.campos["MargenPeso"]!.replacingOccurrences(of: ".", with: "", options: .literal, range: nil))
        let controlLogos = Artigo.leadingZeros(numberOf: 1, for: "1")
        let logo1 = Artigo.leadingZeros(numberOf: 2, for: article.campos["Logo1"]!)
        let logo2 = Artigo.leadingZeros(numberOf: 2, for: article.campos["Logo2"]!)
        let logo3 = Artigo.leadingZeros(numberOf: 2, for: article.campos["Logo3"]!)
        let logo4 = Artigo.leadingZeros(numberOf: 2, for: article.campos["Logo4"]!)
        let logo5 = Artigo.leadingZeros(numberOf: 2, for: article.campos["Logo5"]!)
        let formatoFechaConsumo = Artigo.leadingZeros(numberOf: 2, for: article.campos["FtoConsumo"]!)
        let controlFormatoFechaConsumo = Artigo.leadingZeros(numberOf: 1, for: "1")
        let controlMulticabecal = Artigo.leadingZeros(numberOf: 1, for: "1")
        let modoEquipoMulticabecal = Artigo.leadingZeros(numberOf: 2, for: article.campos["ModoEquipo"]!)
        let formatoEtiquetaE1 = Artigo.leadingZeros(numberOf: 3, for: article.campos["FormatoEtiquetaE1"]!)
        let formatoEtiquetaE2 = Artigo.leadingZeros(numberOf: 3, for: article.campos["FormatoEtiquetaE2"]!)
        let controlFormatoEscrava = Artigo.leadingZeros(numberOf: 1, for: "1")
        
        
        sendData(data: "\(Constants.ID)MG\(Constants.Grupo)\(codArticle)\(controlStock)\(etiquetasStock)\(pesoStock)\(numeroLote!)\(controlFormatos)\(formatoFechaEnvasado)\(formatoFechaValidade)\(formatoFechaExtra)\(formatoFecha)\(controlClassificacao)\(classificacao0)\(saida0)\(classificacao1)\(saida1)\(classificacao2)\(saida2)\(classificacao3)\(saida3)\(controlSimbolos)\(simboloPeso)\(simboloPreço)\(simboloImporte)\(totalPesoNivel1)\(margemPeso)\(controlLogos)\(logo1)\(logo2)\(logo3)\(logo4)\(logo5)\(formatoFechaConsumo)\(controlFormatoFechaConsumo)\(controlMulticabecal)\(modoEquipoMulticabecal)\(String(formatoEtiquetaE1.dropFirst(1)))\(String(formatoEtiquetaE2.dropFirst(1)))\(controlFormatoEscrava)\(String(formatoEtiquetaE1.first!))\(String(formatoEtiquetaE2.first!))")
    }
    
    private func registerL4 (article: Artigo) {
        let codArticle = Artigo.leadingZeros(numberOf: 6, for: article.campos["Cod_Articulo"]!)
        let libres =  Artigo.leadingZeros(numberOf: 14, for: "0")
        
        for index in 0...4 {
            
            let texto1 = article.campos["Texto\(index*2+1)"]?.padding(toLength: 24, withPad: " ", startingAt: 0).spaceBetweenChar()
            let texto2 = article.campos["Texto\(index*2+2)"]?.padding(toLength: 24, withPad: " ", startingAt: 0).spaceBetweenChar()
            
            sendData(data: "\(Constants.ID)L4\(Constants.Grupo)\(codArticle)\(index*2)\(texto1!)\(codArticle)\(index*2+1)\(texto2!)\(libres)")
            
        }
        
    }
    
    private func registerX4(article: Artigo) {
        
        let codArticle = Artigo.leadingZeros(numberOf: 6, for: article.campos["Cod_Articulo"]!)
        let textoG = article.campos["TextoG"]!
        
        if textoG.count > 0 {
            let textosSeparados = textoG.split(by: 115)
            
            for index in 1...textosSeparados.count {
                let codigoTexto = Artigo.leadingZeros(numberOf: 2, for: String(index))
                let texto = textosSeparados[index-1].padding(toLength: 115, withPad: " ", startingAt: 0)
                sendData(data: "\(Constants.ID)X4\(Constants.Grupo)\(codArticle)\(codigoTexto)\(texto)")
            }
        }
        
    }
    
    private func registerTG(article: Artigo) {
        let codArticle = Artigo.leadingZeros(numberOf: 6, for: article.campos["Cod_Articulo"]!)
        
        for index in 12...30 {
            let texto = article.campos["Texto\(index)"]!
            
            if texto.count > 0 {
                let textosSeparados = texto.split(by: 113)
                
                for indexTexto in 1...textosSeparados.count {
                    let codigoTexto = Artigo.leadingZeros(numberOf: 2, for: String(indexTexto))
                    let texto = textosSeparados[indexTexto-1].padding(toLength: 113, withPad: " ", startingAt: 0)
                    sendData(data: "\(Constants.ID)TG\(Constants.Grupo)\(index)\(codArticle)\(codigoTexto)\(texto)")
                }
            }
        }
    }
    
    func startLabeling(article: Artigo) {
        if let _ = Int(article.campos["Cod_Articulo"]!) {
            register4A(article: article)
        }
        
    }
    
     func sendArticle(article: Artigo) {
        if let _ = Int(article.campos["Cod_Articulo"]!) {
            
            registerL2(article: article)
            
            registerL3(article: article)
            
            registerTA(article: article)
            
            registerMG(article: article)
            
            registerL4(article: article)
            
            registerX4(article: article)
            
            registerTG(article: article)
        }
        
        
    }
}

extension DibalCom {
    struct Constants {
        static let Grupo = "50"
        static let ID = "00"
    }
}

extension String {
    func spaceBetweenChar() -> String {
        var texto = String()
        
        for char in self {
            texto = texto + " \(char)"
        }
        
        return texto
    }
    
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }
        
        return results.map { String($0) }
    }
    
}

















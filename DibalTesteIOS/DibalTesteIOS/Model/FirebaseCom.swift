//
//  FirebaseCom.swift
//  DibalTesteIOS
//
//  Created by Jorge Monteiro on 04/05/18.
//  Copyright © 2018 Jorge Monteiro. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseCom {
    
    var clientRef: DocumentReference
    var articles = [Artigo]()
    var selectedArticle = -1
    var list: ListenerRegistration!
    var headers = [ExpandableHeaders(isExpanded: true, Title: "Dados", Fields: [], Image: "dados.png"),
                   ExpandableHeaders(isExpanded: true, Title: "Textos", Fields: [], Image: "textos.png"),
                   ExpandableHeaders(isExpanded: true, Title: "Codigos de Barra", Fields: [], Image: "barcodes.png"),
                   ExpandableHeaders(isExpanded: true, Title: "Automatismos", Fields: [], Image: "automatismos.png"),
                   ExpandableHeaders(isExpanded: true, Title: "Outros", Fields: [], Image: "outros.png")]
    
    
    
    init(clientID: String) {
        
        FirebaseApp.configure()
        clientRef = Firestore.firestore().collection("dibal").document("\(clientID)")
        
    }
    
    func setAllExpanded(){
        for h in headers.indices {
            headers[h].isExpanded = true
        }
    }
    
    
    // MARK: Gets the client header
    func getClientHeader(to Label: UINavigationItem) {
        clientRef.addSnapshotListener { (document, error) in
            if let document = document {
                Label.title = "\(document.data()!["nome"]!)"
                //print(self.clientName)
            } else {
                Label.title = ("CLIENT_NAME")
                //print("Document does not exist")
                
            }
        }
    }
    
    // MARK: Handles the articles
    
    func getAllArticles(tableView: UITableView) {
        clientRef.collection("articles").order(by: "Cod_Articulo").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            querySnapshot?.documentChanges.forEach { diff in
                //print("\(diff.document.documentID) => \(diff.document.data())")
                if (diff.document.data()["Cod_Articulo"]) != nil  {
                    let art = Artigo(campos: diff.document.data())
                    //print(art)
                    if (diff.type == .added) {
                        //print(diff.newIndex)
                        self.articles.insert(art, at: Int(diff.newIndex))
                        
                        let indexPath = IndexPath(row: Int(diff.newIndex), section: 0)
                        tableView.insertRows(at: [indexPath], with: .left)
                        //print (art.codigo)
                    }
                    if (diff.type == .modified) {
                        self.articles[Int(diff.newIndex)] = art
                        tableView.reloadData()
                    }
                    if (diff.type == .removed) {
                        self.articles.remove(at: Int(diff.oldIndex))
                        
                        tableView.reloadData()
                        
                    }
                }
            }
        }
    }
    
    func checkIfArticleExists(artigo: Artigo) -> Bool {
        for art in articles {
            if art.campos["Cod_Articulo"] == artigo.campos["Cod_Articulo"] {
                return true
            }
            
        }
        return false
    }
    
    
    func removeArticle(at index: Int) {
        if index >= 0 {
            var docID: String = ""
            clientRef.collection("articles").whereField("Cod_Articulo", isEqualTo: articles[index].campos["Cod_Articulo"]!)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            //print("\(document.documentID) => \(document.data())")
                            docID = "\(document.documentID)"
                            self.clientRef.collection("articles").document(docID).delete()
                        }
                    }
            }
        }
    }
    
    func checkArticleField(at field: field, string: String) -> String {
        var res = ""
        
        if string.count > field.max {
            res = "Tem \(string.count) caracteres! Max Caracteres: \(field.max)"
        }else{
            
            // 0 - Inteiro | 1 - Preço | 2 - Peso | 3 - String | 4 - Combobox
            switch field.tipo {
            case 0:
                let stringInt = Int(string)
                if stringInt == nil {
                    res = "Valor tem de ser um numero inteiro!"
                }
            case 1:
                let stringDouble = Float(string)
                if stringDouble == nil {
                    res = "Valor não é um valor monetário!"
                }
            case 2:
                let stringDouble = Float(string)
                if stringDouble == nil  {
                    res = "Valor não é um valor de peso!"
                }
            case 6:
                if Artigo.dateConverter(string: string) == "" {
                    return "O valor inserido não é uma data!"
                }
            case 5:
                let stringDouble = Float(string)
                if stringDouble == nil {
                    res = "Valor não é uma percentagem!"
                }
            default:
                res = ""
            }
        }
        
        return res
    }
    
    func formatArticleField(at field: field, string: String) -> String {
        var res = ""
        
        
        
        // 0 - Inteiro | 1 - Preço | 2 - Peso | 3 - String | 4 - Combobox | 5 - Percentagem | 6 - Data
        switch field.tipo {
        case 1:
            return Artigo.currencyConverterwithoutSymbol(string: string)
        case 2:
            return Artigo.weightConverter(string: string)
            
        case 5:
            return Artigo.percentConverter(string: string)
        case 6:
            return Artigo.dateConverter(string: string)!
        default:
            res = string
        }
        
        return res
    }
    
    func uploadArtigo(artigo: Artigo) {
        var docID: String = ""
        if (artigo.campos["Cod_Articulo"] != nil) {
            clientRef.collection("articles").whereField("Cod_Articulo", isEqualTo: artigo.campos["Cod_Articulo"]!)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            //print("\(document.documentID) => \(document.data())")
                            docID = "\(document.documentID)"
                            //print(self.codigo)
                            self.clientRef.collection("articles").document(docID).setData(artigo.campos)
                        }
                    }
                    if docID == "" {
                        self.clientRef.collection("articles").addDocument(data: artigo.campos)
                        
                    }
            }
        }
    }
    
    // MARK: Get all the fields into array
    
    func getAllFields(tableView: UITableView) {
        for h in headers.indices {
            headers[h].Fields.removeAll()
        }
        list = clientRef.collection("fields").order(by: "id").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                querySnapshot?.documentChanges.forEach { diff in
                    if diff.type == .modified || self.isFieldValid(document: diff.document.data()) {
                        
                        var id_master = diff.document.data()["id_master"]! as! Int
                        if id_master >= self.headers.count { id_master = 0}
                        //let id = self.headers[id_master].Fields.count
                        
                        var f = field(id_master: id_master, nome: "\(diff.document.data()["nome"]!)", descricao: "\(diff.document.data()["descricao"]!)", tipo: diff.document.data()["tipo"]! as! Int, visible: diff.document.data()["visible"]! as! Bool, def: "\(diff.document.data()["def"]!)", max: diff.document.data()["max"]! as! Int, campos: [])
                        
                        if f.tipo == 4 {
                            f.campos = diff.document.data()["campos"] as! [[String:Any]]
                        }
                        
                        if (diff.type == .added) {
                            self.headers[id_master].Fields.append(f)
                            //let indexPath = IndexPath(row: id, section: id_master)
                            //tableView.insertRows(at: [indexPath], with: .left)
                        }
                        if (diff.type == .modified) {
                            let index = self.getIDbyNome(nome: f.nome)
                            if index.count > 0, f.id_master != index.section {
                                self.headers[index.section].Fields.remove(at: index.row)
                                //tableView.deleteRows(at: [index], with: .bottom)
                                tableView.reloadData()
                                
                                if index.row >= self.headers[id_master].Fields.count {
                                    let indexPath = IndexPath(row: self.headers[id_master].Fields.count, section: id_master)
                                    if index.count > 0 {
                                        self.headers[id_master].Fields.append(f)
                                        tableView.insertRows(at: [indexPath], with: .left)
                                    }
                                }else{
                                    let indexPath = IndexPath(row: index.row, section: id_master)
                                    if index.count > 0 {
                                        self.headers[id_master].Fields.insert(f, at: index.row)
                                        tableView.insertRows(at: [indexPath], with: .left)
                                    }
                                }
                                
                                
                            }else{
                                self.headers[index.section].Fields[index.row] = f
                                tableView.reloadData()
                            }
                        }
                        if (diff.type == .removed) {
                            let index = self.getIDbyNome(nome: f.nome)
                            if  index.row >= 0 {
                                self.headers[index.section].Fields.remove(at: index.row)
                                tableView.deleteRows(at: [index], with: .bottom)
                            }
                        }
                    }
                }
            }
            let range = NSMakeRange(0, tableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            tableView.reloadSections(sections as IndexSet, with: .automatic)
        }
    }
    
    func createAllFields() {
        var docID: String = ""
        clientRef.collection("fields").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    docID = "\(document.documentID)"
                    self.clientRef.collection("fields").document(docID).delete()
                }
                var index = 0
                
                let campos = ["Cod_Articulo","Cod_Familia","Cod_Subfamilia","Tipo","Cod_Rapido","Precio","Caducidad","IVA","Departamento","Seccion","Tara","Formato","Nombre","Nombre2","Texto1","Texto2","Texto3","Texto4","Texto5","Texto6","Texto7","Texto8","Texto9","Texto10","Precio_Oferta","Fecha_Extra","Formato_EAN","Rentabilidad","Promocion","Precio_Promocion","Com_Promocion","Fin_Promocion","Stock","Existencias","Perdidas","Stock_Min","Stock_Max","Aviso","Num_Oper","Importe","Peso","Margen_Objetivo","Precio_Anterior","Promocion_Actualizada","Precio_Costo","Cantidad_Comprada","Precio_Ultima_Compra","Precio_Medio_Venta","Cantidad_Vendida","Precio_Ultima_Venta","EAN_Scanner","Peso_Tramo1","Precio_Tramo1","Peso_Tramo2","Precio_Tramo2","Peso_Tramo3","Precio_Tramo3","Oper_temp","Num_Oper_Ult","Peso_Ult","Importe_Ult","Carne","Cod_Vacuno","Fecha_Envasado","Tara_Porcentual","Formato_EAN128","Receta","Logo","Nombre3","Texto4_LP2500","Texto4_2_LP2500","Precio_Libre","Clase","PrecioTarifa1","PrecioTarifa2","PrecioTarifa3","Ndespiece","CodigoCompra","TextoG","TipoOferta","Codigo_Conad","EAN13_14","TipoEan","PesoPieza","Conservacion","NumeroUnidades","Nivel1","Nivel2","Nivel3","UmbralTrigger","TiempoEstablecimiento","TiempoMedida","VelocidadCintas","Centrado","Texto4_K","Texto5_K","Glaseado","PesoMinimo","PesoMaximo","EAN13_14_2","TipoEan_2","Formato_EAN128_2","Formato_EAN_2","TipoCW","PesoObjetivo","PorcPesoMinimo","PorcPesoMaximo","NRechazosMin","NRechazosMax","NMedias","ModoPesaje","PesoClasificacion1","NRechazos1","NSalida1","PesoClasificacion2","NRechazos2","NSalida2","PesoClasificacion3","NRechazos3","NSalida3","PesoClasificacion4","NRechazos4","NSalida4","PesoClasificacion5","NRechazos5","NSalida5","PesoClasificacion6","NRechazos6","NSalida6","PesoClasificacion7","NRechazos7","NSalida7","PesoClasificacion8","NRechazos8","NSalida8","SimboloPeso","SimboloPrecio","SimboloImporte","Logo1","Logo2","Logo3","Logo4","Logo5","NumeroLote","FormatoFechaEnvasado","FormatoFechaCaducidad","FormatoFechaExtra","FormatoFechaCongelacion","TotalPeso","MargenPeso","TiempoDeCoccion","TiempoFijo","ControlStock","EtiquetasStock","PesoStock","FtoConsumo","Clasificacion1","Salida1","Clasificacion2","Salida2","Clasificacion3","Salida3","Clasificacion4","Salida4","CodIngredientes","CodTara","ModoEquipo","FormatoEtiquetaE1","FormatoEtiquetaE2","FormatoTotales","FormatoNivel1","FormatoNivel2","FormatoNivel3","DiaSemanaOferta","Longitud","CentradoE1","CentradoE2","EAN_Scanner1","EAN_Scanner2","TextoClasif","ValorT1","ValorT2","ValorNominal","Opt_CE","ImpSoloTot","MinimoON","MinimoOFF","PaqueteMin","EAN13_14_3","TipoEan_3","Formato_EAN128_3","Formato_EAN_3","EAN13_14_4","TipoEan_4","Formato_EAN128_4","Formato_EAN_4","Texto12","Texto13","Texto14","Texto15","Texto16","Texto17","Texto18","Texto19","Texto20","PesoMinimo2CW","PorcenAceptacionCW","PesoEmbalaje","Precio2","CentradoDiscriminador1","CentradoDiscriminador2","CentradoDiscriminador3","CentradoCinta1","Espera","Texto21","Texto22","Texto23","Texto24","Texto25","Texto26","Texto27","Texto28","Texto29","Texto30"]
                for key in campos {
                    
                    let campo: [String: Any] = [
                        "id": index,
                        "id_master": self.headers.count,
                        "nome": key,
                        "descricao": key,
                        "tipo": 0,
                        "visible": false,
                        "def": "",
                        "max": 24,
                        "campos": []
                    ]
                    
                    self.clientRef.collection("fields").document(key).setData(campo)
                    index = index + 1
                }
            }
        }
        
    }
    
    func isFieldValid(document: [String : Any]) -> Bool {
        var existsArrayofFields = false
        var intCampos = 0
        
        for doc in document {
            switch doc.key {
                
            case "id":
                if doc.value as? Int == nil {
                    return false
                }
                intCampos += 1
            case "id_master":
                if doc.value as? Int == nil {
                    return false
                }
                
                if (doc.value as? Int)! >= headers.count {
                    return false
                }
                intCampos += 1
            case "nome":
                for h in headers {
                    if h.Fields.contains(where: {$0.nome == "\(doc.value)"})  {
                        return false
                    }
                }
                intCampos += 1
            case "descricao":
                if "\(doc.value)" == "" {
                    return false
                }
                intCampos += 1
            case "visible":
                if !(doc.value as! Bool) || (doc.value as! Bool) {
                    
                }else{
                    return false
                }
                intCampos += 1
            case "tipo":
                if doc.value as? Int == nil {
                    return false
                }
                if (doc.value as? Int)! == 4 {
                    existsArrayofFields = true
                }
                if (doc.value as? Int)! > 6 {
                    return false
                }
                intCampos += 1
            case "max":
                if doc.value as? Int == nil {
                    return false
                }
                intCampos += 1
            case "campos":
                existsArrayofFields = true
                intCampos += 1
            case "def":
                intCampos += 1
                
                
            default:
                return false
            }
            
        }
        if existsArrayofFields, intCampos == 9 {
            return true
        }else if !existsArrayofFields, intCampos == 8 {
            return true
        }else{
            return false
        }
        
    }
    
    func getIDbyNome(nome: String) -> IndexPath {
        var index = IndexPath()
        for h in self.headers.indices {
            for f in self.headers[h].Fields.indices {
                if self.headers[h].Fields[f].nome == nome {
                    index = IndexPath(row: f, section: h)
                }
            }
        }
        return index
    }
    
}


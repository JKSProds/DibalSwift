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
        clientRef.collection("articles").order(by: "codigo").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            querySnapshot?.documentChanges.forEach { diff in
                //print("\(diff.document.documentID) => \(diff.document.data())")
                if (diff.document.data()["codigo"]) != nil  {
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
                        
                        let indexPath = IndexPath(row: Int(diff.oldIndex), section: 0)
                        tableView.deleteRows(at: [indexPath], with: .bottom)
                    }
                }
            }
        }
    }
    
    func checkIfArticleExists(artigo: Artigo) -> Bool {
        for art in articles {
            if art.campos["codigo"] == artigo.campos["codigo"] {
                return true
            }
            
        }
        return false
    }
    
    
    func removeArticle(at index: Int) {
        
        var docID: String = ""
        clientRef.collection("articles").whereField("codigo", isEqualTo: articles[index].campos["codigo"]!)
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
            default:
                res = ""
            }
        }
        
        return res
    }
    
    
    func uploadArtigo(artigo: Artigo) {
        var docID: String = ""
        if (artigo.campos["codigo"] != nil) {
            clientRef.collection("articles").whereField("codigo", isEqualTo: artigo.campos["codigo"]!)
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
                        let id = self.headers[id_master].Fields.count
                        
                        var f = field(id_master: id_master, nome: "\(diff.document.data()["nome"]!)", descricao: "\(diff.document.data()["descricao"]!)", tipo: diff.document.data()["tipo"]! as! Int, visible: diff.document.data()["visible"]! as! Bool, def: "\(diff.document.data()["def"]!)", max: diff.document.data()["max"]! as! Int, campos: [])
                        
                        if f.tipo == 4 {
                            f.campos = diff.document.data()["campos"] as! [[String:Any]]
                        }
                        
                        if (diff.type == .added) {
                            self.headers[id_master].Fields.append(f)
                            let indexPath = IndexPath(row: id, section: id_master)
                            tableView.insertRows(at: [indexPath], with: .left)
                        }
                        if (diff.type == .modified) {
                            let index = self.getIDbyNome(nome: f.nome)
                            if index.count > 0, f.id_master != index.section {
self.headers[index.section].Fields.remove(at: index.row)
                                //tableView.deleteRows(at: [index], with: .bottom)
                                tableView.reloadData()
                                
                                if index.row >= self.headers[id_master].Fields.count {
                                    let indexPath = IndexPath(row: self.headers[id_master].Fields.count, section: id_master)
                                    self.headers[id_master].Fields.append(f)
                                    tableView.insertRows(at: [indexPath], with: .left)
                                }else{
                                    let indexPath = IndexPath(row: index.row, section: id_master)
                                    self.headers[id_master].Fields.insert(f, at: index.row)
                                    tableView.insertRows(at: [indexPath], with: .left)
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
                if (doc.value as? Int)! > 4 {
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


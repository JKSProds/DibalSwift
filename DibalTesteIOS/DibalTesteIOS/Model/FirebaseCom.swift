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
        clientRef.collection("fields").order(by: "id").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                querySnapshot?.documentChanges.forEach { diff in
                    if (diff.document.data()["id"]) != nil {
                        let id_master = diff.document.data()["id_master"]! as! Int
                        let id = self.headers[id_master].Fields.count
                        
                        let f = field(id_master: id_master, nome: "\(diff.document.data()["nome"]!)", descricao: "\(diff.document.data()["descricao"]!)", tipo: diff.document.data()["tipo"]! as! Int, visible: diff.document.data()["visible"]! as! Bool, def: "\(diff.document.data()["def"]!)")
                        
                        if (diff.type == .added) {
                            self.headers[id_master].Fields.append(f)
                            let indexPath = IndexPath(row: id, section: id_master)
                            tableView.insertRows(at: [indexPath], with: .left)
                        }
                        if (diff.type == .modified) {
                            let index = self.getIDbyNome(nome: f.nome)
                            if (f.id_master != index.section) {
                                
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
                            if  index.row >= 0{
                                self.headers[index.section].Fields.remove(at: index.row)
                                tableView.deleteRows(at: [index], with: .bottom)
                            }
                        }
                    }
                }
            }
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


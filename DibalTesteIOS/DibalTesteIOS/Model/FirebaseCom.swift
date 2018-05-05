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
    var headers = [ExpandableHeaders(isExpanded: true, Title: "Dados", Fields: []),
                   ExpandableHeaders(isExpanded: true, Title: "Textos", Fields: []),
                   ExpandableHeaders(isExpanded: true, Title: "Codigos de Barra", Fields: []),
                   ExpandableHeaders(isExpanded: true, Title: "Automatismos", Fields: []),
                   ExpandableHeaders(isExpanded: true, Title: "Outros", Fields: [])]
    var novoArtigo = false
    
    
    init(clientID: String) {
        FirebaseApp.configure()
        clientRef = Firestore.firestore().collection("dibal").document("\(clientID)")

    }
    
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
    
    func novoArtigo(campos: [String: Any]) {
        clientRef.collection("articles").addDocument(data: campos)
    }
    
    func removeArticle(at index: Int) {
        var docID: String = ""
        clientRef.collection("articles").whereField("codigo", isEqualTo: articles[index].campos["codigo"] as! String)
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
    
    func uploadArtigo(at Index: Int) {
        var docID: String = ""
        if Index >= 0, (articles[Index].campos["codigo"] != nil) {
            clientRef.collection("articles").whereField("codigo", isEqualTo: articles[Index].campos["codigo"] as! String)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            //print("\(document.documentID) => \(document.data())")
                            docID = "\(document.documentID)"
                            //print(self.codigo)
                            self.clientRef.collection("articles").document(docID).setData(self.articles[Index].campos)
                        }
                    }
                    if docID == "" {
                        self.clientRef.collection("articles").addDocument(data: self.articles[Index].campos)
                        self.articles.remove(at: Index)
                    }
            }
        }
    }
    
    
    func getAllFields(tableView: UITableView) {
        for index in 0...headers.count - 1 {
            headers[index].Fields.removeAll()
        }
        
        list = clientRef.collection("fields").order(by: "id").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            querySnapshot?.documentChanges.forEach { diff in
                //print("\(diff.document.documentID) => \(diff.document.data())")
                if (diff.document.data()["id"]) != nil {
                    
                    let f = field(id: diff.document.data()["id"]! as! Int, id_master: diff.document.data()["id_master"]! as! Int, nome: "\(diff.document.data()["nome"]!)", descricao: "\(diff.document.data()["descricao"]!)", tipo: diff.document.data()["tipo"]! as! Int, visible: diff.document.data()["visible"]! as! Bool, def: "\(diff.document.data()["def"]!)")
                    

                    if (diff.type == .added) {
                        //print(diff.newIndex)
                        
                        self.headers[f.id_master - 1].Fields.append(f)
                        let indexPath = IndexPath(row: Int(self.headers[f.id_master - 1].Fields.count - 1), section: f.id_master - 1)
                        tableView.insertRows(at: [indexPath], with: .left)
                    }
                    if (diff.type == .modified) {
                        self.headers[f.id_master - 1].Fields.append(f)
                        tableView.reloadData()
                    }
                    if (diff.type == .removed) {
                        self.headers[f.id_master - 1].Fields.remove(at: Int(diff.oldIndex))
                        let indexPath = IndexPath(row: Int(diff.oldIndex), section: f.id_master - 1)
                        tableView.deleteRows(at: [indexPath], with: .bottom)
                    }
                    
                }
            }
        }
    }
    
    
}

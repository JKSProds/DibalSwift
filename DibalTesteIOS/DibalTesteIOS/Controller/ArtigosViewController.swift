//
//  ViewController.swift
//  DibalTesteIOS
//
//  Created by Jorge Monteiro on 27/04/18.
//  Copyright © 2018 Jorge Monteiro. All rights reserved.
//

import UIKit

class ArtigosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lblHeader: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var NovoArtigoButton: UIButton!
    

    var Firebase = FirebaseCom(clientID: "20lcz9utjo0NKE84twgd")
    var Dibal = DibalCom()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       //loads name of client
        Firebase.getClientHeader(to: lblHeader)
        
        //load all articles
        Firebase.getAllArticles(tableView: tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let tempNavVC = self.tabBarController?.viewControllers?[1] as! ConfigViewController
        tempNavVC.Dibal = self.Dibal
        
        NovoArtigoButton.layer.cornerRadius = NovoArtigoButton.layer.frame.height / 2
    }
    
    @IBAction func clickAddArtigo(_ sender: Any) {
       Firebase.selectedArticle = -1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabBar: CustomTBViewController = segue.destination as! CustomTBViewController
        if Firebase.selectedArticle >= 0 {
            tabBar.Firebase = Firebase
        }
        
        let dadosVC: DetalheArtigoViewController = tabBar.viewControllers![0] as! DetalheArtigoViewController
        dadosVC.Firebase = Firebase
        dadosVC.id_master = 1
        
        let textosVC: DetalheArtigoViewController = tabBar.viewControllers![1] as! DetalheArtigoViewController
        textosVC.Firebase = Firebase
        textosVC.id_master = 2
        
        let codbarrasVC: DetalheArtigoViewController = tabBar.viewControllers![2] as! DetalheArtigoViewController
        codbarrasVC.Firebase = Firebase
        codbarrasVC.id_master = 3
        
        let automatismosVC: DetalheArtigoViewController = tabBar.viewControllers![3] as! DetalheArtigoViewController
        automatismosVC.Firebase = Firebase
        automatismosVC.id_master = 4
        
        let outrosVC: DetalheArtigoViewController = tabBar.viewControllers![4] as! DetalheArtigoViewController
        outrosVC.Firebase = Firebase
        outrosVC.id_master = 5
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Firebase.articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        
        cell.lblCodigo.text = "\(Firebase.articles[indexPath.row].campos["codigo"]!)"
      
        cell.lblDenominacao.text = Firebase.articles[indexPath.row].campos["nome"] as? String
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        Firebase.selectedArticle = indexPath.row
        
        performSegue(withIdentifier: "DetalheArtigoSege", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Apagar") { (action, view, nil) in
            self.Firebase.removeArticle(at: indexPath.row)
            tableView.setEditing(false, animated: true)
        }
        delete.image = #imageLiteral(resourceName: "delete")
        delete.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let start = UIContextualAction(style: .normal, title: "Iniciar") { (action, view, nil) in
           //print("Start")
            self.Dibal.startLabeling(article: self.Firebase.articles[indexPath.row])
            tableView.setEditing(false, animated: true)
        }
        start.image = #imageLiteral(resourceName: "play")
        return UISwipeActionsConfiguration(actions: [start])
    }
    
}


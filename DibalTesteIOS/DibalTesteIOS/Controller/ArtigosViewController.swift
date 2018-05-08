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
    static var UIColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
    
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
        
        //UI Changes
        NovoArtigoButton.layer.cornerRadius = NovoArtigoButton.layer.frame.height / 2
        NovoArtigoButton.backgroundColor = ArtigosViewController.UIColor
        
    
    }
    
    @IBAction func clickAddArtigo(_ sender: Any) {
       Firebase.selectedArticle = -1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextView: DetalheArtigoViewController = segue.destination as! DetalheArtigoViewController
        
            nextView.Firebase = Firebase

        
  
       
        
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
        cell.cellView.backgroundColor = ArtigosViewController.UIColor
        
        cell.lblCodigo.text = Firebase.articles[indexPath.row].campos["codigo"]!
        cell.lblDenominacao.text = Firebase.articles[indexPath.row].campos["nome"]!
        
      cell.lblPreco.text = Artigo.currencyConverter(string: Firebase.articles[indexPath.row].campos["preço"]!)
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        Firebase.selectedArticle = indexPath.row
        
        performSegue(withIdentifier: "DetalheArtigoSege", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Apagar") { (action, view, nil) in
            let alertController = UIAlertController(title: "Remover Artigo", message: "Tem a certeza que deseja remover este artigo?", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Sim", style: .destructive, handler: { alert -> Void in
                self.Firebase.removeArticle(at: indexPath.row)
            })
            let CancelOption = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            alertController.addAction(CancelOption)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
                            tableView.setEditing(false, animated: true)
          
        }
        delete.image = #imageLiteral(resourceName: "delete")
        delete.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let start = UIContextualAction(style: .normal, title: "Iniciar") { (action, view, nil) in
            let alertController = UIAlertController(title: "Iniciar Etiquetagem", message: "Tem a certeza que deseja iniciar a etiquetagem deste artigo?", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Sim", style: .default, handler: { alert -> Void in
                self.Dibal.startLabeling(article: self.Firebase.articles[indexPath.row]) })
            let CancelOption = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            alertController.addAction(CancelOption)
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            tableView.setEditing(false, animated: true)
            
        }
        
            tableView.setEditing(false, animated: true)
        start.image = #imageLiteral(resourceName: "play")
        start.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        return UISwipeActionsConfiguration(actions: [start])
    }
    
}


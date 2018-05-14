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
    private var splitViewDetailArticleViewController: DetalheArtigoViewController?{
        if let dvc = splitViewController?.viewControllers.last as? DetalheArtigoViewController {
            return dvc
            
        }else if let nvc = splitViewController?.viewControllers.last as? UINavigationController {
            return nvc.viewControllers.first as? DetalheArtigoViewController
    
        }
        return nil
        
    }
    private var lastSeguedToDetalhesViewController: DetalheArtigoViewController?
    
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
        tempNavVC.Firebase = self.Firebase
        
        //UI Changes
        NovoArtigoButton.layer.cornerRadius = NovoArtigoButton.layer.frame.height / 2
        //NovoArtigoButton.backgroundColor = ArtigosViewController.UIColor
        
        if let detail = splitViewDetailArticleViewController {
            
            detail.Firebase = self.Firebase
            
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetalheArtigoSegue" {
            if let destinationNavController: UINavigationController = segue.destination as? UINavigationController {
                let detail: DetalheArtigoViewController! = destinationNavController.topViewController as! DetalheArtigoViewController
                detail.Firebase = self.Firebase
                lastSeguedToDetalhesViewController  = detail
                
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Firebase.articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! ListaArtigosTableViewCell
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.cellView.backgroundColor = ArtigosViewController.UIColor
        
        cell.lblCodigo.text = Firebase.articles[indexPath.row].campos["Cod_Articulo"]!
        cell.lblDenominacao.text = Firebase.articles[indexPath.row].campos["Nombre"]!
        
        cell.lblPreco.text = Artigo.currencyConverter(string: Firebase.articles[indexPath.row].campos["Precio"]!)
        
        return cell
    }
    
    @IBAction func AddArticle(_ sender: UIButton) {
        
        if let dvc = splitViewDetailArticleViewController {
            if !dvc.savedArticle {
                let alertController = UIAlertController(title: "Guardar Artigo", message: "Deseja guardar as alterações efetuadas ao artigo?", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Sim", style: .default, handler: { alert -> Void in
                    dvc.saveArtigo(self)
                    self.Firebase.selectedArticle = -1
                    dvc.artigo = Artigo()
                    dvc.loadHeader()
                    dvc.tableView.reloadData()
                    dvc.ErrorMessages = []
                    
                })
                let CancelOption = UIAlertAction(title: "Não", style: .default, handler: { alert -> Void in
                    dvc.savedArticle = true
                    self.Firebase.selectedArticle = -1
                    dvc.artigo = Artigo()
                               dvc.loadHeader()
                    dvc.tableView.reloadData()
                    dvc.ErrorMessages = []
                })
                alertController.addAction(CancelOption)
                alertController.addAction(OKAction)
                
                if let popoverController = alertController.popoverPresentationController {
              
                    if Firebase.selectedArticle == -1 {
                              popoverController.sourceView = self.view
                        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                           popoverController.permittedArrowDirections = []
                    }else{
                         popoverController.sourceView = self.tableView
                        popoverController.sourceRect = self.tableView.rectForRow(at: IndexPath(row: self.Firebase.selectedArticle, section: 0))
                    }
                }
                
                self.present(alertController, animated: true, completion: nil)
            }else{
                self.Firebase.selectedArticle = -1
                dvc.artigo = Artigo()
                           dvc.loadHeader()
                dvc.tableView.reloadData()
                dvc.ErrorMessages = []
            }
            
        }else if let dvc = lastSeguedToDetalhesViewController{
            if !dvc.savedArticle {
                let alertController = UIAlertController(title: "Guardar Artigo", message: "Deseja guardar as alterações efetuadas ao artigo?", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Sim", style: .default, handler: { alert -> Void in
                    dvc.saveArtigo(self)
                    
                    self.Firebase.selectedArticle = -1
                    dvc.artigo = Artigo()
                    dvc.tableView.reloadData()
                               dvc.loadHeader()
                    dvc.ErrorMessages = []
                    self.navigationController?.pushViewController(dvc.navigationController!, animated: true)
                })
                let CancelOption = UIAlertAction(title: "Não", style: .default, handler: { alert -> Void in
                    dvc.savedArticle = true
                    self.Firebase.selectedArticle = -1
                    dvc.artigo = Artigo()
                    dvc.tableView.reloadData()
                               dvc.loadHeader()
                    dvc.ErrorMessages = []
                    self.navigationController?.pushViewController(dvc, animated: true)
                })
                alertController.addAction(CancelOption)
                alertController.addAction(OKAction)
                
                
                if let popoverController = alertController.popoverPresentationController {
                    
                    if Firebase.selectedArticle == -1 {
                        popoverController.sourceView = self.view
                        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                          popoverController.permittedArrowDirections = []
                    }else{
                        popoverController.sourceView = self.tableView
                        popoverController.sourceRect = self.tableView.rectForRow(at: IndexPath(row: self.Firebase.selectedArticle, section: 0))
                    }
                }
                
                
                self.present(alertController, animated: true, completion: nil)
            }else{
                self.Firebase.selectedArticle = -1
                dvc.artigo = Artigo()
                dvc.tableView.reloadData()
                           dvc.loadHeader()
                dvc.ErrorMessages = []
                navigationController?.pushViewController(dvc.navigationController!, animated: true)
            }
        }else{
            self.performSegue(withIdentifier: "DetalheArtigoSegue", sender: self)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        if let dvc = splitViewDetailArticleViewController {
            if indexPath.row != Firebase.selectedArticle {
                if !dvc.savedArticle {
                    let alertController = UIAlertController(title: "Guardar Artigo", message: "Deseja guardar as alterações efetuadas ao artigo?", preferredStyle: .actionSheet)
                    let OKAction = UIAlertAction(title: "Sim", style: .default, handler: { alert -> Void in
                        dvc.saveArtigo(self)
                        self.Firebase.selectedArticle = indexPath.row
                        dvc.artigo = self.Firebase.articles[self.Firebase.selectedArticle]
                        dvc.tableView.reloadData()
                                   dvc.loadHeader()
                        dvc.ErrorMessages = []
                        
                    })
                    let CancelOption = UIAlertAction(title: "Não", style: .default, handler: { alert -> Void in
                        dvc.savedArticle = true
                        self.Firebase.selectedArticle = indexPath.row
                        dvc.artigo = self.Firebase.articles[self.Firebase.selectedArticle]
                        dvc.tableView.reloadData()
                                   dvc.loadHeader()
                        dvc.ErrorMessages = []
                    })
                    alertController.addAction(CancelOption)
                    alertController.addAction(OKAction)
                    
                    if let popoverController = alertController.popoverPresentationController {
                        
                        if Firebase.selectedArticle == -1 {
                            popoverController.sourceView = self.view
                            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                             popoverController.permittedArrowDirections = []
                        }else{
                            popoverController.sourceView = self.tableView
                            popoverController.sourceRect = self.tableView.rectForRow(at: IndexPath(row: self.Firebase.selectedArticle, section: 0))
                        }
                    }
                    
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    self.Firebase.selectedArticle = indexPath.row
                    dvc.artigo = self.Firebase.articles[self.Firebase.selectedArticle]
                    dvc.tableView.reloadData()
                               dvc.loadHeader()
                    dvc.ErrorMessages = []
                }
            }
        }else if let dvc = lastSeguedToDetalhesViewController{
            if !dvc.savedArticle {
                let alertController = UIAlertController(title: "Guardar Artigo", message: "Deseja guardar as alterações efetuadas ao artigo?", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Sim", style: .default, handler: { alert -> Void in
                    dvc.saveArtigo(self)
                    
                    self.Firebase.selectedArticle = indexPath.row
                    dvc.artigo = self.Firebase.articles[self.Firebase.selectedArticle]
                    dvc.tableView.reloadData()
                               dvc.loadHeader()
                    dvc.ErrorMessages = []
                    self.navigationController?.pushViewController(dvc, animated: true)
                })
                let CancelOption = UIAlertAction(title: "Não", style: .default, handler: { alert -> Void in
                    dvc.savedArticle = true
                    self.Firebase.selectedArticle = indexPath.row
                    dvc.artigo = self.Firebase.articles[self.Firebase.selectedArticle]
                    dvc.tableView.reloadData()
                               dvc.loadHeader()
                    dvc.ErrorMessages = []
                    self.navigationController?.pushViewController(dvc.navigationController!, animated: true)
                })
                alertController.addAction(CancelOption)
                alertController.addAction(OKAction)
                
                
                if let popoverController = alertController.popoverPresentationController {
                    
                    if Firebase.selectedArticle == -1 {
                        popoverController.sourceView = self.view
                        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                               popoverController.permittedArrowDirections = []
                    }else{
                        popoverController.sourceView = self.tableView
                        popoverController.sourceRect = self.tableView.rectForRow(at: IndexPath(row: self.Firebase.selectedArticle, section: 0))
                    }
                }
                
                self.present(alertController, animated: true, completion: nil)
            }else{
                self.Firebase.selectedArticle = indexPath.row
                dvc.artigo = self.Firebase.articles[self.Firebase.selectedArticle]
                dvc.tableView.reloadData()
                           dvc.loadHeader()
                dvc.ErrorMessages = []
                self.navigationController?.pushViewController(dvc.navigationController!, animated: true)
            }
        }else{
            Firebase.selectedArticle = indexPath.row
            self.performSegue(withIdentifier: "DetalheArtigoSegue", sender: self)
        }
        
    }
    
    func saveArticle() {
        if let dvc = lastSeguedToDetalhesViewController  {
            if !dvc.savedArticle {
                let alertController = UIAlertController(title: "Guardar Artigo", message: "Deseja guardar as alterações efetuadas ao artigo?", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Sim", style: .default, handler: { alert -> Void in
                    dvc.saveArtigo(self)
                    
                })
                let CancelOption = UIAlertAction(title: "Não", style: .default, handler: { alert -> Void in
                    dvc.savedArticle = true
                    
                })
                alertController.addAction(CancelOption)
                alertController.addAction(OKAction)
                
                
                if let popoverController = alertController.popoverPresentationController {
                    
                    if Firebase.selectedArticle == -1 {
                        popoverController.sourceView = self.view
                        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                        popoverController.permittedArrowDirections = []
                    }else{
                        popoverController.sourceView = self.tableView
                        popoverController.sourceRect = self.tableView.rectForRow(at: IndexPath(row: self.Firebase.selectedArticle, section: 0))
                    }
                }
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Apagar") { (action, view, nil) in
            let alertController = UIAlertController(title: "Remover Artigo", message: "Tem a certeza que deseja remover este artigo?", preferredStyle: .actionSheet)
            let OKAction = UIAlertAction(title: "Sim", style: .destructive, handler: { alert -> Void in
                
                if let dvc = self.splitViewDetailArticleViewController {
                    
                    self.Firebase.selectedArticle = -1
                    dvc.artigo = Artigo()
                    
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = NSIndexSet(indexesIn: range)
                    dvc.tableView.reloadSections(sections as IndexSet, with: .automatic)
                               dvc.loadHeader()
                }else if let dvc = self.lastSeguedToDetalhesViewController {
                    self.Firebase.selectedArticle = -1
                    dvc.artigo = Artigo()
                    
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = NSIndexSet(indexesIn: range)
                    dvc.tableView.reloadSections(sections as IndexSet, with: .automatic)
                               dvc.loadHeader()
                }
                self.Firebase.removeArticle(at: indexPath.row)
            })
            let CancelOption = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            alertController.addAction(CancelOption)
            alertController.addAction(OKAction)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.tableView
                popoverController.sourceRect = self.tableView.rectForRow(at: indexPath)
            }
            
            self.present(alertController, animated: true, completion: nil)
            tableView.setEditing(false, animated: true)
            
        }
        delete.image = #imageLiteral(resourceName: "delete")
        delete.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let start = UIContextualAction(style: .normal, title: "Iniciar") { (action, view, nil) in
            let alertController = UIAlertController(title: "Iniciar Etiquetagem", message: "Tem a certeza que deseja iniciar a etiquetagem deste artigo?", preferredStyle: .actionSheet)
            let OKAction = UIAlertAction(title: "Sim", style: .default, handler: { alert -> Void in
                self.Dibal.startLabeling(article: self.Firebase.articles[indexPath.row]) })
            let CancelOption = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            alertController.addAction(CancelOption)
            alertController.addAction(OKAction)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.tableView
                popoverController.sourceRect = self.tableView.rectForRow(at: indexPath)
            }
            
            self.present(alertController, animated: true, completion: nil)
            tableView.setEditing(false, animated: true)
            
        }

        start.image = #imageLiteral(resourceName: "play")
        start.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        
        let send = UIContextualAction(style: .normal, title: "Enviar") { (action, view, nil) in
            let alertController = UIAlertController(title: "Enviar Artigo", message: "Tem a certeza que deseja enviar este artigo?", preferredStyle: .actionSheet)
            let OKAction = UIAlertAction(title: "Sim", style: .default, handler: { alert -> Void in
                self.Dibal.sendArticle(article: self.Firebase.articles[indexPath.row]) })
            let CancelOption = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            alertController.addAction(CancelOption)
            alertController.addAction(OKAction)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.tableView
                popoverController.sourceRect = self.tableView.rectForRow(at: indexPath)
            }
            
            self.present(alertController, animated: true, completion: nil)
            tableView.setEditing(false, animated: true)
            
        }
        
        send.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        tableView.setEditing(false, animated: true)
        
        return UISwipeActionsConfiguration(actions: [start, send])
    }
    
}






























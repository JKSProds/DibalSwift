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
    @IBOutlet weak var lblBottomNotification: UILabel!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredArticles = [Artigo]()
    
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
        lblBottomNotification.layer.masksToBounds = true
        lblBottomNotification.layer.cornerRadius = lblBottomNotification.layer.frame.height / 2
        //NovoArtigoButton.backgroundColor = ArtigosViewController.UIColor
        
        if let detail = splitViewDetailArticleViewController {
            
            detail.Firebase = self.Firebase
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        setupSearchBar()
        
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height - 20
        // controlBottomConstraint outlet to the control you want to move up
        bottomConstraint.constant = keyboardHeight
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
     bottomConstraint.constant = 16
    }
    func setupSearchBar() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Pesquisa"
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                backgroundview.layer.cornerRadius = 10
                backgroundview.clipsToBounds = true
            }
        }
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["Código", "Nome", "Preço"]
        
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
        if isFiltering() {
            setIsFilteringToShow(filteredItemCount: filteredArticles.count, of: Firebase.articles.count)
            return filteredArticles.count
        }
        setNotFiltering()
        return Firebase.articles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! ListaArtigosTableViewCell
        var artigo = Artigo()
        
        if isFiltering() {
            artigo = filteredArticles[indexPath.row]
        } else {
            artigo = Firebase.articles[indexPath.row]
        }
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.cellView.backgroundColor = ArtigosViewController.UIColor
        
        cell.lblCodigo.text = artigo.campos["Cod_Articulo"]!
        cell.lblDenominacao.text = artigo.campos["Nombre"]!
        
        cell.lblPreco.text = Artigo.currencyConverter(string: artigo.campos["Precio"]!)
        
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
            
            if !dvc.savedArticle {
                let alertController = UIAlertController(title: "Guardar Artigo", message: "Deseja guardar as alterações efetuadas ao artigo?", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Sim", style: .default, handler: { alert -> Void in
                    dvc.saveArtigo(self)
                    if self.isFiltering() {
                        self.Firebase.selectedArticle = self.getIndexByCodigo(codigo: self.filteredArticles[indexPath.row].campos["Cod_Articulo"]!)
                    } else {
                        self.Firebase.selectedArticle = indexPath.row
                    }
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
                if self.isFiltering() {
                    self.Firebase.selectedArticle = self.getIndexByCodigo(codigo: self.filteredArticles[indexPath.row].campos["Cod_Articulo"]!)
                } else {
                    self.Firebase.selectedArticle = indexPath.row
                }
                
                dvc.artigo = self.Firebase.articles[self.Firebase.selectedArticle]
                dvc.tableView.reloadData()
                dvc.loadHeader()
                dvc.ErrorMessages = []
            }
        }else if let dvc = lastSeguedToDetalhesViewController{
            if !dvc.savedArticle {
                let alertController = UIAlertController(title: "Guardar Artigo", message: "Deseja guardar as alterações efetuadas ao artigo?", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "Sim", style: .default, handler: { alert -> Void in
                    dvc.saveArtigo(self)
                    
                    if self.isFiltering() {
                        self.Firebase.selectedArticle = self.getIndexByCodigo(codigo: self.filteredArticles[indexPath.row].campos["Cod_Articulo"]!)
                    } else {
                        self.Firebase.selectedArticle = indexPath.row
                    }
                    
                    dvc.artigo = self.Firebase.articles[self.Firebase.selectedArticle]
                    dvc.tableView.reloadData()
                    dvc.loadHeader()
                    dvc.ErrorMessages = []
                    self.navigationController?.pushViewController(dvc, animated: true)
                })
                let CancelOption = UIAlertAction(title: "Não", style: .default, handler: { alert -> Void in
                    dvc.savedArticle = true
                    if self.isFiltering() {
                        self.Firebase.selectedArticle = self.getIndexByCodigo(codigo: self.filteredArticles[indexPath.row].campos["Cod_Articulo"]!)
                    } else {
                        self.Firebase.selectedArticle = indexPath.row
                    }
                    
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
                if self.isFiltering() {
                    self.Firebase.selectedArticle = self.getIndexByCodigo(codigo: self.filteredArticles[indexPath.row].campos["Cod_Articulo"]!)
                } else {
                    self.Firebase.selectedArticle = indexPath.row
                }
                
                dvc.artigo = self.Firebase.articles[self.Firebase.selectedArticle]
                dvc.tableView.reloadData()
                dvc.loadHeader()
                dvc.ErrorMessages = []
                self.navigationController?.pushViewController(dvc.navigationController!, animated: true)
            }
        }else{
            if self.isFiltering() {
                self.Firebase.selectedArticle = self.getIndexByCodigo(codigo: self.filteredArticles[indexPath.row].campos["Cod_Articulo"]!)
            } else {
                self.Firebase.selectedArticle = indexPath.row
            }
            
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
                var index = -1
                if self.isFiltering() {
                    index = self.getIndexByCodigo(codigo: self.filteredArticles[indexPath.row].campos["Cod_Articulo"]!)
                    self.filteredArticles.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .bottom)
                    
                } else {
                   index = indexPath.row
                }
                self.Firebase.removeArticle(at: index)
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
                
                var index = -1
                if self.isFiltering() {
                    index = self.getIndexByCodigo(codigo: self.filteredArticles[indexPath.row].campos["Cod_Articulo"]!)
                } else {
                    index = indexPath.row
                }
                
                if self.Dibal.startLabeling(article: self.Firebase.articles[index]){
                     self.lblBottomNotification.text = "Artigo enviado com sucesso"
                }else{
                     self.lblBottomNotification.text = "Ocorreu um erro ao enviar!"
                }
                self.lblBottomNotification.fadeInAndOut()
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
        
        start.image = #imageLiteral(resourceName: "play")
        start.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        
        let send = UIContextualAction(style: .normal, title: "Enviar") { (action, view, nil) in
            let alertController = UIAlertController(title: "Enviar Artigo", message: "Tem a certeza que deseja enviar este artigo?", preferredStyle: .actionSheet)
            let OKAction = UIAlertAction(title: "Sim", style: .default, handler: { alert -> Void in
                var index = -1
                if self.isFiltering() {
                    index = self.getIndexByCodigo(codigo: self.filteredArticles[indexPath.row].campos["Cod_Articulo"]!)
                } else {
                    index = indexPath.row
                }
                if self.Dibal.sendArticle(article: self.Firebase.articles[index]) {
                    self.lblBottomNotification.text = "Artigo enviado com sucesso"
                }else{
                     self.lblBottomNotification.text = "Ocorreu um erro ao enviar!"
                }
                self.lblBottomNotification.fadeInAndOut()
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
        
        send.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        tableView.setEditing(false, animated: true)
        
        return UISwipeActionsConfiguration(actions: [start, send])
    }
    
}

extension ArtigosViewController: UISearchResultsUpdating, UISearchBarDelegate {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if scope == "Código" {
            filteredArticles = Firebase.articles.filter({( article : Artigo) -> Bool in
                return (article.campos["Cod_Articulo"]?.lowercased().contains(searchText.lowercased()))!
            })
        }else if scope == "Nome" {
            filteredArticles = Firebase.articles.filter({( article : Artigo) -> Bool in
                return (article.campos["Nombre"]?.lowercased().contains(searchText.lowercased()))!
            })
        }else if scope == "Preço" {
            filteredArticles = Firebase.articles.filter({( article : Artigo) -> Bool in
                return (article.campos["Precio"]?.lowercased().contains(searchText.lowercased()))!
            })
        }
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func getIndexByCodigo (codigo: String) -> Int {
        
        if let index = Firebase.articles.index(where: {$0.campos["Cod_Articulo"] == codigo}) {
            return index
        }
        
        return -1
    }
    
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func setIsFilteringToShow(filteredItemCount: Int, of: Int) {
        lblBottomNotification.fadeIn(duration: 0.35, delay: 0, completion:{_ in })
        if filteredItemCount > 0 {
            lblBottomNotification.text = "A Filtrar \(filteredItemCount) de \(of)"
        }else{
            lblBottomNotification.text = "Nenhum artigo encontrado!"
        }
    }
    
    func setNotFiltering() {
        lblBottomNotification.fadeOut(duration: 0.35, delay: 0, completion: {_ in})
    }
}


extension UIView {
    
    func fadeInAndOut() {
        fadeIn()
        fadeOut()
    }
    
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 3.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}





























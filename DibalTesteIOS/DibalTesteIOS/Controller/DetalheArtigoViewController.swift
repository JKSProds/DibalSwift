//
//  NovoArtigoViewController.swift
//  DibalTesteIOS
//
//  Created by Jorge Monteiro on 29/04/18.
//  Copyright © 2018 Jorge Monteiro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import SkyFloatingLabelTextField

class DetalheArtigoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var Firebase: FirebaseCom!
    var artigo = Artigo()
    var ErrorMessages = [(id: String, message: String, texto: String)]()
    var savedArticle = true {didSet {
        navigationItem.rightBarButtonItem?.isEnabled = !savedArticle
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Firebase.list == nil {
            Firebase.getAllFields(tableView: self.tableView)
        }
        loadHeader()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Guardar", style: .done, target: self, action: #selector(saveArtigo))
        savedArticle = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    func loadHeader() {
        if Firebase != nil {
            if Firebase.selectedArticle >= 0  {
                artigo = Firebase.articles[Firebase.selectedArticle]
            }
            if Firebase.selectedArticle >= 0 {
                if artigo.campos["Nombre"] == "" {
                    navigationItem.title = "Artigo"
                }else{
                    navigationItem.title = artigo.campos["Nombre"]
                }
            }else{
                navigationItem.title = "Novo Artigo"
            }
        }
        savedArticle = true
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyboard()
        if let nvc = self.splitViewController?.viewControllers.first as? UINavigationController, let mvc = nvc.viewControllers.first as? ArtigosViewController {
            mvc.saveArticle()
        }
    }
    
    // MARK: Keyboard Handling
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            tableView.contentInset = UIEdgeInsets.zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        tableView.scrollIndicatorInsets = tableView.contentInset
        
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        dismissKeyboard()
        
        
        return true
    }
    
    // MARK: Handle Navigation Bar Buttons
    
    
    @objc func saveArtigo(_ sender: Any) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        let codigoArtInt = Int(artigo.campos["Cod_Articulo"]!)
        if codigoArtInt != nil, codigoArtInt! > 0, codigoArtInt! < 1000000 {
            artigo.campos["Cod_Articulo"] = "\(codigoArtInt!)"
            if Firebase.selectedArticle == -1, Firebase.checkIfArticleExists(artigo: artigo) {
                let alertController = UIAlertController(title: "Erro", message: "Esse artigo já existe! Não pode sobrepor artigos", preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(OKAction)
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                    
                }
                self.present(alertController, animated: true, completion: nil)
            }else if ErrorMessages.count > 0{
                let alertController = UIAlertController(title: "Erro", message: ErrorMessages.first?.message, preferredStyle: .actionSheet)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(OKAction)
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                    
                }
                self.present(alertController, animated: true, completion: nil)
            }else{
                
                Firebase.uploadArtigo(artigo: artigo)
                //Firebase.list.remove()
                savedArticle = true
                
            }
        }else{
            let alertController = UIAlertController(title: "Erro", message: "O codigo do Artigo está incorreto. Por favor corriga o codigo e tente novamente!", preferredStyle: .actionSheet)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    // MARK: Handle TextField Events
    
    @objc func textChanges(sender:SkyFloatingLabelTextField! ) {
        let index = Firebase.getIDbyNome(nome: sender.accessibilityIdentifier!)
        let campoAtual = Firebase.headers[index.section].Fields[index.row]
        
        if campoAtual.tipo == 1 || campoAtual.tipo == 2 {
            sender.text = sender.text?.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
        }
        
        let mensagem = Firebase.checkArticleField(at: campoAtual, string: sender.text!)
        
        if  mensagem == "" {
            sender.text = Firebase.formatArticleField(at: campoAtual, string: sender.text!)
            if artigo.campos[sender.accessibilityIdentifier!] != sender.text {
                savedArticle = false
            }
            artigo.campos[sender.accessibilityIdentifier!] = sender.text
            if campoAtual.tipo == 6 {
                sender.text = Artigo.dateConverterVisualy(string: sender.text!)
            }
            sender.errorMessage = mensagem
            let indexErro = ErrorMessages.index(where: {($0.id == sender.accessibilityIdentifier)})
            if indexErro != nil {
                ErrorMessages.remove(at: indexErro!)
            }
            sender.title = campoAtual.descricao
        }else{
            sender.errorMessage = "\(campoAtual.descricao) (\(mensagem))"
            if let indexErro = ErrorMessages.index(where: {($0.id == sender.accessibilityIdentifier)}) {
                ErrorMessages[indexErro] = ((id: sender.accessibilityIdentifier!, message: "\(campoAtual.descricao) (\(mensagem))", texto: sender.text!))
            }else{
                ErrorMessages.append((id: sender.accessibilityIdentifier!, message: "\(campoAtual.descricao) (\(mensagem))", texto: sender.text!))
            }
            
        }
        if sender.accessibilityIdentifier! == "Nombre" {
            if artigo.campos["Nombre"] != "" {
                navigationItem.title = artigo.campos["Nombre"]
            }else if Firebase.selectedArticle >= 0{
                navigationItem.title = "Artigo"
            }else if  artigo.campos["Nombre"] == ""{
                navigationItem.title = "Novo Artigo"
            }
        }
        
    }
    
    @objc func deleteArticle(button: UIButton) {
        let alertController = UIAlertController(title: "Remover Artigo", message: "Tem a certeza que deseja remover este artigo?", preferredStyle: .actionSheet)
        let OKAction = UIAlertAction(title: "Sim", style: .destructive, handler: { alert -> Void in
            self.Firebase.removeArticle(at: self.Firebase.selectedArticle)
            
            self.Firebase.selectedArticle = -1
            self.artigo = Artigo()
            
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.tableView.reloadSections(sections as IndexSet, with: .automatic)
            
            //self.navigationController?.popToRootViewController(animated: true)
        })
        let CancelOption = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        alertController.addAction(CancelOption)
        alertController.addAction(OKAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func copyArticle(button: UIButton) {        
        let alertController = UIAlertController(title: "Copiar Artigo", message: "Por favor insira o codigo para onde deseja copiar o artigo!", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        alertController.addAction(OKAction)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            alert -> Void in
            let codigoArtigo = alertController.textFields![0] as UITextField
            let codigoArtInt = Int(codigoArtigo.text!)
            if codigoArtInt != nil, codigoArtInt! > 0, codigoArtInt! < 1000000   {
                self.artigo.campos["Cod_Articulo"] = codigoArtigo.text
                self.Firebase.selectedArticle = -1
                self.saveArtigo(self)
                self.artigo = Artigo()
                self.tableView.reloadData()
                //self.navigationController?.popToRootViewController(animated: true)
            } else {
                let errorAlert = UIAlertController(title: "Erro", message: "Por favor insira um valor válido!", preferredStyle: .actionSheet)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
                
                if let popoverController = errorAlert.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                    
                }
                
                self.present(errorAlert, animated: true, completion: nil)
            }
            
        }))
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Codigo do Artigo"
            textField.textAlignment = .center
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Implementing a method on the UITextFieldDelegate protocol. This will notify us when something has changed on the textfield
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //        if let text = textField.text {
    //            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
    //
    //                if(text.count < 3 || !text.contains("@")) {
    //                    floatingLabelTextField.errorMessage = "Invalid email"
    //                }
    //                else {
    //                    // The error message will only disappear when we reset it to nil or empty string
    //                    floatingLabelTextField.errorMessage = ""
    //                }
    //            }
    //        }
    //        return true
    //    }
    
    // MARK: Handle Table View Creation and Editing
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fieldsCell")! as! DetalhesArtigosTableViewCell
        
        if Firebase.headers[indexPath.section].Fields[indexPath.row].visible {
            
            cell.removeAllSubViewOfType(type: SkyFloatingLabelTextField.self)
            cell.removeAllSubViewOfType(type: UIPickerView.self)
            cell.removeAllSubViewOfType(type: UIButton.self)
            cell.removeAllSubViewOfType(type: UILabel.self)
            cell.removeAllSubViewOfType(type: UIView.self)
            
            let section = indexPath.section
            let row = indexPath.row
            let field = Firebase.headers[section].Fields[row]
            
            cell.placeHolderLabel = field.descricao
            cell.titleLabel = field.descricao
            cell.fieldNome = field.nome
            
            if Firebase.selectedArticle >= 0, artigo.campos[field.nome] != nil, artigo.campos[field.nome] != "" {
                if field.tipo == 6 {
                    cell.fieldText = Artigo.dateConverterVisualy(string: "\(artigo.campos[field.nome]!)")!
                }else{
                    cell.fieldText = "\(artigo.campos[field.nome]!)"
                }
            }else{
                cell.fieldText = field.def
            }
            
            
            //ErrorMessages.index(where: {($0.id == sender.accessibilityIdentifier)})!)
            let indexError = ErrorMessages.index(where: {($0.id == field.nome)})
            if  indexError != nil {
                cell.errorMensagem = ErrorMessages[indexError!].message
                cell.fieldText = ErrorMessages[indexError!].texto
            }else{
                cell.errorMensagem = ""
            }
            
            
            
            if field.tipo != 4 {
                
                cell.textFieldView.delegate = self
                cell.textFieldView.addTarget(self,
                                             action: #selector(textChanges),
                                             for: UIControlEvents.editingDidEnd
                )
                
                if field.nome == "Cod_Articulo", Firebase.selectedArticle != -1 {
                    cell.deleteButton.addTarget(self, action: #selector(deleteArticle), for: .touchUpInside)
                    cell.copyButton.addTarget(self, action: #selector(copyArticle), for: .touchUpInside)
                    
                    cell.addTextFieldAndButton()
                }else{
                    cell.addOnlyTextField()
                }
            }else{
                cell.pickerView.viewControllerMaster = self
                cell.pickerView.pickerData = field.campos
                cell.pickerView.reloadAllComponents()
                
                let index = field.campos.index(where: {$0["valor"] as? String == artigo.campos[field.nome]})
                if index != nil {
                    cell.pickerView.selectRow(index!, inComponent: 0, animated: true)
                }else if cell.pickerView.pickerData.count > 0 {
                    cell.pickerView.selectRow(0, inComponent: 0, animated: true)
                }
                
                cell.addPickerView()
            }
            
        }
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if Firebase.headers[section].isExpanded {
            return Firebase.headers[section].Fields.count
        }
        
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: Loads Section Headers
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        var fontBold = UIFont.boldSystemFont(ofSize: 20)
        fontBold = UIFontMetrics(forTextStyle: .body).scaledFont(for: fontBold)
        var fontBody = UIFont.preferredFont(forTextStyle: .body).withSize(14)
        fontBody = UIFontMetrics(forTextStyle: .body).scaledFont(for: fontBody)
        
        //view.backgroundColor = #colorLiteral(red: 1, green: 0.6031938878, blue: 0.08309882165, alpha: 1)
        view.backgroundColor = ArtigosViewController.UIColor
        
        let image = UIImageView()
        image.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        image.image = UIImage(named: Firebase.headers[section].Image)
        
        view.addSubview(image)
        
        let label = UILabel()
        label.text = Firebase.headers[section].Title
        label.textColor = UIColor.white
        label.font = fontBold
        label.frame = CGRect(x: 40, y: 5, width: self.view.frame.width, height: 30)
        
        view.addSubview(label)
        
        let button = UIButton(type: .system)
        
        button.tag = section
        button.contentHorizontalAlignment = .right
        
        if Firebase.headers[section].isExpanded {
            
            button.setTitle("Fechar", for: .normal)
        }else{
            
            button.setTitle("Abrir", for: .normal)
        }
        
        
        
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = fontBody
        //button.frame = CGRect(x: self.view.frame.width - 65 , y: 5, width: 60, height: 30)
        button.addTarget(self, action: #selector(expandButton), for: .touchUpInside)
        
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  Firebase.headers.count
    }
    
    // MARK: Handle Section Button
    
    @objc func expandButton(button: UIButton) {
        var indexPaths = [IndexPath]()
        let section = button.tag
        
        let isExpanded =  Firebase.headers[section].isExpanded
        Firebase.headers[section].isExpanded = !isExpanded
        
        for row in Firebase.headers[section].Fields.indices {
            
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
            
        }
        
        if !isExpanded {
            tableView.insertRows(at: indexPaths, with: .fade)
            button.setTitle("Fechar", for: .normal)
        }else{
            tableView.deleteRows(at: indexPaths, with: .fade)
            button.setTitle("Abrir", for: .normal)
        }
        //print("\(button.tag) clicked")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if !Firebase.headers[indexPath.section].Fields[indexPath.row].visible {
            return 0
        }
        
        if Firebase.headers[indexPath.section].Fields[indexPath.row].tipo == 4 {
            return 95
        }
        return 50
    }
    
}
extension UIView {
    
    func removeAllSubViewOfType<T: UIView>(type: T.Type) {
        self.subviews.forEach {
            if ($0 is T) {
                $0.removeFromSuperview()
            }
        }
    }
    
}


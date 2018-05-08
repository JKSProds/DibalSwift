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
    var ErrorMessage = String()
    
    @IBOutlet weak var txtHeader: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Firebase.selectedArticle >= 0  {
            artigo = Firebase.articles[Firebase.selectedArticle]
        }
        if Firebase.selectedArticle >= 0 {
            if artigo.campos["Nombre"] == "" {
                txtHeader.title = "Artigo"
            }else{
                txtHeader.title = artigo.campos["nome"]
            }
        }else{
            txtHeader.title = "Novo Artigo"
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        Firebase.getAllFields(tableView: tableView)
        Firebase.setAllExpanded()
        
        
        
    }
    
    // MARK: Keyboar Handling
    
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
    
    @IBAction func cancelNovoArtigo(_ sender: Any) {
        Firebase.list.remove()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveArtigo(_ sender: Any) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        let codigoArtInt = Int(artigo.campos["Cod_Articulo"]!)
        if codigoArtInt != nil, codigoArtInt! > 0, codigoArtInt! < 1000000 {
            artigo.campos["Cod_Articulo"] = "\(codigoArtInt!)"
            if Firebase.selectedArticle == -1, Firebase.checkIfArticleExists(artigo: artigo) {
                let alertController = UIAlertController(title: "Erro", message: "Esse artigo já existe! Não pode sobrepor artigos", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            }else if ErrorMessage != ""{
                let alertController = UIAlertController(title: "Erro", message: ErrorMessage, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            }else{
                
                Firebase.uploadArtigo(artigo: artigo)
                Firebase.list.remove()
                dismiss(animated: true, completion: nil)
            }
        }else{
            let alertController = UIAlertController(title: "Erro", message: "O codigo do Artigo está incorreto. Por favor corriga o codigo e tente novamente!", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
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
            artigo.campos[sender.accessibilityIdentifier!] = sender.text
            sender.errorMessage = mensagem
            ErrorMessage = mensagem
            sender.title = campoAtual.descricao
        }else{
            sender.errorMessage = "\(campoAtual.descricao) (\(mensagem))"
            ErrorMessage = "\(campoAtual.descricao) (\(mensagem))"
        }
        if sender.accessibilityIdentifier! == "Nombre" {
            if artigo.campos["Nombre"] != "" {
                txtHeader.title = artigo.campos["Nombre"]
            }else if Firebase.selectedArticle >= 0{
                txtHeader.title = "Artigo"
            }else if  artigo.campos["Nombre"] == ""{
                txtHeader.title = "Novo Artigo"
            }
        }
    }
    
    @objc func deleteArticle(button: UIButton) {
        let alertController = UIAlertController(title: "Remover Artigo", message: "Tem a certeza que deseja remover este artigo?", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Sim", style: .destructive, handler: { alert -> Void in
            self.Firebase.removeArticle(at: self.Firebase.selectedArticle)
            self.dismiss(animated: true, completion: nil)
        })
        let CancelOption = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        alertController.addAction(CancelOption)
        alertController.addAction(OKAction)
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
            } else {
                let errorAlert = UIAlertController(title: "Erro", message: "Por favor insira um valor válido!", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                    alert -> Void in
                    self.present(alertController, animated: true, completion: nil)
                }))
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
        
        if Firebase.selectedArticle >= 0, artigo.campos[field.nome] != nil {
            cell.fieldText = "\(artigo.campos[field.nome]!)"
        }else{
            cell.fieldText = field.def
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
            cell.pickerView.pickerData = field.campos
            
            let index = field.campos.index(where: {$0["valor"] as? String == artigo.campos[field.nome]})
            if index != nil, cell.pickerView.pickerData.count > 0 {
                cell.pickerView.selectRow(index!, inComponent: 0, animated: true)
            }
            
            cell.addPickerView()
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Firebase.headers[section].isExpanded, Firebase.headers[section].Fields.count > 0 {
            return Firebase.headers[section].Fields.filter({ $0.visible }).count
        }

        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: Loads Section Headers
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        //view.backgroundColor = #colorLiteral(red: 1, green: 0.6031938878, blue: 0.08309882165, alpha: 1)
        view.backgroundColor = ArtigosViewController.UIColor
        
        let image = UIImageView()
        image.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        image.image = UIImage(named: Firebase.headers[section].Image)
        
        view.addSubview(image)
        
        let label = UILabel()
        label.text = Firebase.headers[section].Title
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 20)
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
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
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
        return Firebase.headers.count
    }
    
    // MARK: Handle Section Button
    
    @objc func expandButton(button: UIButton) {
        var indexPaths = [IndexPath]()
        let section = button.tag
        for row in Firebase.headers[section].Fields.indices {
            if Firebase.headers[section].Fields[row].visible {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
            }
        }
        let isExpanded =  Firebase.headers[section].isExpanded
        
        Firebase.headers[section].isExpanded = !isExpanded
        
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


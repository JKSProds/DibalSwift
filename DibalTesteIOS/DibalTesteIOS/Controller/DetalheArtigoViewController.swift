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
import UIFloatLabelTextField

class DetalheArtigoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var Firebase: FirebaseCom!
    var id_master = 1
    var currentIndexPath = IndexPath()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tbvc = self.tabBarController  as! CustomTBViewController
        if tbvc.Firebase != nil {
            self.Firebase = tbvc.Firebase
        }
        
        Firebase.getAllFields(tableView: tableView)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
    }
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
    @objc func textChanges(sender:UIFloatLabelTextField! ) {
        if sender.text != "" {
            let section = currentIndexPath.section
            let row = currentIndexPath.row
            
            if Firebase.selectedArticle == -1{
                
                let artigo = Artigo(campos: [Firebase.headers[section].Fields[row].nome : sender.text!])
                Firebase.articles.append(artigo)
                Firebase.selectedArticle = Firebase.articles.count - 1
                Firebase.novoArtigo = true
            }else{
                Firebase.articles[Firebase.selectedArticle].campos[Firebase.headers[section].Fields[row].nome] = sender.text
            }
            
        }
    }
    
    @IBAction func cancelNovoArtigo(_ sender: Any) {
        if Firebase.novoArtigo {
            Firebase.articles.remove(at: Firebase.selectedArticle)
            Firebase.novoArtigo = false
        }
                //print(Firebase.articles)
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveArtigo(_ sender: Any) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        Firebase.uploadArtigo(at: Firebase.selectedArticle)
        Firebase.novoArtigo = false
        print(Firebase.articles)
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fieldsCell") as! FieldCellTableViewCell
        
        cell.textView.tag = Firebase.headers[indexPath.section].Fields[indexPath.row].id
        cell.textView.placeholder = Firebase.headers[indexPath.section].Fields[indexPath.row].descricao
        if Firebase.selectedArticle >= 0 , Firebase.articles[Firebase.selectedArticle].campos[Firebase.headers[indexPath.section].Fields[indexPath.row].nome] != nil {
            cell.textView.text = "\(Firebase.articles[Firebase.selectedArticle].campos[Firebase.headers[indexPath.section].Fields[indexPath.row].nome]!)"
        }else{
            cell.textView.text = Firebase.headers[indexPath.section].Fields[indexPath.row].def
        }

        
       // cell.textView.font = UIFont.systemFont(ofSize: 14)
        cell.textView.returnKeyType = UIReturnKeyType.done
        
        
        cell.textView.addTarget(self,
                                action: #selector(textChanges),
                                for: UIControlEvents.editingDidEnd
        )

        cell.textView.addTarget(self,
                                action: #selector(clickedInsideTextView),
                                for: UIControlEvents.editingDidBegin
        )
    
        
        return cell
        
    }

    @objc func clickedInsideTextView (textField: UITextField) {
        guard let cell = textField.superview?.superview as? FieldCellTableViewCell else {
            return // or fatalError() or whatever
        }
        
        let indexPath = tableView.indexPath(for: cell)
        
        currentIndexPath = indexPath!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Firebase.headers[section].isExpanded {
        return Firebase.headers[section].Fields.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Firebase.headers.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = #colorLiteral(red: 1, green: 0.6031938878, blue: 0.08309882165, alpha: 1)
        
        let image = UIImageView()
        image.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        
        view.addSubview(image)
        
        let label = UILabel()
        label.text = Firebase.headers[section].Title
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.frame = CGRect(x: 40, y: 5, width: self.view.frame.width, height: 30)
        
        view.addSubview(label)
        
        let button = UIButton(type: .system)
        button.tag = section
        button.setTitle("Fechar", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.frame = CGRect(x: self.view.frame.width - 65 , y: 5, width: 60, height: 30)
        button.addTarget(self, action: #selector(expandButton), for: .touchUpInside)
        
        view.addSubview(button)
        
        return view
    }
    
    @objc func expandButton(button: UIButton) {
        var indexPaths = [IndexPath]()
        let section = button.tag
        for row in Firebase.headers[section].Fields.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
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
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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

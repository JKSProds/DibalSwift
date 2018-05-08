//
//  ConfigViewController.swift
//  DibalTesteIOS
//
//  Created by Jorge Monteiro on 03/05/18.
//  Copyright © 2018 Jorge Monteiro. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {
    @IBOutlet weak var txtIP: UITextField!
    @IBOutlet weak var txtPorta: UITextField!
    
    var Dibal = DibalCom()
    var Firebase: FirebaseCom!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        txtIP.text = Dibal.IP_Adress
        txtPorta.text = "\(Dibal.TX_Port)"
    }
    
    @IBAction func txtIPValueChanged(_ sender: UITextField) {
        Dibal.IP_Adress = String(txtIP.text!)
        //print(Dibal.IP_Adress)
    }
    
    @IBAction func txtPortValueChanged(_ sender: UITextField) {
        Dibal.TX_Port = Int32(txtPorta.text!)!
        //print(Dibal.TX_Port)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @IBAction func createFieldsClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Reset Campos", message: "Tem a certeza que deseja realizar um reset a todos os campos? Terá de reconfigurar cada campo individualmente!", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Sim", style: .destructive, handler: { alert -> Void in
            self.Firebase.createAllFields() })
        let CancelOption = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        alertController.addAction(CancelOption)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

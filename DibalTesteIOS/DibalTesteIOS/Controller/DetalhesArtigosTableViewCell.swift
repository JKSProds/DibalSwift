//
//  DetalhesArtigosTableViewCell.swift
//  DibalTesteIOS
//
//  Created by Jorge Monteiro on 08/05/18.
//  Copyright © 2018 Jorge Monteiro. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField 

class DetalhesArtigosTableViewCell: UITableViewCell, UITextFieldDelegate {

    var placeHolderLabel = String()
    var titleLabel = String()
    var fieldText = String()
    var fieldNome =  String()
    var errorMensagem = String()
    

    
    lazy var pickerViewLabel: UILabel = {
 var fontBody = UIFont.preferredFont(forTextStyle: .body).withSize(14)
        fontBody = UIFontMetrics(forTextStyle: .body).scaledFont(for: fontBody)
        
        let label = UILabel()
        //label.font = UIFont.systemFont(ofSize: 14)
        label.font = fontBody
        label.textColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var pickerView: pickerFieldsView = {
        let cb = pickerFieldsView()
        cb.delegate = cb
        cb.dataSource = cb
        
        cb.translatesAutoresizingMaskIntoConstraints = false
        
        return cb
    }()

    lazy var pickerViewLine: UIView = {

        let line = UIView()
        line.backgroundColor = ArtigosViewController.UIColor
        
        line.translatesAutoresizingMaskIntoConstraints = false

        return line
    }()
    
    lazy var textFieldView: SkyFloatingLabelTextField = {
var fontBody = UIFont.preferredFont(forTextStyle: .body).withSize(14)
        fontBody = UIFontMetrics(forTextStyle: .body).scaledFont(for: fontBody)
        let textField = SkyFloatingLabelTextField()
        
        //textField.font = UIFont.systemFont(ofSize: 14)
        textField.font = fontBody
        textField.titleFont = fontBody
        
        textField.lineHeight = 1.0
        textField.lineColor = ArtigosViewController.UIColor
        
        textField.returnKeyType = UIReturnKeyType.done
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    lazy var copyButton: UIButton = {
  var fontBody = UIFont.systemFont(ofSize: 14)
        fontBody = UIFontMetrics(forTextStyle: .body).scaledFont(for: fontBody)
         //Create button copy
        let copyButton = UIButton(type: .system)
        copyButton.setTitle("Copiar", for: .normal)
        copyButton.setTitleColor(.white, for: .normal)
        //copyButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        copyButton.titleLabel?.font = fontBody
        copyButton.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)

        copyButton.layer.cornerRadius = 5
        copyButton.layer.borderWidth = 1
        copyButton.layer.borderColor = UIColor.orange.cgColor
        
        copyButton.translatesAutoresizingMaskIntoConstraints = false

        return copyButton
    }()
    
   lazy var deleteButton: UIButton = {
    var fontBody = UIFont.systemFont(ofSize: 14)
    fontBody = UIFontMetrics(forTextStyle: .body).scaledFont(for: fontBody)
    
    
        //Create button delete
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Apagar", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        //deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
     deleteButton.titleLabel?.font = fontBody
        deleteButton.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        deleteButton.layer.cornerRadius = 5
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.red.cgColor
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        return deleteButton
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        
    }
    
    
    func addTextFieldAndButton() {
        
        self.addSubview(deleteButton)
        
        
        deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        deleteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        self.addSubview(copyButton)
        
        copyButton.rightAnchor.constraint(equalTo: deleteButton.leftAnchor, constant: -5).isActive = true
        copyButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        copyButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        copyButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        textFieldView.placeholder = placeHolderLabel
        textFieldView.title = titleLabel
        textFieldView.text = fieldText
        textFieldView.accessibilityIdentifier = fieldNome
        textFieldView.errorMessage = errorMensagem
     
        
        self.addSubview(textFieldView)
        
        textFieldView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        textFieldView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        textFieldView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2).isActive = true
       
        //Disable textfield article and change width
        textFieldView.isEnabled = false
        textFieldView.rightAnchor.constraint(equalTo: copyButton.leftAnchor, constant: -5).isActive = true
        
    }
    
    func addOnlyTextField() {
        
        textFieldView.placeholder = placeHolderLabel
        textFieldView.title = titleLabel
        textFieldView.text = fieldText
        textFieldView.accessibilityIdentifier = fieldNome
        textFieldView.errorMessage = errorMensagem
        
               textFieldView.isEnabled = true
        
         self.addSubview(textFieldView)
        
        textFieldView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        textFieldView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        textFieldView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2).isActive = true
         textFieldView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
    
    }
    
    func addPickerView() {
        pickerViewLabel.text = titleLabel.uppercased()
        
        self.addSubview(pickerViewLabel)
        
        pickerViewLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        pickerViewLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2).isActive = true
        pickerViewLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2).isActive = true
        
        pickerView.field = fieldNome
        
        self.addSubview(pickerView)
        
        pickerView.topAnchor.constraint(equalTo: pickerViewLabel.topAnchor, constant: 10).isActive = true
        pickerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        pickerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2).isActive = true
        pickerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -100).isActive = true
        
        self.addSubview(pickerViewLine)
        
        let leadingConstraint = NSLayoutConstraint(item: pickerViewLine, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 4.0)
        let bottomConstraint = NSLayoutConstraint(item: pickerViewLine, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -5.0)
        let trailingConstraint = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: pickerViewLine, attribute: .right, multiplier: 1.0, constant: 4.0)
        let heightConstraint = NSLayoutConstraint(item: pickerViewLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0)
        
        self.addConstraints([bottomConstraint, leadingConstraint, trailingConstraint, heightConstraint])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}

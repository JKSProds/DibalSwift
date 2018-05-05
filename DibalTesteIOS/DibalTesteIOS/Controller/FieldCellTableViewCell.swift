//
//  FieldCellTableViewCell.swift
//  DibalTesteIOS
//
//  Created by Jorge Monteiro on 04/05/18.
//  Copyright © 2018 Jorge Monteiro. All rights reserved.
//

import UIKit
import UIFloatLabelTextField

class FieldCellTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textView: UIFloatLabelTextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textView.delegate = self
        textView.returnKeyType = .next
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

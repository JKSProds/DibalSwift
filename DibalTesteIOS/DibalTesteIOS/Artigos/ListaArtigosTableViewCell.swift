//
//  CustomTableViewCell.swift
//  DibalTesteIOS
//
//  Created by Jorge Monteiro on 29/04/18.
//  Copyright © 2018 Jorge Monteiro. All rights reserved.
//

import UIKit

class ListaArtigosTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var lblCodigo: UILabel!
    @IBOutlet weak var lblPreco: UILabel!
    @IBOutlet weak var lblDenominacao: UILabel!
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //setNeedsLayout()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        var fontBold = UIFont.boldSystemFont(ofSize: 20)
        fontBold = UIFontMetrics(forTextStyle: .body).scaledFont(for: fontBold)
        var fontBody = UIFont.preferredFont(forTextStyle: .body).withSize(14)
        fontBody = UIFontMetrics(forTextStyle: .body).scaledFont(for: fontBody)
        
        lblCodigo.font = fontBold
        lblDenominacao.font = fontBody
        lblPreco.font = fontBody
    }
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

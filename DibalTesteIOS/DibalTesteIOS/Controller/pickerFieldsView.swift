//
//  PickerViewController.swift
//  DibalTesteIOS
//
//  Created by Jorge Monteiro on 07/05/18.
//  Copyright © 2018 Jorge Monteiro. All rights reserved.
//

import UIKit

class pickerFieldsView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    
    
    var pickerData: [[String:Any]] = []
    var field = String()
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let vc = self.window?.rootViewController?.presentedViewController as! DetalheArtigoViewController
        
        vc.artigo.campos[field] = "\(pickerData[row]["valor"]!)"
        
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
  var fontBody = UIFont.preferredFont(forTextStyle: .body).withSize(14)
        fontBody = UIFontMetrics(forTextStyle: .body).scaledFont(for: fontBody)
        
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = fontBody
            pickerLabel?.textAlignment = NSTextAlignment.left
        }
        
        if pickerData[row].count == 2 {
        pickerLabel?.text = "\(pickerData[row]["texto"]!)"
        }
        
        return pickerLabel!;
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
   // func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
   //    return "\(pickerData[row]["texto"]!)"
  //
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        self.layer.borderWidth = 0 // Main view rounded border
//
//        // Component borders
//        self.subviews.forEach {
//            $0.layer.borderWidth = 0
//            $0.isHidden = $0.frame.height <= 1.0
//        }
//    }
}

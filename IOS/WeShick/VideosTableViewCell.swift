//
//  VideosTableViewCell.swift
//  WeShick
//
//  Created by Bani Azarael Mejia Flores on 31/10/17.
//  Copyright © 2017 Bani Azarael Mejia Flores. All rights reserved.
//

import UIKit

class VideosTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var labelEstado: UILabel!
    @IBOutlet weak var labelTitulo: UILabel!
    @IBOutlet weak var buttonBorrar: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

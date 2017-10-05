//
//  VideosTableViewCell.swift
//  Video Share Location
//
//  Created by Ariel de la O on 03/10/17.
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

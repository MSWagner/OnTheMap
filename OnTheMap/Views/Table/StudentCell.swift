//
//  StudentCell.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 01.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit
import DataSource

class StudentCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    var viewModel: StudentViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(viewModel: StudentViewModel) {
        self.viewModel = viewModel
        nameLabel.text = viewModel.name
        urlLabel.text = viewModel.url
    }

}

extension StudentCell {
    static var descriptor: CellDescriptor<StudentViewModel, StudentCell> {
        return CellDescriptor()
            .configure { (data, cell, _) in
                cell.configure(viewModel: data)
        }
    }
}

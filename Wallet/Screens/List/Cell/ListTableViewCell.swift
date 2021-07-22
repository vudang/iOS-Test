//
//  ListTableViewCell.swift
//  Wallet
//
//  Created by tony on 7/20/21.
//  Copyright © 2021 Tsubasa Hayashi. All rights reserved.
//

import UIKit
import AlamofireImage

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var baseLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buyPriceLabel: UILabel!
    @IBOutlet weak var sellPriceLabell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with currency: Currency) {
        let base = [currency.base ?? "", currency.counter ?? ""].filter { !$0.isEmpty }.joined(separator: " / ")
        baseLabel.text = base
        nameLabel.text = currency.name
        buyPriceLabel.text = currency.buyPrice
        sellPriceLabell.text = currency.sellPrice
        if let img = currency.icon, let url = URL(string: img) {
            iconImageView?.af.setImage(withURL: url)
        }
    }
}

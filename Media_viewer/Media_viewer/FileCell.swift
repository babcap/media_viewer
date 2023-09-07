//
//  FileCell.swift
//  Media_viewer
//
//  Created by Arthur on 03.09.2023.
//

import UIKit

class FileCell: UITableViewCell {

    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!

    static var identifier: String { return String(describing: self) }
    static var nib: UINib { return UINib(nibName: identifier, bundle: nil) }

    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }

    func initView() {
        backgroundColor = .clear

        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.nameLabel.text = nil
        self.previewImageView.image = nil
    }

    func setup(with viewModel: FileCellViewModel) {
        nameLabel.text = viewModel.name
        previewImageView.image = viewModel.image
    }
}

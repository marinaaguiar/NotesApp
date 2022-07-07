
import UIKit

struct NotebookCell {
    let notebookName: String?
    let creationDate: String?
    let pageCount: String?
}

class NotebookViewCell: UITableViewCell {

    @IBOutlet weak var notebookTitleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var pageCountLabel: UILabel!

    func fill(_ cell: NotebookCell) {

        notebookTitleLabel.text = cell.notebookName
        creationDateLabel.text = cell.creationDate
        pageCountLabel.text = cell.pageCount
    }
}


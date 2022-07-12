
import UIKit

struct NoteCell {
    let noteName: String
    let creationDate: String?
}

class NoteViewCell: UITableViewCell {
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!

    func fill(_ cell: NoteCell) {
        noteTitleLabel.text = cell.noteName
        creationDateLabel.text = cell.creationDate
    }
}

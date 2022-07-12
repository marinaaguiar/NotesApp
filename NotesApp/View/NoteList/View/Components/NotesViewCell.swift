
import UIKit

struct NoteCell {
    let noteTitle: String?
    let creationDate: String?
}

class NoteViewCell: UITableViewCell {
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!

    func fill(_ cell: NoteCell) {
        noteTitleLabel.text = cell.noteTitle
        creationDateLabel.text = cell.creationDate
    }
}

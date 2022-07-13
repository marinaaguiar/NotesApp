
import UIKit

struct NoteCell {
    let noteTitle: String?
    let lastModifiedDate: String?
}

class NoteViewCell: UITableViewCell {
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var lastModifiedDateLabel: UILabel!

    func fill(_ cell: NoteCell) {
        noteTitleLabel.text = cell.noteTitle
        lastModifiedDateLabel.text = cell.lastModifiedDate
    }
}

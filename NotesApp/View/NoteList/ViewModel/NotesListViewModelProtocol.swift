
import UIKit

protocol NotesListViewModelProtocol: AnyObject {
    func initializeCoreData()
    func numberOfRows() -> Int
    func fillCell(for cell: UITableViewCell,atIndexPath indexPath: Int) -> UITableViewCell
}


protocol NotesListViewModelDelegate: AnyObject {
    func didLoad()
}

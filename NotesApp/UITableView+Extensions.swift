
import UIKit

extension UITableView {

    func dequeCell<T: UITableViewCell>(_ : T.Type, _ indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            return T()
        }
        return cell
    }

    func register<T: UITableViewCell>(_ : T.Type) {
        let identifier = String(describing: T.self)
        register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }

}

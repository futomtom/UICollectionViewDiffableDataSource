
import UIKit

extension UICollectionViewCell {
    static var cellReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView {
    static var viewReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {

    // MARK: - Registering

    func registerCell<T: UICollectionViewCell>(cellClass: T.Type) {
        register(T.self,
                 forCellWithReuseIdentifier: T.cellReuseIdentifier)
    }

    func registerSupplementaryView<T: UICollectionReusableView>(viewClass: T.Type) {
        register(T.self,
                 forSupplementaryViewOfKind: T.viewReuseIdentifier,
                 withReuseIdentifier: T.viewReuseIdentifier)
    }

    // MARK: - Dequeueing
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        let reuseIdentifier = T.cellReuseIdentifier

        guard
            let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                           for: indexPath) as? T
        else {
            assertionFailure("Unable to dequeue a cell for \(reuseIdentifier)")
            return T()
        }

        return cell
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
        let reuseIdentifier = T.viewReuseIdentifier

        guard
            let cell = dequeueReusableSupplementaryView(ofKind: reuseIdentifier,
                                                        withReuseIdentifier: reuseIdentifier,
                                                        for: indexPath) as? T
        else {
            assertionFailure("Unable to dequeue a Supplementary View for \(reuseIdentifier)")
            return T()
        }

        return cell
    }
}


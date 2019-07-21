import UIKit
import CoreData
import os

class FiltersViewController: UICollectionViewController,
    NSFetchedResultsControllerDelegate,
    UICollectionViewDelegateFlowLayout {

    private static let margin: CGFloat = 10

    public static let cellHeight: CGFloat = 80

    private lazy var log: OSLog = {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "FiltersViewController")
    }()

    private let flowLayout = UICollectionViewFlowLayout()

    // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
    private var shouldReloadCollectionView = true

    private var blockOperations = [BlockOperation]()

    /// Aggregated predicate the combines the filter and (if present) the search-term-predicate
    lazy var predicate: NSPredicate = {
        return NSPredicate(format: "%K == %@", #keyPath(Filter.isPrimary), false)
    }()

    init() {
        super.init(collectionViewLayout: flowLayout)
        collectionView.register(FiltersCollectionViewCell.self, forCellWithReuseIdentifier: FiltersCollectionViewCell.identifier)

//        collectionView.emptyDataSetSource = self
//        collectionView.emptyDataSetDelegate = self

        flowLayout.minimumLineSpacing = FiltersViewController.margin
        flowLayout.minimumInteritemSpacing = FiltersViewController.margin
        flowLayout.sectionInset = UIEdgeInsets(top: FiltersViewController.margin,
                                               left: FiltersViewController.margin,
                                               bottom: FiltersViewController.margin,
                                               right: FiltersViewController.margin)
        navigationItem.title = "Filter"

        do {
            try fetchedResultController.performFetch()
        } catch {
            os_log("Error when fetching in %@: %@", log: log, type: .info, type(of: self).description(), String(describing: error))
        }

        collectionView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(add))

        do {
            try fetchedResultController.performFetch()
        } catch {
            os_log("Error when fetching in %@: %@", log: log, type: .info, type(of: self).description(), String(describing: error))
        }

        collectionView.backgroundColor = .white
        collectionView.reloadData()
    }

    @objc func add() {
        StoreManager.shared.container.performBackgroundTask { context in
            let filter = Filter(context: context)
            filter.created = NSDate()
            try? context.save()

            let newFilterObjectID = filter.objectID
            DispatchQueue.main.async {
                let filter = StoreManager.shared.container.viewContext.object(with: newFilterObjectID) as! Filter
                self.present(FilterViewController(filter: filter), animated: true, completion: nil)
            }
        }
    }

    lazy var fetchedResultController: NSFetchedResultsController<Filter> = {
        let fr: NSFetchRequest<Filter> = Filter.fetchRequest()
        fr.predicate = self.predicate
        fr.sortDescriptors = [
            NSSortDescriptor(keyPath: \Filter.created, ascending: false)
        ]
        let frc = NSFetchedResultsController(fetchRequest: fr,
                                             managedObjectContext: StoreManager.shared.container.viewContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        os_log("initial filter, using new fetch-request => %@", log: log, type: .info, String(describing: frc.fetchRequest))
        return frc
    }()

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = fetchedResultController.object(at: indexPath)
        navigationController?.pushViewController(ObjectCollectionViewController(style: .filter(filter)), animated: true)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultController.sections?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let nbrInSection = fetchedResultController.sections?[section].numberOfObjects ?? 0
        os_log("numberOfItemsInSection => %d", log: log, type: .debug, nbrInSection)
        return nbrInSection
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FiltersCollectionViewCell.identifier, for: indexPath) as? FiltersCollectionViewCell else {
            fatalError("Cell couldn't be casted to \(FiltersCollectionViewCell.self)")
        }
        cell.delegate = self
        cell.update(filter: fetchedResultController.object(at: indexPath))
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 2 * flowLayout.minimumLineSpacing,
                      height: FiltersViewController.cellHeight)
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if collectionView.numberOfSections > 0 {
                if collectionView.numberOfItems(inSection: newIndexPath!.section) == 0 {
                    os_log("shouldReloadCollectionView => YES", log: log, type: .debug)
                    shouldReloadCollectionView = true
                } else {
                    blockOperations.append(BlockOperation {
                        self.collectionView.insertItems(at: [newIndexPath!])
                    })
                }
            } else {
                os_log("shouldReloadCollectionView => YES", log: log, type: .debug)
            }
        case .update:
            blockOperations.append(BlockOperation {
                self.collectionView.reloadItems(at: [indexPath!])
            })
        case .delete:
            blockOperations.append(BlockOperation {
                self.collectionView.deleteItems(at: [indexPath!])
            })
        case .move:
            blockOperations.append(BlockOperation {
                self.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
            })
        @unknown default:
            fatalError()
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        os_log("controllerWillChangeContent, emptying `blockOperations`", log: log, type: .debug)
        blockOperations = []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        os_log("controllerDidChangeContent, executing `blockOperations`", log: log, type: .debug)
        if shouldReloadCollectionView {
            os_log("Reloading collectionView", log: log, type: .debug)
            collectionView.reloadData()
        } else {
            collectionView.performBatchUpdates({ blockOperations.forEach { $0.start() } }, completion: { _ in
                os_log("Done executing `blockOperations`", log: self.log, type: .debug)
            })
        }
    }

}

//extension OffersCollectionViewController: DZNEmptyDataSetSource {
//
//    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        return NSAttributedString(string: "NO)
//    }
//
//    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        return NSAttributedString(string: Current.localized("offer.empty-state.description"))
//    }
//
//    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: "offers_empty_state")
//    }
//
//    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
//        return .lightGray
//    }
//
//    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
//        switch search {
//        case .search:
//            return 80
//        case .searchContainer:
//            return -70
//        }
//    }
//
//    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
//        let animation = CABasicAnimation(keyPath: "transform")
//
//        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
//        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat.pi/2, 0.0, 0.0, 1.0))
//
//        animation.duration = 0.25
//        animation.isAdditive = true
//        animation.repeatCount = Float.greatestFiniteMagnitude
//
//        return animation
//    }
//
//}
//
//extension OffersCollectionViewController: DZNEmptyDataSetDelegate { }

extension FiltersViewController: FiltersCollectionViewCellDelegate {

    func requestDeletion(of filter: Filter) {
        let ac = UIAlertController(title: "Ta bort filter?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Avbryt", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Radera", style: .destructive, handler: { _ in
            let objectID = filter.objectID
            StoreManager.shared.container.performBackgroundTask({ context in
                context.delete(context.object(with: objectID))
                try? context.save()
            })
        }))
        ac.view.tintColor = UIColor.lightGreen
        present(ac, animated: true, completion: nil)
    }

}

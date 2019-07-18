// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import SDWebImage
import CoreLocation
import CoreData
import os

class ObjectCollectionViewController: UICollectionViewController {

    let layout = UICollectionViewFlowLayout()

    private lazy var log: OSLog = {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ObjectCollectionViewController")
    }()

    // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
    private var shouldReloadCollectionView = true

    private var blockOperations = [BlockOperation]()

    lazy var filter: Filter = {
        let context = StoreManager.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Filter> = Filter.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Filter.isPrimary), NSNumber(value: true))
        return try! context.fetch(fetchRequest).first!
    }()

    private lazy var roomsButtonView: RoomsButtonsView = {
        return RoomsButtonsView(enabledRooms: self.filter.rooms)
    }()

    private lazy var filterBarButtonItem: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: filter.roomsDescription, style: .done, target: nil, action: nil)
        btn.isEnabled = false
        return btn
    }()

    private lazy var sortingBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(title: filter.sorting.description, style: .done, target: self, action: #selector(changeSorting))
    }()

    private lazy var toolbar: UIToolbar = {
        let tb = UIToolbar(frame: .zero)
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.barTintColor = .lightGreen
        tb.isTranslucent = false
        tb.items = [
            self.filterBarButtonItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            self.sortingBarButtonItem
        ]
        return tb
    }()

    init() {
        super.init(collectionViewLayout: layout)
        collectionView.register(ObjectCollectionViewCell.self, forCellWithReuseIdentifier: ObjectCollectionViewCell.identifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var fetchedResultController: NSFetchedResultsController<LKFObject> = {
        let context = StoreManager.shared.container.viewContext
        let frc = NSFetchedResultsController(fetchRequest: filter.fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = Color.separatorGray
        WebService.shared.update()

        roomsButtonView.addTarget(self, action: #selector(roomsUpdated), for: .valueChanged)
        navigationItem.titleView = roomsButtonView

        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbar.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolbar.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        navigationItem.leftBarButtonItem =
            UIBarButtonItem(image: UIImage(named: "baseline_map_black_24pt"),
                            style: .plain,
                            target: self,
                            action: #selector(switchToMapViewController))

        do {
            try fetchedResultController.performFetch()
        } catch {
            os_log("Error when fetching in %@: %@", log: log, type: .info, type(of: self).description(), String(describing: error))
        }

        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        layout.itemSize = CGSize(width: view.frame.width, height: 100)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 48, left: 0, bottom: 100, right: 0)

        filterWasUpdated()
    }

    @objc func filterWasUpdated() {
        fetchedResultController.fetchRequest.predicate = filter.predicate
        fetchedResultController.fetchRequest.sortDescriptors = filter.sortDescriptor
        os_log("update filter, using new fetch-request => %@", log: log, type: .info, String(describing: fetchedResultController.fetchRequest))

        do {
            try fetchedResultController.performFetch()
        } catch {
            os_log("Error when fetching in %@: %@", log: log, type: .info, type(of: self).description(), String(describing: error))
        }

        filterBarButtonItem.title = filter.roomsDescription
        sortingBarButtonItem.title = filter.sorting.description
        collectionView.reloadData()
    }

    @objc func changeSorting() {
        let alertController = UIAlertController(title: "Sortering", message: nil, preferredStyle: .actionSheet)

        Sorting.allCases.forEach { sorting in
            var desc = sorting.description

            if sorting == filter.sorting {
                desc = String(format: "✓ %@", desc)
            }
            alertController.addAction(UIAlertAction(title: desc, style: .default, handler: { _ in
                self.filter.sorting = sorting
            }))
        }

        alertController.addAction(UIAlertAction(title: "Avbryt", style: .cancel, handler: nil))
        alertController.view.tintColor = UIColor.darkGreen
        present(alertController, animated: true, completion: nil)
    }

    @objc func roomsUpdated() {
        let objectID = filter.objectID
        let enabledRooms = roomsButtonView.enabledRooms
        StoreManager.shared.container.performBackgroundTask { ctx in
            let filter = ctx.object(with: objectID) as! Filter
            filter.rooms = enabledRooms
            try? ctx.save()
            DispatchQueue.main.async(execute: self.filterWasUpdated)
        }
    }

    @objc func switchToMapViewController() {
        let mapVC = (UIApplication.shared.delegate as! AppDelegate).objectMapViewController
        UISelectionFeedbackGenerator().selectionChanged()
        navigationController?.setViewControllers(
            [mapVC],
            animated: false)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultController.sections?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let nbrInSection = fetchedResultController.sections?[section].numberOfObjects ?? 0
        return nbrInSection
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ObjectCollectionViewCell.identifier, for: indexPath) as? ObjectCollectionViewCell else {
            fatalError("Cell couldn't be casted to \(ObjectCollectionViewCell.self)")
        }
        let object = fetchedResultController.object(at: indexPath)
        cell.update(object: object)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(ObjectViewController(object: fetchedResultController.object(at: indexPath)), animated: true)
    }

}

extension ObjectCollectionViewController: NSFetchedResultsControllerDelegate {

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
            fatalError("Unknown case")
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        os_log("controllerWillChangeContent, emptying `blockOperations`", log: log, type: .debug)
        blockOperations = []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        os_log("controllerDidChangeContent, executing `blockOperations`", log: log, type: .debug)
        navigationItem.title = String(format: "%d objekt", fetchedResultController.sections?[0].numberOfObjects ?? 0)
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

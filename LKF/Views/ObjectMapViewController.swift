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
import MapKit
import CoreData
import os

class ObjectMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    private lazy var log: OSLog = {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ObjectMapViewController")
    }()

    let mapView = MKMapView()

    lazy var fetchedResultController: NSFetchedResultsController<LKFObject> = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: self.filter.fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()

    private lazy var roomsButtonView: RoomsButtonsView = {
        return RoomsButtonsView(enabledRooms: self.filter.rooms)
    }()

    lazy var filter: Filter = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Filter> = Filter.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Filter.isPrimary), NSNumber(value: true))
        return try! context.fetch(fetchRequest).first!
    }()

    func filterWasUpdated() {
        fetchedResultController.fetchRequest.predicate = filter.predicate
        fetchedResultController.fetchRequest.sortDescriptors = filter.sortDescriptor

        os_log("update filter, using new fetch-request => %@", log: log, type: .info, String(describing: fetchedResultController.fetchRequest))

        do {
            try fetchedResultController.performFetch()
        } catch {
            os_log("Error when fetching in %@: %@", log: log, type: .info, type(of: self).description(), String(describing: error))
        }

        // Since we can't do a `reloadData` - as we do after a `performFetch` on UITableView or UICollectionView, we'll remove all objects
        // and add the "new ones", that's now available in the FRC.
        mapView.removeAnnotations(mapView.annotations)

        let nbrInSection = fetchedResultController.sections?[0].numberOfObjects ?? 0
        let annotations = (0..<nbrInSection).map {
            row in fetchedResultController.object(at: IndexPath(row: row, section: 0))
        }

        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)

        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMarkerAnnotationView.self.description())
        mapView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        navigationItem.titleView = roomsButtonView
        roomsButtonView.addTarget(self, action: #selector(roomsUpdated), for: .valueChanged)

        navigationItem.leftBarButtonItem =
            UIBarButtonItem(image: UIImage(named: "baseline_view_list_black_24pt"),
                            style: .plain,
                            target: self,
                            action: #selector(switchToCollectionViewController))
        navigationItem.leftBarButtonItem?.tintColor = .white

        do {
            try fetchedResultController.performFetch()
        } catch {
            os_log("Error when fetching in %@: %@", log: log, type: .info, type(of: self).description(), String(describing: error))
        }

        fetchedResultController.fetchedObjects.map {
            mapView.addAnnotations($0)
            mapView.showAnnotations($0, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterWasUpdated()
    }

    @objc func switchToCollectionViewController() {
        let collectionVC = (UIApplication.shared.delegate as! AppDelegate).objectCollectionViewController
        UISelectionFeedbackGenerator().selectionChanged()
        navigationController?.setViewControllers(
            [collectionVC],
            animated: false)
    }

    @objc func roomsUpdated() {
        let pc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let objectID = filter.objectID
        let enabledRooms = roomsButtonView.enabledRooms
        pc.performBackgroundTask { ctx in
            let filter = ctx.object(with: objectID) as! Filter
            filter.rooms = enabledRooms
            try? ctx.save()
            DispatchQueue.main.async(execute: self.filterWasUpdated)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let object = annotation as? LKFObject else { return nil }
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMarkerAnnotationView.self.description())
        view.markerTintColor = .red
        view.displayPriority = .required
        return view
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let object = anObject as? LKFObject else { return }

        switch type {
        case .insert:
            mapView.addAnnotation(object)
        case .update:
            // Only way to update annotation is to remove and add it,
            // for now we skip that - as that makes the in grow back to small again,
            // if it is selected. Which feels wierd.
            //
            // Any changes in the filter will fix this anyway since that will remove and re-add
            // all the annotations anyway, thus updating them.
            break
        case .delete:
            mapView.removeAnnotation(object)
        case .move:
            break
        @unknown default:
            fatalError()
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        os_log("controllerWillChangeContent", log: log, type: .debug)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        os_log("controllerDidChangeContent", log: log, type: .debug)
    }

}

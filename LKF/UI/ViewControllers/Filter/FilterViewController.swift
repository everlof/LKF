import UIKit
import os

protocol FilterViewControllerDelegate: class {
    func filterViewController(_: FilterViewController, didUpdateFilter: Filter)
}

class FilterViewController: UIViewController {

    private lazy var log: OSLog = { OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: type(of: self))) }()

    public weak var delegate: FilterViewControllerDelegate?

    private(set) var filter: Filter

    private let stackView = UIStackView()

    private lazy var roomsButtonsView: RoomsButtonsView = {
        return RoomsButtonsView(enabledRooms: self.filter.rooms)
    }()

    private let buttonView = FilterButtonView()

    init(filter: Filter) {
        self.filter = filter
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 24
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)

        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

        stackView.addArrangedSubview(roomsButtonsView)
        stackView.addArrangedSubview(Separator())
        stackView.addArrangedSubview(buttonView)

        buttonView.useButton.addTarget(self, action: #selector(use), for: .touchUpInside)
        buttonView.useButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

        buttonView.resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        buttonView.resetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

        roomsButtonsView.addTarget(self, action: #selector(roomsChanged), for: .valueChanged)

        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func roomsChanged() {
        StoreManager.shared.container.modify(object: filter, in: { filter in
            filter.rooms = self.roomsButtonsView.enabledRooms
        }, completed: {
            self.delegate?.filterViewController(self, didUpdateFilter: self.filter)
        })
    }

    @objc func reset() {
        StoreManager.shared.container.modify(object: filter, in: { filter in
            filter.raw__rooms = nil
        }, completed: {
            self.roomsButtonsView.enabledRooms = self.filter.rooms
            self.delegate?.filterViewController(self, didUpdateFilter: self.filter)
        })
    }

    @objc func use() {
        dismiss(animated: true, completion: nil)
    }

}

class Separator: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 1 / UIScreen.main.scale)
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.darkGreen.withAlphaComponent(0.2)
        setContentHuggingPriority(.required, for: .vertical)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension FilterViewController: UIViewControllerTransitioningDelegate {

    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        return PresentationController(style: .bottom, presentedViewController: presented, presenting: source)
    }

}

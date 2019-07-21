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

    private lazy var maxRentSliderView: MaxRentSliderView = {
        return MaxRentSliderView(value: Float(self.filter.maxRent))
    }()

    private lazy var minAreaSliderView: MinAreaSliderView = {
        return MinAreaSliderView(value: Float(self.filter.minArea))
    }()

    private lazy var filterRoomsView: FilterRoomsView = {
        return FilterRoomsView(enabledRooms: self.filter.rooms)
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

        stackView.addArrangedSubview(filterRoomsView)
        stackView.addArrangedSubview(Separator())
        stackView.addArrangedSubview(maxRentSliderView)
        stackView.addArrangedSubview(Separator())
        stackView.addArrangedSubview(minAreaSliderView)
        stackView.addArrangedSubview(Separator())
        stackView.addArrangedSubview(buttonView)

        buttonView.useButton.addTarget(self, action: #selector(use), for: .touchUpInside)
        buttonView.useButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

        buttonView.resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        buttonView.resetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

        filterRoomsView.addTarget(self, action: #selector(roomsChanged), for: .valueChanged)
        maxRentSliderView.addTarget(self, action: #selector(maxRentChanged), for: .valueChanged)
        minAreaSliderView.addTarget(self, action: #selector(minAreaChanged), for: .valueChanged)

        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func roomsChanged() {
        StoreManager.shared.container.modify(object: filter, in: { filter in
            filter.rooms = self.filterRoomsView.enabledRooms
        }, completed: {
            self.delegate?.filterViewController(self, didUpdateFilter: self.filter)
        })
    }

    @objc func minAreaChanged() {
        StoreManager.shared.container.modify(object: filter, in: { filter in
            filter.minArea = Int32(self.minAreaSliderView.value)
        }, completed: {
            self.delegate?.filterViewController(self, didUpdateFilter: self.filter)
        })
    }

    @objc func maxRentChanged() {
        StoreManager.shared.container.modify(object: filter, in: { filter in
            filter.maxRent = Int32(self.maxRentSliderView.value)
        }, completed: {
            self.delegate?.filterViewController(self, didUpdateFilter: self.filter)
        })
    }

    @objc func reset() {
        StoreManager.shared.container.modify(object: filter, in: { filter in
            filter.raw__rooms = nil
            filter.minArea = 0
            filter.maxRent = 0
        }, completed: {
            self.filterRoomsView.enabledRooms = self.filter.rooms
            self.maxRentSliderView.change(value: 0, sendFeedback: false)
            self.minAreaSliderView.change(value: 0, sendFeedback: false)
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

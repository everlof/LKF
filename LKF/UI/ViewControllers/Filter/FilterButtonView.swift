import UIKit

class FilterButtonView: UIStackView {

    let useButton: RoundCornerButton = .primaryFilterButton

    let resetButton: RoundCornerButton = .secondaryFilterButton

    init() {
        super.init(frame: .zero)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        axis = .horizontal
        spacing = 24
        distribution = .fillEqually
        addArrangedSubview(resetButton)
        addArrangedSubview(useButton)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

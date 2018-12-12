import UIKit

class PostingActivityCell: UITableViewCell, NibLoadable {

    // MARK: - Properties

    @IBOutlet weak var monthsStackView: UIStackView!
    @IBOutlet weak var viewMoreLabel: UILabel!
    @IBOutlet weak var legendView: UIView!

    // MARK: - Init

    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyles()
        addLegend()
    }

    func configure(monthsData: [[PostingActivityDayData]]) {
        addMonths(monthsData: monthsData)
    }

}

// MARK: - Private Extension

private extension PostingActivityCell {

    func applyStyles() {
        viewMoreLabel.text = NSLocalizedString("View more", comment: "Label for viewing more posting activity.")
        viewMoreLabel.textColor = WPStyleGuide.Stats.actionTextColor
    }

    func addLegend() {
        let legend = PostingActivityLegend.loadFromNib()
        legendView.addSubview(legend)
    }

    func addMonths(monthsData: [[PostingActivityDayData]]) {

        removeExistingMonths()

        for monthData in monthsData {
            let monthView = PostingActivityMonth.loadFromNib()
            monthView.configure(monthData: monthData)
            monthsStackView.addArrangedSubview(monthView)
        }
    }

    func removeExistingMonths() {
        monthsStackView.arrangedSubviews.forEach {
            monthsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    @IBAction func didTapViewMoreButton(_ sender: UIButton) {
        // TODO: show Posting Activity details
        let alertController =  UIAlertController(title: "Posting Activity will be shown here.",
                                                 message: nil,
                                                 preferredStyle: .alert)
        alertController.addCancelActionWithTitle("OK")
        alertController.presentFromRootViewController()
    }

}
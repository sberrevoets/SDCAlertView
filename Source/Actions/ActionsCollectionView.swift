import UIKit

private let kActionCellIdentifier = "actionCell"

class ActionsCollectionView: UICollectionView {

    var actions: [AlertAction] = []

    var visualStyle: AlertVisualStyle! {
        didSet {
            guard let layout = self.collectionViewLayout as? ActionsCollectionViewFlowLayout else {
                return
            }

            layout.visualStyle = self.visualStyle
        }
    }

    var displayHeight: CGFloat {
        guard let layout = self.collectionViewLayout as? ActionsCollectionViewFlowLayout,
            let visualStyle = self.visualStyle else
        {
                return -1
        }

        if layout.scrollDirection == .horizontal {
            return visualStyle.actionViewSize.height
        } else {
            return visualStyle.actionViewSize.height * CGFloat(self.numberOfItems(inSection: 0))
        }
    }

    var actionTapped: ((AlertAction) -> Void)?

    private var highlightedCell: UICollectionViewCell?

    init() {
        super.init(frame: .zero, collectionViewLayout: ActionsCollectionViewFlowLayout())
        self.dataSource = self
        self.delegate = self
        self.backgroundColor = .clear
        self.delaysContentTouches = false

        self.collectionViewLayout.register(ActionSeparatorView.self,
            forDecorationViewOfKind: kHorizontalActionSeparator)
        self.collectionViewLayout.register(ActionSeparatorView.self,
            forDecorationViewOfKind: kVerticalActionSeparator)

        let nibName = String(describing: ActionCell.self)
        let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        self.register(nib, forCellWithReuseIdentifier: kActionCellIdentifier)
    }

    convenience required init?(coder aDecoder: NSCoder) {
        self.init()
    }

    @objc
    func highlightAction(for sender: UIGestureRecognizer) {
        let touchPoint = sender.location(in: self)
        let touchIsInCollectionView = self.bounds.contains(touchPoint)

        let state = sender.state

        if state == .cancelled || state == .failed || state == .ended || !touchIsInCollectionView {
            self.highlightedCell?.isHighlighted = false
            self.highlightedCell = nil
        }

        guard let indexPath = self.indexPathForItem(at: touchPoint),
              let cell = self.cellForItem(at: indexPath as IndexPath),
              cell != self.highlightedCell && self.actions[indexPath.item].isEnabled else
        {
            return
        }

        if sender.state == .began || sender.state == .changed {
            self.highlightedCell?.isHighlighted = false
            cell.isHighlighted = true
            self.highlightedCell = cell

            if #available(iOS 10, *) {
                UISelectionFeedbackGenerator().selectionChanged()
            }
        }

        if sender.state == .ended {
            self.actionTapped?(self.actions[(indexPath as NSIndexPath).item])
        }
    }
}

extension ActionsCollectionView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.actions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kActionCellIdentifier,
            for: indexPath) as? ActionCell
        let action = self.actions[(indexPath as NSIndexPath).item]
        cell?.set(action, with: self.visualStyle)
        return cell!
    }
}

extension ActionsCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let actionWidth = self.visualStyle.actionViewSize.width
        let actionHeight = self.visualStyle.actionViewSize.height

        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        if layout.scrollDirection == .horizontal {
            let width = max(self.bounds.width / CGFloat(self.numberOfItems(inSection: 0)), actionWidth)
            return CGSize(width: width, height: actionHeight)
        } else {
            return CGSize(width: self.bounds.width, height: actionHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath) -> Bool
    {
        let actionCell = self.actions[(indexPath as NSIndexPath).item]
        return actionCell.isEnabled
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.actionTapped?(self.actions[(indexPath as NSIndexPath).item])
    }
}

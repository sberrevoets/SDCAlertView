import UIKit

private let kActionCellIdentifier = "actionCell"

class ActionsCollectionView: UICollectionView {

    var actions: [AlertAction] = []

    var visualStyle: AlertVisualStyle! {
        didSet {
            guard let layout = self.collectionViewLayout as? ActionsCollectionViewFlowLayout else { return }
            layout.visualStyle = self.visualStyle
        }
    }

    var displayHeight: CGFloat {
        guard let layout = self.collectionViewLayout as? ActionsCollectionViewFlowLayout,
            let visualStyle = self.visualStyle else {
                return -1
            }

        if layout.scrollDirection == .Horizontal {
            return visualStyle.actionViewSize.height
        } else {
            return visualStyle.actionViewSize.height * CGFloat(self.numberOfItemsInSection(0))
        }
    }

    var actionTapped: ((AlertAction) -> Void)?

    private var highlightedCell: UICollectionViewCell?

    init() {
        super.init(frame: .zero, collectionViewLayout: ActionsCollectionViewFlowLayout())
        self.dataSource = self
        self.delegate = self
        self.backgroundColor = .clearColor()
        self.delaysContentTouches = false

        self.collectionViewLayout.registerClass(ActionSeparatorView.self,
            forDecorationViewOfKind: kHorizontalActionSeparator)
        self.collectionViewLayout.registerClass(ActionSeparatorView.self,
            forDecorationViewOfKind: kVerticalActionSeparator)

        let nibName = NSStringFromClass(ActionCell).componentsSeparatedByString(".").last!
        let nib = UINib(nibName: nibName, bundle: NSBundle(forClass: self.dynamicType))
        self.registerNib(nib, forCellWithReuseIdentifier: kActionCellIdentifier)
    }

    convenience required init?(coder aDecoder: NSCoder) {
        self.init()
    }

    @objc
    func highlightAction(forPanGesture sender: UIGestureRecognizer) {
        let touchPoint = sender.locationInView(self)
        let touchIsInCollectionView = CGRectContainsPoint(self.bounds, touchPoint)

        let state = sender.state

        if state == .Cancelled || state == .Failed || state == .Ended || !touchIsInCollectionView {
            self.highlightedCell?.highlighted = false
            self.highlightedCell = nil
        }

        guard let indexPath = self.indexPathForItemAtPoint(touchPoint),
                  cell = self.cellForItemAtIndexPath(indexPath)
              where cell != self.highlightedCell && self.actions[indexPath.item].enabled else
        {
            return
        }

        if sender.state == .Began || sender.state == .Changed {
            self.highlightedCell?.highlighted = false
            cell.highlighted = true
            self.highlightedCell = cell
        }

        if sender.state == .Ended {
            self.actionTapped?(self.actions[indexPath.item])
        }
    }
}

extension ActionsCollectionView: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.actions.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kActionCellIdentifier,
            forIndexPath: indexPath) as? ActionCell
        cell?.setAction(self.actions[indexPath.item], withVisualStyle: self.visualStyle)
        return cell!
    }
}

extension ActionsCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let actionWidth = self.visualStyle.actionViewSize.width
        let actionHeight = self.visualStyle.actionViewSize.height

        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        if layout.scrollDirection == .Horizontal {
            let width = max(self.bounds.width / CGFloat(self.numberOfItemsInSection(0)), actionWidth)
            return CGSize(width: width, height: actionHeight)
        } else {
            return CGSize(width: self.bounds.width, height: actionHeight)
        }
    }

    func collectionView(collectionView: UICollectionView,
        shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        let actionCell = self.actions[indexPath.item]
        return actionCell.enabled
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.actionTapped?(self.actions[indexPath.item])
    }
}

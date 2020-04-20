import UIKit

final class ActionSheetView: UIView, AlertControllerViewRepresentable {
    private let primaryView = ActionSheetPrimaryView()
    private let cancelView = ActionSheetCancelActionView()

    var title: NSAttributedString? {
        get { return self.primaryView.title }
        set { self.primaryView.title = newValue }
    }

    var message: NSAttributedString? {
        get { return self.primaryView.message }
        set { self.primaryView.message = newValue }
    }

    var contentView = UIView()
    var topView: UIView { self }
    var actions: [AlertAction] = []
    var visualStyle: AlertVisualStyle!

    var actionTappedHandler: ((AlertAction) -> Void)? {
        didSet {
            self.primaryView.actionTapped = self.actionTappedHandler
            self.cancelView.cancelTapHandler = self.actionTappedHandler
        }
    }

    func prepareLayout() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.primaryView)
        self.addSubview(self.cancelView)

        if let cancelAction = self.assignCancelAction() {
            self.cancelView.buildView(cancelAction: cancelAction, visualStyle: self.visualStyle)
        }

        self.primaryView.buildView(actions: self.actions, contentView: self.contentView,
                                   visualStyle: self.visualStyle)


        NSLayoutConstraint.activate([
            self.primaryView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.primaryView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.primaryView.topAnchor.constraint(equalTo: self.topAnchor),

            self.primaryView.bottomAnchor.constraint(equalTo: self.cancelView.topAnchor, constant: -8),

            self.cancelView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.cancelView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.cancelView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }

    func add(_ behaviors: AlertBehaviors) {
        if !behaviors.contains(.dragTap) {
            return
        }

        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self.primaryView, action: #selector(self.primaryView.highlightAction(for:)))
        panGesture.addTarget(self.cancelView, action: #selector(self.cancelView.highlightAction(for:)))
        self.addGestureRecognizer(panGesture)
    }

    // MARK: - Private

    private func assignCancelAction() -> AlertAction? {
        if let cancelActionIndex = self.actions.firstIndex(where: { $0.style == .preferred }) {
            let cancelAction = self.actions[cancelActionIndex]
            self.actions.remove(at: cancelActionIndex)
            return cancelAction
        } else {
            let cancelAction = self.actions.first
            self.actions.removeFirst()
            return cancelAction
        }
    }
}

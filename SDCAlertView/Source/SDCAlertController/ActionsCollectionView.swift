//
//  ActionsCollectionView.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 7/13/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

private let kActionCellIdentifier = "actionCell"

class ActionsCollectionView: UICollectionView {

    var actions: [AlertAction] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
    }

    @IBAction private func tapped(sender: UITapGestureRecognizer) {
        guard let indexPath = indexPathForItemAtPoint(sender.locationInView(self)) else { return }
        let action = self.actions[indexPath.item]
        action.handler?(action)
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
        cell?.action = self.actions[indexPath.item]
        return cell!
    }
}

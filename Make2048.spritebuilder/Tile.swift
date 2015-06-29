//
//  Tile.swift
//  Make2048
//
//  Created by Alan on 6/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Tile: CCNode {
    weak var valueLabel: CCLabelTTF!
    weak var backgroundNode: CCNodeColor!
    var value: Int = 0 {
        didSet {
            valueLabel.string = "\(value)"
        }
    }
    var mergedThisRound = false
    
    func didLoadFromCCB() {
        value = Int(CCRANDOM_MINUS1_1() + 2) * 2
    }
}

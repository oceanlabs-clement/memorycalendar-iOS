//
//  CalendarCell.swift
//  memorycalendar
//
//  Created by Clement Gan on 28/12/2024.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    var label: UILabel!
    var eventLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Day number label
        label = UILabel(frame: CGRect(x: 5, y: 5, width: frame.width - 10, height: frame.height / 2))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        addSubview(label)
        
        // Event label
        eventLabel = UILabel(frame: CGRect(x: 5, y: frame.height / 2, width: frame.width - 10, height: frame.height / 2))
        eventLabel.textAlignment = .center
        eventLabel.font = UIFont.systemFont(ofSize: 10)
        eventLabel.numberOfLines = 0
        eventLabel.textColor = .gray
        addSubview(eventLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




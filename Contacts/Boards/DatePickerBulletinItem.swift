//
//  DatePickerBulletinItem.swift
//  Contacts
//
//  Created by Johnny Perdomo on 12/26/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit
import BLTNBoard

class DatePickerBLTNItem: BLTNPageItem {
    
    lazy var datePicker = UIDatePicker()
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        datePicker.datePickerMode = .date
        return [datePicker]
    }
}

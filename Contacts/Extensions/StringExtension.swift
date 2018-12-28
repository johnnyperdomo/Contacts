//
//  StringExtension.swift
//  Contacts
//
//  Created by Johnny Perdomo on 12/28/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit

extension String { //Remove white spaces at the beginning and end of string
    
    func removeWhiteSpaces() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

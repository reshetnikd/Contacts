//
//  MailData.swift
//  Contacts
//
//  Created by Dmitry Reshetnik on 28.05.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import Foundation

class MailData {
    var mailboxes = [String]()
    
    init() {
        if let path = Bundle.main.path(forResource: "list", ofType: "txt") {
            if let list = try? String(contentsOfFile: path) {
                mailboxes = list.components(separatedBy: "\n").dropLast()
            }
        }
    }
}

//
//  Nomes.swift
//  Razzle
//
//  Created by Renata Faria on 05/12/19.
//  Copyright © 2019 Renata Faria. All rights reserved.
//

import Foundation

let animaisNomes = ["vaca":"vaca", "cachorro":"cachorro", "gato":"gato", "elefante": "elefante", "bode": "bode", "cavalo":"cavalo", "galinha" : "galinha"]

let som = ["vaca":"muge: mõõõõ", "cachorro":"late: au au", "gato":"mia: miau", "elefante": "barre", "bode": "berra: béééé", "cavalo":"relincha", "galinha" : "canta: cocoricó"]

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

//
//  CrystalAndDragonsView.swift
//  CrystalsAndDragons
//
//  Created by @islamien  on 25/6/25.
//

import Foundation

protocol CrystalAndDragonsViewProtocol {
    func showText(with text: String)
    func readCommand() -> String?
}

final class CrystalAndDragonsView: CrystalAndDragonsViewProtocol {
    func showText(with text: String) {
        print(text)
    }
    
    func readCommand() -> String? {
        return readLine()
    }
}

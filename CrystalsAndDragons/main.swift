//
//  main.swift
//  CrystalsAndDragons
//
//  Created by @islamien  on 25/6/25.
//

import Foundation

private let view = CrystalAndDragonsView()
private let viewModel = CrystalAndDragonsViewModel(view: view)

viewModel.startGame()

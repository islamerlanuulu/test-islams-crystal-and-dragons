//
//  WorldModel.swift
//  CrystalsAndDragons
//
//  Created by @islamien  on 25/6/25.
//

import Foundation

struct WorldModel {
    var rooms: [PositionModel: RoomModel]
    var player: PlayerModel
    var itemsMap: [PositionModel: [ItemModel]]
    
    func contains(_ position: PositionModel) -> Bool {
        return rooms[position] != nil
    }
}



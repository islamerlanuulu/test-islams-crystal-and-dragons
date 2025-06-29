//
//  GameService.swift
//  CrystalsAndDragons
//
//  Created by @islamien  on 29/6/25.
//

import Foundation

final class GameService {
    private var world: WorldModel
    private var player: PlayerModel
    private var stepCount: Int
    
    private(set) var isGameOver = false
    private(set) var message: String = ""
    
    init(
        world: WorldModel,
        position: PositionModel,
        stepCount: Int
    ) {
        self.world = world
        self.player = PlayerModel(position: PositionModel(x: 0, y: 0))
        self.stepCount = stepCount
    }
    
    func describeRoom() -> String {
        guard let room = world.rooms[player.position] else {
            return ""
        }
        
        let items = world.itemsMap[player.position] ?? []
        
        let doors = room.doors.map {
            $0.rawValue.uppercased()
        }
        
        return "You are in the room [\(room.position.x), \(room.position.y)]. There are \(doors.count) doors: \(doors.joined(separator: ", ")). Items in the room: \(items.isEmpty ? "Нету предметов" : items.map(\.rawValue).joined(separator: ", ") + ".")"
    }
    
    func step(with route: Route) {
        guard stepCount >= 0 else {
            message = "Лимит шагов исчерпан, вы умерли.💀"
            isGameOver = true
            return
        }
        
        guard let room = world.rooms[player.position],
              room.doors.contains(route) else {
            message = "❌Тут стены, идти нельзя.❌"
            return
        }
        
        let delta: (dx: Int, dy: Int) = {
            switch route {
            case .n: return (0, 1)
            case .s: return (0, -1)
            case .e: return (1, 0)
            case .w: return (-1, 0)
            }
        }()
        
        player.position = PositionModel(
            x: player.position.x + delta.dx,
            y: player.position.y + delta.dy
        )
        
        stepCount -= 1
        message = describeRoom()
    }
    
    func inventory() -> String {
        return player.inventory.isEmpty ? "У тебя пустой инвентарь. 😕" : "У вас есть в инвентаре: \(player.inventory.map(\.rawValue).joined(separator: ", "))."
    }
    
    func getItem(with name: String) {
        let position = player.position
        
        guard let item = ItemModel(rawValue: name),
              var items = world.itemsMap[position],
              let index = items.firstIndex(of: item) else
        {
            message = "Тут нет \(name). 🤷🏻‍♂️"
            return
        }
        
        if item == .chest {
            message = "Ты не можешь поднять сундук. 😅"
            return
        }
        
        items.remove(at: index)
        world.itemsMap[position] = items
        player.inventory.append(item)
        
        message = "Вы подняли \(name). 😏"
    }
    
    func dropItem(with name: String) {
        let position = player.position
        
        guard let item = ItemModel(rawValue: name),
              let index = player.inventory.firstIndex(of: item) else
        {
            message = "У вас нет \(name). 🤷🏻‍♂️"
            return
        }
        
        player.inventory.remove(at: index)
        var items = world.itemsMap[position] ?? []
        items.append(item)
        world.itemsMap[position] = items
        
        message = "Вы бросили \(name)."
    }
    
    func openChest() {
        let position = player.position
        
        guard var items = world.itemsMap[position],
              items.contains(.chest) else
        {
            message = "Тут нет сундука. 🤷🏻‍♂️"
            return
        }
        
        guard let keyIndex = player.inventory.firstIndex(of: .key) else {
            message = "Нужен ключ 🔑."
            return
        }
        
        items.removeAll {
            $0 == .chest
        }
        
        world.itemsMap[position] = items
        
        player.inventory.remove(at: keyIndex)
        message = "Сундук открыт, вы получили священный Грааль 🥇"
        isGameOver = true
    }
}



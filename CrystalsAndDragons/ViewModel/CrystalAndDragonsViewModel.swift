//
//  CrystalAndDragonsViewModel.swift
//  CrystalsAndDragons
//
//  Created by @islamien  on 25/6/25.
//

import Foundation

final class CrystalAndDragonsViewModel {
    private let view: CrystalAndDragonsView
    private var world: WorldModel
    private var player: PlayerModel
    private var running = true
    private var stepCount = 0
    
    init(view: CrystalAndDragonsView) {
        self.world = WorldFactory.createWorld(width: 5, height: 5)
        self.player = PlayerModel(position: PositionModel(x: 0, y: 0))
        self.view = view
    }
    
    func startGame() {
        view.showText(with: "Введите количество комнат:")
        guard let line = view.readCommand(),
              let count = Int(line), count >= 5
        else {
            view.showText(with: "Нельзя создавать ниже 5 комнат!")
            return
        }
        
        let root = Int(Double(count).squareRoot())
        var width = count, height = 1
        
        for w in (1...root).reversed() {
            if count % w == 0 {
                width = count / w
                height = w
                break
            }
        }
        
        world = WorldFactory.createWorld(width: width, height: height)
        player = PlayerModel(position: PositionModel(x: 0, y: 0))
        stepCount = count * 2
        
        view.showText(with: "Игра началась, \nКристаллы и драконы! (menu – список команд) \nЛимит шагов: \(stepCount)")
        view.showText(with: "Лабиринт \(width) x \(height) из \(count) комнат сгенерирован!")
        view.showText(with: "Нажми на: \nn - Север \ns - Юг \nw - Запад \ne - Восток")
        gameCycle()
    }
    
    private func gameCycle() {
        while running {
            guard let command = view.readCommand() else {
                continue
            }
            
            view.showText(with: commands(with: command))
        }
    }
    
    private func commands(with command: String) -> String {
        let parts = command.lowercased().split(separator: " ")
        
        guard let commands = parts.first else {
            return ""
        }
        
        switch commands {
        case "n":
            return step(with: .n)
        case "s":
            return step(with: .s)
        case "e":
            return step(with: .e)
        case "w":
            return step(with: .w)
        case "see":
            return see()
        case "bag":
            return inventory()
        case "get":
            return getItem(with: String(parts.dropFirst().joined(separator: " ")))
        case "drop":
            return dropItem(with: String(parts.dropFirst().joined(separator: " ")))
        case "open":
            return openChest()
        case "menu":
            return "Все команды: \n🎮n/s/e/w \n👀see \n🪓get [item] \n👝bag \n🛑stop"
        case "stop":
            running = false
            return  "❌Вы остановили игру, игра завершена!❌"
        case "step":
            return "Текщий лимит шагов: \(stepCount)"
        default:
            return "Такой команды нет 😞"
        }
    }
    
    private func items(with position: PositionModel) -> [ItemModel] {
        return world.itemsMap[position] ?? []
    }
    
    private func step(with route: Route) -> String {
        stepCount -= 1
        
        if stepCount <= 0 {
            running = false
            return "Лимит шагов исчерпан, вы умерли.💀"
        }
        
        guard let room = world.rooms[player.position],
              room.doors.contains(route)
        else {
            return "❌Тут стены, идти нельзя.❌"
        }
        
        let delta =
        switch route {
        case .n:
            (0, 1)
        case .s:
            (0,-1)
        case .e:
            (1, 0)
        case .w:
            (-1, 0)
        }
        
        player.position = PositionModel(
            x: player.position.x + delta.0,
            y: player.position.y + delta.1
        )
        
        return see()
    }
    
    private func see() -> String {
        guard let room = world.rooms[player.position] else {
            return ""
        }
        
        let items = items(with: player.position)
        
        let doors = room.doors.map {
            $0.rawValue.uppercased()
        }
        
        return "You are in the room [\(room.position.x), \(room.position.y)]. There are \(doors.count) doors: \(doors.joined(separator: ", ")). Items in the room: \(items.isEmpty ? "Нету предметов" : items.map(\.rawValue).joined(separator: ", ") + ".")"
    }
    
    private func inventory() -> String {
        player.inventory.isEmpty ? "У тебя пустой инвентарь. 😕" : "У вас есть в инвентаре: \(player.inventory.map(\.rawValue).joined(separator: ", "))."
    }
    
    private func getItem(with name: String) -> String {
        let position = player.position
        
        guard var items = world.itemsMap[position],
              let item = ItemModel(rawValue: name),
              let index = items.firstIndex(of: item) else {
            return "Тут нет \(name). 🤷🏻‍♂️"
        }
        
        if item == .chest {
            return "Ты не можешь поднять сундук. 😅"
        }
        
        items.remove(at: index)
        world.itemsMap[position] = items
        player.inventory.append(item)
        
        return "Вы подняли \(name). 😏"
    }
    
    private func dropItem(with name: String) -> String {
        guard let item = ItemModel(rawValue: name),
              let index = player.inventory.firstIndex(of: item) else {
            return "У вас нет \(name)."
        }
        
        player.inventory.remove(at: index)
        world.itemsMap[player.position, default: []].append(item)
        
        return "Вы бросили \(name)."
    }
    
    private func openChest() -> String {
        let itemsHere = items(with: player.position)
        
        guard itemsHere.contains(.chest) else {
            return "Тут нет сундука."
        }
        
        guard let keyIndex = player.inventory.firstIndex(of: .key) else {
            return "Нужен ключ 🔑."
        }
        
        world.itemsMap[player.position] = itemsHere.filter {
            $0 != .chest
        }
        
        player.inventory.remove(at: keyIndex)
        running = false
        
        return "Сундук открыт, вы получили священный Грааль🥇 \nВы победили!"
    }
}

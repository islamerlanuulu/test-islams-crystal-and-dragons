//
//  CrystalAndDragonsViewModel.swift
//  CrystalsAndDragons
//
//  Created by @islamien  on 25/6/25.
//

import Foundation

final class CrystalAndDragonsViewModel {
    private let view: CrystalAndDragonsView
    private var gameService: GameService?
    private var running = false
    
    init(view: CrystalAndDragonsView) {
        self.view = view
    }
    
    func startGame() {
        view.showText(with: "Введите количество комнат:")
        
        guard let line = view.readCommand(), let count = Int(line), count >= 5 else {
            view.showText(with:  "Нельзя создавать ниже 5 комнат!")
            return
        }
        
        let root = Int(Double(count).squareRoot())
        var width = count, height = 1
        
        for w in (1...root).reversed() where count % w == 0 {
            width = count / w
            height = w
            break
        }
        
        let worldModel = WorldFactory.createWorld(width: width, height: height)
        let stepLimit = count * 2
        gameService = GameService(world: worldModel, position: PositionModel(x: 0, y: 0), stepCount: stepLimit)
        
        view.showText(with: "Игра началась, \nКристаллы и драконы! (menu – список команд) \nЛимит шагов: \(stepLimit)")
        view.showText(with: "Лабиринт \(width) x \(height) из \(count) комнат сгенерирован!")
        view.showText(with: "Нажми на: \nn - Север \ns - Юг \nw - Запад \ne - Восток")
        view.showText(with: gameService!.describeRoom())
        running = true
        gameCycle()
    }
    
    private func gameCycle() {
        while running {
            guard let raw = view.readCommand()?.lowercased(),
                  let service = gameService else {
                continue
            }
            
            let parts = raw.split(separator: " ").map(String.init)
            
            let command = parts.first ?? ""
            switch command {
            case "n", "s", "e", "w":
                let route = Route(rawValue: command)!
                service.step(with: route)
                view.showText(with: service.message)
            case "see":
                view.showText(with: service.describeRoom())
            case "bag":
                view.showText(with: service.inventory())
            case "get" where parts.count > 1:
                service.getItem(with: parts[1])
                view.showText(with: service.message)
            case "drop" where parts.count > 1:
                service.dropItem(with: parts[1])
                view.showText(with: service.message)
            case "open":
                service.openChest()
                view.showText(with: service.message)
            case "menu":
                view.showText(with: "Все команды: \n🎮n/s/e/w \n👀see \n🪓get [item] \n👝bag \n🛑stop")
            case "stop":
                running = false
                view.showText(with: "❌Вы остановили игру, игра завершена!❌")
            default:
                view.showText(with: "Такой команды нет 😞")
            }
            
            if service.isGameOver {
                running = false
            }
        }
    }
}


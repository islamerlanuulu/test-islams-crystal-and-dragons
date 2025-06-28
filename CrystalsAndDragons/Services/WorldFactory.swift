//
//  WorldFactory.swift
//  CrystalsAndDragons
//
//  Created by @islamien  on 25/6/25.
//

import Foundation

enum WorldFactory {
    
    static func createWorld(
        width: Int,
        height: Int
    ) -> WorldModel {
        var rooms: [PositionModel: RoomModel] = [:]
        
        for x in 0..<width {
            for y in 0..<height {
                let position = PositionModel(x: x, y: y)
                var doors: [Route] = []
                
                if y < height - 1 {
                    doors.append(.n)
                }
                if y > 0 {
                    doors.append(.s)
                }
                if x < width  - 1 {
                    doors.append(.e)
                }
                if x > 0 {
                    doors.append(.w)
                }
                
                rooms[position] = RoomModel(
                    position: position,
                    doors: doors,
                    items: []
                )
            }
        }
        
        let player = PlayerModel(
            position: .init(
                x: 0,
                y: 0
            )
        )
        
        var world = WorldModel(
            rooms: rooms,
            player: player,
            itemsMap: [:]
        )
        
        let allPositions = (0..<width).flatMap { x in
            (0..<height).compactMap { y in
                (x == 0 && y == 0) ? nil : PositionModel(x: x, y: y)
            }
        }.shuffled()
        
        if allPositions.count >= 4 {
            world.itemsMap[allPositions[0]] = [.key]
            world.itemsMap[allPositions[1]] = [.chest]
            world.itemsMap[allPositions[2]] = [.sword]
            world.itemsMap[allPositions[3]] = [.crystal]
        }
        
        for position in allPositions.dropFirst(4) {
            if Int.random(in: 0..<100) < 15 {
                world.itemsMap[position, default: []].append(.gold)
            }
        }
        
        let limit = width * height * 2
        let dist = reachableDistances(
            with: PositionModel(x: 0, y: 0), rooms: world.rooms)
        
        if let keyPosition = allPositions.first,
           let chestPosition = allPositions.dropFirst(1).first,
           let dKey = dist[keyPosition],
           let dChest = dist[chestPosition],
           (dKey > limit || dChest > limit)
        {
            return createWorld(width: width, height: height)
        }
        
        return world
    }
    
    private static func reachableDistances(
        with start: PositionModel,
        rooms: [PositionModel: RoomModel]
    ) -> [PositionModel: Int] {
        var dist = [start: 0]
        var queue = [start]
        
        while !queue.isEmpty {
            let cur = queue.removeFirst()
            let d0 = dist[cur]!
            
            for dir in rooms[cur]!.doors {
                let delta: (dx: Int, dy: Int) = {
                    switch dir {
                    case .n:
                        return (0, 1)
                    case .s:
                        return (0, -1)
                    case .e:
                        return (1, 0)
                    case .w:
                        return (-1, 0)
                    }
                }()
                let nxt = PositionModel(
                    x: cur.x + delta.dx,
                    y: cur.y + delta.dy
                )
                
                if dist[nxt] == nil {
                    dist[nxt] = d0 + 1
                    queue.append(nxt)
                }
            }
        }
        
        return dist
    }
}


//
//  Game.swift
//  VideoGamesProject
//
//  Created by Abdullah Coban on 18.07.2021.
//

import Foundation

struct GameList: Decodable {
    let next: String
    //let previous: String
    let results: [Game]
}

struct Game: Decodable {
    let id: Int
    let name: String
    let background_image: String
    let rating: Double
    let released: String
}

struct GameDetail: Decodable {
    let id: Int
    let name: String
    let background_image: String
    let metacritic: Int
    let description_raw: String
    let released: String
    let rating: Double
}

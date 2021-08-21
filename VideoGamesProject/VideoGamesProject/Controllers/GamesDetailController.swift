//
//  GamesDetailController.swift
//  VideoGamesProject
//
//  Created by Abdullah Coban on 20.07.2021.
//

import UIKit
import CoreData

class GamesDetailController: UIViewController {
    
    @IBOutlet weak var gameImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var FavoriteBtn: UIButton!
    @IBOutlet weak var notFavoriteBtn: UIButton!
    
    var id: Int = 0
    var game = GameDetail(id: 0, name: "", background_image: "", metacritic: 0, description_raw: "", released: "", rating: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        game = fetchGameWithId(id: id)
        nameLabel.text = game.name
        descriptionLabel.text = game.description_raw
        rateLabel.text = String(game.metacritic)
        dateLabel.text = game.released
        do {
            let url = URL(string: game.background_image)
            let data = try Data(contentsOf: url!)
            gameImg.image = UIImage(data: data)
        }
        catch {
            print("Image Error")
        }
        
        let check = checkFavorite(id: id)
        
        if check == true {
            notFavoriteBtn.alpha = 0
            FavoriteBtn.alpha = 1
        } else {
            notFavoriteBtn.alpha = 1
            FavoriteBtn.alpha = 0
        }
        
    }
    
    
    @IBAction func tappedFavoriteBtn(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        let favoriteItem = NSEntityDescription.insertNewObject(forEntityName: "Favorite", into: context)
        favoriteItem.setValue(id, forKey: "id")
        favoriteItem.setValue(true, forKey: "isFavorite")
        favoriteItem.setValue(game.name, forKey: "name")
        favoriteItem.setValue(game.background_image, forKey: "background_image")
        favoriteItem.setValue(game.released, forKey: "released")
        favoriteItem.setValue(game.rating, forKey: "rating")
        
        
        do {
            try context.save()
            notFavoriteBtn.alpha = 0
            FavoriteBtn.alpha = 1
        } catch  {
            print("Kaydedilemedi...")
        }
    }
    
    @IBAction func tappedNotFavoriteBtn(_ sender: Any) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        let predicate = NSPredicate(format: "id == \(id)")
        fetchRequest.predicate = predicate
        let result = try? context.fetch(fetchRequest)
        let resultData = result as! [Favorite]

           for object in resultData {
                context.delete(object)
           }

           do {
               try context.save()
               notFavoriteBtn.alpha = 1
               FavoriteBtn.alpha = 0
               print("saved!")
           } catch let error as NSError  {
               print("Could not save \(error), \(error.userInfo)")
           }
        
        
    }
    
    func fetchGameWithId(id: Int) -> GameDetail {
        
        let apiKey = "13a009d708da4805a552de5cec5b2908"
        let urlStr = "https://api.rawg.io/api/games/\(id)?key=\(apiKey)"
        
        guard let url = URL(string: urlStr) else {
            fatalError("Invalid URL")
        }
        
        let game = try? JSONDecoder().decode(GameDetail.self, from: Data(contentsOf: url))
        
        guard let game = game else { fatalError("No Data") }
        self.game = game

        return game
    }
    
    func checkFavorite(id: Int) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        let predicate = NSPredicate(format: "id == \(id)")
        fetchRequest.predicate = predicate
        let result = try? context.fetch(fetchRequest)
        let resultData = result as! [Favorite]
        
        if resultData.count > 0 {
            return true
        } else {
            return false
        }
        
    }

}

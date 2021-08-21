//
//  FavoriteGamesListViewController.swift
//  VideoGamesProject
//
//  Created by Abdullah Coban on 21.07.2021.
//

import UIKit
import CoreData

class FavoriteGamesListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var gameList = [Game]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavoriteGames()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favoriteGameDetail",
           let senderVC: GamesDetailController = segue.destination as? GamesDetailController {
            senderVC.id = sender as! Int
        }
    }
    
    private func getFavoriteGames() {
        gameList.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    guard let id = result.value(forKey: "id") as? Int else { return }
                    guard let name = result.value(forKey: "name") as? String else { return }
                    guard let background_image = result.value(forKey: "background_image") as? String else { return }
                    guard let rating = result.value(forKey: "rating") as? Double else { return }
                    guard let released = result.value(forKey: "released") as? String else { return }
                    self.gameList.append(Game(id: id, name: name, background_image: background_image, rating: rating, released: released))
                }
                self.tableView.reloadData()
            } else {
                
            }
        } catch {
            print("Error")
        }
        
    }
    
}

extension FavoriteGamesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if gameList.count == 0 {
            tableView.setEmptyView(title: "NOT FOUND", message: "Game is not found in favorite list.")
        } else {
            tableView.restore()
        }
        
        return gameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteGameCell", for: indexPath)
        
        let gameList = gameList[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = gameList.name
        do {
            let url = URL(string: gameList.background_image)
            let data = try Data(contentsOf: url!)
            cell.imageView?.image = UIImage(data: data)
        }
        catch {
            print("Image Error")
        }
        
        cell.imageView?.setImageOptions()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            print(gameList[indexPath.row].id)
            let id = gameList[indexPath.row].id
            let alert = UIAlertController(title: "Delete Game", message: "Are you sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in }))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                tableView.beginUpdates()
                self.gameList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
                
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
                       print("saved!")
                   } catch let error as NSError  {
                       print("Could not save \(error), \(error.userInfo)")
                   }
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "favoriteGameDetail", sender: gameList[indexPath.row].id)
    }
    
}

//
//  ViewController.swift
//  VideoGamesProject
//
//  Created by Abdullah Coban on 18.07.2021.
//

import UIKit
import Alamofire
import AlamofireImage

class ViewController: UIViewController {
    
    var games = GameList(next: "https://api.rawg.io/api/games?key=13a009d708da4805a552de5cec5b2908&page=1", results: [Game]())
    var gameList = [Game]()
    var filteredGames = [Game]()
    var isFiltering: Bool = false

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let next:String = ""
        games = fetchGames(next: next)
        gameList.append(contentsOf: games.results)
        tableView.dataSource = self
        
        //space between cell
        tableView.separatorColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 100.0
        
        //load more button
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: self.tableView.frame.width, height: 40)))
        button.setTitle("Load more", for: .normal)
        button.backgroundColor = .orange
        button.addTarget(self, action: #selector(moreButtonClicked(_:)), for: .touchUpInside)
        self.tableView.tableFooterView = button

        
    }
    
    @objc func moreButtonClicked(_ sender: UIButton) {
        games = fetchGames(next: games.next)
        gameList.append(contentsOf: games.results)
        tableView.reloadData()
    }
    
    func fetchGames(next: String) -> GameList {
        
        let urlStr: String
        let apiKey = "13a009d708da4805a552de5cec5b2908"
        
        if next == "" {
            urlStr = "https://api.rawg.io/api/games?key=\(apiKey)&page=1"
        } else {
            urlStr = next
        }
        
        
        guard let url = URL(string: urlStr) else {
            fatalError("Invalid URL")
        }
        
        let gameList = try? JSONDecoder().decode(GameList.self, from: Data(contentsOf: url))
        
        guard let games = gameList else { fatalError("No Data") }
        self.games = games
            
        return games
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameDetail" ,
           let senderVC: GamesDetailController = segue.destination as? GamesDetailController {
            senderVC.id = sender as! Int
        }
    }


}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredGames.count
        }
        
        return games.results.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell")
        
        let game: Game
        
        if isFiltering {
            game = filteredGames[indexPath.row]
        } else {
            game = games.results[indexPath.row]
        }
        
        cell?.textLabel?.text = game.name
        cell?.detailTextLabel?.text = "Rating: " + String(game.rating) + " - Released: " + game.released
        cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cell?.textLabel?.numberOfLines = 0
        
        do {
            let url = URL(string: game.background_image)
            let data = try Data(contentsOf: url!)
            cell?.imageView?.image = UIImage(data: data)
        }
        catch {
            print("Image Error")
        }

        cell?.imageView?.setImageOptions()
        
        //Border Code
        cell?.layer.borderWidth = 1.0
        cell?.layer.borderColor = UIColor.white.cgColor
        cell?.layer.cornerRadius = 10
        
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gameDetail", sender: games.results[indexPath.row].id)
    }


}

extension UIImageView {
    
    func setImageOptions() {
        
        let itemSize = CGSize.init(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        self.image!.draw(in: imageRect)
        self.image = UIGraphicsGetImageFromCurrentImageContext()!
        self.layer.cornerRadius = (self.frame.height) / 2
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.clipsToBounds = true
        UIGraphicsEndImageContext()
        
        
    }
    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredGames = games.results.filter({ (game: Game) -> Bool in
            return game.name.lowercased().contains(searchText.lowercased())
        })
        
        if filteredGames.count == 0 {
            tableView.setEmptyView(title: "NOT FOUND", message: "Game is not found.")
        }
        
        isFiltering = true
        tableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        searchBar.text = ""
        tableView.reloadData()
    }
}


extension UITableView {
    
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
}

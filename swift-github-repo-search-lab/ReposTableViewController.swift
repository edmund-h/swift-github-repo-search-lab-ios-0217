//
//  ReposTableViewController.swift
//  github-repo-starring-swift
//
//  Created by Haaris Muneer on 6/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ReposTableViewController: UITableViewController, ReposDataStoreDelegate {
    
    let store = ReposDataStore.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.delegate = self
        self.tableView.accessibilityLabel = "tableView"
        self.tableView.accessibilityIdentifier = "tableView"
        
//        store.getRepositories {
//            OperationQueue.main.addOperation({ 
//                self.tableView.reloadData()
//            })
//        }
        GithubAPIClient.starFunctions(task: GitHubFunctions.checkStarred, repoUrl:"immersedreality/swift-HelloToTheUniverse-lab-swift-intro-000" , completion: {resultCode in
            
            print("initial starCheck complete with code \(resultCode)")
            print ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
        })
        GithubAPIClient.searchForRepo("swift cocoa pods", completion: {})
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.store.repositories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repoCell", for: indexPath)

        let repository:GithubRepository = self.store.repositories[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = repository.fullName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repoDirectory = store.repositories[indexPath.row].fullName
        GithubAPIClient.starFunctions(task: GitHubFunctions.checkStarred, repoUrl: repoDirectory, completion: {
            responseCode in
            switch responseCode{
            case 404:
                GithubAPIClient.starFunctions(task: GitHubFunctions.addStar, repoUrl: repoDirectory, completion: { result in
                    print ("attempted starring with result:\(result)")
                    self.makeAlert(say: "You have starred \(repoDirectory)!")
                    print ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
                })
            case 204:
                GithubAPIClient.starFunctions(task: GitHubFunctions.unStar, repoUrl: repoDirectory, completion: { result in
                    print ("attempted unStarring with result:\(result)")
                    self.makeAlert(say: "You have un-starred \(repoDirectory)!")
                    print ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
                })
            default:
                print ("something has gone terribly wrong")
            }
        })
        
    }
    
    @IBAction func searchButton(_ sender: Any) {
        let searchAlert = UIAlertController (title: "Search", message: "Search for a git repository", preferredStyle: .alert)
        searchAlert.addTextField(configurationHandler:{
            newTextField in
            newTextField.placeholder = "Search"
        })
        self.present(searchAlert, animated: true, completion: {
            print("user notified: \(searchAlert.message)")
        })
        let okAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
            print ("user acknowledged message")
            if let text = searchAlert.textFields?[0].text{
                GithubAPIClient.searchForRepo(text, completion: {})
            }
        }
        searchAlert.addAction(okAction)
    }
}


extension ReposTableViewController {
    func makeAlert (say: String){
        let starredAlert = UIAlertController(title: "", message: say, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
            print ("user acknowledged message")
            return
        }
        starredAlert.addAction(okAction)
    }
    
    
    func newDataAdded(){
        self.tableView.reloadData()
    }
}

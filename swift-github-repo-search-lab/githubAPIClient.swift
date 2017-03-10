//
//  githubAPIClient.swift
//  swift-github-repo-search-lab
//
//  Created by Edmund Holderbaum on 3/9/17.
//  Copyright © 2017 Flatiron School. All rights reserved.
//

import Alamofire
import Foundation

class GithubAPIClient{
    
    class func getRepositories(with completion: @escaping ([Any]) -> ()) {
        let urlString = "\(githubAPIURL)/repositories?client_id=\(Secrets.client_id.rawValue)&client_secret=\(Secrets.client_secret.rawValue)"
        let url = URL(string: urlString)
        let session = URLSession.shared
        
        guard let unwrappedURL = url else { fatalError("Invalid URL") }
        let task = session.dataTask(with: unwrappedURL, completionHandler: { (data, response, error) in
            guard let data = data else { fatalError("Unable to get data \(error?.localizedDescription)") }
            
            if let responseArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                if let responseArray = responseArray {
                    completion(responseArray)
                }
            }
        })
        task.resume()
    }
    
    class func starFunctions(task: GitHubFunctions, repoUrl: String, completion: @escaping (Int)->() ){
        let urlString = "\(githubAPIURL)/user/starred/\(repoUrl)?access_token=\(Secrets.pers_token.rawValue)"
        let url = URL(string: urlString)
        let session = URLSession.shared
        guard let unwrappedURL = url else { fatalError("Invalid URL") }
        print ("URL check complete")
        var request = URLRequest(url: unwrappedURL)
        request.httpMethod = task.rawValue //add the appropriate HTTP Method based on enum
        
        print ("starFunction with \(request.httpMethod) on \(repoUrl)")
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data else { fatalError("Unable to get data \(error?.localizedDescription)") }
            print ("data received: \(data)")
            if let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:String] {
                
                if let responseDict = responseDict {
                    print(responseDict) //print dictionary contents if any
                }else {print("JSON serialization error")}
                
            }else {print ("no data received")}
            
            //print and return back the HTTP Status code (this is how github responds to star requests)
            let  responseCode = response as! HTTPURLResponse
            print ("with status \(responseCode.statusCode)")
            completion(responseCode.statusCode)
        })
        task.resume()
    }
    
    class func searchForRepo(_ searchString: String, completion: ()->()){
        let searchTerms = formatForSearch(searchString)
        let urlString = "\(githubAPIURL)/search/repositories?q=\(searchTerms)&access_token=\(Secrets.pers_token.rawValue)"
        Alamofire.request(urlString).validate().responseJSON { response in
            //print (response.description)
            if let data = response.result.value as? [String:Any]{
                //print ("data received: \(data)")
                guard let items = data["items"] as? [Any] else {print("no bueno ese"); return}
                ReposDataStore.sharedInstance.updateWithNewData(reposArray: items)
                print("updated repos")
            }
        }
    }
    
    fileprivate class func formatForSearch(_ searchString: String) -> String{
        let temp = searchString.components(separatedBy: CharacterSet(charactersIn: " ,./`!@#$%^&*()_{}|[]<>?:"))
        return temp.joined(separator: "+")
    }
    
    static var githubAPIURL = "https://api.github.com"
}


enum GitHubFunctions: String{
    case checkStarred = "GET"
    case addStar = "PUT"
    case unStar = "DELETE"
}
 

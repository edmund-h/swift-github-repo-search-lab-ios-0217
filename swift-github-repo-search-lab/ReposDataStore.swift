//
//  ReposDataStore.swift
//  github-repo-starring-swift
//
//  Created by Haaris Muneer on 6/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ReposDataStore {
    weak var delegate: ReposDataStoreDelegate!
    static let sharedInstance = ReposDataStore()
    fileprivate init() {}
    
    var repositories:[GithubRepository] = []
    
    func getRepositories(with completion: @escaping () -> ()) {
        GithubAPIClient.getRepositories { (reposArray) in
            self.updateWithNewData(reposArray: reposArray)
        }
        completion()
    }
    
    func updateWithNewData(reposArray: [Any]) {
        self.repositories.removeAll()
        for dictionary in reposArray {
            guard let repoDictionary = dictionary as? [String : Any] else { fatalError("Object in reposArray is of non-dictionary type") }
            let repository = GithubRepository(dictionary: repoDictionary)
            self.repositories.append(repository)
            print ("added a thing")
            delegate.newDataAdded()
        }
    }

}

protocol ReposDataStoreDelegate: class{
    func newDataAdded()
}

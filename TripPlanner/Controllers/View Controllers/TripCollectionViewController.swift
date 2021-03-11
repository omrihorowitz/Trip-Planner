//
//  TripCollectionViewController.swift
//  TripPlanner
//
//  Created by Theo Davis on 3/11/21.
//

import UIKit

let dataSource: [String] = ["test1", "test2", "test3", "test4", "test5", "test6", "test7"]

class TripCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

   
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        var cell = UICollectionViewCell()
        
        if let tripNameCell = collectionView.dequeueReusableCell(withReuseIdentifier: "tripCell", for: indexPath) as? TripCollectionViewCell {
            
            tripNameCell.configure(with: dataSource[indexPath.row])
            
            cell = tripNameCell
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Tapped Cell: \(dataSource[indexPath.row])")
    }
}//End of class

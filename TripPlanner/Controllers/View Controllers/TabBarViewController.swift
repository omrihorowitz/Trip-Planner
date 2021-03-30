//
//  TabBarViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers = [setUpFriendsVC(), setUpTripsVC(), setUpAccountVC()]
        addCancelKeyboardGestureRecognizer()
        tabBar.barTintColor = Colors.brown
        tabBar.unselectedItemTintColor = .white
        tabBar.tintColor = Colors.darkBlue
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setUpFriendsVC() -> UIViewController {
        let friendsVC = FriendsViewController()
        friendsVC.tabBarItem.image = UIImage(named: "popluarman")
        friendsVC.tabBarItem.title = "Friends"
        return friendsVC
    }
    
    private func setUpTripsVC() -> UIViewController {
        let TripsVC = TripsViewController()
        TripsVC.tabBarItem.image = UIImage(named: "roadicon")
        TripsVC.tabBarItem.title = "Trips"
        return TripsVC
    }
    
    private func setUpAccountVC() -> UIViewController {
        let AccountVC = AccountViewController()
        AccountVC.tabBarItem.image = UIImage(named: "accounticon")
        AccountVC.tabBarItem.title = "Account"
        return AccountVC
    }

}

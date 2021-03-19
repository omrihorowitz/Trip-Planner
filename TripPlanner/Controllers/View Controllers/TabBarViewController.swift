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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setUpFriendsVC() -> UIViewController {
        let friendsVC = FriendsViewController()
        friendsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 0)
        return friendsVC
    }
    
    private func setUpTripsVC() -> UIViewController {
        let TripsVC = TripsViewController()
        TripsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        return TripsVC
    }
    
    private func setUpAccountVC() -> UIViewController {
        let AccountVC = AccountViewController()
        AccountVC.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 2)
        return AccountVC
    }

}

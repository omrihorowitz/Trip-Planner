import UIKit

protocol MemberSelectedDelegate: AnyObject {
    func memberAdded(members: [String])
}

class ModalTableViewController: UITableViewController {
    
    var members: [String] = []{
        didSet{
            filterFriends()
            loadViewIfNeeded()
            tableView.reloadData()
        }
    }
    var friends: [User] = []
    var delegate: MemberSelectedDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MemberTableViewCell.self, forCellReuseIdentifier: MemberTableViewCell.cellID)
        addCancelKeyboardGestureRecognizer()
    }
    
    
    func filterFriends() {
        UserController.shared.fetchFriends()
        friends = UserController.shared.friends.filter({!members.contains($0.email)})
        
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemberTableViewCell.cellID) as? MemberTableViewCell else { return UITableViewCell() }
        
        cell.set(user: friends[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let friendSelected = friends[indexPath.row]
        
        if UserController.shared.someoneHasBlockedThisPerson(personToCheck: friendSelected, membersInTrip: members) {
            //show pop up
            presentAlertOnMainThread(title: "Uh oh", message: "Someone in the group blocked this member! You can't add them to this trip.", buttonTitle: "Ok")
            return
        } else {
            //add them
            members.append(friendSelected.email)
            delegate?.memberAdded(members: members)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

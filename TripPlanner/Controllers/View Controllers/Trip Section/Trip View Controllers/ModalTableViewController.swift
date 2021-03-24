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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "addFriends")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriends", for: indexPath)
        
        cell.textLabel?.text = friends[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friendSelected = friends[indexPath.row]
        members.append(friendSelected.email)
        delegate?.memberAdded(members: members)
        
        
        dismiss(animated: true, completion: nil)
        
    }
}

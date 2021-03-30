//
//  TripDetailViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//
import MapKit
import UIKit

class TripDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var trip: Trip? {
        didSet {
            loadViewIfNeeded()
            loadTrip()
        }
    }
    
    //colors
    let drkPurple = UIColor(red: 60/255, green: 33/255, blue: 173/255, alpha: 1)
    let medPurple = UIColor(red: 105/255, green: 66/255, blue: 194/255, alpha: 1)
    let lgtPurple = UIColor(red: 176/255, green: 167/255, blue: 247/255, alpha: 1)
    let text = UIColor(red: 218/255, green: 224/255, blue: 239/255, alpha: 1)
    let accentColor = UIColor(red: 86/255, green: 79/255, blue: 80/255, alpha: 1)
    
    
    
    var originLong: Double?
    var destinationLong: Double?
    
    var originLat: Double?
    var destinationLat: Double?
    
    var members: [String] = []
    var tasks: [String] = []
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let ownerLabel = UILabel()
    
    let testLabel = UILabel()
    
    let tripNameLabel = UILabel()
    let tripNameTextField = UITextField()
    
    let membersLabel = UILabel()
    let memberTableView = UITableView()
    let addPeopleButton = TPButton()
    
    let startDateLabel = UILabel()
    let endDateLabel = UILabel()
    let startDate = UIDatePicker()
    let endDate = UIDatePicker()
    let destinationButton = TPButton()
    
    let taskTableView = UITableView()
    let taskButton = TPButton()
    
    let notesLabel = UILabel()
    let notesTextView = UITextView()
    
    let saveButton = TPButton()
    
    static let defaultMKMapItem = MKMapItem()
    let defaultRoute = Route(origin: defaultMKMapItem, stops: [defaultMKMapItem])
    
    // MARK: - LifeCyle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.lightBlue
        setupViews()
        addCancelKeyboardGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.barTintColor = Colors.lightBrown
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            if trip?.owner == UserController.shared.currentUser?.email{
                saveButtonTapped()
            }else if (trip == nil){
                saveButtonTapped()
            } else if trip == nil {
                saveButtonTapped()
            }
        } else {
            navigationController?.navigationBar.barTintColor = .white
        }
    }
    
    func loadTrip() {
        guard let trip = trip else { return }
        
        
        tripNameTextField.text = trip.name
        startDate.date = trip.startDate
        endDate.date = trip.endDate
        notesTextView.text = trip.notes
        originLong = trip.originLong
        originLat = trip.originLat
        destinationLong = trip.destinationLong
        destinationLat = trip.destinationLat
        
        if trip.owner != UserController.shared.currentUser?.email {
            tripNameTextField.isUserInteractionEnabled = false
            startDate.isUserInteractionEnabled = false
            endDate.isUserInteractionEnabled = false
            addPeopleButton.isUserInteractionEnabled = false
            notesTextView.isUserInteractionEnabled = false
            taskButton.isUserInteractionEnabled = false
            saveButton.isUserInteractionEnabled = false
            memberTableView.isUserInteractionEnabled = false
            taskTableView.isUserInteractionEnabled = false
        }
        
        //If we are the owner of the trip, just put current users name up there
        if trip.owner == UserController.shared.currentUser?.email {
            ownerLabel.text = "Trip Owner: \(UserController.shared.currentUser?.name ?? "Unknown")"
            ownerLabel.font = UIFont(name: "AmericanTypeWriter-Bold", size: 30)
        } else {
            // users = [User]
            // trip owner: String
            let tripOwner = UserController.shared.users.filter({$0.email == trip.owner}).first
            
            ownerLabel.text = "Creator: \(tripOwner?.name ?? "Unknown")"
        }
        
        
    }
    
    func setupViews(){
        setupScrollView()
        setupOwnerLabel()
        setupTripNameTextFeild()
        setupFriendTable()
        setupDestinationInfo()
        setupTaskTable()
        setupTaskButton()
        setupNotesLabel()
        setupTextView()
        setUpColorsForLabels()
        setFontsForButtons()
    }
    
    // MARK: - Constraint Methods
    func setUpColorsForLabels() {
        for label in [tripNameLabel, membersLabel, ownerLabel, startDateLabel, endDateLabel] {
            label.textColor = Colors.darkBrown
        }
    }
    
    func setFontsForButtons() {
        for button in [addPeopleButton, taskButton, destinationButton] {
            button.titleLabel?.font = UIFont(name: "AmericanTypeWriter-Bold", size: 20)
        }
    }
    
    func setupScrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.backgroundColor = Colors.lightBrown
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
    
    func setupOwnerLabel() {
        ownerLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(ownerLabel)
        ownerLabel.text = "New Trip"
        ownerLabel.textColor = Colors.darkBlue
        ownerLabel.font = UIFont(name: "AmericanTypeWriter-Bold", size: 20)
        ownerLabel.textAlignment = .center
        ownerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        ownerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        ownerLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
    }
    
    func setupTripNameTextFeild() {
        tripNameLabel.translatesAutoresizingMaskIntoConstraints = false
        tripNameTextField.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(tripNameLabel)
        scrollView.addSubview(tripNameTextField)
        
        tripNameLabel.text = "Trip Name"
        tripNameLabel.textColor = Colors.darkBlue
        tripNameLabel.font = UIFont(name: "AmericanTypeWriter-Bold", size: 20)
        tripNameLabel.topAnchor.constraint(equalTo: ownerLabel.bottomAnchor, constant: 20).isActive = true
        tripNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        tripNameTextField.placeholder = "Enter trip name..."
        tripNameTextField.backgroundColor = Colors.lightBrown
        tripNameTextField.textColor = Colors.darkBlue
        tripNameTextField.textAlignment = .center
        tripNameTextField.font = UIFont(name: "AmericanTypeWriter-Bold", size: 20)
        tripNameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        tripNameTextField.autocorrectionType = UITextAutocorrectionType.no
        tripNameTextField.keyboardType = UIKeyboardType.default
        tripNameTextField.returnKeyType = UIReturnKeyType.done
        tripNameTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        tripNameTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        tripNameTextField.topAnchor.constraint(equalTo: tripNameLabel.bottomAnchor, constant: 10).isActive = true
        tripNameTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        let widthConstraint = tripNameTextField.widthAnchor.constraint(equalToConstant: 250)
        widthConstraint.priority = UILayoutPriority.defaultHigh
        widthConstraint.isActive = true
    }
    
    func setupFriendTable() {
        membersLabel.translatesAutoresizingMaskIntoConstraints = false
        memberTableView.translatesAutoresizingMaskIntoConstraints = false
        addPeopleButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(membersLabel)
        scrollView.addSubview(memberTableView)
        scrollView.addSubview(testLabel)
        scrollView.addSubview(addPeopleButton)
        
        membersLabel.text = "Members"
        membersLabel.textColor = Colors.darkBlue
        membersLabel.font = UIFont(name: "AmericanTypeWriter-Bold", size: 20)
        membersLabel.textAlignment = .center
        membersLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        membersLabel.topAnchor.constraint(equalTo: tripNameTextField.bottomAnchor, constant: 25).isActive = true
        membersLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        
        memberTableView.rowHeight = 100
        memberTableView.delegate = self
        memberTableView.dataSource = self
        memberTableView.backgroundColor = Colors.lightBrown
        memberTableView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        memberTableView.register(MemberTableViewCell.self, forCellReuseIdentifier: MemberTableViewCell.cellID)
        memberTableView.topAnchor.constraint(equalTo: membersLabel.bottomAnchor, constant: 20).isActive = true
        memberTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        memberTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        addPeopleButton.setTitle("Add Member", for: .normal)
        addPeopleButton.backgroundColor = Colors.darkBlue
        addPeopleButton.addTarget(self, action: #selector(showModal), for: .touchUpInside)
        addPeopleButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        addPeopleButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        addPeopleButton.topAnchor.constraint(equalTo: memberTableView.bottomAnchor, constant: 25).isActive = true
        addPeopleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 70).isActive = true
        addPeopleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70).isActive = true
        
    }
    
    func setupDestinationInfo(){
        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
        endDateLabel.translatesAutoresizingMaskIntoConstraints = false
        startDate.translatesAutoresizingMaskIntoConstraints = false
        endDate.translatesAutoresizingMaskIntoConstraints = false
        destinationButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(startDateLabel)
        scrollView.addSubview(endDateLabel)
        scrollView.addSubview(startDate)
        scrollView.addSubview(endDate)
        scrollView.addSubview(destinationButton)
        
        startDateLabel.text = "Start Date"
        startDateLabel.font = UIFont(name: "AmericanTypeWriter-Bold", size: 20)
        startDateLabel.textColor = Colors.darkBlue
        startDateLabel.topAnchor.constraint(equalTo: addPeopleButton.bottomAnchor, constant: 20).isActive = true
        startDateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        startDate.timeZone = NSTimeZone.local
        startDate.tintColor = Colors.lightBlue
        startDate.backgroundColor = Colors.darkBlue
        startDate.datePickerMode = .date
        startDate.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 10).isActive = true
        startDate.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        endDateLabel.text = "End Date"
        endDateLabel.font = UIFont(name: "AmericanTypeWriter-Bold", size: 20)
        endDateLabel.textColor = Colors.darkBlue
        endDateLabel.topAnchor.constraint(equalTo: startDate.bottomAnchor, constant: 20).isActive = true
        endDateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        endDate.timeZone = NSTimeZone.local
        endDate.tintColor = Colors.lightBlue
        endDate.datePickerMode = .date
        endDate.backgroundColor = Colors.darkBlue
        endDate.topAnchor.constraint(equalTo: endDateLabel.bottomAnchor, constant: 10).isActive = true
        endDate.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        destinationButton.setTitle("Plan Route", for: .normal)
        destinationButton.backgroundColor = Colors.darkBlue
        destinationButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        destinationButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        destinationButton.topAnchor.constraint(equalTo: endDate.bottomAnchor, constant: 20).isActive = true
        destinationButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        destinationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 70).isActive = true
        destinationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70).isActive = true
        destinationButton.addTarget(self, action: #selector(goToMap), for: .touchUpInside)
        
    }
    
    @objc func goToMap() {
        
        let map = MapViewController()
        
        map.modalPresentationStyle = .fullScreen
        map.delegate = self
        if let trip = self.trip {
            map.trip = trip
        } else if let originLong = originLong, let originLat = originLat, let destinationLong = destinationLong, let destinationLat = destinationLat {
            map.originLong = originLong
            map.originLat = originLat
            map.destinationLong = destinationLong
            map.destinationLat = destinationLat
        }
        
        navigationController?.pushViewController(map, animated: true)
    }
    
    func setupTaskTable() {
        taskTableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(taskTableView)
        taskTableView.rowHeight = 40
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.backgroundColor = Colors.lightBrown
        taskTableView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        taskTableView.register(UITableViewCell.self, forCellReuseIdentifier: "task")
        taskTableView.topAnchor.constraint(equalTo: destinationButton.bottomAnchor, constant: 25).isActive = true
        taskTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        taskTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
    }
    
    func setupTaskButton() {
        taskButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(taskButton)
        taskButton.setTitle("Add Task", for: .normal)
        taskButton.backgroundColor = Colors.darkBlue
        taskButton.addTarget(self, action: #selector(showTaskAlert), for: .touchUpInside)
        taskButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        taskButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        taskButton.topAnchor.constraint(equalTo: taskTableView.bottomAnchor, constant: 25).isActive = true
        taskButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 70).isActive = true
        taskButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70).isActive = true
    }
    
    func setupNotesLabel() {
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(notesLabel)
        notesLabel.text = "Notes:"
        notesLabel.textColor = Colors.darkBrown
        notesLabel.font = UIFont(name: "AmericanTypeWriter-Bold", size: 20)
        notesLabel.textAlignment = .center
        notesLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        notesLabel.topAnchor.constraint(equalTo: taskButton.bottomAnchor, constant: 20).isActive = true
        notesLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
    }
    
    func setupTextView() {
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(notesTextView)
        notesTextView.center = self.view.center
        notesTextView.textAlignment = .justified
        notesTextView.backgroundColor = Colors.lightBrown
        notesTextView.font = UIFont(name: "AmericanTypewriter-Bold", size: 16)
        notesTextView.isSelectable = true
        notesTextView.dataDetectorTypes = .link
        notesTextView.layer.cornerRadius = 10
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = Colors.darkBrown?.cgColor
        notesTextView.textColor = Colors.darkBlue
        notesTextView.autocorrectionType = .yes
        notesTextView.spellCheckingType = .yes
        notesTextView.autocapitalizationType = .none
        notesTextView.isEditable = true
        
        NSLayoutConstraint.activate([
            notesTextView.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 15),
            notesTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            notesTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -250),
            notesTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc func showModal() {
        let modalTableViewController = ModalTableViewController()
        modalTableViewController.delegate = self
        if (trip != nil){
            modalTableViewController.members = trip?.members ?? []
        }else {
            modalTableViewController.members = members
        }
        
        modalTableViewController.modalPresentationStyle = .automatic
        present(modalTableViewController, animated: true, completion: nil)
    }
    
    @objc func showTaskAlert() {
        let alert = UIAlertController(title: "Enter task", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter task here..."
            textField.font = UIFont(name: "AmericanTypeWriter-Bold", size: 15)
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            guard let newTask = alert.textFields?.first?.text, !newTask.isEmpty else { return }
            if (self.trip != nil) {
                if let tasks = self.trip?.tasks {
                    self.trip?.tasks?.append(newTask)
                } else {
                    self.trip?.tasks = [newTask]
                }
            } else {
                self.tasks.append(newTask)
            }
            self.taskTableView.reloadData()
        }))
        
        self.present(alert, animated: true)
    }
    
    
    @objc func saveButtonTapped() {
        
        guard let name = tripNameTextField.text, !name.isEmpty, let originLong = originLong, let originLat = originLat, let destinationLat = destinationLat, let destinationLong = destinationLong else {
            self.presentAlertOnMainThread(title: "Uh oh", message: "Please fill out all fields & choose a route in order to save.", buttonTitle: "Ok")
            return
        }
        
        guard let owner = UserController.shared.currentUser?.email else { return }
        
        if var trip = trip {
            //update trip
            
            trip.destinationLong = destinationLong
            trip.destinationLat = destinationLat
            trip.originLong = originLong
            trip.originLat = originLat
            
            trip.name = name
            
            trip.startDate = startDate.date
            trip.endDate = endDate.date
            
            if let notes = notesTextView.text {
                trip.notes = notes
            }
            
            TripController.shared.updateTrip(trip: trip) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(_):
                    self.presentAlertOnMainThread(title: "Uh Oh!", message: "Cannot update trip at this time. Check internet and try again later", buttonTitle: "Ok")
                }
            }
        } else {
            let newTrip = Trip(originLong: originLong, originLat: originLat, destinationLong: destinationLong, destinationLat: destinationLat, locationNames: nil, members: members, id: nil, name: name, notes: notesTextView.text, owner: owner, tasks: tasks, startDate: startDate.date, endDate: endDate.date)
            
            TripController.shared.addTrip(trip: newTrip) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(_):
                    self.presentAlertOnMainThread(title: "Uh Oh!", message: "Cannot add trip at this time. Check internet and try again later", buttonTitle: "Ok")
                }
            }
        }
        
        
    }
    
}

extension TripDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == taskTableView {
            if (trip != nil) {
                guard let tasks = trip?.tasks else { return 0 }
                return tasks.count
            } else {
                return tasks.count
            }
        }
        
        if tableView == memberTableView{
            if (trip != nil){
                //guard let trip = self.trip else { return 0 }
                guard let members = trip?.members else { return 0 }
                return members.count
            }else {
                return members.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == memberTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MemberTableViewCell.cellID) as? MemberTableViewCell else {return UITableViewCell()}
            if (trip != nil){
                guard let members = trip?.members else {return UITableViewCell()}
                if UserController.shared.currentUser?.email == trip?.owner {
                    UserController.shared.fetchFriends()
                    let currentMember = members[indexPath.row]
                    let matchingFriend = UserController.shared.friends.filter({$0.email == currentMember})[0]
                    cell.set(user: matchingFriend)
                    cell.backgroundColor = Colors.lightBrown
                } else {
                    let currentMembersEmail = members[indexPath.row]
                    
                    if currentMembersEmail == UserController.shared.currentUser?.email {
                        guard let currentUser = UserController.shared.currentUser else { return UITableViewCell () }
                        cell.set(user: currentUser)
                    } else {
                        let currentMemberAsUser = UserController.shared.users.filter({$0.email == currentMembersEmail})[0]
                        
                        cell.set(user: currentMemberAsUser)
                    }
                    
                    
                }
            } else {
                UserController.shared.fetchFriends()
                let currentMember = members[indexPath.row]
                let matchingFriend = UserController.shared.friends.filter({$0.email == currentMember})[0]
                cell.set(user: matchingFriend)
            }
            cell.isUserInteractionEnabled = false
            cell.backgroundColor = Colors.lightBrown
            return cell
        } else if tableView == taskTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "task") else { return UITableViewCell() }
            if (trip != nil) {
                guard let tasks = trip?.tasks else { return UITableViewCell() }
                cell.textLabel?.text = tasks[indexPath.row]
            } else {
                cell.textLabel?.text = tasks[indexPath.row]
            }
            cell.backgroundColor = Colors.lightBrown
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = Colors.darkBlue
            cell.textLabel?.font = UIFont(name: "AmericanTypewriter-Bold", size: 18)
            return cell
        }
        return UITableViewCell()
}
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if tableView == taskTableView {
                if (trip != nil) {
                    self.trip?.tasks?.remove(at: indexPath.row)
                } else {
                    self.tasks.remove(at: indexPath.row)
                }
                taskTableView.deleteRows(at: [indexPath], with: .fade)
            } else if tableView == memberTableView {
                if (trip != nil){
                    self.trip?.members?.remove(at: indexPath.row)
                }else {
                    self.members.remove(at: indexPath.row)
                }
                memberTableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == memberTableView {
            return 100
        } else {
            return 50
        }
    }
}

extension TripDetailViewController : MapViewGoButtonPressedDelegate {
    func updateCoordinates(originLong: Double, originLat: Double, destinationLong: Double, destinationLat: Double) {
        
        self.originLong = originLong
        self.originLat = originLat
        self.destinationLong = destinationLong
        self.destinationLat = destinationLat
        
        print(originLong, originLat, destinationLat, destinationLong)
        
    }
}

extension TripDetailViewController: MemberSelectedDelegate {
    func memberAdded(members: [String]) {
        if (trip != nil){
            trip?.members = members
        }else {
            self.members = members
        }
        DispatchQueue.main.async {
            self.memberTableView.reloadData()
        }
    }
}

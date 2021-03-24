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
    let addPeopleButton = UIButton()
    
    let tripDatesLabel = UILabel()
    let startDate = UIDatePicker()
    let endDate = UIDatePicker()
    let destinationButton = UIButton()
    
    let taskTableView = UITableView()
    let taskButton = UIButton()
    
    let notesTextView = UITextView()
    
    let saveButton = UIButton()
    
    static let defaultMKMapItem = MKMapItem()
    let defaultRoute = Route(origin: defaultMKMapItem, stops: [defaultMKMapItem])
    
    // MARK: - LifeCyle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        addCancelKeyboardGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
        
    }
    
    func setupViews(){
        setupScrollView()
        setupOwnerLabel()
        setupTripNameTextFeild()
        setupFriendTable()
        setupDestinationInfo()
        setupTaskTable()
        setupTaskButton()
        setupTextView()
        setupSaveButton()
    }
    
    // MARK: - Constraint Methods
    func setupScrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
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
        ownerLabel.text = "Owner"
        ownerLabel.textAlignment = .center
        ownerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        ownerLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        ownerLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
    }
    
    func setupTripNameTextFeild() {
        tripNameLabel.translatesAutoresizingMaskIntoConstraints = false
        tripNameTextField.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(tripNameLabel)
        scrollView.addSubview(tripNameTextField)
        
        tripNameLabel.text = "Trip Name:"
        tripNameLabel.topAnchor.constraint(equalTo: ownerLabel.bottomAnchor, constant: 25).isActive = true
        tripNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        
        tripNameTextField.placeholder = "Enter trip name..."
        tripNameTextField.font = UIFont.systemFont(ofSize: 15)
        tripNameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        tripNameTextField.autocorrectionType = UITextAutocorrectionType.no
        tripNameTextField.keyboardType = UIKeyboardType.default
        tripNameTextField.returnKeyType = UIReturnKeyType.done
        tripNameTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        tripNameTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        tripNameTextField.topAnchor.constraint(equalTo: ownerLabel.bottomAnchor, constant: 20).isActive = true
        tripNameTextField.leadingAnchor.constraint(equalTo: tripNameLabel.trailingAnchor, constant: 15).isActive = true
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
        membersLabel.textAlignment = .center
        membersLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        membersLabel.topAnchor.constraint(equalTo: tripNameTextField.bottomAnchor, constant: 25).isActive = true
        membersLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        
        memberTableView.rowHeight = 40
        memberTableView.delegate = self
        memberTableView.dataSource = self
        memberTableView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        memberTableView.register(UITableViewCell.self, forCellReuseIdentifier: "friend")
        memberTableView.topAnchor.constraint(equalTo: membersLabel.bottomAnchor, constant: 25).isActive = true
        memberTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        memberTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        addPeopleButton.setTitle("Add Member", for: .normal)
        addPeopleButton.backgroundColor = .black
        addPeopleButton.addTarget(self, action: #selector(showModal), for: .touchUpInside)
        addPeopleButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        addPeopleButton.topAnchor.constraint(equalTo: memberTableView.bottomAnchor, constant: 25).isActive = true
        addPeopleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 70).isActive = true
        addPeopleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70).isActive = true
        
    }
    
    func setupDestinationInfo(){
        tripDatesLabel.translatesAutoresizingMaskIntoConstraints = false
        startDate.translatesAutoresizingMaskIntoConstraints = false
        endDate.translatesAutoresizingMaskIntoConstraints = false
        destinationButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(tripDatesLabel)
        scrollView.addSubview(startDate)
        scrollView.addSubview(endDate)
        scrollView.addSubview(destinationButton)
        
        startDate.timeZone = NSTimeZone.local
        startDate.backgroundColor = UIColor.white
        startDate.datePickerMode = .date
        startDate.topAnchor.constraint(equalTo: addPeopleButton.bottomAnchor, constant: 25).isActive = true
        startDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        
        endDate.timeZone = NSTimeZone.local
        endDate.datePickerMode = .date
        endDate.topAnchor.constraint(equalTo: addPeopleButton.bottomAnchor, constant: 25).isActive = true
        endDate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        
        destinationButton.setTitle("Plan Route", for: .normal)
        destinationButton.backgroundColor = .black
        destinationButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        destinationButton.topAnchor.constraint(equalTo: endDate.bottomAnchor, constant: 25).isActive = true
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
        }
        navigationController?.pushViewController(map, animated: true)
    }
    
    func setupTaskTable() {
        taskTableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(taskTableView)
        taskTableView.rowHeight = 40
        taskTableView.delegate = self
        taskTableView.dataSource = self
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
        taskButton.backgroundColor = .black
        taskButton.addTarget(self, action: #selector(showTaskAlert), for: .touchUpInside)
        taskButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        taskButton.topAnchor.constraint(equalTo: taskTableView.bottomAnchor, constant: 25).isActive = true
        taskButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 70).isActive = true
        taskButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70).isActive = true
        //taskButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -20).isActive = true
    }
    
    func setupTextView() {
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(notesTextView)
        notesTextView.center = self.view.center
        notesTextView.textAlignment = .justified
        notesTextView.backgroundColor = .lightGray
        notesTextView.font = .systemFont(ofSize: 20)
        notesTextView.isSelectable = true
        notesTextView.dataDetectorTypes = .link
        notesTextView.layer.cornerRadius = 10
        notesTextView.autocorrectionType = .yes
        notesTextView.spellCheckingType = .yes
        notesTextView.autocapitalizationType = .none
        notesTextView.isEditable = true
        
        NSLayoutConstraint.activate([
            notesTextView.topAnchor.constraint(equalTo: taskButton.bottomAnchor, constant: 25),
            notesTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            notesTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(saveButton)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .black
        saveButton.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 25).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
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
            self.presentAlertOnMainThread(title: "Uh oh", message: "Please fill out all fields & choose a route", buttonTitle: "Ok")
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "friend") else {return UITableViewCell()}
            if (trip != nil){
                guard let members = trip?.members else {return UITableViewCell()}
                UserController.shared.fetchFriends()
                let currentMember = members[indexPath.row]
                let matchingFriend = UserController.shared.friends.filter({$0.email == currentMember})[0]
                cell.textLabel?.text = matchingFriend.name
            } else {
                UserController.shared.fetchFriends()
                let currentMember = members[indexPath.row]
                let matchingFriend = UserController.shared.friends.filter({$0.email == currentMember})[0]
                cell.textLabel?.text = matchingFriend.name
            }
            return cell
        } else if tableView == taskTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "task") else { return UITableViewCell() }
            if (trip != nil) {
                guard let tasks = trip?.tasks else { return UITableViewCell() }
                cell.textLabel?.text = tasks[indexPath.row]
            } else {
                cell.textLabel?.text = tasks[indexPath.row]
            }
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

//
//  TripDetailViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit

class TripDetailViewController: UIViewController {
    
    // MARK: - Properties
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let ownerLabel = UILabel()
    
    let testLabel = UILabel()
    
    let tripNameLabel = UILabel()
    let tripNameTextField = UITextField()
    
    let friendLabel = UILabel()
    let tableView = UITableView()
    let addPeopleButton = UIButton()
    
    let tripDatesLabel = UILabel()
    let startDate = UIDatePicker()
    let endDate = UIDatePicker()
    let destinationButton = UIButton()
    
    let taskTableView = UITableView()
    let taskButton = UIButton()
    
    let textView = UITextView()
    
    let saveButton = UIButton()
    
    
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
        friendLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addPeopleButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(friendLabel)
        scrollView.addSubview(tableView)
        scrollView.addSubview(testLabel)
        scrollView.addSubview(addPeopleButton)
        
        friendLabel.text = "Friends"
        friendLabel.textAlignment = .center
        friendLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        friendLabel.topAnchor.constraint(equalTo: tripNameTextField.bottomAnchor, constant: 25).isActive = true
        friendLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        
        tableView.rowHeight = 40
        tableView.delegate = self
        tableView.dataSource = self
        tableView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "friend")
        tableView.topAnchor.constraint(equalTo: friendLabel.bottomAnchor, constant: 25).isActive = true
        tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        addPeopleButton.setTitle("Add Friend", for: .normal)
        addPeopleButton.backgroundColor = .black
        addPeopleButton.addTarget(self, action: #selector(showModal), for: .touchUpInside)
        addPeopleButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        addPeopleButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 25).isActive = true
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
        
        destinationButton.setTitle("Add Destination", for: .normal)
        destinationButton.backgroundColor = .black
        destinationButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        destinationButton.topAnchor.constraint(equalTo: endDate.bottomAnchor, constant: 25).isActive = true
        destinationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 70).isActive = true
        destinationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70).isActive = true
        
        destinationButton.addTarget(self, action: #selector(goToMap), for: .touchUpInside)
        
    }
    
     @objc func goToMap() {
        let map = MainMapViewController()
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
        textView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(textView)
        textView.center = self.view.center
        textView.textAlignment = .justified
        textView.backgroundColor = .lightGray
        textView.font = .systemFont(ofSize: 20)
        textView.isSelectable = true
        textView.dataDetectorTypes = .link
        textView.layer.cornerRadius = 10
        textView.autocorrectionType = .yes
        textView.spellCheckingType = .yes
        textView.autocapitalizationType = .none
        textView.isEditable = true
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: taskButton.bottomAnchor, constant: 25),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(saveButton)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .black
        saveButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 25).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
    }
    
    @objc func showModal() {
        let modalTableViewController = ModalTableViewController()
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

        }))

        self.present(alert, animated: true)
    }
    
}

extension TripDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableView,
           let cell = tableView.dequeueReusableCell(withIdentifier: "friend")  {
            cell.textLabel?.text = "Friend"
            return cell
        } else if tableView == taskTableView,
                  let cell = tableView.dequeueReusableCell(withIdentifier: "task")  {
            cell.textLabel?.text = "Task"
            return cell
        }
        
        return UITableViewCell()
    }
}

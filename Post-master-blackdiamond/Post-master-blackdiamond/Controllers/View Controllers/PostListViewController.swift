//
//  PostListViewController.swift
//  Post-New
//
//  Created by Eric Lanza on 11/28/18.
//  Copyright © 2018 ETLanza. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    let postController = PostController()
    
    // Creating a refreshControl
    var refreshControl = UIRefreshControl()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting table view datasource and delegate
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setting tableViewCells dynamic heights
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        
        // Setting up refresh control for tableView
        tableView.refreshControl = refreshControl
        
        // Setting refreshControl to call the refreshControlPulled function when user swipes down on the top of the tableView
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    
    // MARK: - IBActions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
    }
    
    // MARK: - Helper Methods
    @objc func refreshControlPulled() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // New Post Alert Controller
    func presentNewPostAlert() {
        let newPostAlertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        
        var usernameTextField = UITextField()
        newPostAlertController.addTextField { (usernameTF) in
            usernameTF.placeholder = "Enter username..."
            usernameTextField = usernameTF
        }
        
        var messageTextField = UITextField()
        newPostAlertController.addTextField { (messageTF) in
            messageTF.placeholder = "Enter message..."
            messageTextField = messageTF
        }
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (postAction) in
            guard let username = usernameTextField.text, !username.isEmpty,
                let text = messageTextField.text, !text.isEmpty else {
                    return
            }
            self.postController.addNewPostWith(username: username, text: text, completion: {
                DispatchQueue.main.async {
                    
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        newPostAlertController.addAction(postAction)
        newPostAlertController.addAction(cancelAction)
        
        self.present(newPostAlertController, animated: true, completion: nil)
    }
    
    // Missing info error alert
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Missing info", message: "Make sure both text fields are filled out", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Custom Reload Table View Function
    func reloadTableView() {
        DispatchQueue.main.async {
            // Add networkActivityIndiator to the reloadView function
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.username) - " + "\(post.date ?? "")"
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate Methods
    
    // MARK: - Black Diamond - Report Funtionality
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reportAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: .destructive) { (_) in
            // This is where you would do something when a post gets reported.
            // Typically you could send an email to your apps "Customer Support" and then you can handle it on the firebase backend.
            // Optionally, you could build in logic that once a post gets reported a certain amount of times, it automatically gets hidden or deleted.  We won't do that for this project, but don't forget this option come time for Group and Capstone projects.
        }
        
        reportAlertController.addAction(reportAction)
        reportAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(reportAlertController, animated: true, completion: nil)
    }
}

// MARK: - Special Thanks to Steve and Greg for fixing this pagination issue!
extension PostListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= (postController.posts.count - 1){
            let preFetchCount = postController.posts.count
            postController.fetchPosts(reset: false) {
                
                let postFetchCount = self.postController.posts.count
                
                if preFetchCount == postFetchCount {
                    print("\(preFetchCount)")
                    print("\(postFetchCount)")
                } else {
                    self.postController.fetchPosts(reset: false) {
                        self.reloadTableView()
                        
                        print("\(preFetchCount)")
                        print("\(postFetchCount)")
                    }
                }
            }
        }
    }
}

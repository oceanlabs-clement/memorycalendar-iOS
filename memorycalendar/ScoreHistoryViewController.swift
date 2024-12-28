//
//  ScoreHistoryViewController.swift
//  memorycalendar
//
//  Created by Clement Gan on 28/12/2024.
//

import UIKit

class ScoreHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    var scores: [[String: Any]] = []  // Array to store score records
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadScores()
    }
    
    // Set up the UI components (Table View)
    func setupUI() {
        view.backgroundColor = .white
        
        title = "Score History"
        
        // Setup Table View
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScoreCell.self, forCellReuseIdentifier: "ScoreCell")
        tableView.rowHeight = 80  // Set a fixed height for each row
        view.addSubview(tableView)
    }
    
    // Load saved scores from UserDefaults
    func loadScores() {
        // Fetch the saved scores array from UserDefaults
        if let savedScores = UserDefaults.standard.array(forKey: "scores") as? [[String: Any]] {
            // Limit to the latest 20 scores
            scores = Array(savedScores.prefix(20))
        }
        
        // Reload the table view to display the scores
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
        
        // Get the score data for this row
        let scoreData = scores[indexPath.row]
        let score = scoreData["score"] as? Int ?? 0
        let timeLeft = scoreData["time"] as? Int ?? 0
        let date = scoreData["date"] as? Date ?? Date()
        
        // Format the date nicely (Month, Year, Time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy, h:mm a"  // Format as "Dec 2024, 1:45 PM"
        let formattedDate = dateFormatter.string(from: date)
        
        // Set the data on the cell
        cell.configure(score: score, timeLeft: timeLeft, date: formattedDate)
        
        return cell
    }
}

class ScoreCell: UITableViewCell {
    
    var scoreLabel: UILabel!
    var timeLabel: UILabel!
    var dateLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Initialize and configure the labels
        scoreLabel = UILabel()
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 18)
        scoreLabel.textAlignment = .left
        contentView.addSubview(scoreLabel)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        timeLabel.textAlignment = .right
        contentView.addSubview(timeLabel)
        
        dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textAlignment = .center
        contentView.addSubview(dateLabel)
        
        // Set up auto-layout for labels
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Score Label (Top-left corner)
            scoreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            scoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            // Time Label (Top-right corner)
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // Date Label (Centered at the second line from the bottom)
            dateLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure the cell with score, time left, and date
    func configure(score: Int, timeLeft: Int, date: String) {
        scoreLabel.text = "Score: \(score)"
        timeLabel.text = "Time Left: \(timeLeft)"
        dateLabel.text = "Date: \(date)"
    }
}

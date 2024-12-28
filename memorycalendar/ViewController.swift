//
//  ViewController.swift
//  memorycalendar
//
//  Created by Clement Gan on 26/12/2024.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // UI Elements
    var scoreLabel: UILabel!
    var timerLabel: UILabel!
    var quitButton: UIButton!
    var score = 0
    var timeLeft = 60  // Example timer value
    var gradientLayer: CAGradientLayer!
    
    var collectionView: UICollectionView!
    var questionLabel: UILabel!
    var answerTextField: UITextField!
    var feedbackLabel: UILabel!
    var submitButton: UIButton!
    
    // Game data
    var calendarDates = [
        1: "Team Meeting", 2: "Doctor Visit", 3: "Sarah Birthday", 4: "Tech Talk",
        5: "Lunch Break", 6: "Team Outing", 7: "Dentist Check", 8: "Dinner Date",
        9: "Yoga Class", 10: "Team Call", 11: "Grocery Run", 12: "Family Trip",
        13: "Hair Cut", 14: "Catch Up", 15: "Wedding Dinner", 16: "Art Workshop",
        17: "Live Concert", 18: "Movie Night", 19: "Football Game", 20: "Lunch Meet",
        21: "Movie Night", 22: "Ski Trip", 23: "Museum Tour", 24: "Business Lunch",
        25: "Camping Fun", 26: "Work Event", 27: "Friends Meetup", 28: "Birthday Party",
        29: "Art Class", 30: "Weekend Trip"
    ]
    
    var shuffledEvents: [String] = []
    
    var currentQuestionDay: Int?
    var isMemoryPhase = true
    var timer: Timer?
    var eventHideTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startTimer()
        startMemoryPhase()
        navigationItem.hidesBackButton = true  // Hide back button on game screen
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        // Create and apply the gradient background
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.lightBlue.cgColor,  // Light blue (sky)
            UIColor.darkBlue.cgColor    // Darker blue (horizon)
        ]
        gradientLayer.locations = [0.0, 1.0]  // Start at the top, end at the bottom
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Score Label (Top Left)
        scoreLabel = UILabel(frame: CGRect(x: 20, y: 60, width: 100, height: 40))
        scoreLabel.text = "Score: 0"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(scoreLabel)
        
        // Timer Label (Top Right)
        timerLabel = UILabel(frame: CGRect(x: view.frame.width - 120, y: 60, width: 100, height: 40))
        timerLabel.text = "Time: 60"
        timerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(timerLabel)
        
        
        
//        // UICollectionView Setup for Calendar
//        let layout = UICollectionViewFlowLayout()
//        let itemSize = (view.frame.width - 40) / 7  // Cell size calculation based on screen width and 7 days
//        layout.itemSize = CGSize(width: itemSize, height: itemSize)
//        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//        layout.minimumLineSpacing = 10
//        layout.minimumInteritemSpacing = 10
//        
//        collectionView = UICollectionView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.width), collectionViewLayout: layout)
//        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        view.addSubview(collectionView)
        
        // Setup UICollectionView for the calendar grid
        let layout = UICollectionViewFlowLayout()
        
        // Increase the height of the cells (make them taller)
        let cellSize = (view.frame.width - 40) / 7  // Keeping the width the same
        let cellHeight = cellSize * 1.5  // Increase height (e.g., 1.5 times the width)
        
        layout.itemSize = CGSize(width: cellSize, height: cellHeight)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // Create the UICollectionView with the updated layout
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.width), collectionViewLayout: layout)
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        // Setup the question label
        questionLabel = UILabel(frame: CGRect(x: 20, y: collectionView.frame.maxY + 20, width: view.frame.width - 40, height: 50))
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 20)
        questionLabel.numberOfLines = 0
        view.addSubview(questionLabel)
        
        // Setup the answer text field
        answerTextField = UITextField(frame: CGRect(x: 20, y: questionLabel.frame.maxY + 10, width: view.frame.width - 40, height: 40))
        answerTextField.borderStyle = .roundedRect
        answerTextField.placeholder = "Enter your answer"
        answerTextField.isHidden = true
        view.addSubview(answerTextField)
        
        // Setup the submit button
        submitButton = UIButton(type: .system)
        submitButton.frame = CGRect(x: 20, y: answerTextField.frame.maxY + 10, width: view.frame.width - 40, height: 40)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.layer.cornerRadius = 25
        submitButton.layer.borderWidth = 2
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)  // Increased font size
        submitButton.isHidden = true
        submitButton.addTarget(self, action: #selector(submitAnswer), for: .touchUpInside)
        view.addSubview(submitButton)
        
        // Setup feedback label
        feedbackLabel = UILabel(frame: CGRect(x: 20, y: submitButton.frame.maxY + 10, width: view.frame.width - 40, height: 40))
        feedbackLabel.textAlignment = .center
        feedbackLabel.font = UIFont.systemFont(ofSize: 18)
        feedbackLabel.isHidden = true
        view.addSubview(feedbackLabel)
        
        // Quit Button (Bottom Center)
        quitButton = UIButton(type: .system)
        quitButton.frame = CGRect(x: (view.frame.width - 200) / 2, y: view.frame.height - 100, width: 200, height: 50)
        quitButton.setTitle("Quit Game", for: .normal)
        quitButton.layer.cornerRadius = 25
        quitButton.layer.borderWidth = 2
        quitButton.layer.borderColor = UIColor.white.cgColor
        quitButton.setTitleColor(.white, for: .normal)
        quitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)  // Increased font size
        quitButton.addTarget(self, action: #selector(quitGame), for: .touchUpInside)
        view.addSubview(quitButton)
    }
    
    func startMemoryPhase() {
        // Shuffle events
        shuffledEvents = Array(calendarDates.values).shuffled()

        // Randomly assign events to days
        var shuffledCalendarDates: [Int: String] = [:]
        let shuffledDays = Array(calendarDates.keys).shuffled()

        for (index, day) in shuffledDays.enumerated() {
            shuffledCalendarDates[day] = shuffledEvents[index]
        }

        // Replace original calendarDates with the shuffled one
        calendarDates = shuffledCalendarDates
        
        // Start memory phase
        isMemoryPhase = true
        questionLabel.text = "Memorize the calendar for the next 5 seconds..."
        collectionView.reloadData()

        // Hide answer UI and wait for a few seconds before asking questions
        answerTextField.isHidden = true
        submitButton.isHidden = true
        feedbackLabel.isHidden = true

        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(startQuestionPhase), userInfo: nil, repeats: false)
    }
    
    @objc func startQuestionPhase() {
        // Ensure the calendar events are hidden when the question phase starts
        isMemoryPhase = false
        questionLabel.text = "What event was on day \(currentQuestionDay ?? 1)?"
        
        // Show answer UI
        answerTextField.isHidden = false
        submitButton.isHidden = false
        feedbackLabel.isHidden = true
        
        // Generate a random day
        currentQuestionDay = Int.random(in: 1...30)
        
        // Reload the collection view to hide events in the question phase
        collectionView.reloadData()
    }
    
    @objc func submitAnswer() {
        guard let answer = answerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !answer.isEmpty else {
            feedbackLabel.text = "Please enter a valid answer."
            feedbackLabel.textColor = .red
            feedbackLabel.isHidden = false
            return
        }
        
        // Get the correct event for the day
        if let event = calendarDates[currentQuestionDay ?? 1] {
            // Compare case-insensitive and allow extra spaces to be ignored
            if event.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).contains(answer) {
                feedbackLabel.text = "Correct! Well done."
                feedbackLabel.textColor = .green
            } else {
                feedbackLabel.text = "Incorrect! The correct answer was: \(event)"
                feedbackLabel.textColor = .red
            }
        }
        
        feedbackLabel.isHidden = false
        answerTextField.text = ""
        
        // Continue with a new question after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.startQuestionPhase()
        }
    }
    
    // Timer Logic
    func startTimer() {
        // Only start the timer once when the game begins
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        // Start event hiding after 5 seconds (hide event labels after memory phase)
        eventHideTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hideEventTitles), userInfo: nil, repeats: false)
    }
    
    @objc func updateTimer() {
        if timeLeft > 0 {
            timeLeft -= 1
            timerLabel.text = "Time: \(timeLeft)"
        } else {
            timer?.invalidate()  // Stop the timer when time is up
            endGame()
        }
    }
    
    @objc func hideEventTitles() {
        // After 5 seconds, hide the event titles from the calendar
        isMemoryPhase = false
        collectionView.reloadData()  // Reload data to hide event titles
    }
    
    @objc func quitGame() {
        let alert = UIAlertController(title: "Quit Game", message: "Are you sure you want to quit?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { _ in
            self.saveScoreAndTime()
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveScoreAndTime() {
        var scores = UserDefaults.standard.array(forKey: "scores") as? [[String: Any]] ?? []
        
        let scoreData: [String: Any] = ["score": score, "time": timeLeft, "date": Date()]
        scores.append(scoreData)
        
        UserDefaults.standard.set(scores, forKey: "scores")
    }
    
    func endGame() {
        // End game logic, e.g., show final score and time
        saveScoreAndTime()
    }

    
    // UICollectionView DataSource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30  // Days of the month (simplified to 30 days)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        let day = indexPath.row + 1
        cell.label.text = "\(day)"
        
        // Show event text if it exists for that day
        if let event = calendarDates[day] {
            cell.eventLabel.text = event
        } else {
            cell.eventLabel.text = ""
        }
        
        // Hide event label during the question phase
        cell.eventLabel.isHidden = isMemoryPhase == false
        
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout method (optional)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 40) / 7, height: (view.frame.width - 40) / 7)
    }
}


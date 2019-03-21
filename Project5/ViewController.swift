//
//  ViewController.swift
//  Project5
//
//  Created by Arash Zakeresfahani on 3/19/19.
//  Copyright © 2019 Arash Zakeresfahani. All rights reserved.
//

import UIKit


class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.rightBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(propmtForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty{
            allWords = ["Empty"]
        }
        startGame()
    }
    
   @objc func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row].lowercased()
        return cell
    }
    
    @objc func propmtForAnswer(){
        
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submiteAction = UIAlertAction(title: "Submit", style: .default){
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        ac.addAction(submiteAction)
        present(ac, animated: true)
        
    }

    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up, you know!"
                    showErrorMassage(title: errorTitle, message: errorMessage)
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
                showErrorMassage(title: errorTitle, message: errorMessage)
            }
        } else {
            guard let title = title?.lowercased() else { return }
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title.lowercased())"
            showErrorMassage(title: errorTitle, message: errorMessage)
        }
    }
    
    func isPossible(word: String) -> Bool{
        guard var tempWord = title?.lowercased() else{ return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            }else{
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool{
        return !usedWords.contains(word.lowercased())
    }
    
    func isReal(word: String) -> Bool {
        if word.count >= 3 {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    
        }else{ return false}
    }
    func showErrorMassage(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}


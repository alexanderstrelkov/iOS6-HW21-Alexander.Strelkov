//
//  ViewController.swift
//  iOS6-HW15-Alexander.Strelkov
//
//  Created by Alexandr Strelkov on 11.07.2022.
//

import UIKit

class ViewController: UIViewController {
    
    var isStopped: Bool = false
        
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!
    @IBAction func searchPasswordButton(_ sender: UIButton) {
        self.stopButton.isEnabled = true
        self.bruteForce(passwordToUnlock: textField.text ?? "")
    }
    @IBAction func generateButton(_ sender: UIButton) {
        textField.text = "\(randomPasswordGenerate())"
    }
    @IBOutlet weak var clearButton: UIButton!
    @IBAction func clearButton(_ sender: UIButton) {
        textField.text = ""
        label.text = ""
        textField.isSecureTextEntry = true
        isStopped = false
        clearButton.isEnabled = false
    }
    @IBOutlet weak var stopButton: UIButton!
    @IBAction func stopButton(_ sender: UIButton) {
        isStopped = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        textField.isSecureTextEntry = true
        clearButton.isEnabled = false
        stopButton.isEnabled = false
    }
    
    func randomPasswordGenerate() -> String {
        let passwordLength = 3
        let passwordCharacters =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        let randomPassword = String((0..<passwordLength).compactMap{ _ in passwordCharacters.randomElement() })
        return randomPassword
    }
    
    func bruteForce(passwordToUnlock: String) {
        let mainQueue = DispatchQueue.main
        mainQueue.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }

        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async {
            let ALLOWED_CHARACTERS: [String] = String().printable.map { String($0) }
            var password: String = ""
            while password != passwordToUnlock && !self.isStopped {
                password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
                mainQueue.async {
                    self.label.text = "Hacking.. \(password)"
                    if password == passwordToUnlock {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.textField.isSecureTextEntry = false
                        self.label.text = "Hacked! Password: \(password)"
                        self.clearButton.isEnabled = true
                        self.stopButton.isEnabled = false
                    }
                }
                if self.isStopped {
                    mainQueue.async {
                        self.activityIndicator.isHidden = true
                        self.label.text = "Password \(password) is not hacked!"
                        self.clearButton.isEnabled = true
                    }
                    break
                }
            }
        }
    }
}

extension String {
    var digits: String { return "0123456789" }
    var lowercase: String { return "abcdefghijklmnopqrstuvwxyz" }
    var uppercase: String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    var punctuation: String { return "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" }
    var letters: String { return lowercase + uppercase }
    var printable: String { return digits + letters + punctuation }
    
    mutating func replace(at index: Int, with character: Character) {
        var stringArray = Array(self)
        stringArray[index] = character
        self = String(stringArray)
    }
}

func indexOf(character: Character, _ array: [String]) -> Int {
    return array.firstIndex(of: String(character))!
}

func characterAt(index: Int, _ array: [String]) -> Character {
    return index < array.count ? Character(array[index])
    : Character("")
}

func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
    var str: String = string
    
    if str.count <= 0 {
        str.append(characterAt(index: 0, array))
    }
    else {
        str.replace(at: str.count - 1,
                    with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))
        
        if indexOf(character: str.last!, array) == 0 {
            str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
        }
    }
    return str
}

//
//  ContentView.swift
//  WordScramble
//
//  Created by Yashavika Singh on 04.06.24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var allWords = [String]()
    @State private var errorMessage = ""
    @State private var errorTitle = ""
    @State private var showingError = false
    @State private var score = 0
    
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter a word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    ForEach(usedWords, id: \.self){
                        word in
                        HStack
                        {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
                Section{
                    Text("Your score: \(score)")
                }
            }
            .navigationTitle(rootWord )
            .onSubmit() {  addNewWord()    }
            .onAppear(perform:  startGame)
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
            
            .toolbar(content: {
               Button("Restart", action: restartGame)
            })

        }

    }
    
    
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines )
        guard answer.count > 0 else {return}
        
        guard isLongerThan2(word: answer) else
        {
            wordError(title: "Too Short", message: "Only words that are three letters or more allowed")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        
        guard isNotStartWord(word: answer) else{
            wordError(title: "there's no bug here", message: "don't use the start word")
            return
        }
      
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        
      withAnimation{
            usedWords.insert(answer, at: 0 )
        }
        score += answer.count
        newWord = ""
        
         
    }
    
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                
                     allWords = startWords.components(separatedBy: "\n")
                    rootWord = allWords.randomElement() ?? "silkworm"
                    return
                }
            }
        fatalError("could not load start.txt")
        }
    
            
            func isNotStartWord(word: String) -> Bool{
            return word != rootWord
            }
    
    
    func restartGame()
    {
        rootWord = allWords.randomElement() ?? "silkworm"
        usedWords = [String]()
        score = 0
    }
    
    
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    func isLongerThan2(word: String) -> Bool
    {
        return word.count > 2
    }
    
        
    func isOriginal(word: String ) -> Bool{
        !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
  
    
    
}

#Preview {
    ContentView()
}


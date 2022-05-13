//
//  ContentView.swift
//  SwiftParsing
//
//  Created by Дмитрий Смирнов on 06.12.2021.
//

import SwiftUI
import SwiftSoup

func test() {
    
    let myUrlString: String = "https://soccer365.ru"
    //guard let myURL = URL(string: myUrlString) else { return }
    //let myURL: URL = URL(string: myUrlString) ?? "error"
    let myURL = URL(string: myUrlString)
    
    do {
        let myHTMLString = try String(contentsOf: myURL!, encoding: .utf8)
        print(myHTMLString)
    } catch let error {
        print("Error: \(error)")
    }
    
}

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
    
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

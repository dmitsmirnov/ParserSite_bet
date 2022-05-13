import UIKit
import SwiftSoup

var greeting = "Hello, playground"

class Match {
    
    let id: String
    let title: String
    let link: String
    let time: String
    let league: String
    
    init(id: String, title: String, link: String, time: String, league: String) {
        self.id = id
        self.title = title
        self.link = link
        self.time = time
        self.league = league
    }
    
}

func test() {
    
    let myUrlString: String = "https://soccer365.ru/online/&tab=3"
    //guard let myURL = URL(string: myUrlString) else { return }
    //let myURL: URL = URL(string: myUrlString) ?? "error"
    let myURL = URL(string: myUrlString)
    
    do {
        let myHTMLString = try String(contentsOf: myURL!, encoding: .utf8)
        do {
            let doc = try SwiftSoup.parse(myHTMLString)
            do {
                let result_data = try doc.getElementById("result_data")
                do {
                    
                    let arrayLinks = try result_data?.getElementsByClass("live_comptt_bd").array()
                    
                    var matchs: [Match] = []
                    for x in arrayLinks! {
                        
                        let time = try x.getElementsByClass("status").text()
                        
                        //if time == "Завершен" {
                        //    continue
                        //}
                        
                        let i = try x.getElementsByClass("game_link")
                        
                        let league_span = try x.getElementsByClass("img16").select("span").first()!
                        let league = try league_span.text()
                        
                        if league == "Товарищеский" {
                            continue
                        }
                        
                        let link  = try i.attr("href")
                        let title = try i.attr("title")
                        let id    = try i.attr("dt-id")
                        
                        let match = Match(id: id, title: title, link: link, time: time, league: league)
                        matchs.append(match)
                        //break
                        
                    }
                    
                    var globalResults: [Match] = []
                    
                    for match in matchs {
                        let URLMatch = URL(string: "https://soccer365.ru/games/" + match.id)
                        print(match.title)
                        
                        do {
                            let HTMLMatchString = try String(contentsOf: URLMatch!, encoding: .utf8)
                            
                            do {
                                let doc2 = try SwiftSoup.parse(HTMLMatchString)
                                
                                do {
                                    let gm_block = try doc2.getElementsByClass("gm_block inline-block").html()
                                    
                                    do {
                                        let live = try SwiftSoup.parse(gm_block)
                                        
                                        let live_left = try live.getElementsByClass("live_block_hf").html()
                                        //let live_right = try live.getElementsByClass("live_block_hf right").html()
                                        
                                        let ht = try SwiftSoup.parse(live_left)
                                        let ht_el = try ht.getElementsByClass("ht").array()
                                        let at_el = try ht.getElementsByClass("at").array()
                                        
                                        var goals_ht: [String] = []
                                        var goals_at: [String] = []
                                        
                                        for i in ht_el {
                                            let goal_ht = try i.getElementsByClass("gls").text()
                                            goals_ht.append(goal_ht)
                                        }
                                        
                                        for i in at_el {
                                            let goal_at = try i.getElementsByClass("gls").text()
                                            goals_at.append(goal_at)
                                        }
                                        
                                        
                                        if goals_at.count > 2 && goals_ht.count > 2 {
                                            if (goals_ht[0] == "0" && goals_at[0] == "0") && (goals_ht[1] == "0" && goals_at[1] == "0") {
                                                globalResults.append(match)
                                                print("222")
                                            }
                                        }
                                        
                                        if goals_at.count > 5 && goals_ht.count > 5 {
                                            if (goals_ht[5] == "0" && goals_at[5] == "0") && (goals_ht[6] == "0" && goals_at[6] == "0") {
                                                globalResults.append(match)
                                                print(2)
                                            }
                                        }
                                        
                                        
                                    }
                                }
                                
                            }
                        }
                    }
                    for x in globalResults {
                        print(x.title)
                    }
                }
            }
        }
        
    } catch let error {
        print("Error: \(error)")
    }
    
}

test()

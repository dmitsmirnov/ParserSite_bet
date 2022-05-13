import UIKit
import SwiftSoup

enum DayNight {
    case day
    case night
}

enum TypeOfMatch {
    case DZ
    case OZ
    case EO
    case MX
}

class Match {
    
    let id: String
    let title: String
    let link: String
    var description: String = ""
    var country: String = ""
    var league: String = ""
    var time: String = ""
    //var typeOfMatch: TypeOfMatch? = nil
    var typeOfMatch: String = ""
    var timeOfGoal: Int = 0
    var interval: Int = 0
    var scored1: Double = 0
    var scored2: Double = 0
    var missed1: Double = 0
    var missed2: Double = 0
    
// scored1/scored2
//    var ei: Double {
//        return (self.scored1 + self.scored2) / 2
//    }
//
//    var x5: Double {
//        return (self.scored1 + self.missed1) - (self.scored2 - self.missed2)
//    }
//
//    var x6: Double {
//        return self.x5 / ((self.scored1 + self.scored2) / 2)
//    }
    
    var index: Double {
        return ((self.missed1 / self.scored1) + (self.missed2 / self.scored2)) / 4
    }
    
    init(id: String, title: String, link: String, time: String) {
        self.id = id
        self.title = title
        self.link = link
        self.time = time
    }
    
}

func searchCountry (href_club: String, match: Match) {
    
//    search counrty
//    let live_game_ht = try doc2.getElementsByClass("live_game_ht").select("a")
//    let href_club = try live_game_ht.attr("href")

    do {
        let url_club = URL(string: "https://soccer365.ru" + href_club)
        let HTMLClub = try String(contentsOf: url_club!, encoding: .utf8)
        let doc3 = try SwiftSoup.parse(HTMLClub)
        
        let params_comp = try doc3.getElementsByClass("params_comp noborder").select("a")
        let href_county = try params_comp.attr("href")
        
        let league = try doc3.getElementsByClass("params_comp noborder").select("span").text()
        
        let url_country = URL(string: "https://soccer365.ru" + href_county)
        let HTMLCountry = try String(contentsOf: url_country!, encoding: .utf8)
        let doc4 = try SwiftSoup.parse(HTMLCountry)
        
        let profile_params = try doc4.getElementsByClass("profile_params")
        let country = try profile_params.select("span").text()
        
        match.country = country
        match.league = league
        
    } catch let error {
        print(error)
    }

}


func GetTime(time: String, format: String) -> DayNight{
    
    //var a = "20.12.21, 08:00"
    // 22.12, 21:00

    let dateF = DateFormatter()
    //dateF.dateFormat = "dd.MM, HH:mm"
    dateF.dateFormat = format
    //dateF.dateFormat = "dd.MM.yy, HH:mm"
    dateF.timeZone = TimeZone(abbreviation: "UTC")
    let newdate = dateF.date(from: time)

    if newdate != nil {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        
        let hour = calendar.component(.hour, from: newdate!)
        //let min = calendar.component(.minute, from: newdate)
        
        switch hour {
        case 8...23:
        //case 0...8:
            return DayNight.day
        default:
            return DayNight.night
        }
        
    } else {
        return DayNight.day
    }
    
}

enum Errors: Error {
    case nilInGoal
    case nilInPengoal
}

func SearchTimeOfGoal(href_match: String, match: Match) throws {
    
    var array:[Int] = []
    let pattern = "^[^+,']*"
    
    do {
        let url_match = URL(string: href_match)
        //let url_match = URL(string: "https://soccer365.ru/games/1405182/")
        let HTMLMatch = try String(contentsOf: url_match!, encoding: .utf8)
        let doc = try SwiftSoup.parse(HTMLMatch)
        
        // just goal
        let div_goal = try doc.getElementsByClass("live_goal").first()
        //print(div_goal)
        //print(type(of: div_goal))
        let a1 = div_goal?.parent()
        //print(a1)
        //print(type(of: a1))
        let b1 = a1?.parent()
        //print(b1)
        //print(type(of: b1))
        let min1 = try b1?.getElementsByClass("event_min").text()
        //print(min1)
        //print(type(of: min1))
        //let min1:String? = "45+2"
        
        //var q = min1!
        
        if let time1 = min1 {
            if let res = time1.range(of: pattern, options: .regularExpression) {
                //print(time1[res])
                array.append(Int(time1[res])!)
            }
            //let test = try! NSRegularExpression(pattern: pattern)
            //let range = NSRange(location: 0, length: x.utf16.count)
            //test.firstMatch(in: x, options: [], range: range) != nil
        }
        
        // penalty goal
        let div_pengoal = try doc.getElementsByClass("live_pengoal").first()
        let a2 = div_pengoal?.parent()
        let b2 = a2?.parent()
        let min2 = try b2?.getElementsByClass("event_min").text()
        
        if let time2 = min2 {
            if let res = time2.range(of: pattern, options: .regularExpression) {
                array.append(Int(time2[res])!)
            }
        }
        
        // own goal
        let div_owngoal = try doc.getElementsByClass("live_owngoal").first()
        let a3 = div_owngoal?.parent()
        let b3 = a3?.parent()
        let min3 = try b3?.getElementsByClass("event_min").text()
        
        if let time3 = min3 {
            if let res = time3.range(of: pattern, options: .regularExpression) {
                array.append(Int(time3[res])!)
            }
        }
        
        array.sort(by: < )
        if array.count > 0 {
            match.timeOfGoal = array[0]
        } else {
            match.timeOfGoal = 999
        }

        switch match.timeOfGoal {
        case 1...15:
            match.interval = 15
        case 16...30:
            match.interval = 30
        case 31...45:
            match.interval = 45
        case 46...60:
            match.interval = 60
        case 61...75:
            match.interval = 75
        case 76...90:
            match.interval = 90
        default:
            // error
            match.interval = 999
        }

    } catch let error {
        print(error)
    }
    
}

//do {
//    try SearchTimeOfGoal(href_match: "", match: Match(id: "", title: "test", link: "123", time: "12:00"))
//} catch let error {
//    print(error)
//}

func GetScoredMissed(href_match: String, match: Match) {
    
    do {
        let url_match = URL(string: href_match + "/&tab=form_teams")
        //let url_match = URL(string: "https://soccer365.ru/games/1665645/&tab=form_teams")
        let HTMLMatch = try String(contentsOf: url_match!, encoding: .utf8)
        let doc = try SwiftSoup.parse(HTMLMatch)
        
        // just goal
        let td_array = try doc.getElementsByTag("td").array()
        let text1: String = "Забито голов за игру"
        let text2: String = "Пропущено голов за игру"
        
        for i in td_array {
            if try i.text() == text1 {
                //print(try i.text())
                let parent = i.parent()
                let tr_array = parent?.children().array()
                //var x: Int = 0
                //x = try Int(tr_array![0].text())!
                match.scored1 = try Double(tr_array![0].text())!
                match.scored2 = try Double(tr_array![2].text())!
//                for x in tr_array! {
//                    if try x.text() == text1 {
//                        continue
//                    }
//                    //print(try x.text())
//
//                }
            } else if try i.text() == text2 {
                let parent = i.parent()
                let tr_array = parent?.children().array()
                match.missed1 = Double(try tr_array![0].text())!
                match.missed2 = Double(try tr_array![2].text())!
//                for x in tr_array! {
//                    if try x.text() == text2 {
//                        continue
//                    }
//                    //print(try x.text())
//                }
            }
        }
    

    } catch let error {
        print(error)
    }
    
}

//GetScoredMissed(href_match: "", match: Match(id: "", title: "", link: "", time: ""))

func SearchMatсhes(month: String, day: String) {
    
    //let myUrlString: String = "https://soccer365.ru/online/&tab=3"
    let myUrlString: String = "https://soccer365.ru/online/&date=2022-\(month)-\(day)&tab=3"
    let myURL = URL(string: myUrlString)
    do {
        let myHTMLString = try String(contentsOf: myURL!, encoding: .utf8)
        let doc = try SwiftSoup.parse(myHTMLString)
        
        let game_link = try doc.getElementsByClass("game_link").array()
        var matchs: [Match] = []
        for game in game_link {
            
            let link  = try game.attr("href")
            let title = try game.attr("title")
            let id    = try game.attr("dt-id")
            
            // only day
            //let value = try h2_html?.text()
            // if day = now day that size11, else size10
            let atrTime = try game.getElementsByClass("size11")
            let time = try atrTime.text()
            
            //print(type(of: time))
            // check on night
            let timeOfDay: DayNight = GetTime(time: time, format: "HH:mm")
            
            if timeOfDay == DayNight.day {
                if time.contains("Отменен") == false || time.contains("Перенесен") == false {
                    let match = Match(id: id, title: title, link: link, time: time)
                    matchs.append(match)
                }
            }
            
            //break
            
        }
        
        var results_dZ: [Match] = []
        var results_oZ: [Match] = []
        var results_EO_dZ: [Match] = []
        
        var results_MX: [Match] = []
        
        // only one for chanal
        var results_oO: [Match] = []
        
        print("Matches found - \(matchs.count)")
        print("------")
        
        for match in matchs {
            
            do {
                //let match = Match(id: "1576461", title: "test", link: "test")
                
                //sleep(1)
                usleep(150000)
                
                let URLMatch = URL(string: "https://soccer365.ru/games/" + match.id)
                //let URLMatch = URL(string: "https://soccer365.ru/games/1576369/")
                let HTMLMatchString = try String(contentsOf: URLMatch!, encoding: .utf8)
                let doc2 = try SwiftSoup.parse(HTMLMatchString)
                
                let ht_el = try doc2.getElementsByClass("ht").array()
                let at_el = try doc2.getElementsByClass("at").array()
                
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
                
                
                if goals_at.count == 10 && goals_ht.count == 10 {
                    
                    // results only 2-(0-0)
                    if goals_at.count > 2 && goals_ht.count > 2 {
                        if (goals_ht[0] == "0" && goals_at[0] == "0") && (goals_ht[1] == "0" && goals_at[1] == "0") {
                            let h2_html = try doc2.select("h2").first()
                            let value = try h2_html?.text()
                            match.description = value!
                            
                            let live_game_ht = try doc2.getElementsByClass("live_game_ht").select("a")
                            let href_club = try live_game_ht.attr("href")
                            searchCountry(href_club: href_club, match: match)
                            
                            results_dZ.append(match)
                            match.typeOfMatch = "DZ"
                            GetScoredMissed(href_match: "https://soccer365.ru/games/" + match.id, match: match)
                        }
                    }
                    
                    if goals_at.count > 5 && goals_ht.count > 5 {
                        if (goals_ht[5] == "0" && goals_at[5] == "0") && (goals_ht[6] == "0" && goals_at[6] == "0") {
                            let h2_html = try doc2.select("h2").first()
                            let value = try h2_html?.text()
                            match.description = value!
                            
                            let live_game_ht = try doc2.getElementsByClass("live_game_ht").select("a")
                            let href_club = try live_game_ht.attr("href")
                            searchCountry(href_club: href_club, match: match)
                            
                            results_dZ.append(match)
                            match.typeOfMatch = "DZ"
                            GetScoredMissed(href_match: "https://soccer365.ru/games/" + match.id, match: match)
                        }
                    }
               
                    // results 1-(0-0)
                    if (goals_ht[0] == "0" && goals_at[0] == "0") && (goals_ht[5] == "0" && goals_at[5] == "0") {
                        let h2_html = try doc2.select("h2").first()
                        let value = try h2_html?.text()
                        match.description = value!
                        
                        let live_game_ht = try doc2.getElementsByClass("live_game_ht").select("a")
                        let href_club = try live_game_ht.attr("href")
                        searchCountry(href_club: href_club, match: match)
                        
                        results_oZ.append(match)
                        match.typeOfMatch = "OZ"
                        GetScoredMissed(href_match: "https://soccer365.ru/games/" + match.id, match: match)
                    }
                    
                    // only one for channel
                    if goals_at.count > 1 && goals_ht.count > 1 {
                        
                        if (goals_ht[0] == "0" && goals_at[0] == "0") {
                            let h2_html = try doc2.select("h2").first()
                            let value = try h2_html?.text()
                            match.description = value!
                            
                            let live_game_ht = try doc2.getElementsByClass("live_game_ht").select("a")
                            let href_club = try live_game_ht.attr("href")
                            searchCountry(href_club: href_club, match: match)
                            
                            results_oO.append(match)
                            match.typeOfMatch = "Only One"
                            //GetScoredMissed(href_match: "https://soccer365.ru/games/" + match.id, match: match)
                        }
                    }
                    
                    // each other
                    let URL_EachOther = URL(string: "https://soccer365.ru/games/" + match.id + "/&tab=stats_games")
                    let HTMLEachOtherString = try String(contentsOf: URL_EachOther!, encoding: .utf8)
                    let doc3 = try SwiftSoup.parse(HTMLEachOtherString)
                    
                    let ht3_el = try doc3.getElementsByClass("ht").array()
                    let at3_el = try doc3.getElementsByClass("at").array()
                    
                    var goals_ht3: [String] = []
                    var goals_at3: [String] = []
                    
                    if ht3_el.count > 1 && at3_el.count > 1 {
                        
                        for i in 0...1 {
                            let goal_ht3 = try ht3_el[i].getElementsByClass("gls").text()
                            goals_ht3.append(goal_ht3)
                        }
                        
                        for i in 0...1 {
                            let goal_at3 = try at3_el[i].getElementsByClass("gls").text()
                            goals_at3.append(goal_at3)
                        }
                        
                        if (goals_ht3[0] == "0" && goals_at3[0] == "0")
                            && (goals_ht3[1] == "0" && goals_at3[1] == "0") {
                            let h3_html = try doc3.select("h2").first()
                            let value3 = try h3_html?.text()
                            match.description = value3!
                            
                            let live_game_ht3 = try doc3.getElementsByClass("live_game_ht").select("a")
                            let href_club3 = try live_game_ht3.attr("href")
                            searchCountry(href_club: href_club3, match: match)
                            
                            results_EO_dZ.append(match)
                            match.typeOfMatch = "EO"
                            GetScoredMissed(href_match: "https://soccer365.ru/games/" + match.id, match: match)
                        
                            // only one for channel
                        } else if (goals_ht3[0] == "0" && goals_at3[0] == "0") {
                            let h3_html = try doc3.select("h2").first()
                            let value3 = try h3_html?.text()
                            match.description = value3!
                            
                            let live_game_ht3 = try doc3.getElementsByClass("live_game_ht").select("a")
                            let href_club3 = try live_game_ht3.attr("href")
                            searchCountry(href_club: href_club3, match: match)
                            
                            results_oO.append(match)
                            match.typeOfMatch = "Only One"
                            //GetScoredMissed(href_match: "https://soccer365.ru/games/" + match.id, match: match)
                        }
                        
                    }
                }
                                
            } catch let error {
                print("Error: \(error)")
            }
        
        // end for
        }
        
        print("All matches - \(results_oZ.count+results_dZ.count+results_EO_dZ.count)")
        print("------")
        print("Double ziro - \(results_dZ.count):")
         
        var i: Int = 1
        
        for x in results_dZ {
            print(String(i) + ". " + x.country + ": " + x.league + ": "
                    + x.title + ": " + x.time + " index: " + String(x.index))
            i += 1
            
            if results_oZ.contains(where: {$0.id == x.id}) {
                results_MX.append(x)
            }
            
            if results_EO_dZ.contains(where: {$0.id == x.id}) {
                results_MX.append(x)
            }
        }
        print("------")
        print("Once ziro - \(results_oZ.count):")
        for x in results_oZ {
            print(String(i) + ". " + x.country + ": " + x.league + ": "
                    + x.title + ": " + x.time + " index: " + String(x.index))
            i += 1
            
            if results_EO_dZ.contains(where: {$0.id == x.id}) {
                results_MX.append(x)
            }
        }
        
        print("------")
        print("Each other - \(results_EO_dZ.count):")
        for x in results_EO_dZ {
            print(String(i) + ". " + x.country + ": " + x.league + ": "
                    + x.title + ": " + x.time + " index: " + String(x.index))
            i += 1
        }
        
        // mix matches
        print("------")
        print("MIX - \(results_MX.count):")
        for x in results_MX {
            print(String(i) + ". " + x.country + ": " + x.league + ": "
                    + x.title + ": " + x.time + " index: " + String(x.index))
            i += 1
        }
        
        // only one for channel
        print("------")
        print("Only One - \(results_oO.count):")
        for x in results_oO {
            print(String(i) + ". " + x.country + ": " + x.league + ": "
                    + x.title + ": " + x.time + " index: " + String(x.index))
            i += 1
        }
        
    } catch let error {
        print("Error: \(error)")
    }
    
}


func CheackMatсhes(year: String, month: String, day: String) {
    
    //let myUrlString: String = "https://soccer365.ru/online/&tab=3"
    let myUrlString: String = "https://soccer365.ru/online/&date=\(year)-\(month)-\(day)&tab=3"
    let myURL = URL(string: myUrlString)
    do {
        let myHTMLString = try String(contentsOf: myURL!, encoding: .utf8)
        let doc = try SwiftSoup.parse(myHTMLString)
        
        let game_link = try doc.getElementsByClass("game_link").array()
        var matchs: [Match] = []
        for game in game_link {
            
            let link  = try game.attr("href")
            let title = try game.attr("title")
            let id    = try game.attr("dt-id")
            
            // check on night
            let size10 = try game.getElementsByClass("size10")
            let time = try size10.text()
            //let timeOfDay: DayNight = GetTime(time: time, format: "dd.MM, HH:mm")
            let timeOfDay: DayNight = GetTime(time: time, format: "dd.MM.yy, HH:mm")
            if timeOfDay == DayNight.day {
                
                if time.contains("Отменен") == false || time.contains("Перенесен") == false {
                    let match = Match(id: id, title: title, link: link, time: time)
                    matchs.append(match)
                }
            }
            //break
            
        }
        
        var results_dZ: [Match] = []
        var results_oZ: [Match] = []
        var results_EO_dZ: [Match] = []
        var positiveMatches: [Match] = []
        
        // negatives
        var negative_dZ: [Match] = []
        var negative_oZ: [Match] = []
        var negative_EO_dZ: [Match] = []
        var negativeMatches: [Match] = []
        
        //print("Matches found - \(matchs.count)")
        //print("------")
        
        //let match = Match(id: "1624901", title: "test", link: "test")
        //matchs.append(match)
        
        for match in matchs {
            
            do {
                //let match = Match(id: "1613272", title: "test", link: "test")
                
                //sleep(1)
                usleep(75000)
                
                let URLMatch = URL(string: "https://soccer365.ru/games/" + match.id)
                //let URLMatch = URL(string: "https://soccer365.ru/games/1624901")
                let HTMLMatchString = try String(contentsOf: URLMatch!, encoding: .utf8)
                let doc2 = try SwiftSoup.parse(HTMLMatchString)
                
                //print(type(of: doc2))
                
                let ht_el = try doc2.getElementsByClass("ht").array()
                let at_el = try doc2.getElementsByClass("at").array()
                
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
                
                
                if goals_at.count == 10 && goals_ht.count == 10 {
                    
                    // results only 2-(0-0)
                    if goals_at.count > 2 && goals_ht.count > 2 {
                        if (goals_ht[0] == "0" && goals_at[0] == "0") && (goals_ht[1] == "0" && goals_at[1] == "0") {
                            let h2_html = try doc2.select("h2").first()
                            let value = try h2_html?.text()
                            match.description = value!
                            
                            let live_game_ht = try doc2.getElementsByClass("live_game_ht").select("a")
                            let href_club = try live_game_ht.attr("href")
                            searchCountry(href_club: href_club, match: match)
                            
                            match.typeOfMatch = "DZ"
                            results_dZ.append(match)
                            
                            let live_goals = try doc2.getElementsByClass("live_game_goal").select("span").array()
                            //AddNegativeMatch()
                            let x0 = try live_goals[0].text()
                            let x1 = try live_goals[1].text()
                            if x0 == "0" && x1 == "0" {
                                //if negativeMatches.contains(where: {$0.id == match.id}) {
                                //    continue
                                //} else {
                                    negativeMatches.append(match)
                                    negative_dZ.append(match)
                                //}
                            } else {
                                //if positiveMatches.contains(where: {$0.id == match.id}) {
                                //    continue
                                //} else {
                                    //SearchTimeOfGoal(href_match: "https://soccer365.ru/games/" + match.id, match: match)
                                    positiveMatches.append(match)
                                //}
                            }
                            
                        }
                    }
                    
                    if goals_at.count > 5 && goals_ht.count > 5 {
                        if (goals_ht[5] == "0" && goals_at[5] == "0") && (goals_ht[6] == "0" && goals_at[6] == "0") {
                            let h2_html = try doc2.select("h2").first()
                            let value = try h2_html?.text()
                            match.description = value!
                            
                            let live_game_ht = try doc2.getElementsByClass("live_game_ht").select("a")
                            let href_club = try live_game_ht.attr("href")
                            searchCountry(href_club: href_club, match: match)
                            
                            match.typeOfMatch = "DZ"
                            results_dZ.append(match)
                            
                            // check on result
                            let live_goals = try doc2.getElementsByClass("live_game_goal").select("span").array()
                            //AddNegativeMatch()
                            let x0 = try live_goals[0].text()
                            let x1 = try live_goals[1].text()
                            if x0 == "0" && x1 == "0" {
                                //if negativeMatches.contains(where: {$0.id == match.id}) {
                                //    continue
                                //} else {
                                    negativeMatches.append(match)
                                    negative_dZ.append(match)
                                //}
                            } else {
                                //if positiveMatches.contains(where: {$0.id == match.id}) {
                                //    continue
                                //} else {
                                    //SearchTimeOfGoal(href_match: "https://soccer365.ru/games/" + match.id, match: match)
                                    positiveMatches.append(match)
                                //}
                            }
                            
                        }
                    }
                    
                    // results 1-(0-0)
                    if (goals_ht[0] == "0" && goals_at[0] == "0") && (goals_ht[5] == "0" && goals_at[5] == "0") {
                        let h2_html = try doc2.select("h2").first()
                        let value = try h2_html?.text()
                        match.description = value!
                        
                        let live_game_ht = try doc2.getElementsByClass("live_game_ht").select("a")
                        let href_club = try live_game_ht.attr("href")
                        searchCountry(href_club: href_club, match: match)
                        
                        match.typeOfMatch = "OZ"
                        results_oZ.append(match)
                        
                        let live_goals = try doc2.getElementsByClass("live_game_goal").select("span").array()
                        //AddNegativeMatch()
                        let x0 = try live_goals[0].text()
                        let x1 = try live_goals[1].text()
                        if x0 == "0" && x1 == "0" {
                            //if negativeMatches.contains(where: {$0.id == match.id}) {
                            //    continue
                            //} else {
                                negativeMatches.append(match)
                                negative_oZ.append(match)
                            //}
                        } else {
                            //if positiveMatches.contains(where: {$0.id == match.id}) {
                            //    continue
                            //} else {
                                //SearchTimeOfGoal(href_match: "https://soccer365.ru/games/" + match.id, match: match)
                                positiveMatches.append(match)
                            //}
                        }
                        
                    }
                    
                }
                
                // each other
                let URL_EachOther = URL(string: "https://soccer365.ru/games/" + match.id + "/&tab=stats_games")
                let HTMLEachOtherString = try String(contentsOf: URL_EachOther!, encoding: .utf8)
                let doc3 = try SwiftSoup.parse(HTMLEachOtherString)
                
                let ht3_el = try doc3.getElementsByClass("ht").array()
                let at3_el = try doc3.getElementsByClass("at").array()
                
                var goals_ht3: [String] = []
                var goals_at3: [String] = []
                
                if ht3_el.count > 2 && at3_el.count > 2 {
                    
                    for i in 1...2 {
                        let goal_ht3 = try ht3_el[i].getElementsByClass("gls").text()
                        goals_ht3.append(goal_ht3)
                    }
                    
                    for i in 1...2 {
                        let goal_at3 = try at3_el[i].getElementsByClass("gls").text()
                        goals_at3.append(goal_at3)
                    }
                    
                    if (goals_ht3[0] == "0" && goals_at3[0] == "0")
                        && (goals_ht3[1] == "0" && goals_at3[1] == "0") {
                        let h3_html = try doc3.select("h2").first()
                        let value3 = try h3_html?.text()
                        match.description = value3!
                        
                        let live_game_ht3 = try doc3.getElementsByClass("live_game_ht").select("a")
                        let href_club3 = try live_game_ht3.attr("href")
                        searchCountry(href_club: href_club3, match: match)
                        
                        match.typeOfMatch = "EO"
                        results_EO_dZ.append(match)
                        
                        let live_goals = try doc2.getElementsByClass("live_game_goal").select("span").array()
                        //AddNegativeMatch()
                        let x0 = try live_goals[0].text()
                        let x1 = try live_goals[1].text()
                        if x0 == "0" && x1 == "0" {
                            //if negativeMatches.contains(where: {$0.id == match.id}) {
                            //    continue
                            //} else {
                                negativeMatches.append(match)
                                negative_EO_dZ.append(match)
                            //}
                        } else {
                            //if positiveMatches.contains(where: {$0.id == match.id}) {
                            //    continue
                            //} else {
                                //SearchTimeOfGoal(href_match: "https://soccer365.ru/games/" + match.id, match: match)
                                positiveMatches.append(match)
                            //}
                        }
                        
                    }
                    
                }
                
            } catch let error {
                print("Error: \(error)")
            }
            
        }
        
        //var a: Set<Match> = []
        
        //let totalArray: [Match] = results_oZ + results_dZ + results_EO_dZ
        
        //var result = Statistic()
        //statistic.total_all      += totalArray.count
        //statistic.total_negative += negativeMatches.count
        statistic.positive_DZ += results_dZ.count
        statistic.positive_OZ += results_oZ.count
        statistic.positive_EO += results_EO_dZ.count
        
        statistic.negative_DZ += negative_dZ.count
        statistic.negative_OZ += negative_oZ.count
        statistic.negative_EO += negative_EO_dZ.count
        
        statistic.date           = month
        statistic.NegativeMatches += negativeMatches
        statistic.PositiveMatches += positiveMatches
        
        // mix
        for x in results_dZ {
            if results_oZ.contains(where: {$0.id == x.id}) {
                statistic.mixMatches.append(x)
            }
            if results_EO_dZ.contains(where: {$0.id == x.id}) {
                statistic.mixMatches.append(x)
            }
        }
        
        for x in results_oZ {
            if results_EO_dZ.contains(where: {$0.id == x.id}) {
                statistic.mixMatches.append(x)
            }
        }
        
    } catch let error {
        print("Error: \(error)")
    }
    
}


struct Statistic {
    
    var positive_DZ: Int = 0
    var positive_OZ: Int = 0
    var positive_EO: Int = 0
    
    var positiveTotal: Int {
        return positive_DZ+positive_OZ+positive_EO
    }
    
    var negative_DZ: Int = 0
    var negative_OZ: Int = 0
    var negative_EO: Int = 0
    
    var negativeTotal: Int {
        return negative_DZ+negative_OZ+negative_EO
    }
    
    var date: String = ""
    var NegativeMatches: [Match] = []
    var PositiveMatches: [Match] = []
    
    var mixMatches: [Match] = []
    
}

// main
var month: String = "05"
var day: String = "07"
var statistic = Statistic()

// search
SearchMatсhes(month: month, day: day)

// check
for day_x in 1...31 {
    CheackMatсhes(year: "2021", month: month, day: String(day_x))
}

print("Month - \(month)")
print("-----Mix matches------")
print("count - \(statistic.mixMatches.count)")
print("---------")

for i in statistic.mixMatches {
    
    do {
        //print(i.id)
        try SearchTimeOfGoal(href_match: "https://soccer365.ru/games/" + i.id, match: i)
    } catch let error {
        print(error)
        print(i.id)
    }
    GetScoredMissed(href_match: "https://soccer365.ru/games/" + i.id, match: i)
    print(i.country + "  |  " +
            i.league + "  |  " +
            i.title + "   |   " +
            i.time + "   |   " +
            i.typeOfMatch + "   |   " +
            String(i.timeOfGoal) + "   |   " +
            String(i.interval) + "   |   " +
            String(i.scored1) + "   |   " +
            String(i.scored2) + "   |   " +
            String(i.missed1) + "   |   " +
            String(i.missed2)
          
    )
}

/*
print("Month - \(month)")
print("-----Positive matches------")
print("DZ - \(statistic.positive_DZ)")
print("OZ - \(statistic.positive_OZ)")
print("EO - \(statistic.positive_EO)")
print("---ALL---\(statistic.positiveTotal)")
print("---------")

print("-----Negative matches------")
print("DZ - \(statistic.negative_DZ)")
print("OZ - \(statistic.negative_OZ)")
print("EO - \(statistic.negative_EO)")
print("---ALL---\(statistic.negativeTotal)")
print("---------")

print("Details negative matches:")
print("country      |      leaugue      |      match         |       time       |           type         |       goal_min         |       interval      |      scored1      |      scored2         |       missed1       |           missed2         |       index")

for i in statistic.NegativeMatches {
    GetScoredMissed(href_match: "https://soccer365.ru/games/" + i.id, match: i)
    print(i.country + "  |  " +
            i.league + "  |  " +
            i.title + "   |   " +
            i.time + "   |   " +
            i.typeOfMatch + "   |   " +
            String(i.timeOfGoal) + "   |   " +
            String(i.interval) + "   |   " +
            String(i.scored1) + "   |   " +
            String(i.scored2) + "   |   " +
            String(i.missed1) + "   |   " +
            String(i.missed2) + "   |   " +
            String(i.index)
            
    )
    
}

print("---------")
print("Details positive matches:")
print("country      |      leaugue      |      match         |       time       |           type         |       goal_min         |       interval      |      scored1      |      scored2         |       missed1       |           missed2         |       index")

for i in statistic.PositiveMatches {
    
    do {
        //print(i.id)
        try SearchTimeOfGoal(href_match: "https://soccer365.ru/games/" + i.id, match: i)
    } catch let error {
        print(error)
        print(i.id)
    }
    GetScoredMissed(href_match: "https://soccer365.ru/games/" + i.id, match: i)
    print(i.country + "  |  " +
            i.league + "  |  " +
            i.title + "   |   " +
            i.time + "   |   " +
            i.typeOfMatch + "   |   " +
            String(i.timeOfGoal) + "   |   " +
            String(i.interval) + "   |   " +
            String(i.scored1) + "   |   " +
            String(i.scored2) + "   |   " +
            String(i.missed1) + "   |   " +
            String(i.missed2) + "   |   " +
            String(i.index)
          
    )
}
*/




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
    
    //var timeOfDay: DayNight {
    //}
    
    
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

//func AddNegativeMatch(array: [String]) {
//
//    let x0 = try array[0].text()
//    let x1 = try array[1].text()
//    if x0 == "0" && x1 == "0" {
//        negativeMatches.append(match)
//    }
//
//}

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
    
//    var calendar = Calendar.current
//    calendar.timeZone = TimeZone(abbreviation: "UTC")!
//
//    let hour = calendar.component(.hour, from: newdate)
//    //let min = calendar.component(.minute, from: newdate)
    
}

func SearchMathes(month: String, day: String) {
    
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
            let size11 = try game.getElementsByClass("size10")
            let time = try size11.text()
            
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
            print(String(i) + ". " + x.country + ": " + x.league + ": " + x.title + ": " + x.time)
            i += 1
        }
        print("------")
        print("Once ziro - \(results_oZ.count):")
        for x in results_oZ {
            print(String(i) + ". " + x.country + ": " + x.league + ": " + x.title + ": " + x.time)
            i += 1
        }
        
        print("------")
        print("Each other - \(results_EO_dZ.count):")
        for x in results_EO_dZ {
            print(String(i) + ". " + x.country + ": " + x.league + ": " + x.title + ": " + x.time)
            i += 1
        }
        
    } catch let error {
        print("Error: \(error)")
    }
    
}


func CheackMathes(month: String, day: String) {
    
    //let myUrlString: String = "https://soccer365.ru/online/&tab=3"
    let myUrlString: String = "https://soccer365.ru/online/&date=2021-\(month)-\(day)&tab=3"
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
            let timeOfDay: DayNight = GetTime(time: time, format: "dd.MM, HH:mm")
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
                usleep(150000)
                
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
                                if negativeMatches.contains(where: {$0.id == match.id}) {
                                    continue
                                } else {
                                    negativeMatches.append(match)
                                    negative_dZ.append(match)
                                }
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
                                if negativeMatches.contains(where: {$0.id == match.id}) {
                                    continue
                                } else {
                                    negativeMatches.append(match)
                                    negative_dZ.append(match)
                                }
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
                            if negativeMatches.contains(where: {$0.id == match.id}) {
                                continue
                            } else {
                                negativeMatches.append(match)
                                negative_oZ.append(match)
                            }
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
                            if negativeMatches.contains(where: {$0.id == match.id}) {
                                continue
                            } else {
                                negativeMatches.append(match)
                                negative_EO_dZ.append(match)
                            }
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
        statistic.matches        += negativeMatches
                
        
    } catch let error {
        print("Error: \(error)")
    }
    
}


struct Statistic {
    
    //var total_all: Int = 0
    
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
    var matches: [Match] = []
    
//    var total_negative: Int {
//        return matches.count
//    }
    
}


// main
var month: String = "01"
var day: String = "11"
var statistic = Statistic()

// search
SearchMathes(month: month, day: day)

// check
for day in 1...31 {
    CheackMathes(month: month, day: String(day))
}

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

print("Detals negative matches:")
print("country      |      leaugue      |      match         |       time       |           type")

for i in statistic.matches {
    print(i.country + "  |  " + i.league + "  |  " + i.title + "   |   " + i.time + "   |   " + i.typeOfMatch)
}




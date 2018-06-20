import Foundation

func magicWith (_ str1:String, and str2: String) -> String {

    let a = Array(str1)
    let b = Array(str2)
    
    var dist = [[Int]]()
    var operation = [[String]]()
    
    for _ in 0...a.count {
        dist.append(Array.init(repeating: 0, count: b.count + 1))
    }
    
    for _ in 0...a.count {
        operation.append(Array.init(repeating: "", count: b.count + 1))
    }
    
    for i in 1...a.count {
        dist[i][0] = i
        operation[i][0] = "d"
    }
    
    for j in 1...b.count {
        dist[0][j] = j
        operation[0][j] = "i"
    }
    
    for i in 1...a.count {
        for j in 1...b.count {
            
            let cost = a[i-1] != b[j-1] ? 1:0
            
            if dist[i][j-1] < dist[i-1][j] && dist[i][j-1] < dist[i-1][j-1] + cost {
                dist[i][j] = dist[i][j-1] + 1
                operation[i][j] = "i"
                
            } else if dist[i-1][j] < dist[i-1][j-1] + cost {
                dist[i][j] = dist[i-1][j] + 1
                operation[i][j] = "d"
                
            } else {
                dist[i][j] = dist[i-1][j-1] + cost
                operation[i][j] = cost == 1 ? "s":"n"
            }
        }
        
    }

    var route = ""
    var i = a.count
    var j = b.count
    
    while i != 0 || j != 0 {
        let c = operation[i][j];
        route.append(c);
        if c == "s" || c == "n"{
            i -= 1;
            j -= 1;
        }
        else if c == "d" {
            i -= 1
        }
        else {
            j -= 1
        }
    }
   
    return String(route.reversed()).replacingOccurrences(of: "n", with: "")
}



let myDream = magicWith("jysi", and: "junic")














//func levenshtein(aStr: String, bStr: String) -> Int {
//
//    let a = Array(aStr)
//    let b = Array(bStr)
//
//    var dist = [[Int]]()
//    var operation = [[String]]()
//
//
//    for _ in 0...a.count {
//        dist.append(Array.init(repeating: 0, count: b.count + 1))
//    }
//
//    for _ in 0...a.count {
//        operation.append(Array.init(repeating: "", count: b.count + 1))
//    }
//
//    for i in 1...a.count {
//        dist[i][0] = i
//
//        operation[i][0] = "d"
//
//        //        print(dist[i][0])
//        //        print(dist)
//        //        print("-------")
//    }
//
//    for j in 1...b.count {
//        dist[0][j] = j
//
//        operation[0][j] = "i"
//
//        //        print(dist[0][j])
//        //        print(dist)
//        //        print("++++++++")
//
//
//    }
//
//    //    print(dist)
//    //    print("----------")
//
//    for i in 1...a.count {
//        for j in 1...b.count {
//
//            let cost = a[i-1] != b[j-1] ? 1:0
//
//            if dist[i][j-1] < dist[i-1][j] && dist[i][j-1] < dist[i-1][j-1] + cost {
//                dist[i][j] = dist[i][j-1] + 1
//                operation[i][j] = "i"
//            } else if dist[i-1][j] < dist[i-1][j-1] + cost{
//                dist[i][j] = dist[i-1][j] + 1
//                operation[i][j] = "d"
//            } else {
//                dist[i][j] = dist[i-1][j-1] + cost
//                operation[i][j] = cost == 1 ? "s":"n"
//            }
//        }
//
//            }
//
//
//    print(operation)
//
//
//    var route = ""
//    var i = a.count
//    var j = b.count
//
//    while i != 0 || j != 0 {
//        let c = operation[i][j];
//        route.append(c);
//        if c == "s" || c == "n"{
//            i -= 1;
//            j -= 1;
//        }
//        else if c == "d" {
//            i -= 1
//        }
//        else {
//            j -= 1
//        }
//    }
//
//    print(String(route.reversed()))
//
//    return dist[a.count][b.count]
//}
//levenshtein(aStr: "adc", bStr: "vddf")









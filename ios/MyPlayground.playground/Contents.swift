let url = URL(string: "localhost/")!
var request = URLRequest(url: url)
request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
request.httpMethod = "POST"
let postString = "id=13&name=Jack"
request.httpBody = postString.data(using: .utf8)
let task = URLSession.shared.dataTask(with: request) { data, response, error in
    guard let data = data, error == nil else {                                                 // check for fundamental networking error
        print("error=\(error)")
        return
    }
    
    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
        print("statusCode should be 200, but is \(httpStatus.statusCode)")
        print("response = \(response)")
    }
    
    let responseString = String(data: data, encoding: .utf8)
    print("responseString = \(responseString)")
}
task.resume()

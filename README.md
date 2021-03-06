# BookReviewApp

This app allows for users to get the rating of a book instantly bu taking a picture of a book. Here is a detailed overview of how it actually works: 

## Recognizing the Text

We first have to recognize the title of the book from the picture the user takes. In order to do this, we make use of Swift's Vision library. All of htis work is done in the configureOCR method. 

The first thing we do in the OCR method is get all the observations. In order do this, we use the following piece of code: 

```swift
ocrRequest = VNRecognizeTextRequest { (request, error) in
    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
```

The above code essentially gathers all the observations the AI thinks the text is. Of course we want to extract the one with the most accuracy. In order to do this, we loop through all the observations and see which one has the most acuracy: 

```swift
var ocrText = ""
    for observation in observations {
    guard let topCandidate = observation.topCandidates(1).first else { return }
                    
    ocrText += topCandidate.string + "\n"
}
```

Now that we have the top candidiate, the next logical step would be to get the HTML. 

## Getting the HTML 

In order to get the HTML, we must have the URL we want to scrape from. If you take a look at amazon url's you will notice that all of them are in the same form. Using this form, we can write the folowing code using Swifts URLComponents: 

```swift
var html = ""
                let scheme = "https"
                let host = "www.amazon.com"
                let path = "/s"
                let k =  ocrText
                let i = "stripbooks"
                let kItem = URLQueryItem(name: "k", value: k)
                let iItem = URLQueryItem(name: "i", value: i)
                
                var urlComponents = URLComponents()
                urlComponents.scheme = scheme
                urlComponents.host = host
                urlComponents.path = path
                urlComponents.queryItems = [kItem, iItem]
                
                guard let url = urlComponents.url else { return }

```
Now that we have the URL, we can actually get the HTML: 

```swift
URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data else {
                        print(error ?? "")
                        return
                    }
                    html = String(data: data, encoding: .utf8)!
                    let pattern = #"(\d.\d) out of 5 stars"#
                    if let range = html.range(of: pattern, options: .regularExpression) {
                        let rating = html[range].prefix(3)
                        ocrText = ""
                        ocrText = ocrText + rating
                        DispatchQueue.main.async {
                            self.ocrTextView.text = ocrText
                            self.scanButton.isEnabled = true
                        }
                        
                    }
                    
                }.resume()
                
```

In the above code, we not only got the HTML of the website but we also took out the specific part we want. Since we just want the number of stars, we search for that in the html string and extract that. 

## Adding the rating to the user's screen using ARKit

Now for the exciting part: we make the rating show up on the user's screen using ARKit. We write a function for this: 


```swift
private func showARText() {
    let text = SCNText(string: ocrTextView.text, extrusionDepth: 0.5)
           let material = SCNMaterial()
           material.diffuse.contents = UIColor.magenta
           text.materials = [material]
    
           text.font = UIFont(name: "HelveticaNeue", size: 2)
           
           let node = SCNNode()
           node.position = SCNVector3(x:0, y:0.02, z:-0.1)
           node.scale = SCNVector3(x:0.01, y:0.01, z:0.01)
           node.geometry = text
           
           sceneView.scene.rootNode.addChildNode(node)
           sceneView.autoenablesDefaultLighting = true
    
}
                
```

In the first bit of the above code, we set the material, color, and font of the text (feel free to change this if you like): 

```swift
let material = SCNMaterial()
material.diffuse.contents = UIColor.magenta
text.materials = [material]

text.font = UIFont(name: "HelveticaNeue", size: 2)

```

Next, we create a node, which is essentially the position of the text. We create the node first and then we set the position using ```swiftSCNVector3()``` and finally we set the geometry of the node to the actual text. In the last 2 lines, we add our node to the end of the childNodes array and we tell SceneKit to automatically light to the scene: 

```swift
let node = SCNNode()
node.position = SCNVector3(x:0, y:0.02, z:-0.1)
node.scale = SCNVector3(x:0.01, y:0.01, z:0.01)
node.geometry = text

sceneView.scene.rootNode.addChildNode(node)
sceneView.autoenablesDefaultLighting = true
```

And that's it!

## Walkthrough and Screenshots

In this case, we take the picture of <em>The Giver</em> by Lois Lowry (a great book!)
![Take the picture of the book](PictureOfBook.png)

Now, we adjust the picture we just took so that just the title (and maybe the author) is the "image" that the text recognitition will be performed on. 
![Five Fingers](AdjustPictureOfBook.png)

Finally, once we take the image, the rating is shown augmented on the user's screen as shown below. 
![Five Fingers](ARText.png)

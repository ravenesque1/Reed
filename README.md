# Reed

Exploring SwiftUI and Combine in the form of a blog reader using the [News API](https://newsapi.org). The service allows you to receive news information, and is free for developers with attribution.


## Installation

This project requires Xcode 11.2+, and runs Swift 5. You will also need to create your own free [API key](https://newsapi.org/docs/get-started). 

1. clone and open the project.

```
git clone https://github.com/ravenesque1/Reed.git
cd leer
open Reed.xcodeproj
```

2. Create your API key using News API. An email is required, and at the free developer tier, there is a 500 request limit per day.

3. Open `NewsWebService.swift`, and replace the value of `newsApiKey` ("YOUR_API_KEY_HERE") with your key.

The project should now run.

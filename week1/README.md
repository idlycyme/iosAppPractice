## Rotten Tomatoes

This is a movies app displaying box office and top rental DVDs using the [Rotten Tomatoes API](http://developer.rottentomatoes.com/docs/read/JSON).

Time spent: `<10>`

### Features

#### Required

- [v] User can view a list of movies. Poster images load asynchronously.
- [v] User can view movie details by tapping on a cell.
- [v] User sees loading state while waiting for the API.
- [v] User sees error message when there is a network error: http://cl.ly/image/1l1L3M460c3C
- [v] User can pull to refresh the movie list.

#### Optional

- [v] All images fade in.
- [v] For the larger poster, load the low-res first and switch to high-res when complete.
- [v] All images should be cached in memory and disk: AppDelegate has an instance of `NSURLCache` and `NSURLRequest` makes a request with `NSURLRequestReturnCacheDataElseLoad` cache policy. I tested it by turning off wifi and restarting the app.
- [v] Customize the highlight and selection effect of the cell.
- [v] Customize the navigation bar.
- [v] Add a tab bar for Box Office and DVD.
- [v] Add a search bar: pretty simple implementation of searching against the existing table view data.

### Walkthrough
![Video Walkthrough](week1_demo_ydlin.gif)

Credits
---------
* [Rotten Tomatoes API](http://developer.rottentomatoes.com/docs/read/JSON)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)

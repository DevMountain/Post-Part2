# Post - Part Two

## Project Summary

Build functionality to allow the user to submit new posts to the feed. Make the network requests more efficient by adding paging functionality to the Post Controller. Update the table view to support paging.

Students who complete this project independently are able to:

* use URLSession to make asynchronous POST HTTP requests
* build custom table views that support paging through network requests

## Part Two - Alert Controllers, URLSessionDataTask (HTTP POST method), Paging Requests

### Setup

Open your POST day 1 project and we will continue to build off that project.

## Step One - Add Posting Functionality to the PostController

### Summary

Update your `PostController` to initialize a new `Post` and use an `URLSessionDataTask` to post it to the API.

### Instructions

* Add an `addNewPostWith(username:text:completion:)` function.

* Implement this function:
  
  * Initialize a `Post` object with the memberwise initializer
  
  * Create a variable called `postData` of type `Data` but don't give it a value.
  
  * Inside of a do-catch block:
  
    * Create an instance of `JSONEncoder`
  
    * Call `encode(value: Encodable) throws` on your instance of the JSONEncoder, passing in the post as an argument. You will need to assign the return of this function to the `postData` variable you created in one of the previous steps. *This is a throwing function so make sure to catch the possible error.*

  * Next, unwrap your baseURL.

  * Next, create a property `postEndpoint` that will hold the unwrapped `baseURL` with a path extension appended to it. Go back and look at your sample URL to see what this extension should be.

  * Create an instance of URLRequest and give it the `postEndpoint`.  *(DO NOT forget to set the request's httpMethod -> `"POST"` and httpBody -> `postData`)*

  * As we did in the `fetchPosts()` function in Part 1, you need to create and run (`dataTask.resume()`) a `URLSession.shared.dataTask` and handle it's results:

    * Check for errors. (_See Firebase's documentation for details on catching errors from the Post API._)

    * Unwrap the data returned from the dataTask and this time, also convert the data to a string.

      * Note: You can use `String(data: data, encoding: .utf8)` to capture and print a readable representation of the returned data. Because of the quirks of this specific API, you will want to check this string to see if the returned data indicates an error.

    * If there are no errors, log the success and the response to the console.

    * After posting to the API, call `fetchPosts()` to load the new `Post` you added and any other new `Post` objects from the server.

    * This is a little tricky but you'll need to call `completion()` for the `addNewPostWith(username:text:completion:)` function inside of the completion closure that gets called when the `fetchPosts()` is finished.

## Step Two - Add Posting Functionality to the User Interface

### Summary

Now that we have added a function to post data to our API, we need to allow the user to create a post inside the app.

### Instructions

* Add a (+) `UIBarButtonItem` to the `PostListTableViewController` scene in storyboard

* Add an IBAction to the `PostListTableViewController` class file from the bar button item

* Write a `presentNewPostAlert()` function that initializes a `UIAlertController`.

  * Add a `usernameTextField` and a `messageTextField` to the alert controller that the user will use to create their message.

  * Add a `Post` alert action that guards for username and message text, and uses the `postController` to add a post with the username and text.

    * In the completion handler, be sure to call `reloadTableView()`

* Write a `presentErrorAlert()` function that initializes a `UIAlertController` that says the user is missing information and should try again. Call the function if the user doesn't include text in the `usernameTextField` or `messageTextField`

* Create a `Cancel` alert action, add both alert actions to the alert controller, and then present the alert controller.

* Call the `presentNewPostAlert()` function from the IBaction of the + `UIBarButtonItem`

## Step Three -  Improving Efficiency of the Network Requests

### Summary

You may have noticed that the network request to load the global feed can take multiple seconds to run. As more students build this project and submit more messages, the data returned from the `PostController` will get larger and larger. When you are working with hundreds of objects this is not a problem, but once you start dealing with thousands, tens of thousands, or more, things will start slowing down considerably.

Additionally, consider that the user is unlikely to scroll all the way to the first message in the global feed if there are thousands of posts. We can be more efficient by not loading it in the first place.

To avoid the inefficiency of loading data that will never be displayed, many APIs support 'querying' or 'paging'. The Post API you are using for this project supports paging. We will implement paging on the `PostController` and add support on the Post List Scene to load new posts as the user scrolls.

We will need to update the `PostController` to fetch a limited number of `Post` objects from the API by using the URL parameters detailed in the API documentation.

### Instructions

Consider that there are two use cases for using the `fetchPosts` function:

* To load a fresh list of `Post` objects for when the user wants to see the latest posts.

* To add the next set (or 'page') of posts to the already fetched posts for when the user wants to see older posts than the ones already loaded.

So you must update the `fetchPosts` function to support both of these cases.

* Add a Bool `reset` parameter to the beginning of the `fetchPosts` function and assign a default value of `true`.

  * This value will be used to determine whether you should replace the `posts` property or append posts to the end of it.

  * Review the API Documentation [Firebase documentation](https://firebase.google.com/docs/database/rest/retrieve-data?authuser=1#section-rest-filtering) to determine what URL parameters you need to pass to fetch a subset of posts.

  * Note: Experiment with the URL parameters using PostMan, Paw, or your web browser.

* Consider the following concepts. Attempt to implement the different ways you have considered. Continue to the next step after 10 minutes.

  * Consider how you can get the range of timestamps for the request

  * Consider how many `Post` dictionaries you want to be returned in the request

  * Use a whiteboard to draw out scenarios and potential sorting and filtering mechanisms to get the data you want

* Use the following logic to generate the URL parameters to get the desired subset of `Post` JSON. This can be complex but think through it before using the included sample code below.

* You want to order the posts in reverse chronological order.

* Request the posts ordered by `timestamp` to put them in chronological order (`orderBy`).

* Specify that you want the list to end at the `timestamp` of the least recent `Post` you have already fetched (or at the current date if you haven't posted any). Specify that you want the posts at the end of that ordered list (`endAt`).

* Specify that you want the last 15 posts (`limitToLast`).

* Determine the necessary `timestamp` for your query based on whether you are resetting the list (where you would want to use the current time), or appending to the list (where you would want to use the time of the earlier fetched `Post`). 

* As this is quite a bit to modify we will walk you through this: 

* Add this code inside of the `fetchPosts()` function, being the first line of code it will run:

    * <details>

        <summary> <code> Code </code> </summary>

        ```swift
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
        ```
        
    </details>

* Build a `[String: String]` Dictionary literal of the URL Parameters you want to use. Add this code after you unwrap the `baseURL`

  * <details>

    <summary> <code> Code </code> </summary>

    ```swift
    let urlParameters = [
    "orderBy": "\"timestamp\"",
    "endAt": "\(queryEndInterval)",
    "limitToLast": "15",
    ]
    ```

  </details>
* Create a constant called `queryItems`. We need to compactMap over the urlParameters, turning them into `URLQueryItem`s.
  * <details>

    <summary> <code> Code </code> </summary>

    ```swift
    let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
    ```
  </details>

* Create a variable called `urlComponents` of type `URLComponents`. Pass in the unwrapped `baseURL` and `true` as arguments to the initializer.

* Set the `urlComponents.queryItems` to the `queryItems` we just created from the `urlParameters`.

* Then, create a `url` constant. Assign it the value returned from `urlComponents?.url`. *This will need to be placed inside a guard statement to unwrap it.

* Lastly, modify the `getterEndpoint` to append the extension to the `url` not to the `unwrappedURL`.

* Now you'll need to make changes to the code where the data has already come back from the request. Replace the `self.posts = sortedPosts` with logic that uses the `reset` parameter to determine whether you should replace `self.posts` or append to `self.posts`.
 
  * Note: If you want to reset the list, you want to replace, otherwise, you want to append. *Review the method on Array called `append(contentsOf:)`*

## Step Four - Add Paging Functionality to the User Interface

### Summary

Add paging functionality to the ListView by adding logic that checks for when the user has scrolled to the end of the table view and calls the updated `fetchPosts` function with the correct parameters.

### Instructions

* Review the `UITableViewDelegate` [Protocol Reference](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableViewDelegate_Protocol/index.html) to find a function that could be used to determine when the user has scrolled to the bottom of the table view.

  * Note: Move on to the next step after reviewing for potential solutions to implement this feature.

* Add an extension of `PostListViewController` to the bottom of the file

* Add and implement the `tableView(_:willDisplay:forRowAt:)` function

* Check if the `indexPath.row` of the cell parameter is greater than or equal to the number of posts currently loaded - 1 on the `postController`

* If so, call the `fetchPosts` function with reset set to false

* In the completion closure, reload the table view

## Step Five - Test and Refine the Paging Logic

### Summary

Review the newly implemented paging feature. Scroll through the posts on the feed. Pay special attention to any abnormalities (unordered posts, repeated posts, empty posts, etc).

You will notice that there is a repeated post where every new fetch occurred. If you review the API documentation, you'll find that our `endAt` query parameter is inclusive, meaning that it will _include_ any posts that match the exact `timestamp` of the last post. So each time we run the `fetchPosts` function, the API will return a duplicate of the last post.

We can fix this bug by adjusting the `timestamp` we use for the query by a single digit.

### Instructions

* Add a computed property `queryTimestamp` to the `Post` type that returns a `TimeInterval` adjusted by 0.00001 from the `self.timestamp`

* Update the `queryEndInterval` variable in the `fetchPosts` function to use the `posts.last?.queryTimestamp` instead of the regular `timestamp`

Run the app, check for bugs, and fix any you may find.

### Black Diamonds

* Fix the issue caused by scrolling all the way to the oldest post in the `tableView(willDisplayCell:)` function
* Any app that displays user-submitted content is required to provide a way to report and hide content, or it will be rejected during App Review. Add reporting functionality to the project.
* Make your table view more efficient by inserting cells for new posts instead of reloading the entire table view.

## Contributions

If you see a problem or a typo, please fork, make the necessary changes, and create a pull request so we can review your changes and merge them into the master repo and branch.

## Copyright

© DevMountain LLC, 2017. Unauthorized use and/or duplication of this material without express and written permission from DevMountain, LLC is strictly prohibited. Excerpts and links may be used, provided that full and clear credit is given to DevMountain with appropriate and specific direction to the original content.

<p align="center">
<img src="https://s3.amazonaws.com/devmountain/readme-logo.png" width="250">
</p>

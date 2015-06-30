## Twitter [(raw)](https://gist.githubusercontent.com/timothy1ee/b9b1860c8ecb4b0b1c18/raw/2adc3f63677d81644e00245cee891eee88907767/gistfile1.md)

This is a basic twitter app to read and compose tweets the [Twitter API](https://apps.twitter.com/).

Time spent: `<17>`

### Features

#### Required

- [v] User can sign in using OAuth login flow
- [v] User can view last 20 tweets from their home timeline
- [v] The current signed in user will be persisted across restarts
- [v] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.  In other words, design the custom cell with the proper Auto Layout settings.  You will also need to augment the model classes.
- [v] User can pull to refresh
- [v] User can compose a new tweet by tapping on a compose button.
- [v] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [v] User can retweet, favorite, and reply to the tweet directly from the timeline feed.

#### Optional

- [v] When composing, you should have a countdown in the upper right for the tweet limit.
- [v] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [v] Retweeting and favoriting should increment the retweet and favorite count.
- [v] User should be able to unretweet and unfavorite and should decrement the retweet and favorite count.
- [v] Replies should be prefixed with the username and the reply_id should be set when posting the tweet,
- [v] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.

### Walkthrough

![Video Walkthrough](week3_demo_ydlin.gif)


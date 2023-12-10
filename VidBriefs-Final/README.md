# VidBriefs

# BUSINESS

### Marketing and Legal
- **Form a PLC**: This should be done early in your process, as it's important for legal and financial reasons.
- **Learn Legal Risks of AI**: Parallel to your development, understand the legal aspects to ensure compliance.
- **Market to University Students at £7.99/year**: This should be part of your ongoing marketing strategy, but more focused once the app is nearing completion.

### Continuous Tasks
- **Chance to Rate the Video, and Rate the Summary for Help with Next Summarisation**: Implement this as a feature that evolves with user feedback.
- **Search the LLM for Specific Information Which They Want to Learn**: Continuously refine this feature based on user feedback and AI advancements.
- **Add Recommendations for Other Videos to Look At**: This can be an ongoing improvement as your database grows.
- **What Do They Do After They've Saved the Time**: This is more of a value proposition and user engagement strategy, continuously evolve this based on user feedback.

### Notes
- Prioritize tasks that lay the foundation for others.
- Regularly review and adjust your plan based on progress and challenges.
- Consider user feedback crucial for continuous improvement.
- Keep learning and adapting to new developments in AI and app development.

# CODE

cd /Users/alfienurse/Desktop/Development/xcode\ dev/VidBriefs

### IPhone screenshots
(1290 x 2796px or 2796 x 1290px)

### IPad screenshots
(2048 x 2732px or 2732 x 2048px)


## Checklist


- [ ] GET NEW APIKEY and on first app run get the openaiapikey from server then save it to keychain for the device, do serverside work and incorporate this functionality in while also creating a database

- [ ] Reinstate Youtube API - get other youtube api data and pass with the prompt

- [ ] Guess which prompt to suggest

- [x] MAKE A AUDIO READER OF THE SUMMARY ON INSIGHTVIEW
- [ ] make a proper nice voice for the reading

- [ ] pick the level of detail you want your question summarised in 

- [ ] Set up database, gettings themes and concise essential piece of infomation regarding the video

- [ ] insure asynchrounous, so the user can send the request and swipe off the app

- [ ] fix libary
- [ ] functionality to summarise a downloadable text file

- [ ] Register and sign up accounts 
- [ ] make it spin the summary shown on the every 5 times it reaches the view

- [ ] MAKE BUTTONS OPACITY 20 CUSTOMTEAL for everything
- [x] solve safe area errors in insight view and others
- [ ] change theme color button
_ [x] work out group problem with insight view

- [x] database implemtnation


- [x] calculate if text is under the 128k token limit before deciding to loop over it
- [x] "Don't waste your time watching long videos!"- 
- [ ] remove the clarifying when pressing paste button
- [ ] prompt engineer to ask gpt to only get the important infomation for the question
- [x] Start using the YouTube API
- [x] Move paste button left in the url textbox
- [x] Move the randomize button to top right
- [x] "List the things being discussed"
- [ ] change the response output to look easier to read
- [ ] prompt engineer the ai to bold important things

## For a more detailed recommendation system:

Collect Data: Start by collecting data on user interactions with videos (views, likes, duration watched) and video metadata (tags, categories, etc.).

Data Analysis: Analyze this data to find patterns and correlations. Machine learning models can be useful here.

Algorithm Implementation: Implement algorithms like collaborative filtering, content-based filtering, or hybrid methods to provide personalized video recommendations.
Continuous Improvement: Regularly update your models and algorithms based on new data and user feedback.

This approach lays the groundwork for a robust recommendation system, which you can refine and expand over time based on your specific requirements and user data.



1 - [x] Give my API key for all users
2 - [x] Fix tabview to fluidly swipe
3 - [x] "Un-update" back to IOS 16
4 - [x] fix stupid colouring and tabview background
5 - [x] Add a paste button into url textbox
6 - [x] Add functionality to manually randomize the insight on the homevie

- [ ] set up a limited company
- [ ] take some good screenshots

- Filter summaries into categories
- Implementation to suggest videos  
- Having option to listen to an audio voice generation of the transcript and then can mix the sound with(e.g binaural beats)
- Alternated tokens for summary gpt
- swipe down to reload libraryview 
- possible opinon to like or dislike

*When using the YouTube API to fetch data from a video URL, you can obtain a variety of information beyond just the title and transcript. Here's a list of some additional fields you might consider retrieving:* DONE

1. Video ID: Unique identifier for the video.

2. Channel ID: Identifier for the channel where the video was uploaded.

3. Channel Title: Name of the channel that uploaded the video.

4. Description: Full description of the video,

5. Published At: Date and time when the video was uploaded.

6. Thumbnails: URLs of the video thumbnails at various resolutions.

7. Tags: List of tags associated with the video.

8. Category ID: Identifier for the category of the video.

9. Live Broadcast Content: Indicates if the video is a live broadcast.

10. Duration: Length of the video.

11. View Count: Number of times the video has been viewed.

12. Like Count: Number of likes on the video.

13. Dislike Count: Number of dislikes on the video (Note: YouTube has made dislikes

private, so this might not be available).

14. Favorite Count: Number of times the video has been marked as favorite.

15. Comment Count: Number f comments on the video.

16. Status: Indicates if the video is public, private, or unlisted.

17. Content Rating: Age restriction information.

18. Region Restriction: Information about where the video is blocked or allowed.

19. Default Language: Original language of the video's content.

20, Caption: Indicates if the video has captions.

21. License: Type of license of the video (e.g., YouTube standard license, Creative

Commons),

22. Embeddable: Indicates if the video can be embedded on other websites.



## Business
https://www.disability-grants.org/business-grants-for-the-disabled.html
https://www.scope.org.uk/advice-and-support/start-up-a-business/

- [ ] Offer plans for higher cost for more summarisetons, bronze, silver, gold

- [ ] Sell YouTube summaries tokens and charge for using my API

- Invation tech = type of business

- type of business = innovation tech

- My business code = 62012 business and domestic software development

- international money transfer

- Grant funding

## Plan

### Immediate Short-Term Goals (1-2 Weeks)
1. [x] **Decide on a Good Colour Combination**: This is a foundational task that will influence the design of your app. It's relatively simple and sets the stage for UI development.

2. [x] **Fix the Swiping When Reaching the Last View on the Right**: Since you've already implemented swiping between views, fixing this should be a straightforward task.

3. [x] **TabView Implementation**: Follow the tutorial linked ([YouTube Tutorial](https://www.youtube.com/watch?v=DLj9yM-zLyc)) to implement this feature. This is a key UI component.

3.5. [x] Swipe up on the app in root view to “open the app” (send it too the next page) swipe up high up to not open app

3.75. [ ] Adjust black and grey for dark mode and lighmode 

4. [] **Finish Investor Pitch**: Refine your pitch to secure funding, which is crucial for long-term development and marketing efforts.

### Mid-Term Goals (3-6 Weeks)

5.  [ ] Functionality to Read Out a Generated Insight/Brief**: This is a core feature that should follow the basic UI implementations.

6. [x] Animation to Swipe Up to Move on from RootView**: Enhances user experience and should be tackled after basic UI elements like TabView are in place.

7. [ ] Filter What the AI Looks for in the Video**: This requires some understanding of AI and how it will interact with video content, a fundamental part of your app's functionality.

8. [ ] Add in a Database That Saves the Initial Summaries and Themes (Keywords)**: Essential for storing user data and preferences, which is important for personalized experiences.

9. [ ] Concise Summary First, Then Option to Furthermore Summarise Specifically**: Develop this feature as it's a key selling point of your app.

10. [ ] Functionality to Listen to the Transcript with an AI-Generated Voice**: This is a significant feature that will require some research and development.

### Long-Term Goals (2-6 Months)
- [x] **Incorporate Data Gained from the Summarisation to Give Tailored Adverts**: This involves both AI and understanding user data, which is more complex.

- [x] **Incorporate GPT into YouTube (Final Task)**: This is a major feature and should be tackled once you have a stable version of the app with basic functionalities.

- [ ] **AI Maintains a Conversation with the User with Knowledge of the Video**: This is an advanced feature and should be developed after the basic AI functionalities are stable.

14. **Implement Own API Key for Use by Everyone**: This is crucial for scaling up but should be done after ensuring that basic functionalities are working well.

15. **Market to Disabled People**: This is part of your marketing strategy but requires a stable, fully functional app.

16. **DALL-E Integration for Quick Pictures**: This is an advanced feature and should be tackled later in the development process.

17. **Incorporate Ad Revenue Which Runs While Waiting for the Response**: This is a monetization strategy that should be implemented once the app is functional and engaging.



## App development ideas

- [ ] AI THAT READS A BOOK AND TELLS YOU WHAT YOU WANT TO KNOW

- [ ] selection of noice voices for the AI

- [ ] suggest videos for user based on registeration details and videos summarised

- [ ] really personalise it, get user to register with likes and dislikes, asking questions to indicate their likes and dislike

- [ ] HAVE SUGGESTIVE VIDEOS TO USE IN THE URL-BOX. PICK DIFFERENT CATEGORY'S FOR RANDOM VIDEO FROM THE CATEGORY

- [ ] My own summary tokens to use my app?

- [ ] Summarise educational content(here's you bitesize version of this course)

- [ ] Incorporate GPT into YouTube

- [ ] functionality to read out a generated insight/brief

- [ ] Animation to swipe up to move on from rootview

- [ ] Brief Summarisation/Synopsis where a user has a choice to summarise more

- [ ] AI maintains a conversation with the user with knowledge of the video

- [x] Implement own API key for use by everyone

- [ ] TabView: https://www.youtube.com/watch?v=DLj9yM-zLyc: 

- [ ] Filter what the AI looks for in the video

- [ ] instead of putting in own api key, use mine 10 summarisations for basic plan and implement chance to get a higher paid plan

- [ ] incorporate data gained from the summarisation to give them tailored adverts

- [ ] chance to rate the video, and rate the summary for help with next summarisation

- [ ] Search the LLM for specific infomation which they want to learn

- [ ] Add in a database that saves the initial summaries and themes(keywords))

- [ ] Concise summary first, then opition to furthermore summarise specifcally

- [ ] When you push a summary, produce themes and keywords)

- [ ] Add recomendations for other videos to look at 

- [ ] Market to disabled people

- [ ] what do they do after they've saved the time

- [x] swipe between the views in the app

- [ ] Fix the swiping when reaching the last view on the right

- [ ] Brand as a podcast time saver("get all the infomation from a 2-hour long podcast in a minute")

- [x] Swipe between views that are on the tabview

- [ ]  makde tabview pop out with it's own background colour'

- [ ] Functionality to listen to the transcript with a AI generated voice, having options to have something else playing, such as a background noise to enhance focus(binarul beats 40hz). Have functionalties like an audio playing app

- [ ] dall-e integration for quick pictures made from the infomation of the transcript, have the pictures inside the insight summary labels

- [ ] Decide on a good colour combination

- [ ] Incorporate ad revenue which runs while waiting for the response, takes around 30-45 seconds

- [x] Investor Pitch: Use GPT to craft a compelling, cost-focused investment proposition. Target price: £7.99.

- [ ] finish investor pitch

Marketing:
1. Form a PLC.
2. Learn legal risks of AI
3. Market to university students at £7.99/year. Use demo videos and ads for promotion.


## AI Voice-Generated Transcript Playback:

This feature will use text-to-speech (TTS) technology to convert video transcripts into audio. Users can listen to the content of YouTube videos in an AI-generated voice. This is particularly useful for users who prefer audio content or are visually impaired.
Customizable Voice Options:

Users can choose from various AI voices for playback, allowing them to select a voice that is most pleasant or suitable for their listening experience.
Simultaneous Background Audio Playback:

Alongside the AI voice reading the transcript, users have the option to play background music or ambient sounds. This adds a layer of customization for the user, enhancing the listening experience.
Integrated Audio Player Functionality:

The app doubles as an audio player. Users can not only listen to AI-read transcripts but also play their own music or audio files within the app. This feature consolidates media consumption, making the app a one-stop solution for both informative and recreational listening.
Adjustable Audio Settings:

Users have control over the volume balance between the AI voice and the background audio. They can adjust these settings to ensure neither the voice nor the music/sounds overpower each other.
Playback Controls:

Standard playback controls (play, pause, stop, rewind, fast forward) are available for both the AI voice and background audio. This provides users with full control over their listening experience.

## Ad peronaliser
To create an algorithm that personalizes ad content based on a user's interaction with summarized YouTube video transcripts, you can follow these steps:

1. **Data Collection and Summarization Integration**: Collect data from the app that summarizes YouTube video transcripts. Focus on the types of videos users are summarizing, their engagement with the summaries, and any feedback they provide.

2. **User Interaction Analysis**: Analyze how users interact with the summaries. Look for patterns in the types of videos they frequently summarize, the length of summaries they prefer, and specific topics they focus on.

3. **Transcript Content Analysis**: Develop a system to understand the content of the video transcripts. This involves natural language processing (NLP) techniques to categorize content into themes, genres, and topics.

4. **User Preference Modeling**: Build models that link the types of summaries a user interacts with to their potential ad preferences. For instance, a user frequently summarizing tech-related videos might be interested in ads about new tech gadgets.

5. **Ad Content Categorization**: Similar to transcript content analysis, categorize available ad content into various themes and topics.

6. **Personalization Algorithm Development**: Create an algorithm that matches ad content with user preferences based on their interaction with video summaries. The algorithm should consider both the content of the summaries and the user’s engagement patterns.

7. **Machine Learning Implementation**: Use machine learning to refine the algorithm. It should learn from ongoing user interactions to improve its predictions over time.

8. **Feedback Loop and Adaptation**: Implement a system to capture user feedback on the ads shown (e.g., clicks, views, dismissals). Use this feedback to further refine the personalization algorithm.

9. **Privacy and Ethical Considerations**: Ensure the system respects user privacy and adheres to data protection regulations. Clearly communicate to users how their data is used for ad personalization.

10. **Performance Optimization**: Optimize the system for efficiency and scalability, ensuring it can handle a growing number of users and ad content.

11. **User Control Features**: Allow users to control their ad preferences, providing them with options to opt-out or modify the types of ads they want to see.

12. **Continuous Learning and Updating**: Regularly update the system to accommodate new content types, user behavior changes, and advancements in NLP and machine learning.

By following these steps, you can develop a sophisticated system that personalizes ad content based on user interactions with YouTube video summaries.



### Different types to call an insight

Synopsis: Indicates a brief summary of the main points or narrative of the video.
Summary: A straightforward term that conveys the essence of the video content in a condensed form.
Recap: Suggests a concise review or summary, often used to quickly convey key points.
Digest: Implies a condensed version of information that is easy to understand.
Overview: Offers a general description or summary of the video's content.
Essentials: Highlights the most important or fundamental aspects of the video.
Highlights: Focuses on the most significant or interesting parts of the video.
Key Takeaways: Emphasizes the main points or lessons to be learned from the video.
Briefing: Suggests a concise and informative summary, typically used in informational contexts.
Condensation: Implies a reduction of the content to its core elements, maintaining the essential points.

	




## Xcode shortcuts
- `cmd + 0` = show/hide navigator on left
- `cmd + option + 0` = show/hide inspector on right
- `cmd + shift + y` = show/hide console on bottom
- `option + click` = Quick documentation


## Prompts

> "I want you to act as a UX/UI developer. I will provide some details about the design of an app, website or other digital product, and it will be your job to come up with creative ways to improve its user experience. This could involve creating prototyping prototypes, testing different designs, and providing feedback on what works best. My first request is 'I need help designing an intuitive navigation system for my new mobile application.'"

## Design & Interaction

### Design Enhancements
- [ ] **Visual Appeal**: Enhance the interface's aesthetics.
- [ ] **Rounded Corners**: Soften the edges with modern, rounded corners.
- [ ] **Customize Layout**: Adapt the layout to suit the app's theme.
- [ ] **App Store Icon**: Utilize tools like hotspot, fastlane, and appscreens.

### User Interaction
- [ ] **Responsive Text**: Implement stylish, responsive disappearing text.
- [ ] **Quick Actions**: Facilitate fast actions (e.g., create workout, create meal).
- [ ] **Context Menus**: Enhance UX with context menus ([SwiftUI guide](https://swiftanytime.com/blog/contextmenu-in-swiftui)).

## Functionality & Content

### General Functionality
- [ ] **Async Processing**: Utilize asynchronous techniques where needed.
- [ ] **OpenAI Integration**: Notify users asynchronously when OpenAI responses arrive.
- [ ] **Profile Creation**: Use `user=user_id` for simpler identification.

### Content Management
- [ ] **Food Search**: Optimize searching for food items.
- [ ] **Question Boxes**: Provide for form, nutrition, and community-based queries.
- [ ] **Top Comments**: Implement Stack Overflow-like top comment functionality.
- [ ] **Advice Section**: Collate and share valuable advice.

## Health & Fitness Features
- [ ] **Exercise Management**: Facilitate new exercise introductions.
- [ ] **Meal Ideas**: Enable the addition of new meal ideas.
- [ ] **Haptic Feedback**: Implement feedback for rest intervals.
- [ ] **Goal Notifications**: Encourage users through goal-tracking push notifications.

## Miscellaneous
- [ ] **Clear GPT Conversation**: Provide specific user GPT conversation clearance.
- [ ] **Checkboxes**: Implement checkbox ticking from initial plans.
- [ ] **Sidebar/Footer**: Populate with app's functional elements.

## Animations

### Overview

Animations add life to user interactions and create a more engaging experience. Here are some creative ideas:

### Fluid Card Animation

1. **Description:** Fluid card animations create a smooth, liquid-like transition between states.
2. **Steps:** 
   - Create a `UIView` for the card.
   - Use `UIPanGestureRecognizer` to track gestures.
   - Apply `CABasicAnimation` to smooth out transitions.
3. **How to Implement:**
   ```swift
   let animation = CABasicAnimation(keyPath: "position")
   animation.fromValue = NSValue(cgPoint: fromPosition)
   animation.toValue = NSValue(cgPoint: toPosition)
   animation.duration = 0.5
   cardView.layer.add(animation, forKey: nil)

## Slide Animations

Slide animations are a great way to transition between views and give the user a sense of direction and connection between different parts of your app.

### Slide In

The Slide In animation can be used to make an element or view appear from off-screen. Here's how you can implement this in your iOS app:

```swift
UIView.animate(withDuration: 0.5) {
  view.frame.origin.x = 0
}
```

### Slide Out

The Slide Out animation is the opposite of the Slide In, where an element or view moves off-screen. Here's how you can implement this:

```swift
UIView.animate(withDuration: 0.5) {
  view.frame.origin.x = -view.frame.width
}
```

### Fade Animations

Fade animations create a smooth transition between element states, adjusting the transparency over time.

#### Fade In

Makes an element or view gradually appear:

```swift
UIView.animate(withDuration: 0.5) {
    view.alpha = 1.0
}
```

#### Fade Out

Makes an element or view gradually disappear:

```swift
UIView.animate(withDuration: 0.5) {
    view.alpha = 0.0
}
```

### Bounce Animations

Bounce animations give feedback to user actions by making elements move dynamically.

#### Bouncing Buttons

Make a button bounce when pressed:

```swift
UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
    button.transform = CGAffineTransform.identity
})
```

#### Bouncing Notifications

Make a notification or alert bounce into view:

```swift
// Similar to Bouncing Buttons but with different view and parameters.
```

### 3D Animations

3D animations add depth and perspective to elements.

#### 3D Flip

Create a 3D flip effect:

```swift
UIView.transition(with: view, duration: 1.0, options: .transitionFlipFromRight, animations: nil, completion: nil)
```

#### 3D Spin

Make an element spin around its axis:

```swift
let spinAnimation = CABasicAnimation(keyPath: "transform.rotation")
spinAnimation.fromValue = 0
spinAnimation.toValue = Double.pi * 2
spinAnimation.duration = 1
view.layer.add(spinAnimation, forKey: nil)
```

### Loading Animations

Provide feedback during operations that require waiting.

#### Spinning Wheel

A classic spinner:

```swift
let activityIndicator = UIActivityIndicatorView(style: .large)
activityIndicator.startAnimating()
view.addSubview(activityIndicator)
```

#### Progress Bar

Visual feedback on the progress of an operation:

```swift
let progressBar = UIProgressView(progressViewStyle: .default)
progressBar.setProgress(0.5, animated: true)
view.addSubview(progressBar)
```

### Interaction Animations

Enhance interactions with dynamic feedback.

#### Button Press Effects

Effects when a button is pressed:

```swift
// Similar to Bouncing Buttons with different parameters.
```

#### Swipe Gestures

Detect and respond to swipe gestures:

```swift
let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
swipeRight.direction = .right
view.addGestureRecognizer(swipeRight)
```

## Conclusion

Leveraging design enhancements, user interactions, robust functionality, and creative animations will contribute to a more intuitive and visually appealing app experience. Tailoring these ideas to the app's specific needs ensures a seamless user experience.

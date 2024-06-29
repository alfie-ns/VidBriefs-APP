//
//  APIManager.swift
//  Youtube-Summarizer
//
//  Created by Alfie Nurse on 02/09/2023.
//

import Foundation // Import Foundation(used for URLSession and JSON decoding)
import KeychainSwift // Import KeychainSwift(used for storing API keys)

enum TranscriptSource {
    case youtube
    case tedTalk
    //case vimeo
    //case coursera
    //case udemy
    //case khanAcademy
    //case skillshare
    //case researchPapers
    //case books
    //case articles
    //case blogs
    //case forums
    //case socialMedia
    //case newsArticles
    //case podcasts
    //case audiobooks
    //case interviews?
    //case documentaries
    //case webinars
    //case onlineCourses?
    //case onlineTutorials?
    // perhaps the AI, since it's on the users phone ios app, it can copy text directly from the users phone
    
}

struct APIManager {
    static var currentConversationId: UUID? //

    class ConversationHistory {
        private static var conversations: [UUID: [[String: String]]] = [:]
        
        static func createNewConversation() -> UUID {
            let id = UUID()
            conversations[id] = [["role": "system", "content": "You are a helpful assistant that provides insights about YouTube videos."]]
            return id
        }
        
        static func clear() {
            conversations.removeAll()
        }
        
        static func addUserMessage(_ message: String, forConversation id: UUID) {
            conversations[id, default: []].append(["role": "user", "content": message])
        }
        
        static func addAssistantMessage(_ message: String, forConversation id: UUID) {
            conversations[id, default: []].append(["role": "assistant", "content": message])
        }
        
        static func addSystemMessage(_ message: String, forConversation id: UUID) {
            conversations[id, default: []].append(["role": "system", "content": message])
        }
        
        static func getMessages(forConversation id: UUID) -> [[String: String]] {
            return conversations[id] ?? []
        }
        
        static func clearConversation(_ id: UUID) {
            conversations.removeValue(forKey: id)
        }
    }
    
    private static var keychain = KeychainSwift() // Create a KeychainSwift object to store API keys -> secure storage of API keys

    static var openai_apikey: String {
        ProcessInfo.processInfo.environment["openai-apikey"] ?? ""
    }
    
    // Structure to store and manage request timestamps to only allow less than 3 requests a month
    struct RequestTracker {
        static var timestamps: [Date] = [] // Array to store request timestamps

        static func cleanUpOldTimestamps() { // Function to remove timestamps older than a week
            timestamps = timestamps.filter { Date().timeIntervalSince($0) < 604800 } // 604800 seconds in a week
        }

        static func isRequestAllowed() -> Bool { // bool function to check if request is allowed
            cleanUpOldTimestamps() // Clean up old timestamps before checking
            return timestamps.count < 3 // Return true if less than 3 requests have been made in the last week
        }

        static func addTimestamp() { // func to append a new timestamp to the timestamps array
            timestamps.append(Date())
        }
    }
    
    // Defines a structure for decoding JSON responses related to video transcripts.
    struct TranscriptResponse: Decodable {
        //let title: String   FIX [ ]    // Holds the title of the video.
        let transcript: String  // Contains the transcript text of the video.
    }

    // Defines a structure for decoding JSON responses related to video captions.
    struct CaptionResponse: Decodable {
        let kind: String        // Specifies the type of the response.
        let items: [Item]       // An array of 'Item' structures representing individual captions.
    }

    // Represents an individual caption item in the caption response.
    struct Item: Decodable {
        let id: String          // Unique identifier for the caption item.
    }

    // Defines a structure for holding snippet information of a video.
    struct Snippet: Decodable {
        let videoId: String  // The unique identifier of the video associated with this snippet.
    }
    
    func retrieveOpenAIKey() -> String? { // Function to retrieve the OpenAI API key from the keychain
        return ProcessInfo.processInfo.environment["openai-apikey"] // Return the OpenAI API key from the environment
    }
    
    static func addSystemMessage(_ message: String, forConversation id: UUID) {
        ConversationHistory.addSystemMessage(message, forConversation: id)
    }
    

    // Function to handle all custom insight requests from API for transcript to turn into an insight
    static func handleCustomInsightAll(url: String, source: TranscriptSource, userPrompt: String, completion: @escaping (Bool, String?) -> Void) {

        // Step 0: Init conversation history
        // ----------------------------------
        ConversationHistory.clear()
        ConversationHistory.addUserMessage(userPrompt, forConversation: APIManager.currentConversationId ?? UUID())
        // Begin the conversation with the user prompt

        // Step 1: Get the entire transcript
        // ----------------------------------

        // Choose the appropriate function to fetch the transcript based on the source
        switch source {
        case .youtube:
            GetTranscript(yt_url: url) { (success, transcript) in
                processTranscriptFetchResult(success: success, transcript: transcript, userPrompt: userPrompt, completion: completion)
            }
        case .tedTalk:
            GetTedTalkTranscript(ted_url: url) { (success, transcript) in
                processTranscriptFetchResult(success: success, transcript: transcript, userPrompt: userPrompt, completion: completion)
            }
        }
    }

    private static func processTranscriptFetchResult(success: Bool, transcript: String?, userPrompt: String, completion: @escaping (Bool, String?) -> Void) {
        if success, let transcript = transcript {
            print("Transcript: \(transcript)")

            let words = transcript.split(separator: " ")
            print("Words in transcript: \(words.count)")

            if words.count < 120000 {
                print("one-prompt summarisation")

                fetchOneGPTSummary(transcript: transcript, customInsight: userPrompt) { finalSummary in
                    if let finalSummary = finalSummary {
                        completion(true, finalSummary)
                    } else {
                        completion(false, "GPT could not be reached, check the API key is correct")
                    }
                }
            } else if words.count > 12000 {
                print("Chunk summarisation")
                let chunks = breakIntoChunks(transcript: transcript)
                fetchGPTSummaries(chunks: chunks, customInsight: userPrompt) { (finalSummary) in
                    if let finalSummary = finalSummary {
                        completion(true, finalSummary)
                    } else {
                        completion(false, "GPT could not be reached, check the API key is correct")
                    }
                }
            } else {
                print("Error")
            }
        } else {
            completion(false, "Could not get the transcript, check the url is correct")
        }
    }
    
   static func fetchOneGPTSummary(transcript: String, customInsight: String, completion: @escaping (String?) -> Void) {
        let apiUrl = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openai_apikey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 300.0

       ConversationHistory.addUserMessage("Please summarize this YouTube video transcript: \(transcript). Only after you have fully traversed the entire transcript, answer the user's question regarding the video using parts of this: \(customInsight).", forConversation: APIManager.currentConversationId ?? UUID())

        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": ConversationHistory.getMessages(forConversation: APIManager.currentConversationId ?? UUID())
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let choices = json["choices"] as? [[String: Any]], let message = choices.first?["message"] as? [String: Any], let text = message["content"] as? String {
                    ConversationHistory.addAssistantMessage(text, forConversation: APIManager.currentConversationId ?? UUID())
                    completion(text)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }


    static func fetchGPTSummaries(chunks: [String], customInsight: String, completion: @escaping (String?) -> Void) {
        
        let apiUrl = URL(string: "https://api.openai.com/v1/chat/completions")! // OpenAI API url
        var summaries: [String] = [] // Summary list created for each seperate summary
        let dispatchGroup = DispatchGroup() // Create a new DispatchGroup to manage a set of related, asynchronous tasks.
        
        

        print("Before fetchGPTSummaries for loop")
        
        for (index, chunk) in chunks.enumerated() { // For each index(to count the chunks) and chunk
            dispatchGroup.enter() // Enter DispatchGroup
            print("Entered Dispatch Group for chunk \(index + 1)") // Log numbered interation of the loop
//          let openai_apikey = UserDefaults.standard.string(forKey: "openai_apikey") ?? "" // Use users API key [X] [ ] store in keychain
            
            // Create request to OpenAI
            var request = URLRequest(url: apiUrl)
            request.httpMethod = "POST" // POST request
            request.addValue("Bearer \(openai_apikey)", forHTTPHeaderField: "Authorization") // User's API key as http header
            request.addValue("application/json", forHTTPHeaderField: "Content-Type") //
            request.timeoutInterval = 300.0 // Long interval to prevent long response timeout
            
            // Create list called systemMessages with each necessary system message for the iterated GPT call
            var systemMessages: [[String: String]] = [
                ["role": "system", "content": String(format: "Start of loop %d", index + 1)],
                ["role": "system", "content": """
                    You have been asked to extract specific information from a YouTube video transcript.
                    The transcript is divided into multiple chunks, and you must process each chunk individually.

                    Your task is to follow these steps:
                    - Review each chunk of the transcript and identify every concise piece of information that aligns with the given user prompt.
                    - After processing all chunks, summarise all relevant information you have found in a single response.
                    - Use only the information found in this transcript for your response.

                    Remember, because you have to process each node individually, you must provide a summary for each chunk which answers the user's question.

                    Your guiding rule, as defined by the user, is: \(customInsight)
                """],
                ["role": "system", "content": String(format: """
                    You are iterating over each chunk of a YouTube video transcript.
                    You are interpreting chunk %d out of %d.
                    You must note the information in this chunk regarding the user's prompt: (%@).
                    The next message contains the chunk content.
                """, index + 1, chunks.count, customInsight)],
                ["role": "system", "content": String(format: "CHUNK %d: %@", index + 1, chunk)],
                ["role": "system", "content": String(format: "End of loop %d", index + 1)]
            ]
            
            // Checks for last chunk
            if index == chunks.count - 1 { // if index is the last chunk 
                systemMessages.append(["role": "system", "content": "This is the final chunk of the entire video transcript. Please identify the last few sentences relative to all of the chunks if needed, to structure the summarisation to be as close as to the users wish as possible"]) // Append warning that final loop is now
            }
            
            // Request Body for OpenAI API call
            let requestBody: [String: Any] = [
                
                "model": "gpt-4o", // [ ] OPTION TO CHANGE TO 3.5
                "messages": systemMessages // Pass systemMessages list as messages for API call
            ]
            
            // Try serialize JSON and if faild catch print that
            do { // try and if fail catch
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            } catch { // error
                print("Failed to serialize JSON")
                completion(nil)
                return
            }
            // Attempt final stage of API call and check for 401 error
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                // Check for HTTP response and handle 401 Unauthorized error
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    print("Unauthorized: Invalid OpenAI API key.") // Log unauthorized access
                    completion(nil) // Complete with nil due to error
                    dispatchGroup.leave() // Signal that this async task is done
                    return
                }

                // Log the full API response for debugging
                print("API Response: \(String(describing: response))")
                // Attempt to convert data to a UTF-8 string and log it
                if let unwrappedData = data, let dataString = String(data: unwrappedData, encoding: .utf8) {
                    print("API Data String: \(dataString)")
                }

                // Attempt to parse the JSON data returned from the API
                do { // try and if fail catch
                    // Deserialize JSON into a dictionary and check for expected structure
                    if let unwrappedData = data, let json = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any] {
                        print("Parsed JSON: \(json)") // Log the parsed JSON
                        // Navigate through the JSON structure to extract the summary text
                        if let choices = json["choices"] as? [[String: Any]],
                           let message = choices.first?["message"] as? [String: Any],
                           let text = message["content"] as? String {
                            summaries.append(text) // Append the summary text to summaries array
                        } else {
                            // Log an error if the expected summary text structure is not found
                            print("Failed to extract summary text for chunk \(index + 1)")
                        }
                    } else {
                        // Log an error if JSON data could not be cast to a dictionary
                        print("Failed to cast JSON for chunk \(index + 1)")
                    }
                } catch let jsonError {
                    // Log parsing error details
                    print("Failed to parse JSON for chunk \(index + 1) due to error: \(jsonError)")
                }
                // Indicate that this part of the task is complete
                dispatchGroup.leave()
            }
            // Start the network task
            task.resume()
        }
        
        // SECOND OPENAI CALL TO SUMMARISE SUMMARISED CHUNKS
        // -------------------------------------------------
            
            // After all tasks in the dispatch group have completed, this block will be executed
            dispatchGroup.notify(queue: .main) {
                let intermediateSummary = summaries.joined(separator: "\n") // Combine all summaries into one string
                var request = URLRequest(url: apiUrl) // Prepare a new URLRequest for the OpenAI API
                request.httpMethod = "POST" // Set the HTTP method to POST
                request.addValue("Bearer \(openai_apikey)", forHTTPHeaderField: "Authorization") // Include the API key in the request headers
                request.addValue("application/json", forHTTPHeaderField: "Content-Type") // Set the content type of the request to JSON
                request.timeoutInterval = 300.0 // Set a timeout interval of 5 minutes
                
                // Construct the body of the request with the task and the summaries
                let requestBody: [String: Any] = [
                    
                    "model": "gpt-4o", // Specify  model to use
                    "messages": [["role": "system", "content": """
                                
                                  Your task is now to summarise all the relevant pieces
                                  and append each part of the information you have found in a single response.
                                
                                  Listed summary information: \(intermediateSummary)
                                  Users prompt: \(customInsight)
                                
                                """]] // Provides the context and the task for the model
                ]
                
                // serialise the request body to JSON
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
                } catch {
                    print("Failed to serialize JSON for final summary") // Log serialization error
                    completion(nil) // Complete with nil due to error
                    return
                }
                
                // Perform the network task to get the final summary
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    do {
                        // Attempt to deserialize the JSON response
                        if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            // Extract the summary text from the JSON response
                            if let choices = json["choices"] as? [[String: Any]],
                               let message = choices.first?["message"] as? [String: Any],
                               let text = message["content"] as? String {
                                completion(text) // Pass the final summary to the completion handler
                            } else {
                                print("Failed to extract final summary text.") // Log an error if the summary text is not found
                                completion(nil) // Complete with nil due to error
                            }
                        } else {
                            print("Failed to cast JSON for final summary.") // Log an error if JSON casting fails
                            completion(nil) // Complete with nil due to error
                        }
                    } catch let jsonError {
                        print("Failed to parse JSON for final summary due to error: \(jsonError)") // Log JSON parsing error
                        completion(nil) // Complete with nil due to error
                    }
                }
                task.resume() // Start the network task
            }
        }

    
    // GET TRANSCRIPT API CALL
    static func GetTranscript(yt_url: String, completion: @escaping (Bool, String?) -> Void) {
        
        let getTranscriptUrl = URL(string: "http://127.0.0.1:8000/youtube/get_youtube_transcript/")! // '!' means 'must have a value
        //let getTranscriptUrl = URL(string: "http://34.66.187.223:8000/response/get_youtube_transcript/")!
        
        // Makes request to the api for youtube transcript
        var request = URLRequest(url: getTranscriptUrl) // Create a new URLRequest object with the given URL
        request.httpMethod = "POST" // POST request
        request.timeoutInterval = 3000 // Long interval to prevent long response timeout
        
        // Give the youtube url to api as a parameter in the api call
        let parameters: [String: Any] = [
            "url": yt_url
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Initiates a URLSession data task with the given request. Upon completion,
        // it checks for a valid HTTPURLResponse and passes a failure message if not received.
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, "Fetch failed.")
                return
            }
            
            // Switch between each case
            switch httpResponse.statusCode {
            case 200...299: // Status codes indicating success
                // If data = the data given back by the API call
                if let data = data {
                    
                    do { // Do the following
                        // Decode the data received from API and save as decodedData
                        let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                        // If can decode response data, save to responseString
                        if let responseString = decodedData["response"] {
                            // API call completed successfully, return the response string
                            completion(true, responseString)
                        } else {
                            // Key 'response' not found in decoded data, return an error
                            completion(false, "Key not found.")
                        }
                    } catch { // Catch and handle errors in decoding
                        // Decoding the JSON failed, return an error
                        completion(false, "Decoding failed.")
                    }
                } else {
                    // No data was returned by the API call, return an error
                    completion(false, "No data.")
                }
            default: // Any other status codes indicate a failed fetch
                // The fetch did not succeed, return an error
                completion(false, "Fetch failed with status code: \(httpResponse.statusCode).")
            }
        }.resume() // Resume the task if it's in a suspended state; this starts the network call
    }

    // NEW - TEST [ ] 
    static func GetTedTalkTranscript(ted_url: String, completion: @escaping (Bool, String?) -> Void) {

        let getTedTalkTranscriptUrl = URL(string: "http://127.0.0.1:8000/ted_talks/get_tedtalk_transcripts/")! // Adjust the URL to your Django endpoint

        var request = URLRequest(url: getTedTalkTranscriptUrl)
        request.httpMethod = "POST"
        request.timeoutInterval = 3000

        let parameters: [String: Any] = [
            "url": ted_url
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, "Fetch failed.")
                return
            }

            switch httpResponse.statusCode {
            case 200...299:
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                        if let responseString = decodedData["response"] {
                            completion(true, responseString)
                        } else {
                            completion(false, "Key not found.")
                        }
                    } catch {
                        completion(false, "Decoding failed.")
                    }
                } else {
                    completion(false, "No data.")
                }
            default:
                completion(false, "Fetch failed with status code: \(httpResponse.statusCode).")
            }
        }.resume()
    }
    
    // BREAK TRANSCRIPT INTO CHUNKS
    // Break into chunks and process an entire video transcript if token length exceeds 80,000
    static func breakIntoChunks(transcript: String, maxTokens: Int = 80000) -> [String] {

        var chunks: [String] = [] // Holds the chunks of transcript text
        let words = transcript.split(separator: " ") // Splits transcript into words
        var chunk: [String] = [] // Temp storage for the current chunk
        var tokenCount: Int = 0 // Tracks the number of tokens in the current chunk

        // Loop through each word in the transcript
        for word in words {
            let currentWordTokenCount = 1 // Pretend each word counts as one token
            // Check if adding the current word keeps us under the max token limit
            if tokenCount + currentWordTokenCount <= maxTokens {
                chunk.append(String(word)) // Add word to current chunk
                tokenCount += currentWordTokenCount // Update token count
            } else {
                chunks.append(chunk.joined(separator: " ")) // Chunk's full, add it to chunks array
                chunk = [String(word)] // Start a new chunk with the current word
                tokenCount = currentWordTokenCount // Reset token count for new chunk
            }
        }
        
        // Catch any remaining words that didn't make the last full chunk
        if !chunk.isEmpty {
            chunks.append(chunk.joined(separator: " ")) // Add final chunk to chunks array
        }
        
        return chunks // Send back all the chunks made
    }

    static func chatWithGPT(message: String, conversationId: UUID, completion: @escaping (String?) -> Void) {
        let apiUrl = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openai_apikey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 300.0

        // Add the new user message to the conversation history
        ConversationHistory.addUserMessage(message, forConversation: conversationId)
        
        let messages = ConversationHistory.getMessages(forConversation: conversationId)
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": messages
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Error serializing request body: \(error)")
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error in API call: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received from API")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    // Add the AI's response to the conversation history
                    ConversationHistory.addAssistantMessage(content, forConversation: conversationId)
                    completion(content)
                } else {
                    print("Unexpected JSON structure")
                    completion(nil)
                }
            } catch {
                print("Error parsing JSON: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }

}

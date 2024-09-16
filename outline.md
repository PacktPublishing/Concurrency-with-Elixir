Drive
<https://drive.google.com/drive/folders/1PS94_ABD0Bl6V5MPTCHP5ybt6582EhPx>

Guy:

1. Overview
2. Examples
6. GenStage
9. Flow

Everett:

3. Tasks
4. Supervisors: when tasks get more complex
5. Concurrency: more advanced primitives
7. Broadway
8. Oban

<https://docs.google.com/document/d/1FImQ3wGeHQGyNWIeOMQHmjt6FVuvs9q7uN1vgS80RHg/edit>

Title: Learning Concurrency with Elixir
Subtitle:
ABOUT THE AUTHORS

Guy Argo
Guy Argo is a functional programming veteran having studied a Ph.D. under Prof John Hughes at The University of Glasgow back in 1986. He’s a programming language nerd having coded in C++, Java, Python and Ruby before finally returning to his functional programming roots by adopting Elixir. When he’s not hacking Elixir,  you can find him playing pool, chess, and racing old cars. He lives in San Francisco with his two cats, Jean and Agnes.

Everett Griffiths
Everett Griffiths is polyglot developer and instructor with over 20 years of experience.  He has worked in Elixir, PHP, Python, Node, and Ruby for startups and large publicly traded companies.  He has taught software development courses at the University of Southern California and the University of California, Berkeley.  Everett is passionate about writing clean, performant code.
The Book’s Goal
A good tech book needs to be more than an arbitrary list of topics. Our most successful books are all written with a specific audience in mind: it’s more than just people who want to learn the tech, it’s people who want to solve a problem. Before you start planning out the structure of your book, let’s think about the challenges facing your readers and how this title will help them overcome them. Here are a few questions to help us understand the book’s ideal market - for each one replace the example with your own answers:

What kind of individual would be interested in this book?
Moore’s law states that the number of transistors on an integrated circuit will double every two years. Many thought this would cause processor speed to double every two years too but recently it has hit a physical limit: processors are getting too hot. Instead, chip manufacturers are doubling the number of cores every two years.

So programmers must learn a new skill if they are to leverage the continued improvement in processing power in new hardware: namely concurrency.

Thus the readership for this book is any elixir programmer who wishes to use his hardware to its full potential.

What knowledge do they need before they start reading?
A basic understanding of Elixir syntax and semantics and a rudimentary knowledge of programming.
Why should they buy this book?

See above comment about Moore’s law.

Any elixir programmer who wants to leverage the full potential of modern hardware needs this book.
What is the product approach and USP of the book?
USP = Unique Selling Point
Walk the reader through various built-in and third party  libraries that make crucial use of concurrency. No other book directly tackles the topic of concurrency in Elixir.
Product Breakdown: In 2 sentences, describe the “journey” the book takes the reader on. Look at your section headings for help
The book walks you through various packages and third party libraries in the Elixir ecosystem that allow the reader to leverage concurrency to its maximum potential
By the end of this book you will...
By the end of this book you will have understood Elixir’s approach to concurrency and how to apply it to real world problems so that your application can fully exploit the potential of modern hardware

COMPETITIVE BOOK TITLES
What is unique about your book? You will need to look on Amazon at books that have been well-received – what are the top three market-leading books that your book will compete with?  Examine the description, table of contents, and book reviews.

List the books here:

1
Elixir in Action
2
Programming Elixir by Dave Thomas
3
Elixir programming: Mastering Scalability and Concurrency
4

Please ensure that you have looked at the description, table of contents, and book reviews for each of these books.
The Book Structure
To help you understand the ideal structure and pacing of a good book, we’ve created a short course to help you when plotting out your book. You can find it on our community site, here: Outline Course. Your contact at Packt will be able to help you get set up on our community site. The course itself is short and will aid you significantly when planning your outline.
Parts and Chapters
Packt books are normally divided into 3 or 4 parts, each consisting of 3-5 chapters. These “parts” are a group of chapters that work toward the same goal. The learning outcomes you listed previously will help to inform these. For example: A book on using IoT with AWS might be split into 3 parts: Part 1: Choose, connect, and control the right IoT device; Part 2: Route, persist, and analyze IoT data; Part 3: Commission, provision, and effectively manage IoT device fleets. Each one of these parts covers a number of chapters, as you’ll see in the next section.
Chapter Outline
Each chapter should have a clear focus. Each chapter title should clearly state what aspect of the overall topic the chapter deals with. Continuing the example above your section on choosing the right IoT device might be broken down into 4 chapters as follows: “Connecting and Controlling Devices for the First Time”, “How to choose the right IoT device and device software”; “Building constrained IoT devices with FreeRTOS”; “Building progressive applications with AWS IoT Greengrass”.

Have a go at listing your chapters in the tables below, divided into different parts. The first table has been filled out using the example above; replace these examples with your chapters. PLEASE NOTE: Chapter titles appear on Amazon.

Part 1:  Getting Started
1
Concurrency: Overview
2
Concurrency: Examples You may Already be Familiar With
3
The Task module

Part 2: Advanced Topics
4
Supervisors: When your Tasks are more complex
5
Concurrency: More Advanced Primitives
6
Built-In: GenStage
7
Package: Broadway
8
Package: Oban
9
Package: Flow

Detailed Outline
Now it’s time to plan out your chapters in more detail. In the following section you will have the opportunity to list what each chapter does and what the user is gaining from it. The first one has been filled out using the example above. Use this as a template and add as many additional chapters as you need.

Chapter 1: Concurrency: Overview
[] pages

Description: Introduction to the core concepts of concurrency and how it is used as a tool to do distributed work.  Special attention given to Elixir’s DNA and why it is well suited to solve this type of problem.

Chapter Headings (3-5 main chapter headings)

Concurrency vs. Parallelism? Distributing workloads
Actor model + message passing and the benefits of functional programming
Primitives (send and receive)

Skills learned: For each heading, insert what the reader will learn to DO in this chapter?

Understand how to model distributed work
Send messages between processes

Chapter 2: Concurrency: Examples You may Already be Familiar With
[] pages

Description: Readers are already familiar with many concurrent tasks even though they may not have noticed it.  This chapter explains some of the landmarks that the reader may already be familiar with.

Chapter Headings (3-5 main chapter headings)

First example: Elixir compilation!
Concurrency in Tests: async true vs. async false
Concurrency in Logging: async, non-blocking code
Concurrency in database connection pools (DBConnection)
Concurrency in handling HTTP requests (bandit)
Visualizing your processes (supervision tree) with observer

Skills learned: For each heading, insert what the reader will learn to DO in this chapter?

Gain familiarity with with familiar problems that have been solved using concurrency
Understand the structure of the code that enables concurrency

Chapter 3: The Task module
[] pages

Description: The cornerstone of leveraging concurrency in Elixir

Chapter Headings (3-5 main chapter headings)

Using Task.async_stream to solve embarrassingly parallel problems
Task.async + Task.await vs Task.yield – compare to Node?
Task scheduling (Process.send_after)

Skills learned: For each heading, insert what the reader will learn to DO in this chapter?

Easy Elixir recipes for doing concurrent tasks
Schedule work for later

Chapter 4: Supervisors: When your Tasks are more complex
[] pages

Description: When tasks become more complex and work takes longer to complete, they will inevitably fail. This chapter introduces another core Elixir component: Supervisors. This is how we manage long-running work and ensure that our code gets back in the saddle if it ever crashes.

Chapter Headings (3-5 main chapter headings)

It’s ok to fail: the Philosophy of Failure
When and how to supervise (strategy: one_for_one, ignore, etc)
Task.Supervisor.async_stream_nolink
Registries

Skills learned: For each heading, insert what the reader will learn to DO in this chapter?

Understand when tasks require supervision and how to configure it.
Recipes for defining supervised work
Understand how to build and populate registries to keep track of multiple processes

Chapter 5: Concurrency: More Advanced Primitives
[] pages

Description: Elixir’s built-in capacity for dealing with tasks and supervising them goes beyond just structuring a single application: it offers conventions and protocols that allow multiple applications and machines to communicate together.

Chapter Headings (3-5 main chapter headings)

Structuring a distributed network
Sending messages between nodes
Registries Redux

Skills learned: For each heading, insert what the reader will learn to DO in this chapter?

Send messages between Elixir applications
Send messages between Elixir nodes
Track processes in registries that span multiple nodes

Chapter 6: Built-In: GenStage
[] pages

Description: GenStage is an Elixir construct with no direct Erlang equivalent: understanding its components is critical to understanding the architecture of other distributed solutions.

Chapter Headings (3-5 main chapter headings)

Terminology: Producers and Consumers
Use Cases: DIY
How to configure the number of Producers and Consumers

Skills learned: For each heading, insert what the reader will learn to DO in this chapter?

Build an Elixir app using GenStage components
Configure the GenStage configuration to optimize work performance.

Chapter 7: Broadway
[] pages

Description: Broadway is an add-on Elixir package that offers a streamlined solution for certain tasks, often used for draining queues .

Chapter Headings (3-5 main chapter headings)

Intro: The evolution of GenStage; managing backpressure
Use Cases: All about Draining Queues
Examples

Skills learned: For each heading, insert what the reader will learn to DO in this chapter?

Understand the types of problems for which Broadway is a good solution.
Set up and configure a Broadway application.

Chapter 8: Oban
[] pages

Description: Oban leverages PostGreSQL to track asynchronous work. It offers an alternative to queue-based solutions and can offer greater visibility.

Chapter Headings (3-5 main chapter headings)

Intro: background job system leveraging postgresql
Use Cases
Examples

Skills learned: For each heading, insert what the reader will learn to DO in this chapter?

Understand the types of problems for which Broadway is a good solution.
Set up and configure a Broadway application.

Chapter 9: Flow
[] pages

Description: Flow is another 3rd-party Elixir package that stands on the shoulders of GenStage. Like the Enum and Stream modules, it targets collections, offering flexibility for dealing how the concurrent work is approached.

Chapter Headings (3-5 main chapter headings)

Introduction
Understanding Concurrency with Flow
Practical Examples and Use Cases
Flow Operators and Functions
Performance Considerations and Best Practices

Skills learned: For each heading, insert what the reader will learn to DO in this chapter?

Understand how to leverage Flow for efficient concurrent processing of data, improving performance and scalability.
Learn how to apply Flow to real-world scenarios, extracting maximum benefit from its features.
Acquire techniques for optimizing performance and designing efficient data processing pipelines using Flow, ensuring smooth and reliable operation in production environments.

– end of outline –
Community outreach (optional)
Technical Reviewers
Can you recommend peers and members of your community to become technical reviewers?

Full name
Email Address
LinkedIn Profile
1.

2.

3.

Amazon Reviewers
Can you recommend peers and members of your community to leave Amazon reviews?

Full name
Email Address
LinkedIn Profile

Influencers
Can you recommend any influential community members or organizations for Packt to collaborate with on the marketing campaign of your title?

Full name
Email Address
LinkedIn Profile
1.

2.

3.

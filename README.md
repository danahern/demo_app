Dan Ahern's Demo Application
========

Description
--------
Demo application that uses the github API to perform various actions surrounding starred repositories.

What is this
--------
This is a code challenge, the goal was to spend a few hours and write website that used the github API.  It would allow someone to view and manage their github respositories.

Stats
```Text
Test Coverage: 72.83%
Lines of Code: 67 (tested) / 92 (total)
Time Spent: 5 hours
```

Challenge
-------
Build a Ruby on Rails application that lets someone view and manage their starred GitHub repositories.

The application should have the following features:

1. A view of all of the users starred repos.
2. The ability to unstar a repo.
3. A search interface to find new repositories, which you can star.
4. Real-time display of newly starred repositories.
    a. If a user stars a repo in the GitHub UI it should show up in your app without having to refresh the browser.

Bonus Points - Recommend Repos
1. Build a feature that recommends public github repositories based on your starred repos.


Requirements
--------
Redis

Github Application key and secret (https://github.com/settings/applications/new)

Installation
--------
```
cp config/database.yml.example config/database.yml
```

```
cp config/application.yml.example config/application.yml
```

Edit the database.yml file to match up with your database (I'm using a mysql database you made need to change the gemfile if you're running something different).

Edit the application.yml file to add in your github application key and secret. (Make sure you point the application to wherever you're going to be running the server.)

Start the server up (rails s)

Run the resque processor (rake resque:work QUEUE=recommendations)

Enjoy!

Testing
--------
Here are the commands to get testing up and working.

```
rake db:create
rake db:migrate
rake db:test:prepare
rake
```

Guard is also being used for automated test reloading

```
guard -c
```

Notes
==========

Decisions
---------
I decided to move the recommendation generator into a background processor because in the real world this would give me freedom to email out when recommendations are generated as well as work within the confines of githubs rate limiting.  I have found the recommendations to be pretty good for my own starred repos, however YMMV.

I used twitter bootstrap to keep a consistent look between github and the site (I used the default theme for bootstrap similar to what github uses).  The result is a very smooth flow between the two sites.

I chose to focus most of my tests on the models.  I started testing the controllers too, and may possibly continue later, but the controllers are, for the most part, relying on the models for all their logic so testing the models should provide fairly strong regression protection coverage.


Ajax
---------
In several areas I am reloading the website via ajax every 30 seconds.  This will provide you with an appearance of new data by just leaving your browser open.

Recommendations
------------
With the recommendations it will generate them for you when you hit the recommendations page.  This will display a loading bar until it automatically reloads and has the new recommendations.

Recommendations right now are set to be generated every hour.  If you hit the link and you don't have 'stale' enough recommendations then it will display them for you and won't write a task to the background processor.  However if the recommendations are stale or if you don't have any then it will right the task to the background processor.
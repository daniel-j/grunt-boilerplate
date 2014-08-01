[![Built with Grunt](https://cdn.gruntjs.com/builtwith.png)](http://gruntjs.com/)

Grunt Boilerplate with CoffeeScript, LESS, eco, Jade and Backbone+Marionette
====

Installation
====

Install grunt-cli and bower:

$ sudo npm install -g grunt-cli bower

$ npm install && bower install && grunt bower:install

Usage
===

To build the app in development, run:

$ grunt

And in production:

$ NODE_ENV=production grunt

To run in watch mode, use the edit task:

$ grunt edit

If you run in watch mode, you may run into this error: http://stackoverflow.com/questions/16748737/grunt-watch-error-waiting-fatal-error-watch-enospc

A simple, extendable messaging system designed for deployments

Usage
=====
    gem install envoy (use sudo if not using RVM)
    require 'envoy'

Create a new messenger
----------------------
    messenger = Envoy::Messenger.new

Define some transports
----------------------
    messenger.transports.each do |transport|
      transport.add_transport(:campfire, :account => 'foo', :token => 'bar', :room => 'my_room')
    end

OR

    messenger.transport(:campfire, :account => 'foo', :token => 'bar', :room => 'my_room')

Add some messages
-----------------
    messenger.messages.each do |message|
      message.add_message(:name => 'Start deployment message', :subject => "Carlos started deployment of branch foo to production at #{Time.now}")
      message.add_message(:name => 'End deployment message', :subject => "Carlos ended deployment of branch foo to production at #{Time.now}")
    end

OR

    messenger.message(:name => 'Start deployment message', :subject => "Carlos started deployment of branch foo to production at #{Time.now}")

Deliver messages one at a time
------------------------------

    messenger.deliver_start_deployment_message

AND THEN

    messenger.deliver_end_deployment_message

Deliver all messages
--------------------

    messenger.deliver_all_messages

Email, Campfire, and Webhook Transports are included. Create your own by inheriting from Envoy::Transport

Sample Capistrano Usage
=======================

    begin
      require 'envoy'
      set :envoy_loaded, true
    rescue LoadError
      set :envoy_loaded, false
    end

    if envoy_loaded
      set :messenger, Envoy::Messenger.new
      set :git_username, `git config user.name`.gsub("\n", '')
      messenger.transport :name => :campfire, :account => [YOUR ACCOUNT HERE], :token => [YOUR TOKEN HERE], :use_ssl => true
    else
      set :messenger, nil
    end

    before :deploy do
      if messenger
        messenger.message :name => :start_deployment,
          :subject => "#{git_username} started deployment of branch master to production for project Foo at #{Time.now}"
        messenger.deliver_start_deployment
      end
    end

    after :deploy do
      if messenger
        messenger.message :name => :end_deployment,
          :subject => "#{git_username} ended deployment of branch master to production for project Foo at #{Time.now}"
        messenger.deliver_end_deployment
      end
    end

Thanks
------

Thanks to [Robby Russell](http://robbyonrails.com) for beta testing

Copyright
---------

**Envoy** is Copyright (c) 2010 [Carlos Rodriguez](http://eddorre.com), released under the MIT License.
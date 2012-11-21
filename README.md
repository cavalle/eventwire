# Eventwire: Event Collaboration for the Masses[ ![Build Status](https://secure.travis-ci.org/cavalle/eventwire.png?branch=master)](http://travis-ci.org/cavalle/eventwire)

Eventwire is a generic and simple interface to various backends (AMQP, Redis, ZeroMQ, MongoDB) to help building event-driven systems

_**WARNING:** This gem is in a very early stage of development. No first version has been released yet. That means that some of things described in this file might not be implemented, and those which are, might not be production ready._

<img src="http://dl.dropbox.com/u/645329/eventwire.jpg" />

## What is Event Collaboration?

> When we have components that collaborate with each other, whether they be as small objects in a single address space or as large as application communicating across the Internet, we commonly think of their style of collaboration as being driven by requests. One component needs information that another has, so the needier component requests it, if then that component needs another to do something, out goes another request.

> Event Collaboration works differently. Instead of components making requests when they need something, components raise events when things change. Other components then listen to events and react appropriately. Event Collaboration leads to some very different ways of thinking about how parts need to think about their interaction with other parts.

_See the complete [Martin Fowler's article][1] for a comprehensive explanation._

For example, a Project Management System might publish events when tasks are marked as completed, like this:

    class Task
      include Eventwire::Publisher

      def mark_as_complete!(user)
        @completed = true
        publish_event :task_completed, :task_name => @name, :by => user.name
      end
      
      # ...
    end

Meanwhile, on the other side of the universe, an Analytics Application is supposed to gather data to calculate the average task completion time. Using Event Collaboration, it could be done like this:

    module TasksStats
      include Eventwire::Subscriber
    
      on :task_created do |event|
        @start_times[event.task_name] = Time.now
      end
    
      on :task_completed do |event|
        @completion_time_sum   += Time.now - @start_times.delete(event.task_name)
        @completion_time_count += 1
      end
    
      def self.average_completion_time
        @completion_time_sum / @completion_time_count
      end
      
      # ...
    end

Finally, the Notifier is also interested in the same event:

    class Notifier
      include Eventwire::Subscriber
      
      on :task_completed do |event|
        Notifier.new(:email   => find_boss_email(event.by), 
                     :subject => "Task #{event.task_name} completed").send!
      end
      
      # ...
    end
      
The beauty behind all this is that, using the right infrastructure, any of these components might belong to completely different applications and run in separated processes or machines. Or they all might be part of the same app and run in the same process. Components don't care about any of that, that's to say, they are **very loosely coupled**.

> The great strength of Event Collaboration is that it affords a very loose coupling between its components; this, of course, is also its great weakness.

_Be sure to check all the trade-offs in [Fowler's article][1] (“When to use it” section)_

## So, What's Eventwire?

Eventwire is a Ruby library that abstracts developers from the low-level details (messaging, routing, serialization…) that enable Event Collaboration.

### Interface

It provides two modules, `Eventwire::Publisher` and `Eventwire::Subscriber`, which are all developers need to care about:

- Notify changes with `Eventwire::Publisher#publish_event`
- React to changes with `Eventwire::Subscriber#on` 

See the code examples above.

### Adapters

Committing to that simple generic interface, Eventwire includes various drivers for different backends. Developers can choose which one to use depending on what is available in their current infrastructure or what are their needs in terms of reliability, performance or scalability. Currently four drivers are provided:

- `Eventwire::Adapter::InProcess` (for testing and development mainly)
- `Eventwire::Adapter::AMQP` (default driver. Requires an AMQP server like RabbitMQ)
- `Eventwire::Adapter::Redis` (experimental. Requires a Redis server)
- `Eventwire::Adapter::Mongo` (experimental. Requires a MongoDB server)

### Workers

Finally, Eventwire includes a convenient Rake task for starting workers that will run the event handling logic. Eventwire's workers can be distributed between multiple machines and handle failure gracefully, so that no event is lost and any error can easily be traced. They also maximize throughput, minimize latency and fairly distribute the workload (different trade-offs might apply depending on the specific driver used. Check the drivers' docs for more info)

## Getting started

Since this is 2012, I suppose your app will have a `Gemfile` where you have to add the gem.

    gem 'eventwire', :git => "git://github.com/cavalle/eventwire.git"
    
And then install it…

    $ bundle install
    
Now you can just include the `Eventwire::Publisher` and `Eventwire::Subscriber` wherever you want to notify or react to events as in the examples at the beginning of this document.

Eventwire's default (and recommended) driver uses an AMQP server as backend. RabbitMQ is suggested, you can install it:

In MacOSX, using Homebrew:

    $ brew install rabbitmq
    
In Ubuntu >= 9.04:

    $ sudo apt-get install rabbitmq-server
    
For other systems, check [this][2].

Before running your app or your workers you need to start the server.

    $ rabbitmq-server
    
Now, if you're not in Rails 3, add this to your `Rakefile`

    require 'eventwire/tasks'
    
Finally, start a worker with:

    $ rake eventwire:work
    
**Note one important thing:** By default, Eventwire won't know about your application's environment. That is, it won't be able to find and run your event handlers. That means that you need to make sure that your environment and any class including `Eventwire::Subscriber` are loaded before the `eventwire:work` task is executed. 

For instance, in Rails you could add a file in `config/initializers` called `event_handlers.rb` that requires any event handler in your app (i.e. any class or module using `Eventwire::Subscriber`). Then, you just need to start your workers with:

    $ rake environment eventwire:work

## License

Released under the MIT license

[1]: http://martinfowler.com/eaaDev/EventCollaboration.html
[2]: http://www.rabbitmq.com/install.html

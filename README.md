[![Build Status](https://secure.travis-ci.org/KensoDev/kiqit.png)](https://secure.travis-ci.org/KensoDev/kiqit)


## Overview
Kiqit is a gem meant to work with the [Sidekiq](http://github.com/mperham/sidekiq) queue system. It was adapted from the Perform Later gem.

Usually, when working with Sidekiq, you need separate "Worker" classes and you also need to do `Sidekiq.enqueue` whenever you want to add a task to the queue.

That can be a real hassle if you are adding Sidekiq to an existing project, it can also add quite a bit of code to your system.

`kiqit` fills this need, it offers a suite to handle all of your queuing needs, both for Objects and for ActiveRecord models.

## Why?
*Why* should you queue something for later?

You should queue something whenever the method handles some heavy lifting, some timely actions like API, 3rd party HTTP requests and more.

The basic logic is that whatever you don't need to do NOW, you should do later, this will make your site faster and the users will feel it.

## Real life use case
At [Gogobot](http://gogobot.com) whenever you post a review, there's major score calculation going on. This can sometimes take up to a minute, depending on the user graph.

The user should not wait for this on submit, it can be queued into later execution.

## Installation
gem install kiqit

If you are using bundler, simply add
`gem "kiqit"` to your Gemfile


## Configuration
In an initializer, all you need to say is whether you want kiqit to be enabled or not, typically, it will be something like this

```ruby
unless Rails.env.test?
  Kiqit.config.enabled = true # this will default to false if unset
end
```

## Usage

### ActiveRecord

`kiqit` comes with a special method you can use on ActiveRecord models.


```ruby

	class User < ActiveRecord::Base
	  def long_running_method
	    # Your code here
	  end
	  later :long_running_method
	
	  def long_running_method_2
	    # Your code here
	  end
	  later :long_running_method_2, queue: :some_queue_name
	
	  def lonely_long_running_method
	    # Your code here
	  end
	  later :lonely_long_running_method, :loner => true, queue: :some_queue_name

    def delayed_long_running_method
      # Your code here
    end
    later :delayed_long_running_method, :delay => 30, queue: :some_queue_name
	end
	
```

```ruby
	u = User.find(some_user_id)
	u.long_running_method # Method will be queued into the :generic queue
	u.long_running_method_2 # Method will be queued into :some_queue_name queue
	u.lonely_long_running_method # Method will be queued into the :some_queue_name queue, only a single instance of this method can exist in the queue.
  u.delayed_long_running_method # Method will be queued into :some_queue_name queue only after 30 seconds have passed.
```

You can of course choose to run the method off the queue, just prepend `now_` to the method name and it will be executed in sync.

```ruby
	u = User.find(some_user_id)
	u.now_long_running_method
```

### Objects/Classes

If you want class methods to be queued, you will have to use the `kiqit` special method.

```ruby
	class SomeClass
		def self.some_heavy_lifting_method
	  	  # Your code here
	  	end
	  	
		def self.some_more_heavy_lifting(user_id)
	  	  # Your code here
	  	end  	
	end
	
	SomeClass.kiqit(:queue_name, :some_heavy_lifting_method)
	SomeClass.kiqit(:queue_name, :some_more_heavy_lifting, user_id)
	

```

If you want the method to be a loner (only a single instance in the queue), you will need to use the `kiqit!` method.

```ruby
	SomeClass.kiqit!(:queue_name, :some_more_heavy_lifting, user_id)
```

## The params parser
`kiqit` has a special class called `ArgsParser`, this class is in charge of *translating* the args you are passing into params that can actually be serialized to JSON cleanly.

Examples:

```ruby
	user = User.find(1)
	Kiqit::ArgsParser.params_to_sidekiq(user) => 'AR:#User:1'
	
	hotel = Hotel.find(1)
	Kiqit::ArgsParser.params_to_sidekiq(hotel) => 'AR:#Hotel:1'
	
	hash = { name: "something", other: "something else" }
	Kiqit::ArgsParser.params_to_sidekiq(hash) 
	=> ---
		:name: something
		:other: something else
	# Hashes are translated into YAML
```

Basically, the `ArgsParser` class allows you to keep passing any args you want to your methods without worrying about whether they serialize cleanly or not.

`ArgsParser` also patched `sidekiq-mailer` so you can pass in AR objects to mailers as well.

## The custom finder
I found the need to add a custom finder to the args parser.

### Why?
At Gogobot for example, we use slave databases, those sometimes have lag, so when the finder is executed it returns nil, even though the record is actually on the master.

So, I added support for custom finders.

#### Example:

```ruby
	class CustomFinder
		def self.find(klass, id)
			Octopus.using(:master) {
				klass.where(id: id).first
			} unless klass.where(id: id).first
		end
	end
```

Then in an initializer

```ruby
	Kiqit::Plugins.add_finder(CustomFinder)
```

You can also remove the finder in runtime

```ruby
	Kiqit::Plugins.clear_finder!
```

So, at Gogobot for example, we will fall back to master if the record was not found on the slave DB.

 
## Contribute / Bug reports

If you have an issue with this gem, please open an issue in the main repo, it will help tons if you could supply a failing spec with that, so I can better track where the bug is coming from, if not, no worries, just report I will do my best to address it as fast and efficient as I can.

If you want to contribute (awesome), open a feature branch, base it on master.

Be as descriptive as you can in the pull request description, just to be clear what problem you are solving or what feature are you adding.

## Authors

Avi Tzurel ([@kensodev](http://twitter.com/kensodev)) http://www.kensodev.com
Tom Caspy

## Contributors

* Felipe Lima ([@felipecsl](http://twitter.com/felipecsl)) 
http://blog.felipel.com/

Felipe did awesome work on making sure `kiqit` can work with any args and any number of args passed into the methods.
Felipe now has commit rights to the repo.

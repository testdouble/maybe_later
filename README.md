<img src="https://user-images.githubusercontent.com/79303/150394856-67252204-2857-412c-b379-851144776728.jpg" width="90%"/>

# maybe_later - get slow code out of your users' way

Maybe you've been in this situation: you want to call some Ruby while responding
to an HTTP request, but it's a time-consuming operation, its outcome won't
impact the response you send, and naively invoking it will result in a slower
page load or API response for your users.

In almost all cases like this, Rubyists will reach for a [job
queue](https://edgeguides.rubyonrails.org/active_job_basics.html). And that's
usually the right answer! But for relatively trivial tasks—cases where the
_only_ reason you want to defer execution is a faster page load—creating a new
job class and scheduling the work onto a queuing system can feel like overkill.

If this resonates with you, the `maybe_later` gem might be the best way to run
that code for you (eventually).

##  Bold Font Disclaimer

⚠️ **If the name `maybe_later` didn't make it clear, this gem does nothing to
ensure that your after-action callbacks actually run. If the code you're calling
is very important, use [sidekiq](https://github.com/mperham/sidekiq) or
something!** ⚠️

## Setup

Add the gem to your Gemfile:

```ruby
gem "maybe_later"
```

If you're using Rails, the gem's middleware will be registered automatically. If
you're not using Rails but _are_ using a rack-based server that supports
[env["rack.after_reply"]](https://github.com/rack/rack/issues/1060) (which
includes
[puma](https://github.com/puma/puma/commit/be4a8336c0b4fc911b99d1ffddc4733b6f38d81d)
and
[unicorn](https://github.com/defunkt/unicorn/commit/673c15e3f020bccc0336838617875b26c9a45f4e)),
just add `use MaybeLater::Middleware` to your `config.ru` file.

## Usage

Using the gem is pretty straightforward, just pass the code you want to run to
`MaybeLater.run` as a block:

```ruby
MaybeLater.run {
  AnalyticsService.send_telemetry!
}
```

Each block passed to `MaybeLater.run` will be run after the HTTP response is
sent.

If the code you're calling needs to be executed in the same thread that's
handling the HTTP request, you can pass `inline: true`:

```ruby
MaybeLater.run(inline: true) {
  # Thread un-safe code here
}
```

And your code will be run right after the HTTP response is sent. Additionally,
if there are any inline tasks to be run, the response will include a
`"Connection: close` header so that the browser doesn't sit waiting on its
connection while the web thread executes the deferred code.

_[**Warning about `inline`:** running
slow inline tasks runs the risk of saturating the server's available threads
listening for connections, effectively shifting the slowness of one request onto
later ones!]_


## Configuration

The gem offers a few configuration options:

```ruby
MaybeLater.config do |config|
  # Will be called if a block passed to MaybeLater.run raises an error
  config.on_error = ->(error) {
    # e.g. Honeybadger.notify(error)
  }

  # Will run after each `MaybeLater.run {}` block, even if it errors
  config.after_each = -> {}

  # By default, tasks will run in a fixed thread pool. To run them in the
  # thread dispatching the HTTP response, set this to true
  config.inline_by_default = false

  # How many threads to allocate to the fixed thread pool (default: 5)
  config.max_threads = 5

  # If set to true, will invoke the after_reply tasks even if the server doesn't
  # provide an array of rack.after_reply array
  config.invoke_even_if_server_is_unsupported = false
end
```

## Help! Why isn't my code running?

If the blocks you pass to `MaybeLater.run` aren't running, possible
explanations include:

* Because the blocks passed to `MaybeLater.run` are themselves stored in a
  thread-local array, if you invoke `MaybeLater.run` from a thread that isn't
  handling with a Rack request, the block will never run
* If your Rack server doesn't support `rack.after_reply`, the blocks will never
  run
* If the block _is_ running and raising an error, you'll only know about it if
  you register a `MaybeLater.config.on_error` handler

## Acknowledgement

The idea for this gem was triggered by [this
tweet](https://twitter.com/julikt/status/1483585327277223939) in reply to [this
question](https://twitter.com/searls/status/1483572597686259714). Also, many
thanks to [Matthew Draper](https://github.com/matthewd) for answering a bunch of
questions I had while implementing this.

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.

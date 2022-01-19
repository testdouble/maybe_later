# maybe_later

Maybe you've been in this situation: you want to run some Ruby while responding
to an HTTP request, but it's a time-consuming operation and you don't want to
delay the user from receiving the HTTP response.

In almost all cases, Rubyists will lead to a [job
queue](https://edgeguides.rubyonrails.org/active_job_basics.html) for this. But
that's quite a lot of overhead for relatively trivial tasks—especially when it's
not the end of the world if a failure results in your code not being run. In
that case, it might seem like overkill to add Redis to your production
environment or configure a new job just to record telemetry to an analytics
service or save an action to an audit log. The `maybe_later` gem exists for
those cases where you want to fire-and-forget something without holding up the
user.

**[Disclaimer: if the name `maybe_later` didn't make it clear, this gem does
nothing to ensure that your after-action callbacks run. If the code you're
running is important, use [sidekiq](https://github.com/mperham/sidekiq) or
something!]**

## Setup

Add the gem to your Gemfile:

```ruby
gem "maybe_later"
```

If you're using Rails, the gem's middleware will be registered automatically. If
you're not using Rails but are using a rack-based server that supports
[env["rack.after_reply"]](https://github.com/rack/rack/issues/1060) (which might only
be
[puma](https://github.com/puma/puma/commit/be4a8336c0b4fc911b99d1ffddc4733b6f38d81d)
and
[unicorn](https://github.com/defunkt/unicorn/commit/673c15e3f020bccc0336838617875b26c9a45f4e)), just `use MaybeLater::Middleware` in your rackup file.

You can also configure the gem with optional callbacks:

```ruby
MaybeLater.config do |config|
  config.on_error = ->(error) {
    # Will be called if a `MaybeLater.run {}` callback errors, e.g.:
    # Bugsnag.notify(error)
  }
  config.after_each = -> {
    # Will run after each `MaybeLater.run {}` block, even if it errors
  }
end
```

## Usage

Once you've got it installed and configured, using the gem is pretty
straightforward, just pass the code you want to run to `MaybeLater.run` as a
block:

```ruby
MaybeLater.run { AnalyticsService.send_telemetry! }
```

Each block passed to `MaybeLater.run` will be run in order after the HTTP
response is sent.

## Why isn't my code running?

Because the blocks are stored in a thread-local array, if you invoke
`MaybeLater.run` from a thread that isn't associated with a Rack request, the
block will never run. If your Rack server doesn't support `rack.after_reply`,
the blocks will never run.

## Acknowledgement

The idea for this gem was triggered by [this
tweet](https://twitter.com/julikt/status/1483585327277223939) in reply to
[this question](https://twitter.com/searls/status/1483572597686259714) and, as
always, [Matthew Draper](https://github.com/matthewd) answered a bunch of
questions I had while implementing this.

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.

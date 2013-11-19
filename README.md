x-moj-auth
==========

prototype ruby/rack based auth service

to run the tests: ```rspec spec```

to build the gem: ```gem build rack_moj_auth.gemspec```

to install the gem ```gem install rack_moj_auth-*.gem```

to use the gem, add it to your gemfile ```gem 'rack_moj_auth'```

There's some environment config required, but that still needs figuring out.

The likely consequence of including this gem in your Rails project is that your request specs will all immedaitely fail.  Have fun with that ;)

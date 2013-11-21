x-moj-auth
==========

prototype ruby/rack based auth service

to run the tests: ```rspec spec```

to build the gem: ```gem build rack_moj_auth.gemspec```

to install the gem ```gem install rack_moj_auth-*.gem```

to use the gem, add it to your gemfile ```gem 'rack_moj_auth'```

Set the environment variable 'auth_service_url' to be the FQURL of your auth service, eg rails s auth_service_url='http://localhost:3000' or somesuch.

This Gem no longer auto-adds itself into a Rails middleware stack, so you'll need to add it yourself. One way of doing this is to add the following to ```config/application.rb```

```config.middleware.use RackMojAuth::Midleware```
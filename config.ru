require 'rack'
require './moj_preauth_methods'
require './moj_postauth_methods'
require './moj_auth_filter'
require './stubbed_api'

# it's important they come this way round
use MojPreAuthMethods
use MojAuthFilter
use MojPostAuthMethods

run StubbedApi.new
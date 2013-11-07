require 'rack'
require './moj_preauth_methods'
require './moj_postauth_methods'
require './moj_auth_filter'
require './stubbed_api'

# significant order
use MojPreAuthMethods
use MojAuthFilter
use MojPostAuthMethods

run StubbedApi.new

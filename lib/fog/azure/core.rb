require 'fog/core'
require 'fog/xml'
require 'fog/json'

module Fog
  module Azure
    extend Fog::Provider

    service(:virtual_machine,    'VirtualMachine')
    service(:cloud_service,      'CloudService')


    class Mock
      def self.foo(vendor, account_id, path, region = nil)
        ""
      end
    end

    module Errors
      class NotFound < ServiceError; end
    end
  end
end

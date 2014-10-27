require 'fog/core/model'

module Fog
  module CloudService
    class Azure
      class CloudService < Fog::Model
        identity :id

        attribute :name
        attribute :cost
        attribute :description

        def foo
          ""
        end
      end
    end
  end
end

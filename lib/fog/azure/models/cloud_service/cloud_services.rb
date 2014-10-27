require 'fog/core/collection'
require 'fog/azure/cloud_service/models/cloud_service/cloud_service'

module Fog
  module CloudService
    class Azure
      class CloudServices < Fog::Collection
        model Fog::CloudService::Azure::CloudService

        def all
          data = service.get_products.body
          load(data)
        end

        def get(product_id)
          response = service.get_product(product_id)
          new(response.body)
        rescue Fog::CloudService::Azure::NotFound
          nil
        end
      end
    end
  end
end

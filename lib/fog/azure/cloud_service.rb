require "fog/azure/core"
require "base64"
require 'net/https'
require 'uri'

module Fog
  class CloudService < Fog::Service

    requires :subscription_id, :api_cert, :service_name, :label, :location, :affinity_group

    model_path 'fog/azure/models/cloud_service'
    model       :cloud_service
    collection  :cloud_services


    request_path 'fog/azure/requests/cloud_service'
    request :create_cloud_service


    class Mock

    end

    class Real
      def initialize(options={})

        #TODO: Need to move lower options to non-global context (i.e per-request)
        @subscription_id  = options[:subscription_id]
        @endpoint_uri     = "https://management.core.windows.net/#{@subscription_id}/services/hostedservices"
        @api_cert   = options[:api_cert]

        @service_name     = options[:service_name]
        @label            = options[:label]
        @location         = options[:location]
        @affintiy_group   = options[:affinity_group]
        @description      = options[:description] || nil
        @extended_props   = options[:extended_props] || nil
        @reverse_dns_fqdn = options[:reverse_dns_fqdn] || nil

        raise "You must specify either an affinity group or a location, not both" if ((@affintiy_group && @location) ||
                                                                                      (@affintiy_group.nil? && @location.nil?))
      end

      def reload

      end

      def request(params)
        url = URI.parse(@endpoint_uri)
        request = Net::HTTP::Post.new(url.request_uri)
        request.body = body
        request['x-ms-version'] = '2014-06-01'
        request['Content-Type'] = 'application/xml' unless body.nil?

        http(uri).request(request)
      end


      private

      def http(uri)
        url = URI.parse(uri)
        pem = File.read(@api_cert)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.cert = OpenSSL::X509::Certificate.new(pem)
        http.key = OpenSSL::PKey::RSA.new(pem)
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http
      end

      def body
<<XML_BODY
<?xml version="1.0" encoding="utf-8"?>
<CreateHostedService xmlns="http://schemas.microsoft.com/windowsazure">
  <ServiceName>#{@service_name}</ServiceName>
  <Label>#{Base64.encode64(@label)}</Label>
  #{description}
  #{location_or_affinity}
  #{extended_props}
  #{reverse_dns_fqdn}
</CreateHostedService>
XML_BODY
      end

      def extended_props
        return "" if @extended_props.nil?
        str = "<ExtendedProperties>\n"
        @extended_props.each do |prop|
          str << "  <ExtendedProperty>\n    <Name>#{prop[:name]}</Name>\n    <Value>#{prop[:value]}</Value>\n  </ExtendedProperty>"
        end
        str << "</ExtendedProperties>"
        str
      end

      def description
        @description.nil? ? "" : "<Description>#{@description}</Description>"
      end

      def location_or_affinity
        value = "<Location>#{@location}</Location>" unless @location.nil?
        value = "<AffinityGroup>#{@affintiy_group}</AffinityGroup>" unless @affintiy_group.nil?
        value
      end

      def reverse_dns_fqdn
        @reverse_dns_fqdn.nil? ? "" : "<ReverseDnsFqdn>#{@reverse_dns_fqdn}</ReverseDnsFqdn>"
      end
    end
  end
end
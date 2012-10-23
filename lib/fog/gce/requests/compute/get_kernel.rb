module Fog
  module Compute
    class GCE

      class Mock

        def get_kernel(kernel_name)
          Fog::Mock.not_implemented
        end

      end

      class Real

        def get_kernel(kernel_name)
          api_method = @compute.kernels.get
          parameters = {
            'project' => 'google',
            'kernel' => kernel_name
          }

          result = self.build_result(api_method, parameters)
          response = self.build_response(result)
        end

      end

    end
  end
end

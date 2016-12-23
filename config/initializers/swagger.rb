GrapeSwaggerRails.options.url = '/api/api-docs'

GrapeSwaggerRails.options.before_action do
  GrapeSwaggerRails.options.app_url = request.protocol + request.host_with_port
end

GrapeSwaggerRails.options.app_name = 'Central'

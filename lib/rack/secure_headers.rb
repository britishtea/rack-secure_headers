require "rack"

module Rack
  class SecureHeaders
    DEFAULTS = {
      hsts: { max_age: "31536000", include_subdomains: true },
      x_content_type_options: "nosniff",
      x_frame_options: "SAMEORIGIN",
      x_permitted_cross_domain_policies: "none",
      x_xss_protection: "1; mode=block"
    }

    def initialize(app, options = {})
      options = DEFAULTS.merge(options)

      @app = app
      @headers = base_headers(options)

      if options[:hsts]
        @headers["Strict-Transport-Security"] = hsts_header(options[:hsts])
      end
    end

    def call(env)
      tuple = @app.call(env)
      tuple[1].merge!(@headers)
      
      return tuple
    end

    private

    def base_headers(options)
      headers = {
        "X-Content-Type-Options" => options[:x_content_type_options],
        "X-Frame-Options" => options[:x_frame_options],
        "X-Permitted-Cross-Domain-Policies" => options[:x_permitted_cross_domain_policies],
        "X-XSS-Protection" => options[:x_xss_protection],
      }

      headers.each do |header, value|
        headers.delete(header) if value.nil?
      end

      return headers
    end

    def hsts_header(opts)
      header = "max-age=#{opts.fetch(:max_age)}"
      header << "; includeSubdomains" if opts[:include_subdomains]
      header << "; preload" if opts[:preload]

      return header
    end
  end
end

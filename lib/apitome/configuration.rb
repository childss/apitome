module Apitome
  class Configuration
    attr_reader :settings

    def initialize(parent = nil)
      @parent = parent
      @settings = {}
    end

    def self.add_setting(name, opts = {})
      define_method("#{name}=") { |value| settings[name] = value }
      define_method("#{name}") do
        if settings.has_key?(name)
          settings[name]
        elsif @parent.respond_to?(:settings) && @parent.settings.has_key?(name)
          @parent.settings[name]
        else
          opts[:default]
        end
      end
    end

    add_setting :mount_at, default: '/api/docs'
    add_setting :doc_path, default: 'doc/api'
    add_setting :title, default: 'Apitome Documentation'
    add_setting :layout, default: 'apitome/application'
    add_setting :code_theme, default: 'default'
    add_setting :css_override, default: nil
    add_setting :js_override, default: nil
    add_setting :readme, default: '../api.md'
    add_setting :single_page, default: true
    add_setting :url_formatter, default: -> (str) { str.gsub(/\.json$/, '').underscore.gsub(/[^0-9a-z]+/i, '-') }

    def root
      settings[:root]
    end

    def root=(path)
      settings[:root] = Pathname.new(path.to_s) if path.present?
    end

    def code_theme_url
      "apitome/highlight_themes/#{code_theme}"
    end
  end
end

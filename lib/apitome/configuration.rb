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
    add_setting :root, default: nil
    add_setting :title, default: 'Apitome Documentation'
    add_setting :layout, default: 'apitome/application'
    add_setting :code_theme, default: 'default'
    add_setting :css_override, default: nil
    add_setting :js_override, default: nil
    add_setting :readme, default: '../api.md'
    add_setting :single_page, default: true
    add_setting :url_formatter, default: -> (str) { str.gsub(/\.json$/, '').underscore.gsub(/[^0-9a-z]+/i, '-') }
    add_setting :group_name, default: nil

    def code_theme_url
      "apitome/highlight_themes/#{code_theme}"
    end

    def groups
      @groups ||= []
    end

    def define_group(name)
      group_config = self.class.new(self)
      group_config.group_name = name
      group_config.doc_path = self.doc_path.join(name.to_s)
      group_config.mount_at = "#{self.mount_at}/#{name}"
      group_config.readme = "../#{name}.md"
      yield group_config if block_given?
      groups << group_config
    end

    def group?
      !@parent.nil?
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.setup
    yield configuration if block_given?
  end
end

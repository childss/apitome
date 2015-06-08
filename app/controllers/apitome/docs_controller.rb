class Apitome::DocsController < ActionController::Base
  layout Apitome.configuration.layout

  helper_method *[
    :resources,
    :example,
    :formatted_body,
    :param_headers,
    :param_extras,
    :formatted_readme,
    :set_example,
    :id_for,
    :rendered_markdown
  ]

  def index
    if using_groups? && params[:path].nil?
      render 'groups'
    end
  end

  def show
    path = params[:path]
    if using_groups? && !path.empty? && !path.include?('/')
      render action: 'index'
    end
  end

  def simulate
    request = example["requests"][0]
    if request
      request["response_headers"].each { |k, v| headers[k] = v }
      render text: request["response_body"], status: request["response_status"]
    else
      render text: "No simulation for this endpoint", status: 404
    end
  end

  private

  def file_for(path)
    if configuration.group?
      segments = path.split('/')
      path = segments[1..-1].join('/') if segments[0] == configuration.group_name
    end

    file = configuration.root.join(configuration.doc_path, path)
    raise Apitome::FileNotFoundError.new("Unable to find #{file}") unless File.exists?(file)
    File.read(file)
  end

  def resources
    file = "index.json"
    if configuration.group?
      file = "#{configuration.group_name}/index.json"
    end
    @resources ||= JSON.parse(file_for(file))["resources"]
  end

  def example
    @example ||= JSON.parse(file_for("#{params[:path]}.json"))
  end

  def set_example(resource)
    @example = JSON.parse(file_for("#{resource}.json"))
  end

  def formatted_readme
    return unless configuration.readme
    file = configuration.root.join(configuration.doc_path, configuration.readme)
    rendered_markdown(file_for(file.to_s))
  end

  def rendered_markdown(string)
    if defined?(GitHub::Markdown)
      GitHub::Markdown.render(string)
    else
      Kramdown::Document.new(string).to_html
    end
  end

  def formatted_body(body, type)
    if type =~ /json/ && body.present?
      JSON.pretty_generate(JSON.parse(body))
    else
      body
    end
  rescue JSON::ParserError
    return body if body == " "
    raise JSON::ParserError
  end

  def param_headers(params)
    titles = %w{Name Description}
    titles += param_extras(params)
    titles
  end

  def param_extras(params)
    params.map do |param|
      param.reject { |k, _v| %w{name description required scope}.include?(k) }.keys
    end.flatten.uniq
  end

  def id_for(str)
    configuration.url_formatter.call(str)
  end

  def configuration
    if Apitome.configuration.groups.empty? || params[:path].nil?
      Apitome.configuration
    else
      name = params[:path].split('/').first
      group = Apitome.configuration.groups.find { |g| g.group_name == name }
      if group.nil?
        raise Apitome::UndefinedGroupError
      else
        group
      end
    end
  end

  def groups
    Apitome.configuration.groups
  end

  def using_groups?
    !groups.empty?
  end

  helper_method :configuration
  helper_method :groups
end

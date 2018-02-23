require 'logger'
require 'net/http'
require 'terrapin'
require 'yaml'

class AxeChangeDownloader
  attr_accessor :config, :logger, :cmd, :type, :failure_limit

  def initialize(type, logger, failure_limit: 1000)
    @logger = logger
    @type = type
    @config = YAML.load_file(__config_file)
    @failure_limit = failure_limit
    Terrapin::CommandLine.logger = logger
  end

  def download
    Dir.chdir(__output_directory) do
      __curl(download_url)
    end
    config[type] += 1
    save_config
  end

  def download_url
    raise "Failure limit reach" if self.failure_limit < 0

    response = Net::HTTP.get_response(URI.parse(__metadata_url))

    logger.debug "response code: #{response.code}"

    unless response.kind_of?(Net::HTTPRedirection)
      logger.debug "I don't know what to do with #{response}"
      logger.debug "Incrementing index and trying again..."
      self.failure_limit -= 1
      self.config[type] += 1
      return download_url
    end

    url = __base_url + redirect_url(response)
    logger.debug "download url: #{url}"
    url
  end

  def redirect_url(response)
    if response['location'].nil?
      response.body.match(/<a href=\"([^>]+)\">/i)[1]
    else
      response['location']
    end
  end

  def save_config
    logger.debug "saving config to #{__config_file}"
    File.open(__config_file, 'w') do |f|
      f.write(self.config.to_yaml)
    end
  end

  private

  def __curl(uri)
    Terrapin::CommandLine.new('curl', "-O --silent #{uri}").run
  end

  def __config_file
    File.join(File.dirname(__FILE__), '..', 'config.yaml')
  end

  def __metadata_url
    "#{__base_url}/download.php?#{type}=#{config[type]}"
  end

  def __base_url
    'http://axechange.fractalaudio.com'
  end

  def __output_directory
    File.join(File.dirname(__FILE__), '..', type)
  end
end

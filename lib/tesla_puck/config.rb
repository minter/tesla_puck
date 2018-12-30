# frozen_string_literal: true

module TeslaPuck
  # Holds the configuration values from the YAML file
  class Config
    attr_reader :tesla_email, :tesla_password, :tesla_client_secret,
                :tesla_client_id, :nhl_team_id, :home_address,
                :arena_parking_distance_miles, :arena_longitude, :arena_latitude,
                :redis_url, :web_password, :log_enabled, :log_file, :time_zone

    def initialize
      config = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/environment.yml'))
      config.each_key do |key_value|
        va = config[key_value].to_s
        var_name = "@#{key_value}" # the '@' is required
        instance_variable_set(var_name, va)
      end
    end
  end
end

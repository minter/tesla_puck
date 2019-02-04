# frozen_string_literal: true

module TeslaPuck
  # Holds the configuration values from the YAML file
  class Config
    attr_reader :home_address, :log_file, :redis_url, :tesla_client_id,
                :tesla_client_secret, :tesla_email, :tesla_password,
                :time_zone, :web_password, :pushover_user_key, :pushover_token

    def initialize
      config = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/environment.yml'))
      config.each_key do |key_value|
        va = config[key_value].to_s
        var_name = "@#{key_value}" # the '@' is required
        instance_variable_set(var_name, va)
      end
    end

    def log_enabled?
      !@log_enabled.empty?
    end

    def nhl_team_id
      @nhl_team_id.to_i
    end

    def arena_latitude
      @arena_latitude.to_f
    end

    def arena_longitude
      @arena_longitude.to_f
    end

    def arena_parking_distance_miles
      @arena_parking_distance_miles.to_f
    end

    def pushover_enabled?
      !@pushover_enabled.empty?
    end
  end
end

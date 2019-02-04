# frozen_string_literal: true

module TeslaPuck
  # Models the functions with the Tesla API
  class Tesla
    def initialize
      @config = TeslaPuck::Config.new
      tesla_api = TeslaApi::Client.new(@config.tesla_email,
                                       @config.tesla_client_id,
                                       @config.tesla_client_secret)
      tesla_api.login!(@config.tesla_password)
      @car = tesla_api.vehicles.first
    end

    def notify(title, message)
      client = Rushover::Client.new(@config.pushover_token)
      return client.notify(@config.pushover_user_key, message, :title => title)
    end

    def wake_up!
      @car.wake_up
      sleep 5 while @car.vehicle_state.nil?
    end

    def at_arena?
      car_coordinates = [@car.drive_state['latitude'], @car.drive_state['longitude']]
      arena_coordinates = [@config.arena_latitude, @config.arena_longitude]
      Geocoder::Calculations.distance_between(car_coordinates, arena_coordinates) < @config.arena_parking_distance_miles
    end

    def celebrate!
      @car.honk_horn
      @car.flash_lights
      @car.honk_horn
      @car.flash_lights
      @car.honk_horn
      @car.flash_lights
    end

    def prepare_to_leave!
      @car.auto_conditioning_start
      @car.navigation_request(@config.home_address)
    end
  end
end

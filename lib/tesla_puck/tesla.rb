# frozen_string_literal: true

module TeslaPuck
  # Models the functions with the Tesla API
  class Tesla
    def initialize
      # Get token - https://tesla-info.com/tesla-token.php
      if !ENV["TESLA_ACCESS_TOKEN"].empty?
        tesla_api = TeslaApi::Client.new(access_token: ENV["TESLA_ACCESS_TOKEN"])
      else
        tesla_api = TeslaApi::Client.new(email: ENV["TESLA_EMAIL"], client_id: ENV["TESLA_CLIENT_ID"], client_secret: ENV["TESLA_CLIENT_SECRET"])
        tesla_api.login!(ENV["TESLA_PASSWORD"])
      end
      @car = tesla_api.vehicles.first
    end

    def notify(title, message)
      client = Rushover::Client.new(ENV["PUSHOVER_TOKEN"])
      client.notify(ENV["PUSHOVER_USER_KEY"], message, title: title)
    end

    def wake_up!
      @car.wake_up
      timestamp = nil
      while timestamp.nil?
        begin
          timestamp = @car.vehicle_state["timestamp"]
          sleep 5
        rescue Faraday::ClientError
          sleep 10
        end
      end
    end

    def at_arena?
      car_coordinates = [@car.drive_state["latitude"], @car.drive_state["longitude"]]
      arena_coordinates = Geocoder.search(ENV["ARENA_ADDRESS"]).first.coordinates
      Geocoder::Calculations.distance_between(car_coordinates, arena_coordinates) < ENV["ARENA_PARKING_DISTANCE_MILES"].to_f
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
      @car.navigation_request(ENV["HOME_ADDRESS"])
    end
  end
end

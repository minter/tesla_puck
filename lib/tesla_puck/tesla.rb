# frozen_string_literal: true

module TeslaPuck
  # Models the functions with the Tesla API
  class Tesla
    def initialize
      tesla_api = TeslaApi::Client.new(email: ENV["TESLA_EMAIL"], client_id: ENV["TESLA_CLIENT_ID"], client_secret: ENV["TESLA_CLIENT_SECRET"])
      tesla_api.login!(ENV["TESLA_PASSWORD"])
      @car = tesla_api.vehicles.first
    end

    def notify(title, message)
      client = Rushover::Client.new(ENV["PUSHOVER_TOKEN"])
      client.notify(ENV["PUSHOVER_USER_KEY"], message, title: title)
    end

    def wake_up!
      @car.wake_up
      sleep 5 while @car.vehicle_state.nil?
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

# frozen_string_literal: true

module TeslaPuck
  # Models functions with the NHL StatsWeb API
  class Scheduler
    attr_accessor :scheduled

    def initialize
      @config = TeslaPuck::Config.new
      time_zone = TZInfo::Timezone.get(@config.time_zone)
      today = time_zone.to_local(Time.now).strftime('%Y-%m-%d')

      @game = HTTParty.get("https://statsapi.web.nhl.com/api/v1/schedule?teamId=#{@config.nhl_team_id}&date=#{today}")['dates'].first
      @scheduled = @game.nil? ? false : true
      return if @scheduled == false

      @away = @game['games'].first['teams']['away']
      @home = @game['games'].first['teams']['home']
    end

    def pending?
      @game['games'].first['status']['detailedState'] == 'Scheduled'
    end

    def final?
      @game['games'].first['status']['detailedState'] == 'Final'
    end

    def my_team_home?
      @home['team']['id'].to_i == @config.nhl_team_id.to_i
    end

    def my_team_win?
      win = if @away['team']['id'].to_i == @config.nhl_team_id.to_i
              @away['score'] > home['score']
            else
              @home['score'] > away['score']
            end
      win
    end
  end
end

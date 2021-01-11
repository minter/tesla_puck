# frozen_string_literal: true

module TeslaPuck
  # Models functions with the NHL StatsWeb API
  class Scheduler
    def initialize
      @time_zone = TZInfo::Timezone.get(ENV['TIME_ZONE'])
      today = @time_zone.to_local(Time.now).strftime('%Y-%m-%d')

      @game = HTTParty.get("https://statsapi.web.nhl.com/api/v1/schedule?teamId=#{ENV['NHL_TEAM_ID']}&date=#{today}")['dates'].first
      @scheduled = @game.nil? ? false : true
      return if @scheduled == false

      @away = @game['games'].first['teams']['away']
      @home = @game['games'].first['teams']['home']
    end

    def game_time
      @time_zone.to_local(Time.parse(@game['games'].first['gameDate']))
    end

    def status
      @game['games'].first['status']['detailedState']
    end

    def scheduled_for_today?
      @scheduled
    end

    def pending?
      status == 'Scheduled' || status == 'Pre-Game'
    end

    def in_progress?
      status.match?(/In Progress/)
    end

    def final?
      status == 'Final'
    end

    def my_team_home?
      @home['team']['id'].to_i == ENV['NHL_TEAM_ID'].to_i
    end

    def my_team_win?
      if @away['team']['id'].to_i == ENV['NHL_TEAM_ID'].to_i
        @away['score'] > @home['score']
      else
        @home['score'] > @away['score']
      end
    end
  end
end

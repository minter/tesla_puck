# frozen_string_literal: true

module TeslaPuck
  # The Sidekiq worker that polls the NHL API and connects to your car
  class Worker
    include Sidekiq::Worker

    def notify(title, message)
      client = Rushover::Client.new(@config.pushover_token)
      resp = client.notify(@config.pushover_user_key, message, title: title)
      return resp unless @config.log_enabled?

      if resp.ok?
        logger.debug "#{title} - successfully sent to Pushover"
      else
        logger.warn "#{title} - failed to send to Pushover"
      end
      resp
    end

    def perform(_notified = false)
      @config = TeslaPuck::Config.new

      game = Scheduler.new
      logger = Logger.new(@config.log_file) if @config.log_enabled?

      # If the scheduler is nil, no games for your team today. Try again tomorrow.
      unless game.scheduled_for_today?
        if @config.log_enabled?
          logger.debug ' There is no game scheduled today for your team. Exiting.'
        end
        return
      end

      # Quit until tomorrow if we're not home (because we're not parked at the
      # arena for an away game, natch)
      unless game.my_team_home?
        if @config.log_enabled?
          logger.debug 'Your team is not the home team for the game today. Exiting.'
        end
        return
      end

      # If the game hasn't started yet, re-queue for an hour from now
      if game.pending?
        if @config.log_enabled?
          logger.debug 'There is a game today, but it has not started yet. Rescheduling for an hour past start time.'
        end
        self.class.perform_at(game.game_time + 3600)
        return
      end

      # Re-queue for 5 minutes later or so if the game is in progress
      if game.in_progress?
        if @config.log_enabled?
          logger.debug 'Your game is in progress. Checking back in 5 minutes for a final.'
        end
        if @config.pushover_enabled? && !_notified?
          _notified = true
          notify('Game Started', 'Tesla Puck is tracking your game.')
        end
        self.class.perform_in 300
        return
      end

      unless game.final?
        logger.debug "The game is not final, but is an unexpected state. Status is #{game.status}. Retrying in 5 minutes."
        self.class.perform_in 300
        return
      end

      # Wake up the Tesla
      car = Tesla.new
      car.wake_up!
      logger.debug 'Your car is now awake.' if @config.log_enabled?

      # Re-queue for tomorrow if the car's not at the arena
      unless car.at_arena?
        if @config.log_enabled?
          logger.debug 'Your car is not close enough to the arena. Exiting.'
        end
        return
      end

      # If we've made it this far: The game is final, it's at PNC, and the Tesla is at PNC. Let's start
      # getting ready to go home!

      if game.my_team_win?
        logger.debug 'You won! Preparing to celebrate!' if @config.log_enabled?
        car.celebrate!
      end

      if @config.log_enabled?
        logger.debug 'Preparing to turn on climate control and head for home!'
      end

      if @config.pushover_enabled?
        notify('Starting Climate Control', 'Tesla Puck is turning on climate control.')
      end

      car.prepare_to_leave!
    end
  end
end

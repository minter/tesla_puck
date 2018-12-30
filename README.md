# TeslaPuck

Inspired by my friend @RangerRick, this is a weird little NHL/Tesla API mashup. Since I'm attending all Carolina Hurricanes games, driving my Model 3, I'd love for the car to be warmed up and ready to head home as soon as a Canes home game ends.

To that end, this little program watches the NHL API for a home game for my team. If there's a home game today, it's gone final, and my car is parked at the arena, it will send an API action to my car to turn on the climate control and set the navigation for home.

If the home team wins, it will also honk the horn and flash the lights in celebration!

If there's no home game today, it just quietly exits, to try again tomorrow.

## Requirements

The following technologies are required to run this:
* **Ruby** - 2.5.x recommended
* **Bundler** - use Bundler to install the required rubygems
* **Redis** - used by Sidekiq
* **Cron** - To run the daily job to see if there's a home game

Additionally, we recommend a web server that can load a Rack configuration (like [Phusion Passenger](https://www.phusionpassenger.com)) and something that can daemonize Sidekiq (like systemd if you're on Ubuntu)

## Installation

Clone this repository to your system.

Install the required gems with Bundler

`bundle install --without development`

Copy `config/environment.yml.example` to `config/environment.yml` and edit the values to match your requirements (see below)

Set up a crontab entry to run the worker job once a day:

`0 11 * * * /path/to/ruby -r /path/to/lib/tesla_puck.rb -e 'TeslaPuck::Worker.perform_async'`

Configure systemd or your daemonizer of choice to run Sidekiq.

Configure Passenger or your web server of choice to serve up the Sidekiq web admin via Rack. An example for Passenger/Nginx is provided in `examples/nginx-passenger.conf`

## Configuration

The configuration lives in a file named `environment.yml` in the `config/` directory. A sample is provided for you, so that you can adjust to your particular needs. The configuration values are as follows:
* **arena_latitude** - The latitude of the arena. You can get this from a geocoding website.
* **arena_longitude** - The longitude of the arena. See above.
* **arena_parking_distance_miles** - How close to the arena (in miles) does your car need to be for this to work. We don't want to start your car if it's home in your garage.
* **home_address** - The address of where you're going after the game. We pre-load this into your navigation after the game is over.
* **log_enabled** - If you want to have a log written to help you see what's happening, set this value to anything. If it's blank, we will not log. Recommended value to enable the log is `true`
* **log_file** - If you're logging, here's where to write the log file.
* **redis_url** - The URL to your redis database (use the `/1` or another number at the end to choose an unused database)
* **tesla_client_id** - The client ID that allows access to the Tesla API. This seems to get passed around the internet, and there doesn't seem to be a reliable way to get it programatically.
* **tesla_client_secret** - The client secret for the Tesla API. See above.
* **tesla_email** - Your email address that you use to log into your Tesla account (only stored locally and used to authenticate to your car).
* **tesla_password** - The password that you use to log into your Tesla account (only stored locally and used to authenticate to your car).
* **time_zone** - The time zone that your team is in. Provided in `TZInfo` format, so you'll want to pick one of these:
  * `America/New_York` - Eastern Time
  * `America/Chicago` - Central Time
  * `America/Denver` - Mountain Time
  * `America/Phoenix` - Arizona's weird DST rules
  * `America/Los_Angeles` - Pacific Time
* **nhl_team_id** - The numeric ID for the NHL team that you are following (see the table below)
* **web_password** - The password used to protect your Sidekiq web UI

## Team ID Numbers

These are the team ID numbers required as part of NHL StatsWeb to pull game/team information.

Team Name | Team ID
--- | ---
Anaheim Ducks | 24
Arizona Coyotes | 53
Boston Bruins | 6
Buffalo Sabres | 7
Carolina Hurricanes | 12
Calgary Flames | 20
Chicago Blackhawks | 16
Colorado Avalanche | 21
Columbus Blue Jackets | 29
Dallas Stars | 25
Detroit Red Wings | 17
Edmonton Oilers | 22
Florida Panthers | 13
Los Angeles Kings | 26
Minnesota Wild | 30
Montréal Canadiens | 8
Nashville Predators | 18
New Jersey Devils | 1
New York Islanders | 2
New York Rangers | 3
Ottawa Senators | 9
Philadelphia Flyers | 4
Pittsburgh Penguins | 5
St. Louis Blues | 19
San Jose Sharks | 28
Seattle | 55
Tampa Bay Lightning | 14
Toronto Maple Leafs | 10
Vancouver Canucks | 23
Vegas Golden Knights | 54
Washington Capitals | 15
Winnipeg Jets | 52

## Known Issues

This code currently just grabs the first Tesla out of your account. If you have more than one Tesla: First, congratulations. Second, the code may need to be updated to get the correct car for you.

It would be nice if we could get the time zone of the game venue, but the NHL API does not provide that. It's only provided for the team. So it's possible that oddly-scheduled games might not work properly if the game is finishing "tomorrow" in your time zone.

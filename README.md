# TeslaPuck

Inspired by an idea from my friend [@RangerRick](https://github.com/RangerRick), this is a weird mashup of the [NHL StatsWeb API](https://www.kevinsidwar.com/iot/2017/7/1/the-undocumented-nhl-stats-api) and the [Tesla API](https://github.com/timdorr/tesla-api). Since I'm attending all Carolina Hurricanes games, driving my Model 3, I'd love for the car to be warmed up and ready to head home as soon as a Canes home game ends.

To that end, this little program watches the NHL API for a home game for my team. If there's a home game today, it's gone final, and my car is parked at the arena, it will send an API action to my car to turn on the climate control and set the navigation for home. That way, when I walk out to my car, it's warmed up and ready to head for home!

If the home team wins, it will also honk the horn and flash the lights in celebration!

If there's no home game today, it just quietly exits, to try again tomorrow.

You can use this for your own local team and arena - just set those in the configuration file and run it on your own Ruby-friendly server!

## Installation

### Easiest - use Docker Compose

The easiest way to get `tesla_puck` up and running is by using [Docker Compose](https://docs.docker.com/compose/). This will download Docker images, set everything up, and run the software.

To run `tesla_puck` with Docker Compose, you will need to create two files:
* A `.env` file with your configuration
* A `docker-compose.yml` file for Docker.

#### docker-compose.yml

You should be able to copy this file verbatim into a directory on your Docker-enabled system:

```
version: "3"
services:
  redis:
    image: "redis:4.0-alpine"
    command: redis-server
    volumes:
      - "redis:/data"

  website:
    depends_on:
      - "redis"
    image: minter/tesla_puck:latest
    command: bundle exec puma -e production config.ru
    ports:
      - "${WEB_PORT}:9292"
    environment:
      REDIS_URL: redis://redis:6379/0

  sidekiq:
    depends_on:
      - "redis"
    image: minter/tesla_puck:latest
    command: bundle exec sidekiq -e production -C config/sidekiq.yml -g teslapuck -r /app/lib/tesla_puck.rb
    environment:
      REDIS_URL: redis://redis:6379/0

volumes:
  redis:
```

Then, add your `.env` file (see the [Configuration](#configuration-with-env) section below)

Once both files are in place, run: `docker-compose up -d` - that will pull the required images, start the servides, and run them in the background. The Sidekiq admin will be available on whichever port you set the `WEB_PORT` value to.

### Slightly less easy - clone the repository and run Docker Compose

Clone this repository to your system.

Create a `.env` file or copy the `.env.example` file to `.env` and edit it for your values (see the [Configuration](#configuration-with-env) section below)

Inside the checked-out repository, run: `docker-compose up` using the `docker-compose.yml` provided inside the repository.



### Least Easy - run everything manually

The following technologies are required to build this:
* **Ruby** - 2.7.x recommended
* **Bundler** - use Bundler to install the required rubygems
* **Redis** - used by Sidekiq

Additionally, we recommend a web server that can load a Rack configuration (like [Phusion Passenger](https://www.phusionpassenger.com)) and something that can daemonize Sidekiq (like systemd if you're on Ubuntu)

#### Installation

Clone this repository to your system.

Install the required gems with Bundler

`bundle install --without development`

Copy `.env.example` to `.env` and edit the values to match your requirements ([see below](#configuration-with-env))

Configure systemd or your daemonizer of choice to run Sidekiq. An example is provided in `examples/sidekiq-teslapuck.service`

Configure Passenger or your web server of choice to serve up the Sidekiq web admin via Rack. An example for Passenger/Nginx is provided in `examples/nginx-passenger.conf`

## Configuration with .env

The configuration lives in a file named `.env` in the root directory where you're running things. A sample is provided for you as `.env.example`, so that you can adjust to your particular needs.

Previously, `tesla_puck` used a file named `config/environment.yml` - that file is no longer loaded.

Configuration values are in the form:

`CONFIGURATION_VARIABLE=value`

The configuration options are as follows:
* **ARENA_LATITUDE** - The latitude of the arena. You can get this from a [geocoding website](https://geocoding.geo.census.gov/geocoder/locations/address?form).
* **ARENA_LONGITUDE** - The longitude of the arena. See above.
* **ARENA_PARKING_DISTANCE_MILES** - How close to the arena (in miles) does your car need to be for this to work. We don't want to start your car if it's home in your garage.
* **HOME_ADDRESS** - The address of where you're going after the game. We pre-load this into your navigation after the game is over. Should be street/city/state/zip.
* **LOG_ENABLED** - If you want to have a log written to help you see what's happening, set this value to anything. If it's blank, we will not log. Recommended value to enable the log is `true`
* **LOG_FILE** - If you're logging, here's where to write the log file.
* **redis_url** - The URL to your redis database (use the `/1` or another number at the end to choose an unused database)
* **TESLA_CLIENT_ID** - The client ID that allows access to the Tesla API. This seems to get passed around the internet, and there doesn't seem to be a reliable way to get it programatically.
* **TESLA_CLIENT_SECRET** - The client secret for the Tesla API. See above.
* **TESLA_EMAIL** - Your email address that you use to log into your Tesla account (only stored locally and used to authenticate to your car).
* **TESLA_PASSWORD** - The password that you use to log into your Tesla account (only stored locally and used to authenticate to your car).
* **TIME_ZONE** - The time zone that your team is in. Provided in `TZInfo` format, so you'll want to pick one of these:
  * `America/New_York` - Eastern Time
  * `America/Chicago` - Central Time
  * `America/Denver` - Mountain Time
  * `America/Phoenix` - Arizona's weird DST rules
  * `America/Los_Angeles` - Pacific Time
* **NHL_TEAM_ID** - The numeric ID for the NHL team that you are following (see the table below)
* **WEB_PASSWORD** - The password used to protect your Sidekiq web UI
* **WEB_PORT** - The TCP port to expose the web server on.

## Team ID Numbers

These are the team ID numbers required as part of NHL StatsWeb to pull game/team information.

Team Name | Team ID
--- | ---
Anaheim Ducks | 24
Arizona Coyotes | 53
Boston Bruins | 6
Buffalo Sabres | 7
Calgary Flames | 20
Carolina Hurricanes | 12
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
Seattle Kraken | 55
Tampa Bay Lightning | 14
Toronto Maple Leafs | 10
Vancouver Canucks | 23
Vegas Golden Knights | 54
Washington Capitals | 15
Winnipeg Jets | 52

## Known Issues

This code currently just grabs the first Tesla out of your account. If you have more than one Tesla: First, congratulations. Second, the code may need to be updated to get the correct car for you.

It would be nice if we could get the time zone of the game venue, but the NHL API does not provide that. It's only provided for the team. So it's possible that oddly-scheduled games might not work properly if the game is finishing "tomorrow" in your time zone.

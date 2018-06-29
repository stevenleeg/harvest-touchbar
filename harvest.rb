require 'http'
require 'date'
require 'json'

# Create new token on harvest dev account to get your credentials 
HARVEST_TOKEN = ''
HARVEST_ACCOUNT_ID = 123456

def generate_request
  HTTP.headers({
    'Authorization' => "Bearer #{HARVEST_TOKEN}",
    'Harvest-Account-Id' => HARVEST_ACCOUNT_ID,
    'User-Agent' => 'BetterTouchTool (steve@stevegattuso.me)'
  })
end

def get_latest_timer
  resp = generate_request
    .get('https://api.harvestapp.com/v2/time_entries', params: {
      from: Date.today.to_s
    })

  json = JSON.parse(resp.body)

  # Get the latest entry's time
  timers = json['time_entries'].sort do |a, b|
    a_date = DateTime.strptime(a['updated_at'])
    b_date = DateTime.strptime(b['updated_at'])

    if a_date > b_date
      -1
    elsif a_date < b_date
      1
    else
      0
    end
  end

  timers.first
end

def toggle_latest
  latest = get_latest_timer
  return generate_err if latest.nil?

  if latest['is_running']
    generate_request.patch(
      "https://api.harvestapp.com/v2/time_entries/#{latest['id']}/stop"
    )
  else
    generate_request.patch(
      "https://api.harvestapp.com/v2/time_entries/#{latest['id']}/restart"
    )
  end

  hours = latest['hours'].floor
  minutes = ((latest['hours'] - hours) * 60).ceil

  puts JSON.generate({
    text: "#{hours}:#{minutes}",
    background_color: '0, 0, 0, 0',
    icon_path: "~/Code/scripts/harvest-#{!latest['is_running'] ? 'active' : 'inactive'}.png", 
  })
end

def generate_status
  latest = get_latest_timer
  return generate_err if latest.nil?

  hours = latest['hours'].floor
  minutes = ((latest['hours'] - hours) * 60).ceil

  puts JSON.generate({
    text: "#{hours}:#{minutes}",
    background_color: '0, 0, 0, 0',
    icon_path: "~/Code/scripts/harvest-#{latest['is_running'] ? 'active' : 'inactive'}.png", 
  })
end

def generate_err
  puts JSON.generate({
    text: "--",
    background_color: '0, 0, 0, 0',
    icon_path: "~/Code/scripts/harvest-inactive.png", 
  })
end

if ARGV[0] == '-t'
  toggle_latest
else
  generate_status
end

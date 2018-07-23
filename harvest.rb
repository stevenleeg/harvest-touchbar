require 'http'
require 'date'
require 'json'
require 'yaml'

# Create new token on harvest dev account to get your credentials 
ROOT_PATH = File.expand_path(File.dirname(__FILE__))
CONFIG = YAML.load_file(File.join(ROOT_PATH, 'config.yml'))

def generate_request
  HTTP.headers({
    'Authorization' => "Bearer #{CONFIG['harvest_token']}",
    'Harvest-Account-Id' => CONFIG['harvest_account_id'],
    'User-Agent' => 'BetterTouchTool (steve@stevegattuso.me)'
  })
end

def icon_path(active:)
  File.join(ROOT_PATH, "resources/harvest-#{active ? 'active' : 'inactive'}.png")
end

def get_latest_timer
  begin
    resp = generate_request
      .get('https://api.harvestapp.com/v2/time_entries', params: {
        from: Date.today.to_s
      })
  rescue HTTP::ConnectionError
    return nil
  end

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
    text: "#{hours}:#{minutes.to_s.rjust(2, '0')}",
    background_color: '0, 0, 0, 0',
    icon_path: icon_path(active: !latest['is_running']), 
  })
end

def generate_status
  latest = get_latest_timer
  return generate_err if latest.nil?

  hours = latest['hours'].floor
  minutes = ((latest['hours'] - hours) * 60).ceil

  puts JSON.generate({
    text: "#{hours}:#{minutes.to_s.rjust(2, '0')}",
    background_color: '0, 0, 0, 0',
    icon_path: icon_path(active: latest['is_running']), 
  })
end

def generate_err
  puts JSON.generate({
    text: "--:--",
    background_color: '0, 0, 0, 0',
    icon_path: icon_path(active: false),
  })
end

if ARGV[0] == '-t'
  toggle_latest
elsif ARGV[0] == '-j'
  config = File.read(File.join(ROOT_PATH, 'resources/bettertouchtool.json'))
  json = JSON.parse(config)

  json['BTTShellTaskActionScript'] =
    "#{RbConfig.ruby} #{ROOT_PATH}/harvest.rb -t"
  json['BTTTriggerConfig']['BTTTouchBarShellScriptString'] =
    "#{RbConfig.ruby} #{ROOT_PATH}/harvest.rb"

  puts JSON.generate(json)
else
  generate_status
end

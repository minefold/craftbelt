class MinecraftSettings
  attr_reader :build_dir, :instance, :settings

  def initialize(build_dir)
    @build_dir = build_dir
    @instance = Craftbelt::MinecraftInstance.new('.')
  end

  def data
    @data ||= begin
      data_text = ENV['DATA']
      if !data_text
        data_text = File.read(File.expand_path(ENV['DATAFILE']))
      end

      JSON.parse(data_text, symbolize_names: true)
    end
  end

  def settings
    @settings ||= begin
      # TODO remove when access policies are standard
      access = data[:access] || {
        whitelist: (data['settings']['whitelist'] || '').split
      }

      schema = JSON.parse(File.read("#{@build_dir}/funpack.json"))['schema']

      Settings.new(schema, data[:settings].merge(
          "name" => data[:name],
          "enable-white-list" => data[:access],
          "level-name" => (@instance.level_paths.first || 'level')
        )
      )
    end
  end

  def write_player_files
    File.write('ops.txt', player_list(data[:settings][:ops]))
    File.write('white-list.txt', player_list(data[:settings][:whitelist]))
    File.write('banned-players.txt', player_list(data[:settings][:blacklist]))
  end

  def write_templates(templates)
    templates.each do |src, dest|
      `mkdir -p #{File.dirname(dest)}`
      File.write(dest, settings.erb(File.read("#{@build_dir}/templates/#{src}")))
    end
  end

  # TODO remove this when players are passed as an array
  def player_list(player_setting)
    if player_setting.is_a? Array
      player_setting.join("\n")
    else
      player_setting || ''
    end
  end
end
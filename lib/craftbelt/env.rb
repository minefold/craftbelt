require 'craftbelt/instance'

module Craftbelt
  class Env
    attr_reader :build_dir, :instance, :settings

    def initialize(instance_dir, build_dir, extra_settings={})
      @instance = Craftbelt::Instance.new(instance_dir)
      @build_dir = build_dir
      vals = settings_raw.merge(
          "name" => data[:name],
          "enable-white-list" => whitelist?,
          "level-name" => (instance.level_paths.first || 'level')
        ).merge(extra_settings)

      @settings = Settings.new(schema, vals)
    end

    def data
      @data ||= begin
        JSON.parse(ENV['DATA'] || '{}', symbolize_names: true) rescue {}
      end
    end

    def schema
      @schema ||= begin
        JSON.parse(File.read("#{@build_dir}/funpack.json"))['schema']
      end
    end

    def access
      @access ||= begin
        data[:access] || { blacklist: [] }
      end
    end

    def whitelist?
      !!access[:whitelist]
    end

    def settings_raw
      @settings_raw ||= begin
        data[:settings] || {}
      end
    end

    def write_player_files
      File.write('ops.txt', player_list(settings_raw[:ops])) if settings_raw[:ops]
      File.write('white-list.txt', player_list(access[:whitelist])) if access[:whitelist]
      File.write('banned-players.txt', player_list(access[:blacklist])) if access[:blacklist]
    end

    def write_templates(templates)
      templates.each do |src, dest|
        `mkdir -p #{File.dirname(dest)}`
        File.write(dest, erb(File.read("#{@build_dir}/templates/#{src}")))
      end
    end

    # TODO remove this when players are passed as an array
    def player_list(player_setting)
      if player_setting.is_a? Array
        player_setting.join("\n")
      else
        player_setting
      end
    end

    def ram
      (ENV['RAM'] || 1024).to_i
    end

    def field(name)
      settings.field(name)
    end
    alias_method :f, :field

    def erb(template)
      ERB.new(template).result(binding)
    end

  end
end
require 'find'
require 'nbtfile'

module Craftbelt
  class Instance
    attr_reader :root

    ROOT_FILES = %w(
      server.properties
      ops.txt
      white-list.txt
    )

    def initialize(initial_root)
      @initial_root = initial_root
    end

    def root
      @root ||= find_root!
    end

    def valid?
      !root.nil?
    end

    # converts single player worlds to server worlds
    def prepare!
      if level_in_root?
        Dir.chdir(root) do
          ROOT_FILES.each do |root_file|
            `rm -f #{root_file}`
          end
          `mkdir -p level; mv * level 2>/dev/null; touch #{ROOT_FILES.first}`
        end
      end
    end

    def level_in_root?
      relative_level_paths == ['.']
    end

    def to_h(include_paths = [])
      Dir.chdir(root) do
        {
          root: root,
          paths: relative_level_paths + include_paths.select{|p| File.exist?(p) },
          settings: read_settings
        }
      end
    end

    def level_dats
      @level_dats ||= begin
        paths = []
        Find.find(@initial_root) do |path|
          if path =~ /\/(level|uid)\.dat$/
            paths << path
          end
        end
        paths
      end
    end

    def read_settings
      settings = {}
      begin
        nbt = NBTFile.read(File.open(level_dats.first))
        settings = {
          seed: nbt[1]['Data']['RandomSeed'].value.to_s
        }
      rescue
        # nbt read failed
      end
      settings
    end

    def level_paths
      @level_paths ||= level_dats.map{|file| File.dirname(file).gsub(/^\.\//, '') }
    end

    def relative_level_paths
      level_paths.map{|p| relative_path(root, p) }.uniq
    end

    def relative_path(root, path)
      relative = (path.split('/') - root.split('/')).join('/')
      relative == '' ? '.' : relative
    end

    def find_root!
      Find.find(@initial_root) do |path|
        ROOT_FILES.each do |root_file|
          if path.end_with? root_file
            return File.expand_path(File.dirname(path))
          end
        end
      end

      # no root files, might be single player world
      if level_paths.any?
        File.expand_path(level_paths.min)
      end
    end
  end
end
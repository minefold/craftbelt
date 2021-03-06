require 'spec_helper'
require 'craftbelt/instance'
require 'fakefs'

module Craftbelt
  describe MinecraftInstance do
    def self.paths(paths)
      before do
        stub = Find.stub(:find)
        paths.each do |path|
          stub.and_yield(path)
        end
      end
    end

    before { FileUtils.mkdir_p('tmp/server')  }

    subject { MinecraftInstance.new('.') }

    context 'single player world' do
      paths %w(
        tmp/server/level.dat
        tmp/server/region/r.0.0.mca
      )
      its(:root) { should end_with 'tmp/server' }
      its(:level_paths) { should == ['tmp/server'] }
      it "should serialize" do
        subject.to_h.should == {
          root: File.expand_path('tmp/server'),
          paths: ['.'],
          settings: {}
        }
      end
    end

    context 'server world' do
      paths %w(
        tmp/server/server.properties
        tmp/server/level/level.dat
      )
      its(:root) { should end_with 'tmp/server' }
      its(:level_paths) { should == ['tmp/server/level'] }
      it "should serialize" do
        subject.to_h.should == {
          root: File.expand_path('tmp/server'),
          paths: ['level'],
          settings: {}
        }
      end
    end
  end
end
require 'rrd'

module Hyperion
  class Collectd
    COLLECTD_BASE_DIR = '/var/lib/collectd/rrd'
    GRAPH_BASE_DIR    = '/tmp'

    attr_accessor :base_dir

    def initialize (base_dir = COLLECTD_BASE_DIR)
      @base_dir = base_dir

      if !@base_dir || !Dir.exists?(@base_dir)
        raise ArgumentError
      end
    end

    def hosts
      Dir.glob("#{base_dir}/*")
        .keep_if {|d| d != /^\.\.?$/ }
        .map {|d| Host.new(File.basename(d), d) }
    end

    class Host
      attr_accessor :name, :path

      def initialize (name, path)
        @name = name
        @path = path
      end

      def plugins
        Dir.glob("#{path}/*")
          .keep_if {|d| d != /^\.\.?$/ }
          .map {|d| Plugin.new(name, File.basename(d).split('-').first, d) }
      end
    end

    class Plugin
      attr_accessor :host, :name, :path

      def initialize (host, name, path)
        @host = host
        @name = name
        @path = path
      end

      def rrds
        Dir.glob("#{path}/*")
          .keep_if {|d| d != /^\.\.?$/ }
          .map { |d| RRD.new(name, File.basename(d).sub(/\.rrd$/, '').split('-').last, d) }
      end
    end

    class RRD::Error < RuntimeError; end
    class RRD
      attr_accessor :plugin, :name, :path

      def initialize (plugin, name, path)
        @plugin = plugin
        @name   = name
        @path   = path
      end

      def host
        path.split('/')[-3]
      end

      def title
        "#{host} #{plugin} - #{name}"
      end

      def graph (options = {})
        graph = options[:graph] ? options[:graph] : "#{GRAPH_BASE_DIR}/#{plugin}-#{name}.png"
        defs  = RRD::Definition.find(plugin).map do |definition|
          definition.sub(/\{file\}/, path)
        end
        puts defs
        ::RRD::Wrapper.graph(graph, '-t', title, *defs)
      end

      class Definition
        def self.find (plugin)
          DEFINITIONS[plugin.to_sym]
        end

        DEFINITIONS = {
          cpu: [
            '-v', 'CPU load',
            'DEF:avg={file}:value:AVERAGE',
            'DEF:min={file}:value:MIN',
            'DEF:max={file}:value:MAX',
            "AREA:max#ff0000",
            "AREA:min#ffffff",
            "LINE1:avg#4169e1:Percent",
            'GPRINT:min:MIN:%6.2lf%% Min,',
            'GPRINT:avg:AVERAGE:%6.2lf%% Avg,',
            'GPRINT:max:MAX:%6.2lf%% Max,',
            'GPRINT:avg:LAST:%6.2lf%% Last\l'
          ],
          load: [
            '-v', 'System load',
            'DEF:s_avg={file}:shortterm:AVERAGE',
            'DEF:s_min={file}:shortterm:MIN',
            'DEF:s_max={file}:shortterm:MAX',
            'DEF:m_avg={file}:midterm:AVERAGE',
            'DEF:m_min={file}:midterm:MIN',
            'DEF:m_max={file}:midterm:MAX',
            'DEF:l_avg={file}:longterm:AVERAGE',
            'DEF:l_min={file}:longterm:MIN',
            'DEF:l_max={file}:longterm:MAX',
            "AREA:s_max#B7EFB7",
            "AREA:s_min#FFFFFF",
            "LINE1:s_avg#00E000: 1m average",
            'GPRINT:s_min:MIN:%4.2lf Min,',
            'GPRINT:s_avg:AVERAGE:%4.2lf Avg,',
            'GPRINT:s_max:MAX:%4.2lf Max,',
            'GPRINT:s_avg:LAST:%4.2lf Last\n',
            "LINE1:m_avg#0000FF: 5m average",
            'GPRINT:m_min:MIN:%4.2lf Min,',
            'GPRINT:m_avg:AVERAGE:%4.2lf Avg,',
            'GPRINT:m_max:MAX:%4.2lf Max,',
            'GPRINT:m_avg:LAST:%4.2lf Last\n',
            "LINE1:l_avg#FF0000:15m average",
            'GPRINT:l_min:MIN:%4.2lf Min,',
            'GPRINT:l_avg:AVERAGE:%4.2lf Avg,',
            'GPRINT:l_max:MAX:%4.2lf Max,',
            'GPRINT:l_avg:LAST:%4.2lf Last'
          ],
        }
      end
    end
  end
end

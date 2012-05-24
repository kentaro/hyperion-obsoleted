require 'rrd'

module Hyperion
  class Collectd
    COLLECTD_BASE_DIR = configatron.collectd_base_dir
    GRAPH_BASE_DIR    = configatron.collectd_graph_base_dir

    attr_accessor :base_dir

    def initialize (base_dir = COLLECTD_BASE_DIR)
      @base_dir = base_dir

      if !@base_dir || !Dir.exists?(@base_dir)
        raise ArgumentError
      end
    end

    def hosts_map
      @_hosts_map ||= Dir.glob("#{base_dir}/*")
        .keep_if {|d| d != /^\.\.?$/ }
        .map {|d| Host.new(File.basename(d), d) }
        .reduce({}) {|r, i| r[i.name] = i; r }
    end

    def hosts
      hosts_map.values
    end

    def plugins_for (host)
      host = hosts_map[host] || return
      host.plugins
    end

    def rrd_for (host, plugin, type)
      host   = hosts_map[host]         || return
      plugin = host.plugin_for(plugin) || return

      plugin.rrd_for(type)
    end

    class Host
      attr_accessor :name, :path

      def initialize (name, path)
        @name = name
        @path = path
      end

      def plugins_map
        @_plugins_map ||= Dir.glob("#{path}/*")
          .keep_if {|d| d != /^\.\.?$/ }
          .sort
          .map {|d| Plugin.new(name, File.basename(d), d) }
          .find_all{|p| p.has_spec? }
          .reduce({}) {|r, i| r[i.ident] = i; r }
      end

      def plugins
        plugins_map.values
      end

      def plugin_for (plugin)
        plugins_map[plugin]
      end
    end

    class Plugin
      attr_accessor :host, :name, :number, :path

      def initialize (host, name, path)
        @host = host
        @path = path
        (@name, @number) = *name.split('-')
      end

      def ident
        number ? "#{name}-#{number}" : name
      end

      def has_spec?
        Spec.find(name) ? true : false
      end

      def rrds_map
        @_rrds_map ||= Dir.glob("#{path}/*")
          .keep_if {|d| d != /^\.\.?$/ }
          .map { |d| RRD.new(name, File.basename(d).sub(/\.rrd$/, '').split('-').last, d) }
          .reduce({}) {|r, i| r[i.name] = i; r }
      end

      def rrds
        rrds_map.values
      end

      def rrd_for (rrd)
        rrds_map[rrd]
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
        "#{host} #{plugin}(#{name})"
      end

      def graph (options = {})
        graph = options[:graph] ? options[:graph] : "#{GRAPH_BASE_DIR}/#{plugin}-#{name}.png"

        if (spec = Spec.find(plugin))
          spec = spec.map do |line|
            line.sub(/\{file\}/, path)
          end

          if (::RRD::Wrapper.graph(graph, '-t', title, *spec))
            graph
          else
            raise RRD::Error.new(::RRD.error)
          end
        else
          raise ArgumentError.new('no such graph')
        end
      end
    end

    class Spec
      class << self
        def find (plugin)
          SPECS[plugin.to_sym]
        end
      end

      SPECS = {
        cpu: [
          '-v', 'CPU load',
          'DEF:avg={file}:value:AVERAGE',
          'DEF:min={file}:value:MIN',
          'DEF:max={file}:value:MAX',
          "AREA:max#B7B7F7",
          "AREA:min#FFFFFF",
          "LINE1:avg#0000FF:Percent",
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
        df: [
          '-v', 'Percent',
          '-l', '0',
          'DEF:free_avg={file}:free:AVERAGE',
          'DEF:free_min={file}:free:MIN',
          'DEF:free_max={file}:free:MAX',
          'DEF:used_avg={file}:used:AVERAGE',
          'DEF:used_min={file}:used:MIN',
          'DEF:used_max={file}:used:MAX',
          'CDEF:total=free_avg,used_avg,+',
          'CDEF:free_pct=100,free_avg,*,total,/',
          'CDEF:used_pct=100,used_avg,*,total,/',
          'CDEF:free_acc=free_pct,used_pct,+',
          'CDEF:used_acc=used_pct',
          "AREA:free_acc#B7EFB7",
          "AREA:used_acc#F7B7B7",
          "LINE1:free_acc#00E000:Free",
          'GPRINT:free_min:MIN:%5.1lf%sB Min,',
          'GPRINT:free_avg:AVERAGE:%5.1lf%sB Avg,',
          'GPRINT:free_max:MAX:%5.1lf%sB Max,',
          'GPRINT:free_avg:LAST:%5.1lf%sB Last\l',
          "LINE1:used_acc#FF0000:Used",
          'GPRINT:used_min:MIN:%5.1lf%sB Min,',
          'GPRINT:used_avg:AVERAGE:%5.1lf%sB Avg,',
          'GPRINT:used_max:MAX:%5.1lf%sB Max,',
          'GPRINT:used_avg:LAST:%5.1lf%sB Last\l'
        ],
        memory: [
          '-b', '1024',
          '-v', 'Bytes',
          'DEF:avg={file}:value:AVERAGE',
          'DEF:min={file}:value:MIN',
          'DEF:max={file}:value:MAX',
          "AREA:max#B7B7F7",
          "AREA:min#FFFFFF",
          "LINE1:avg#0000FF:Memory",
          'GPRINT:min:MIN:%5.1lf%sbyte Min,',
          'GPRINT:avg:AVERAGE:%5.1lf%sbyte Avg,',
          'GPRINT:max:MAX:%5.1lf%sbyte Max,',
          'GPRINT:avg:LAST:%5.1lf%sbyte Last\l'
        ],
        users: [
          '-v', 'Users',
          'DEF:users_avg={file}:users:AVERAGE',
          'DEF:users_min={file}:users:MIN',
          'DEF:users_max={file}:users:MAX',
          "AREA:users_max#B7B7F7",
          "AREA:users_min#FFFFFF",
          "LINE1:users_avg#0000FF:Users",
          'GPRINT:users_min:MIN:%4.1lf Min,',
          'GPRINT:users_avg:AVERAGE:%4.1lf Average,',
          'GPRINT:users_max:MAX:%4.1lf Max,',
          'GPRINT:users_avg:LAST:%4.1lf Last\l'
        ],
        swap: [
          '-v', 'Bytes', '-b', '1024',
          'DEF:avg={file}:value:AVERAGE',
          'DEF:min={file}:value:MIN',
          'DEF:max={file}:value:MAX',
          "AREA:max#B7B7F7",
          "AREA:min#FFFFFF",
          "LINE1:avg#0000FF:Bytes",
          'GPRINT:min:MIN:%6.2lf%sByte Min,',
          'GPRINT:avg:AVERAGE:%6.2lf%sByte Avg,',
          'GPRINT:max:MAX:%6.2lf%sByte Max,',
          'GPRINT:avg:LAST:%6.2lf%sByte Last\l'
        ],
        entropy: [
          '-v', 'Bits',
          'DEF:avg={file}:entropy:AVERAGE',
          'DEF:min={file}:entropy:MIN',
          'DEF:max={file}:entropy:MAX',
          "AREA:max#B7B7F7",
          "AREA:min#FFFFFF",
          "LINE1:avg#0000FF:Bits",
          'GPRINT:min:MIN:%4.0lfbit Min,',
          'GPRINT:avg:AVERAGE:%4.0lfbit Avg,',
          'GPRINT:max:MAX:%4.0lfbit Max,',
          'GPRINT:avg:LAST:%4.0lfbit Last\l'
        ],

        # disk: [
        #   'DEF:rtime_avg={file}:rtime:AVERAGE',
        #   'DEF:rtime_min={file}:rtime:MIN',
        #   'DEF:rtime_max={file}:rtime:MAX',
        #   'DEF:wtime_avg={file}:wtime:AVERAGE',
        #   'DEF:wtime_min={file}:wtime:MIN',
        #   'DEF:wtime_max={file}:wtime:MAX',
        #   'CDEF:rtime_avg_ms=rtime_avg,1000,/',
        #   'CDEF:rtime_min_ms=rtime_min,1000,/',
        #   'CDEF:rtime_max_ms=rtime_max,1000,/',
        #   'CDEF:wtime_avg_ms=wtime_avg,1000,/',
        #   'CDEF:wtime_min_ms=wtime_min,1000,/',
        #   'CDEF:wtime_max_ms=wtime_max,1000,/',
        #   'CDEF:total_avg_ms=rtime_avg_ms,wtime_avg_ms,+',
        #   'CDEF:total_min_ms=rtime_min_ms,wtime_min_ms,+',
        #   'CDEF:total_max_ms=rtime_max_ms,wtime_max_ms,+',
        #   "AREA:total_max_ms#F7B7B7",
        #   "AREA:total_min_ms#FFFFFF",
        #   "LINE1:wtime_avg_ms#00E000:Write",
        #   'GPRINT:wtime_min_ms:MIN:%5.1lf%s Min,',
        #   'GPRINT:wtime_avg_ms:AVERAGE:%5.1lf%s Avg,',
        #   'GPRINT:wtime_max_ms:MAX:%5.1lf%s Max,',
        #   'GPRINT:wtime_avg_ms:LAST:%5.1lf%s Last\n',
        #   "LINE1:rtime_avg_ms#0000FF:Read ",
        #   'GPRINT:rtime_min_ms:MIN:%5.1lf%s Min,',
        #   'GPRINT:rtime_avg_ms:AVERAGE:%5.1lf%s Avg,',
        #   'GPRINT:rtime_max_ms:MAX:%5.1lf%s Max,',
        #   'GPRINT:rtime_avg_ms:LAST:%5.1lf%s Last\n',
        #   "LINE1:total_avg_ms#F7B7B7:Total",
        #   'GPRINT:total_min_ms:MIN:%5.1lf%s Min,',
        #   'GPRINT:total_avg_ms:AVERAGE:%5.1lf%s Avg,',
        #   'GPRINT:total_max_ms:MAX:%5.1lf%s Max,',
        #   'GPRINT:total_avg_ms:LAST:%5.1lf%s Last'
        # ],

        # processes: [
        #   "DEF:running_avg={file}:running:AVERAGE",
        #   "DEF:running_min={file}:running:MIN",
        #   "DEF:running_max={file}:running:MAX",
        #   "DEF:sleeping_avg={file}:sleeping:AVERAGE",
        #   "DEF:sleeping_min={file}:sleeping:MIN",
        #   "DEF:sleeping_max={file}:sleeping:MAX",
        #   "DEF:zombies_avg={file}:zombies:AVERAGE",
        #   "DEF:zombies_min={file}:zombies:MIN",
        #   "DEF:zombies_max={file}:zombies:MAX",
        #   "DEF:stopped_avg={file}:stopped:AVERAGE",
        #   "DEF:stopped_min={file}:stopped:MIN",
        #   "DEF:stopped_max={file}:stopped:MAX",
        #   "DEF:paging_avg={file}:paging:AVERAGE",
        #   "DEF:paging_min={file}:paging:MIN",
        #   "DEF:paging_max={file}:paging:MAX",
        #   "DEF:blocked_avg={file}:blocked:AVERAGE",
        #   "DEF:blocked_min={file}:blocked:MIN",
        #   "DEF:blocked_max={file}:blocked:MAX",
        #   'CDEF:paging_acc=sleeping_avg,running_avg,stopped_avg,zombies_avg,blocked_avg,paging_avg,+,+,+,+,+',
        #   'CDEF:blocked_acc=sleeping_avg,running_avg,stopped_avg,zombies_avg,blocked_avg,+,+,+,+',
        #   'CDEF:zombies_acc=sleeping_avg,running_avg,stopped_avg,zombies_avg,+,+,+',
        #   'CDEF:stopped_acc=sleeping_avg,running_avg,stopped_avg,+,+',
        #   'CDEF:running_acc=sleeping_avg,running_avg,+',
        #   'CDEF:sleeping_acc=sleeping_avg',
        #   "AREA:paging_acc#F3DFB7",
        #   "AREA:blocked_acc#B7DFF7",
        #   "AREA:zombies_acc#F7B7B7",
        #   "AREA:stopped_acc#DFB7F7",
        #   "AREA:running_acc#B7EFB7",
        #   "AREA:sleeping_acc#B7B7F7",
        #   "LINE1:paging_acc#F3DFB7:Paging  ",
        #   'GPRINT:paging_min:MIN:%5.1lf Min,',
        #   'GPRINT:paging_avg:AVERAGE:%5.1lf Average,',
        #   'GPRINT:paging_max:MAX:%5.1lf Max,',
        #   'GPRINT:paging_avg:LAST:%5.1lf Last\l',
        #   "LINE1:blocked_acc#00A0FF:Blocked ",
        #   'GPRINT:blocked_min:MIN:%5.1lf Min,',
        #   'GPRINT:blocked_avg:AVERAGE:%5.1lf Average,',
        #   'GPRINT:blocked_max:MAX:%5.1lf Max,',
        #   'GPRINT:blocked_avg:LAST:%5.1lf Last\l',
        #   "LINE1:zombies_acc#FF0000:Zombies ",
        #   'GPRINT:zombies_min:MIN:%5.1lf Min,',
        #   'GPRINT:zombies_avg:AVERAGE:%5.1lf Average,',
        #   'GPRINT:zombies_max:MAX:%5.1lf Max,',
        #   'GPRINT:zombies_avg:LAST:%5.1lf Last\l',
        #   "LINE1:stopped_acc#A000FF:Stopped ",
        #   'GPRINT:stopped_min:MIN:%5.1lf Min,',
        #   'GPRINT:stopped_avg:AVERAGE:%5.1lf Average,',
        #   'GPRINT:stopped_max:MAX:%5.1lf Max,',
        #   'GPRINT:stopped_avg:LAST:%5.1lf Last\l',
        #   "LINE1:running_acc#00E000:Running ",
        #   'GPRINT:running_min:MIN:%5.1lf Min,',
        #   'GPRINT:running_avg:AVERAGE:%5.1lf Average,',
        #   'GPRINT:running_max:MAX:%5.1lf Max,',
        #   'GPRINT:running_avg:LAST:%5.1lf Last\l',
        #   "LINE1:sleeping_acc#0000FF:Sleeping",
        #   'GPRINT:sleeping_min:MIN:%5.1lf Min,',
        #   'GPRINT:sleeping_avg:AVERAGE:%5.1lf Average,',
        #   'GPRINT:sleeping_max:MAX:%5.1lf Max,',
        #   'GPRINT:sleeping_avg:LAST:%5.1lf Last\l'
        # ]
      }
    end
  end
end

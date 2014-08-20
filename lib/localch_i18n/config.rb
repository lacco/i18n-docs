require "pathname"

module LocalchI18n
  class Config
    def initialize(opts = {})
      opts.each do |(attr, value)|
        self.send("#{attr}=", value)
      end
    end

    def self.from_file(path)
      raise "No config file at #{path} found." unless ::File.exists?(path)
      self.new(YAML.load_file(path))
    end

    def self.default(name, default_proc, converter_proc = lambda{|val| val})
      instance_variable = :"@_#{name}"
      setter_method =  :"#{name}="
      getter_method = :"#{name}"

      define_method setter_method do |val|
        instance_variable_set(instance_variable, instance_exec(val, &converter_proc))
      end

      define_method getter_method do
        instance_variable_get(instance_variable) || send(setter_method, instance_exec(&default_proc))
      end
    end

    default :locales, lambda {I18n.available_locales}
    default :export_dir, lambda {::File.join('tmp', 'i18n-docs')}, lambda {|path| Pathname.new(path)}
    default :locale_dir, lambda {::File.join('config', 'locales')}, lambda {|path| Pathname.new(path)}
    default :project_root, lambda {defined?(Rails) ? Rails.root : Dir.pwd}, lambda {|path| Pathname.new(path)}
    default :files, lambda {[]}, lambda {|files| files.map{|file| File.new(self, file)}}

    def log(msg)
      puts "  #{msg}"
    end

    def relative_project_path_for(path)
      path.relative_path_from(project_root)
    end

    class File
      attr_accessor :path, :source, :config, :name

      def initialize(config, attrs)
        @config = config

        attrs.each do |(attr, val)|
          send("#{attr}=", val)
        end
      end

      def full_path_for(locale)
        config.project_root.join(config.locale_dir.join(path).to_s.gsub('#{locale}', locale.to_s))
      end

      def path=(f)
        #ensure .yml filename
        f = f + ".yml" if f !~ /\.yml$/
        @path = f
      end

      def name
        @name || path.gsub(/\.yml$/, "").gsub(/[^a-zA-Z]/, "_").gsub(/^_|_+|_$/, "")
      end
    end
  end
end

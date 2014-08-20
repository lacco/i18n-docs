# encoding: utf-8
#
module LocalchI18n
  class TranslationImporter
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def import
      config.log ""
      config.log "Start importing files:"

      config.files.each do |file|
        csv = open(file.source).read.force_encoding('UTF-8')
        converter = CsvToYaml.new(csv, file, config.locales)
        converter.process
        converter.write_files
        config.log "* Imported #{file.source} to #{file.path}"
      end

      config.log ""
      config.log "Finished!"
      config.log ""
    end
  end
end



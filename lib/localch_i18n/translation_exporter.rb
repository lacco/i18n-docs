module LocalchI18n
  class TranslationExporter
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def export
      config.log ""
      config.log "Start exporting files:"

      config.files.each do |file|
        translations = {}
        config.locales.each do |locale|
          path = file.full_path_for(locale)
          translations[locale] = flatten_translations_hash(YAML.load_file(path)[locale.to_s])
        end

        export_path = config.project_root.join(config.export_dir, file.name + ".csv")
        FileUtils.mkdir_p(File.dirname(export_path))
        write_to_csv(export_path, translations)

        config.log "* Writing CSV to #{config.relative_project_path_for(export_path)}"
      end

      config.log ""
      config.log "CSV files can be removed safely after uploading them manually to Google Spreadsheet."
      config.log ""
    end

    protected

    def write_to_csv(export_path, translations)
      CSV.open(export_path, "wb") do |csv|
        csv << (["key"] + config.locales)

        translations[config.locales.first].keys.each do |key|
          values = config.locales.map do |locale|
            translations[locale][key]
          end
          csv << values.unshift(key)
        end
      end
    end

    def flatten_translations_hash(translations, parent_key = [])
      flat_hash = {}

      translations.each do |key, t|
        current_key = parent_key.dup << key
        if t.is_a?(Hash)
          # descend
          flat_hash.merge!(flatten_translations_hash(t, current_key))
        else
          # leaf -> store as value for key
          flat_hash[current_key.join('.')] = t
        end
      end
      flat_hash
    end

  end

end

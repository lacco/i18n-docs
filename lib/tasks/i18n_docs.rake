
namespace :i18n do

  desc "Find and list translation keys that do not exist in all locales"
  task :missing_keys => :environment do
    finder = LocalchI18n::MissingKeysFinder.new(I18n.backend)
    finder.find_missing_keys
  end

  desc "Download translations from Google Spreadsheet and save them to YAML files."
  task :import_translations => :environment do
    raise "'Rails' not found! Tasks can only run within a Rails application!" if !defined?(Rails)

    config = LocalchI18n::Config.from_file(Rails.root.join('config', 'translations.yml'))

    LocalchI18n::TranslationImporter.new(config).import
  end

  desc "Export all language files to CSV files (only files contained in en folder are considered)"
  task :export_translations => :environment do
    raise "'Rails' not found! Tasks can only run within a Rails application!" if !defined?(Rails)

    config = LocalchI18n::Config.from_file(Rails.root.join('config', 'translations.yml'))

    LocalchI18n::TranslationExporter.new(config).export
  end

end



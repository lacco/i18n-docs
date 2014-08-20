# require 'rake'

# load rake tasks in case GEM is included within rails project

require 'csv'
require 'yaml'
require 'open-uri'
require 'localch_i18n/config'
require 'localch_i18n/missing_keys_finder'
require 'localch_i18n/csv_to_yaml'
require 'localch_i18n/translation_exporter'
require 'localch_i18n/translation_importer'



if defined?(Rails)
  class LocalchI18nTask < Rails::Railtie
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
    end
  end
end


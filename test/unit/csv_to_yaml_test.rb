require 'test_helper'
require 'mocha'

# run test: ruby -I test/ -I lib/ test/unit/csv_to_yaml_test.rb

Rails = Struct.new(:dummy)

module UnitTests
  
  class CsvToYamlTest < Test::Unit::TestCase
    include TestHelper
    
    def setup
      create_tmp_dir
      
      @input_file  = File.join(fixture_path, 'minimal.csv')
      @output_file = File.join(tmp_dir, 'test.yml')
      @locales = ['de', 'en']
      
      Rails.stubs(:root).returns(stub(:join => @output_file))
      
      @csv_to_yaml = LocalchI18n::CsvToYaml.new(@input_file, @output_file, @locales)
    end
    
    def teardown
      remove_tmp_dir
    end
    
    def test_process_row
      row1 = {'key' => 'homepage.meta.title', 'en' => 'Phonebook of Switzerland', 'de' => 'Telefonbuch der Schweiz'}
      row2 = {'key' => 'homepage.welcome', 'en' => 'Welcome', 'de' => 'Willkommen'}
      @csv_to_yaml.process_row(row1)
      @csv_to_yaml.process_row(row2)
      
      translations = @csv_to_yaml.translations
      assert_equal 'Telefonbuch der Schweiz', translations['de']['homepage']['meta']['title']
      assert_equal 'Willkommen', translations['de']['homepage']['welcome']
      assert_equal 'Phonebook of Switzerland', translations['en']['homepage']['meta']['title']
      assert_equal 'Welcome', translations['en']['homepage']['welcome']
    end
    
    
    def test_store_translations
      keys = ['homepage', 'meta', 'title']
      @csv_to_yaml.store_translation(keys, 'de', 'Telefonbuch der Schweiz')
      
      translations = @csv_to_yaml.translations
      assert_equal 'Telefonbuch der Schweiz', translations['de']['homepage']['meta']['title']
    end
    
    def test_process
      @locales.each do |locale| 
        assert_empty @csv_to_yaml.translations[locale], "expected translation hash for locale '#{locale}' to be empty"
      end
      
      @csv_to_yaml.process
      
      @locales.each do |locale|
        assert @csv_to_yaml.translations[locale]['tel']['extended']['company_label']
        assert @csv_to_yaml.translations[locale]['tel']['extended']['company_label'].is_a?(String)
        assert @csv_to_yaml.translations[locale]['tel']['search_button']
        assert @csv_to_yaml.translations[locale]['tel']['search_button'].is_a?(String)
      end
    end
    
    def test_write_files
      assert !File.exists?(@output_file)
      @csv_to_yaml.process
      @csv_to_yaml.write_files
      assert File.exists?(@output_file)
    end
    
  end
end
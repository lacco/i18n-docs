require 'test_helper'

# run test: ruby -I test/ -I lib/ test/unit/locale_builder_test.rb

module UnitTests
  class TranslationsTest < Test::Unit::TestCase
    include TestHelper

    def setup
      create_tmp_dir

      config = LocalchI18n::Config.new(
        :locale_dir => File.join(tmp_dir),
        :locales => [:en, :de],
        :files => [
          :source => File.join(fixture_path, "minimal.csv"),
          :path => '#{locale}/navigation.yml'
        ]
      )
      @importer = LocalchI18n::TranslationImporter.new(config)
    end

    def teardown
      remove_tmp_dir
    end

    def test_import
      assert Dir[File.join(tmp_dir, "*")].empty?

      @importer.import

      de_path = File.join(tmp_dir, "de", "navigation.yml")
      en_path = File.join(tmp_dir, "en", "navigation.yml")

      assert File.exists?(de_path)
      assert File.exists?(en_path)

      assert_equal "Find It", YAML.load_file(en_path)["en"]["tel"]["search_button"]
      assert_equal "Finden", YAML.load_file(de_path)["de"]["tel"]["search_button"]
    end
  end
end

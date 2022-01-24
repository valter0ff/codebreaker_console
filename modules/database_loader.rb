module DatabaseLoader
  DATA_FILE = File.expand_path('../db/db.yml', __dir__)
  DIR_NAME = 'db'.freeze

  def load_from_file
    YAML.load_stream(File.read(DATA_FILE)) if File.exist?(DATA_FILE)
  end

  def store_to_file(hsh)
    Dir.mkdir(DIR_NAME) unless Dir.exist?(DIR_NAME)
    File.open(DATA_FILE, 'a') { |file| file.write(hsh.to_yaml) }
  end
end

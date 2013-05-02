module Hari
  module Scripts

    SCRIPT_PATH = File.expand_path('../scripts', __FILE__)

    def map
      @scripts ||= {}
    end

    def load
      files = Dir[SCRIPT_PATH.join('**/*.lua')]

      files.each do |file|
        name   = file.gsub("#{SCRIPT_PATH}/", '').gsub('.lua', '')
        script = File.read(file)
        sha    = Hari.redis.script(:load, script)
        map[name] = sha
      end
    end

    def sha(script_name)
      map[script_name.to_s]
    end

  end
end

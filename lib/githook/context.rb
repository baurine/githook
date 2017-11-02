module Githook
  class Context
    def self.set(key, value)
      @env ||= {}
      @env[key] = value
    end
  
    def self.fetch(key, def_val)
      @env ||= {}
      @env[key] || def_val
    end 
  end
end

def set(key, value)
  Githook::Context.set(key, value)
end

def fetch(key, def_val)
  Githook::Context.fetch(key, def_val)
end

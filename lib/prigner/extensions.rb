class Symbol

  # Method for comparison between symbols.
  def <=>(other)
    self.to_s <=> other.to_s
  end

end

class Hash

  # Only symbolize all keys, including all key in sub-hashes. 
  def symbolize_keys
    return self.clone if self.empty?
    self.inject({}) do |hash, (key, value)|
      hash[key.to_sym] = if value.kind_of? Hash
                           value.symbolize_keys
                         else
                           value
                         end
      hash
    end
  end

  # Set instance variables by key and value only if object respond
  # to access method for variable.
  def instance_variables_set_to(object)
    collect do |variable, value|
      object.instance_variable_set("@#{variable}", value) if object.respond_to? variable
    end
    object
  end

  # Convert to Struct including all values that are Hash class.
  def to_struct
    keys    = self.keys.sort
    members = keys.map{ |key| key.to_sym }
    Struct.new(*members).new(*keys.map do |key|
      if self[key].kind_of? Hash
        self[key].to_struct
      else
        self[key]
      end
    end) unless self.empty?
  end

end

class Struct

  # Public bind.
  def binding
    super
  end

end

class Pathname

  # For compatibilities with Net::HTTP.get method.
  def get(file)
    result = self.join(file.gsub(/^\/(.*?)$/){$1})
    def result.to_s
      return [self.inspect, self.read].join("\n")
    end
    result
  end

  # For compatibilities with the Net::HTTPResponse.read_body method.
  alias read_body read

  # For compatibilities with the Net::HTTP.address method.
  alias address expand_path

  # For compatibilities with the Net::HTTP.port method.
  def port
    nil
  end

  # For compatibilities with the Net::HTTP.start method.
  def start
    block_given? ? (yield self) : self
  end

end

class NilClass

  # nil is empty? of course!
  def empty?
    true
  end

end

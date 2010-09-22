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

class String

  # Convert to Pathname.
  def to_path
    Pathname(self)
  end

end

class Struct

  # Public bind.
  def binding
    super
  end

end

class Pathname

  def chpath(source, path)
    self.path.gsub(%r{#{source}}, path).to_path
  end

end


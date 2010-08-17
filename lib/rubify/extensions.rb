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
    Struct.new(*self.keys).new(*self.keys.map do |key|
      if self[key].kind_of? Hash
        self[key].to_struct
      else
        self[key]
      end
    end) unless self.keys.empty?
  end

end

class String

  # Convert to Pathname.
  def to_path
    Pathname(self)
  end

end

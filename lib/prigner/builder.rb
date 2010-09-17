class Rubify::Builder

  def self.evaluate(buildfile)
    builder = new
    builder.instance_eval(File.read(buildfile.to_s), buildfile.to_s, 1)
    builder
  end

  def metainfo(&block)
    @block = :metainfo
    yield
    @block = nil
  end

  def options(&block)
    @block = :options
  end

  def models(&block)
    @block = :models
    yield
    @block = nil
  end

  def method_missing(key, *args)
    if within_block? and namespace.include? key.to_s
      config key, args.first
    else
      super(key, *args)
    end
  end

private

  def initialize
    @metainfo    = {}
    @options     = {}
    @directories = []
    @models      = {}
    @namespace   = {
      :metainfo => %w{author email version description},
      :options  => %w{on},
      :models   => %w{source}
    }
  end

  def config(key, value)
    instance_variable_get("@#{@block}")[key] = value
  end

  def namespace
    @namespace[@block]
  end

  def within_block?
    !@block.nil?
  end

end


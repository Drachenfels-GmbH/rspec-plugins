class Foobar
  attr_accessor :loaded, :added, :reload_required

  def initialize
    @added = []
    @loaded = []
    @reload_required = false
    reset
  end

  def reload
    if @reload_required && ! @loaded.empty?
      puts "RELOAD #{@loaded}"
      @reloaded = @loaded
      @reload_required = false
    end
  end

  def load
    if ! @added.empty?
      puts "LOADING #{@added}"
      @loaded += @added
      @added = []
    end
  end

  def add(fixture_id)
    puts "ADD #{fixture_id}"
    @added << fixture_id
  end

  def remove(fixture_id)
    puts "REMOVE #{fixture_id}"
    @removed << @loaded.delete(fixture_id)
    @reload_required = true
  end

  attr_accessor :removed, :reloaded

  def reset
    @removed = []
    @reloaded = []
  end
end
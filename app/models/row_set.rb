class RowSet
  include Enumerable

  attr_reader :max_size, :block_start, :last_row_num, :last_update

  def initialize(max_size, time = Time)
    @rows = []
    @time = time
    @max_size = max_size
  end

  def length
    @rows.length
  end

  def block_started?
    !(@block_start.nil?)
  end

  def add_row(row_num, row)
    @rows << row
    @last_row_num = row_num

    unless block_started?
      @block_start = row_num
      @last_update = @time.now
    end

    row
  end

  def flush
    @rows.clear
    @last_update = @time.now
    @block_start = nil
  end

  def full?
    self.length >= @max_size
  end

  def each &block
    @rows.each{ |r| yield r }
  end

  def rate
    return 0 unless @last_update

    (self.length / (@time.now.to_f - @last_update.to_f)).to_i
  end
end

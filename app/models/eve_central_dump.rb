require 'csv'

class EveCentralDump
  START_ROW = 1

  def initialize(options = {})
    @batch_size = options[:batch_size] || 2500

    @heading_map = options[:heading_map] ||
      {
        'orderid'      => :order_id,
        'regionid'     => :region_id,
        'systemid'     => :solar_system_id,
        'stationid'    => :station_id,
        'typeid'       => :type_id,
        'minvolume'    => :min_vol,
        'bid'          => :bid,
        'price'        => :price,
        'volenter'     => :vol_enter,
        'volremain'    => :vol_remain,
        'issued'       => :issued,
        'duration'     => :duration,
        'range'        => :range,
        'reportedtime' => :reported_ts,
      }

    @logger = options[:logger]
  end

  def parse_headings(row)
    raise MalformedHeader if row.blank? || row.length < 12

    column_map = {}

    colnum = 0
    row.each do |title|
      column_map[colnum] = @heading_map[title] if @heading_map[title]
      colnum += 1
    end

    raise MalformedHeader if column_map.empty?

    column_map
  end

  def duration_to_days(duration)
    if duration =~ /(\d+)\s+day/
      $1.to_i
    elsif duration =~ /^(\d+)$/
      $1.to_i
    else
      @logger.warn "Bad duration: '#{duration}'" if @logger
      nil
    end
  end

  def clean_row(row, column_map)
    new_row = []
    row.each_index do |i|
      name  = column_map[i]
      value = row[i]

      new_row[i] = value
      if [:order_id, :type_id, :system_id, :region_id, :solar_system_id,
          :station_id, :bid, :range, :min_vol, :vol_remain, :vol_enter].include?(name)
        new_row[i] = value.to_i

      elsif name == :price
        new_row[i] = value.to_f
      elsif name == :duration
        new_row[i] = duration_to_days(row[i])

      elsif [:issued, :reported_ts].include?(name)
        new_row[i] = Time.parse(value + ' UTC')
      end
    end

    new_row
  end

  def save_row(row_update)
    row_update[:gen_name] = 'Eve Market Dump'
    Order.save_if_new(row_update)
  end

  def file_lines(file)
    @lines ||= `wc -l #{file}`.split.first.to_i
  end

  def validate_file(file)
    if file.nil? || file.empty?
      raise "No file name specified"
    elsif ! File.exists?(file)
      raise "#{file} doesn't exist!"
    elsif ! File.readable?(file)
      raise "Cannot read #{file}!"
    elsif file_lines(file) <= START_ROW
      raise "File too short!"
    end
  end

  def file_heading(file)
    `head -1 #{file}`
  end

  def load_headings(file)
    parse_headings( CSV.parse( file_heading(file)).first )
  end

  def last_line?(file, row_num)
    row_num == file_lines(file) - 1
  end

  def load_file(file, start_row = 1)
    validate_file(file)

    total_lines = file_lines(file)

    heading_map = load_headings(file)

    row_set = RowSet.new(@batch_size)

    row_num = 0
    start = Time.now.to_f

#    begin
#      RawOrder.connection.execute("DROP INDEX index_raw_orders_on_order_id")
#    rescue ActiveRecord::StatementInvalid => e
#    end

    CSV.foreach(file) do |row|
      if row_num >= start_row
        begin
          row_update = remap_row(row, heading_map)
        rescue Exception => e
          @logger.warn "#{e}: #{e.message} on row #{row_num}" if @logger
        end

        row_set.add_row(row_num, row_update) if row_update

        if row_set.full? || last_line?(file, row_num)
          write_row_set(row_set)

          if @logger && row_num % 100 == 0
            @logger.debug "Loading: #{row_set.block_start} - #{row_num+1} of #{total_lines} (#{run_time(start)}, #{row_set.rate} r/s)"
          end

          row_set.flush
        end
      end

      row_num += 1
    end
#    RawOrder.connection.execute("CREATE INDEX index_raw_orders_on_order_id ON raw_orders (order_id)")
  end

  private

  def remap_row(row, column_map)
    row_data = {}

    cleaned_row = clean_row(row, column_map)

    cleaned_row.each_index do |i|
      val = cleaned_row[i]

      row_data[ column_map[i] ] = val if column_map[i]
    end

    row_data
  end

  def run_time(start)
    running = (Time.now.to_f - start.to_f).to_i

    if running < 60
      str = "#{running} s"
    elsif running < 3600
      str = "#{(running / 60.0).round(2)} m"
    else
      str = "#{(running / 3600.0).round(2)} h"
    end
  end

  def write_row_set(row_set)
    ActiveRecord::Base.transaction do
      row_set.each { |row| save_row(row) }
    end
  end

  class MalformedHeader < Exception; end
end

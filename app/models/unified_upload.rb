class InvalidUploadFormat < StandardError; end
class InvalidGenerator < StandardError; end
class RelayedUpload < StandardError; end
class UnknownType < StandardError; end

class UnifiedUpload
  attr_reader :result_type, :version, :gen_name, :gen_version, :upload_keys, :rows

  def initialize(data, logger=nil)
    @data = data
    @logger = logger

    parse_data(data)
  end

  def debugging?
    @logger && @logger.debug?
  end

  def self.build_upload(data, logger=nil)
    type = data.fetch('resultType').downcase.capitalize

    begin
      (self.name + type).constantize.new(data, logger)
    rescue NameError => e
      raise UnknownType, type
    end
  end

  def uploader_mapping
    {
    :volRemaining => :vol_remain,
    :orderID => :order_id,
    :stationID => :station_id,
    :solarSystemID => :solar_system_id,
    :volEntered => :vol_enter,
    :minVolume => :min_vol,
    :issueDate => :issued,
    :generatedAt => :reported_ts,
    :date => :ts,
    }
  end

  def remap_model_columns(columns)
    columns.map do |col|
      if @model.column_names.include?(col)
        col.to_sym
      else
        uploader_mapping[col.to_sym]
      end
    end
  end

  def parse_metadata(data)
    @result_type  = data['resultType']
    @version      = data['version']
    @upload_keys  = data['uploadKeys']

    generator     = data.fetch('generator', {})
    @gen_name     = generator['name']
    @gen_version  = generator['version']

    @columns = remap_model_columns(data['columns'])

    raise InvalidUploadFormat unless @columns && @result_type

    true
  end

  def row_valid?(row, rowset)
    return true if rowset['regionID'] && rowset['typeID']

    false
  end

  def map_row(row, rowset)
    return nil unless row_valid?(row, rowset)

    row_data = Hash[*@columns.zip(row).flatten]
    row_data.merge!({:region_id   => rowset['regionID'],
                     :type_id     => rowset['typeID'],
                     :gen_name    => @gen_name,
                     :gen_version => @gen_version,
                     :reported_ts  => rowset['generatedAt']})
    row_data
  end

  def parse_rowset(rowset)
    rowset['rows'].inject([]) do |ary, row|
      new_row = map_row(row, rowset)

      ary << new_row if new_row
    end
  end

  def parse_data(data)
    parse_metadata(data)

    raise InvalidGenerator, "#{@gen_name}, #{@gen_version}" unless @gen_name

    @upload_keys.each do |key|
      # Found some data with wrong bid fields coming from Eve Central / RELAYED
      if key['key'] == 'RELAYED' && @result_type != 'history'
        raise RelayedUpload, "#{key['name']}, #{key['key']}"
      end
    end

    @rows = []
    data['rowsets'].each do |rowset|
      new_row = parse_rowset(rowset)
      @rows += new_row unless new_row.blank?
    end
  end
end

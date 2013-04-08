class UnifiedUploadHistory < UnifiedUpload
  def initialize(data, logger = nil)
    @model = OrderHistory
    super(data, logger)
  end

  def history_exists?(row)
    OrderHistory.exists?(row[:type_id], row[:region_id], row[:ts])
  end

  def save_rows
    ActiveRecord::Base.transaction do
      @rows.inject(0) do |count, row|
        row.delete(:reported_ts)

        unless history_exists?(row)
          ret = OrderHistory.create(row, without_protection: true)
        end

        if ret && ret.valid?
          @logger.debug "History: #{ret}" if debugging?
          count += 1
        else
          @logger.warn "Errors: #{ret.errors.inspect}" if @logger && ret
        end

        count
      end
    end
  end
end

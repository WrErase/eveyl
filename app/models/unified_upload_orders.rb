class UnifiedUploadOrders < UnifiedUpload
  def initialize(data, logger = nil)
    @model = Order
    super(data, logger)
  end

  def save_rows
    @rows.inject(0) do |count, row|
      ret = @model.save_if_new(row)

      if ret && ret.valid?
        @logger.debug "Order: #{ret}" if debugging?
        count += 1
      end

      count
    end
  end
end

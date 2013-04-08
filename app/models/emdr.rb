class Emdr
  def initialize(options = {})
    @logger = options[:logger] || Logger.new(STDOUT)
    @url    = options[:url] || 'tcp://relay-us-east-1.eve-emdr.com:8050'
    @upload_class = options[:unified_upload] || UnifiedUpload
  end

  def get_market_data
    @subscriber.recv_string(string = '')

    market_json = Zlib::Inflate.new(Zlib::MAX_WBITS).inflate(string)

    JSON.parse(market_json) unless market_json.blank?
  end

  def rate
    (@rows / (Time.now.to_f - @start_time)).round(2)
  end

  def monitor
    @logger.info "Connecting to EMDR Relay..."

    # For some reason, extracting ZMQ connect into a seperate
    # method causes a hang after the first few receives
    context = ZMQ::Context.new
    @subscriber = context.socket ZMQ::SUB
    @subscriber.connect @url
    @subscriber.setsockopt(ZMQ::SUBSCRIBE,"")
    @subscriber.setsockopt(ZMQ::HWM, 100)

    @logger.info "Monitoring Started"
    loop do
      begin
        market_data = get_market_data
        next unless market_data.present?

        u = @upload_class.build_upload(market_data, @logger)

        u.save_rows
      rescue SystemExit, Interrupt
        @logger.info "Interrupt received, shutting down monitoring"
        @subscriber.close
        break
      rescue Exception => e
        @logger.warn "Upload Parse Failed: #{e}, #{e.message}"
        next
      end
    end
  end
end

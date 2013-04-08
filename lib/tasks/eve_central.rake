namespace :eve_central do
  desc "Load a CSV dump"
  task :load_dump, [:file,:start] => :environment do |t, args|
    if args[:file]
      path = args[:file]
    else
      path = "#{Rails.root}/tmp/" + dump_name
    end
    start_row = (args[:start] || 1).to_i

    unless File.exists?(path)
      path.gsub!(/\.gz/, '')

      unless File.exists?(path)
        puts "Cannot find #{file}!"
        exit
      end
    end

    Rails.logger.info "Loading Eve Central dump: #{file}"
    if path =~ /.gz$/
      output = gunzip_file(path)
    else
      output = path
    end

    ActiveRecord::Base.logger = Rails.logger.clone
    ActiveRecord::Base.logger.level = Logger::INFO

    dump = EveCentralDump.new(logger: Logger.new(STDOUT))
    dump.load_file(output, start_row)
    Rails.logger.info "Completed load of Eve Central dump: #{file}"
  end

  task :get_dump, [:file] => :environment do |t, args|
    file = args[:file] || dump_name
    url = 'http://eve-central.com/dumps/' + file

    output = "#{Rails.root}/tmp/" + file
    exit if File.exists?(output)

    Downloader.get_file(url, output)

    Rails.logger.info "Download of #{url.to_s} complete"
  end

  def dump_name
    1.day.ago.localtime.strftime("%F") + '.dump.gz'
  end

  def gunzip_file(file)
    begin
      Downloader.gunzip_file(file)
    # TODO - More restrictive
    rescue Downloader::InvalidFile => e
      Rails.logger.error "File read exception on #{file}: #{e}"
      nil
    end
  end
end

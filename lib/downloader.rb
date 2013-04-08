require 'net/http'

module Downloader
  def self.gunzip_file(file, output_file = nil, delete = true)
    raise UnknownFile unless File.exists?(file)

    output_name = file.gsub(".gz", '') unless output_file
    begin
      File.open(file) do |f|
        gz = Zlib::GzipReader.new(f)
        output = File.open(output_name, 'w')
        output.write(gz.read)
        gz.close
      end
      File.delete(file) if File.size?(output_name) && delete
    rescue Zlib::GzipFile::Error => e
      raise InvalidFile
    end

    output_name
  end

  def self.get_file(url, output_path)
    uri = URI(url)

#    response = Typhoeus.get(uri)
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      # TODO - Retry the request
      http.request request do |response|
        if response.message != 'OK'
          raise BadResponse, "Response #{response.code} for #{uri.to_s}"
          return
        end

        open output_path, 'wb' do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
  end

  class BadResponse < Exception; end
  class UnknownFile < Exception; end
  class InvalidFile < Exception; end
end

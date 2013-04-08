class EveCentralImport < ActiveRecord::Base
  scope :running, where(status: 'running')
  scope :last_import, order("stop desc").limit(1).first

  def self.log_start(filename)
    self.create(filename: filename,
                start: Time.now,
                status: 'running')
  end

  def self.log_stop(filename, rows, status = 'success', error = nil)
    self.where(filename: filename)
        .first
        .update_attributes(stop: Time.now,
                           rows: rows,
                           status: status,
                           error: error)
  end
end

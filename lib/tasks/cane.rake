begin
  require 'cane/rake_task'

  desc "Run cane to check quality metrics"
  Cane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 20
    cane.add_threshold 'coverage/covered_percent', :>=, 90
    cane.no_style = true
    cane.no_readme = true
    cane.no_doc = true
  end

  task :default => :quality
rescue LoadError
  warn "cane not available, quality task not provided."
end

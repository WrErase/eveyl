# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
end

guard :rspec, :wait => 45, :cli => "--color --drb", :all_after_pass => false, :bundler => false, :all_on_start => false, :keep_failed => false do
  watch('spec/spec_helper.rb')                                               { "spec" }
  watch('app/controllers/application_controller.rb')                         { "spec/controllers" }
  watch(%r{^spec/support/(requests|controllers|mailers|models)_helpers\.rb}) { |m| "spec/#{m[1]}" }
  watch(%r{^spec/.+_spec\.rb})

  watch(%r{^app/controllers/(.+)_(controller)\.rb})                          { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb"] }
  watch(%r{^app/controllers/api/v1//(.+)_(controller)\.rb})                      { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/api/#{m[1]}_#{m[2]}_spec.rb"] }

  watch(%r{^app/(.+)\.rb})                                                   { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb})                                                   { |m| "spec/lib/#{m[1]}_spec.rb" }
end


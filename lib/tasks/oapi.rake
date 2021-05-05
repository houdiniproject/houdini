require 'grape-swagger/rake/oapi_tasks'
namespace :oapi do
  task gen: [:environment] do
    ENV['store'] = 'tmp/openapi.json'
    GrapeSwagger::Rake::OapiTasks.new(Houdini::Api)
    Rake::Task['oapi:fetch'].invoke()
  end
end
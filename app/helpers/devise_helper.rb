module DeviseHelper
  def devise_error_messages!
    if resource && !resource.errors.empty?
      resource.errors.first.first.to_s + ' ' + 
        resource.errors.first.second
    end
  end
end

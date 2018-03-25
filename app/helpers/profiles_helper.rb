module ProfilesHelper

  def get_shortened_name name
    if name
      name.length > 18 ? name[0..18] + '...' : name
    else
      'Your Account'
    end
  end

end

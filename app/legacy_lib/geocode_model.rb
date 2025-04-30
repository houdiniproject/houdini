# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module GeocodeModel
  def self.supporter(id)
    supp = Supporter.find_by_id(id)
    if supp.address && supp.state_code && supp.city
      with_reverse(supp)
    end
  end

  # Just a wrapper around a model's geocode method for delaying with:
  # GeocodeModel.delay.geocode(user)
  def self.geocode(model)
    begin
      model.geocode
    rescue Exception => e
      puts e
    end
    model.save
    model
  end

  def self.with_reverse(model)
    begin
      model.geocode
      model.reverse_geocode
    rescue Exception => e
      puts e
    end
    model.save
    model
  end

  # Geocode and get the timezone for a model
  def self.with_timezone(model)
    begin
      geocode(model)
    rescue Exception => e
      puts e
    end
    return model unless model.latitude && model.longitude

    model.timezone = NearestTimeZone.to(model.latitude, model.longitude)
    model.save
    model
  end
end

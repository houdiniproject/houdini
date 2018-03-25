module FetchNonprofit

	def self.with_params(params, administered_nonprofit=nil)
		if params[:state_code] && params[:city] && params[:name]
			return Nonprofit.where(:state_code_slug => params[:state_code], :city_slug => params[:city], :slug => params[:name]).last
		elsif params[:nonprofit_id] || params[:id]
			return Nonprofit.find_by_id(params[:nonprofit_id] || params[:id])
    elsif administered_nonprofit
      administered_nonprofit
		end
	end

end


module FetchCoupon
	def self.page params
		return params[:name].gsub('-','_') if params[:name]
	end
end
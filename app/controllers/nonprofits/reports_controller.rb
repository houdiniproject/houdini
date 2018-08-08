# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class ReportsController < ApplicationController
    include Controllers::NonprofitHelper
    before_filter :authenticate_nonprofit_user!

    def end_of_year
      respond_to do |format|
        format.csv do
          filename = "end-of-year-report-#{params[:year]}.csv"
          data = QuerySupporters.year_aggregate_report(params[:nonprofit_id], {:year => params[:year]})
          send_data(Format::Csv.from_array(data), filename: filename)
        end
      end
    end

    def end_of_year_custom
      respond_to do |format|
        format.csv do
          name_description = nil
          if (params[:year])
            name_description = params[:year]
          elsif (params[:start])
            name_description = "from-#{params[:start]}"
          end

          filename = "end-of-year-report-#{name_description}.csv"
          data = QuerySupporters.year_aggregate_report(params[:nonprofit_id], {:year => params[:year], :start => params[:start]})
          send_data(Format::Csv.from_array(data), filename: filename)
        end
      end
    end
  end
end

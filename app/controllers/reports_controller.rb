
class ReportsController < ApplicationController
  include LoginConcern
  authorization_required

  respond_to :html, :csv, :xsl, :xml, :json

  def weekly_status
    @status_reports = StatusReport.where('report_date >= ?', 1.week.ago.to_date).includes(:project, :profile)
    respond_with @status_reports
  end

end

class StatusReportSerializer < ActiveModel::Serializer
  attributes :ref, :report_date, :summary, :details, :tags_string
end

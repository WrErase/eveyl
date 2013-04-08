module DataTable
  def self.table_to_pages(params)
    per_page = params[:iDisplayLength].to_i
    per_page = 10 if per_page < 1

    start = params[:iDisplayStart].to_i
    start = 0 if start < 0

    page = (start / per_page).to_i + 1

    OpenStruct.new(page: page, per_page: per_page)
  end

  def self.table_to_order(params, columns)
    order = []
    params.each do |k,v|
      idx = (k =~ /iSortCol_(\d+)/ ? $1 : nil)
      next unless idx

      order_dir = params["sSortDir_#{idx}".to_sym] || 'desc'
      order_by  = columns[ params[k].to_i ]
      order << "#{order_by.to_s} #{order_dir}"
    end

    order.join(',')
  end

  def self.search_to_table(results, total, columns)
    retval = {}

    if results.blank?
      retval[:iTotalDisplayRecords] = retval[:iTotalRecords] = 0
      retval[:aaData] = []
    else
      retval[:iTotalDisplayRecords] = retval[:iTotalRecords] = total

      retval[:aaData] = results.collect do |item|
        columns.inject([]) { |ary, col| ary << item.send(col.to_sym) }
      end
    end

    retval
  end
end

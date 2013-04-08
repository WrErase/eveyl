class PagedCollection
  attr_reader :page, :per_page, :collection

  def initialize(collection, page, per_page, path)
    @page        = page
    @per_page    = per_page || 50
    @collection  = collection
    @path        = path

    @total       = collection.count
  end

  def total_pages
    return 0 unless @per_page > 0

    (@total.to_f / @per_page).ceil
  end

  def empty?
    return true if @collection.empty?
  end

  def collection
    @collection.paginate(page: @page, per_page: @per_page)
  end

  def page_params(page)
    {page: page, per_page: @per_page}.to_param
  end

  def next_page
    return if @page == last_page?(@page)

    @path + "?#{page_params(@page+1)}"
  end

  def prev_page
    return if @page == 1

    @path + "?#{page_params(@page-1)}"
  end

  def first_page?(page)
    page == 1
  end

  def last_page?(page)
    total_pages == page
  end

  def to_hash
    h = {page: @page, per_page: @per_page, total: @total, pages: total_pages}
    h[:prev] = prev_page unless first_page?(@page)
    h[:next] = next_page unless last_page?(@page)

    h
  end
end

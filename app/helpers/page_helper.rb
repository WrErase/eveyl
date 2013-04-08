module PageHelper
  def page_hash(page, rpp, route)
    h = { page: @page,
          per_page: @rpp}

    h.merge!(next: self.send(:route, page))
  end
end

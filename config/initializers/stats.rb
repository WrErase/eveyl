module Stats
  def median
    return nil if empty?

    sorted = self.sort
    sorted.length % 2 == 1 ? sorted[sorted.length/2] : (sorted[sorted.length/2 - 1] + sorted[sorted.length/2]).to_f / 2
  end

  def mean
    return nil if empty?

    self.inject(0) { |total, val| total += val.to_f } / length
  end

  def percentile(percentile = 0.0)
    # multiply items in the array by the required percentile
    # (e.g. 0.75 for 75th percentile)
    # round the result up to the next whole number
    # then subtract one to get the array item we need to return
    self ? self.sort[((length * percentile).ceil)-1] : nil
  end

  def get_fences(type)
    return nil if empty? || length < 4

    lower_q = percentile(0.25)
    upper_q = percentile(0.75)
    iqr     = upper_q - lower_q

    if type == :inner
      multi = 1.5
    elsif type == :outer
      multi = 3
    end

    lower_fence = lower_q - (multi * iqr)
    upper_fence = upper_q + (multi * iqr)

    [lower_fence, upper_fence]
  end

  def get_inner_fences
    get_fences(:inner)
  end

  def get_outer_fences
    get_fences(:outer)
  end

  def find_outliers(type = :extreme)
    return if length < 4

    if type == :extreme
      lower_fence, upper_fence = get_outer_fences
    elsif type == :minor
      lower_fence, upper_fence = get_inner_fences
    end
    self.reject { |val| val >= lower_fence && val <= upper_fence }
  end

  def prune_outliers!(type = :extreme)
    return self if length < 4

    if type == :extreme
      lower_fence, upper_fence = get_outer_fences
    elsif type == :minor
      lower_fence, upper_fence = get_inner_fences
    end
    self.delete_if { |p| p < lower_fence || p > upper_fence }
  end

  def stdev
    mean = self.mean
    Math.sqrt( self.inject(0) { |total,p| total += (p - mean)**2 } / length )
  end
end

class Array
  include Stats
end

module Operators

  def <=>(a, b)
    a.range <=> b.range
  end

  def ==(other)
    self.range == other.range
  end

  def +(increment)
    increment_range(increment)
  end

  def -(increment)
    increment_range(increment * -1)
  end

  def each
    range.each do |r|
      yield r
    end
  end

  def first
    range.first
  end

  def last
    range.last
  end

end

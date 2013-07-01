class UnluckyNumberSkipper

  DefaultUnluckyNumbers  = %w(4 9 13 17 42 666)

  def initialize(unlucky_number_list = DefaultUnluckyNumbers)
    if !unlucky_number_list.kind_of?(Array) || unlucky_number_list.find { |num| num.to_s !~ /\A[0-9]+\z/ }
      raise ArgumentError.new('argument must be an array of integer')
    end

    @loose_regexp  = generate_loose_regexp(unlucky_number_list)
    @strict_regexp = generate_strict_regexp(unlucky_number_list)
  end

  def next(integer, options = {})
    unless integer.kind_of?(Integer)
      raise ArgumentError.new('not an integer')
    end

    if options[:strict]
      next_strict(integer)
    else
      next_loose(integer)
    end
  end

  private

  def generate_loose_regexp(unlucky_numbers)
    s = '\A('
    s += unlucky_numbers.map { |num| num.to_s }.join('|')
    s += ')\z'

    Regexp.new(s)
  end

  def generate_strict_regexp(unlucky_numbers)
    s = '('
    s += unlucky_numbers.map { |num| num.to_s }.join('|')
    s += ')'

    Regexp.new(s)
  end

  def next_strict(integer)
    integer += 1

    unlucky_pos = (integer.to_s =~ @strict_regexp)

    if unlucky_pos
      i = increment_by_position(integer, unlucky_pos, $1)
      if i.to_s =~ @strict_regexp
        next_strict(i)
      else
        i
      end
    else
      integer
    end
  end

  def next_loose(integer)
    integer += 1

    unlucky_pos = (integer.to_s =~ @loose_regexp)
    if unlucky_pos
      i = increment_by_position(integer, unlucky_pos, $1)
      if i.to_s =~ @loose_regexp
        next_strict(i)
      else
        i
      end
    else
      integer
    end
  end

  def increment_by_position(integer, unlucky_pos, matched)
    increment_pos = unlucky_pos + matched.length
    integer + (10 ** (integer.to_s.length - increment_pos))
  end
end

if __FILE__ == $0
  b = UnluckyNumberSkipper.new
  p b.next(2)  # =>  3
  p b.next(3)  # =>  5
  p b.next(12) # => 14
  p b.next(41) # => 43

  o = { :strict => true }

  p b.next(129, o)     # => 140
end

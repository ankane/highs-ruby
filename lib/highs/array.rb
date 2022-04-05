module Highs
  class BaseArray
    NOT_SET = Object.new

    def initialize(size, value = NOT_SET)
      @size = size
      @ptr =
        if value == NOT_SET
          Fiddle::Pointer.malloc(size * self.class::SIZE)
        else
          if value.size != size
            # TODO add variable name to message
            raise ArgumentError, "wrong size (given #{value.size}, expected #{size})"
          end
          Fiddle::Pointer[value.pack("#{self.class::FORMAT}#{size}")]
        end
    end

    def to_a
      @ptr[0, @size * self.class::SIZE].unpack("#{self.class::FORMAT}#{@size}")
    end

    def to_ptr
      @ptr
    end
  end

  class DoubleArray < BaseArray
    FORMAT = "d"
    SIZE = Fiddle::SIZEOF_DOUBLE
  end

  class IntArray < BaseArray
    FORMAT = "i!"
    SIZE = Fiddle::SIZEOF_INT
  end
end

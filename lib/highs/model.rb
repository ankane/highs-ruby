module Highs
  class Model
    def initialize
      @ptr = FFI.Highs_create
      ObjectSpace.define_finalizer(self, self.class.finalize(@ptr))

      # TODO add option
      check_status FFI.Highs_setBoolOptionValue(@ptr, "output_flag", 0)
    end

    def solve
      col_value = DoubleArray.new(num_col)
      col_dual = DoubleArray.new(num_col)
      row_value = DoubleArray.new(num_row)
      row_dual = DoubleArray.new(num_row)
      col_basis = IntArray.new(num_col)
      row_basis = IntArray.new(num_row)

      check_status FFI.Highs_run(@ptr)
      check_status FFI.Highs_getSolution(@ptr, col_value, col_dual, row_value, row_dual)
      check_status FFI.Highs_getBasis(@ptr, col_basis, row_basis)
      model_status = FFI.Highs_getModelStatus(@ptr)

      {
        status: FFI::MODEL_STATUS[model_status],
        obj_value: FFI.Highs_getObjectiveValue(@ptr),
        col_value: col_value.to_a,
        col_dual: col_dual.to_a,
        row_value: row_value.to_a,
        row_dual: row_dual.to_a,
        col_basis: col_basis.to_a.map { |v| FFI::BASIS_STATUS[v] },
        row_basis: row_basis.to_a.map { |v| FFI::BASIS_STATUS[v] }
      }
    end

    def to_ptr
      @ptr
    end

    def self.finalize(ptr)
      # must use proc instead of stabby lambda
      proc { FFI.Highs_destroy(ptr) }
    end

    private

    def num_col
      FFI.Highs_getNumCol(@ptr)
    end

    def num_row
      FFI.Highs_getNumRow(@ptr)
    end

    def check_status(status)
      Highs.send(:check_status, status)
    end
  end
end

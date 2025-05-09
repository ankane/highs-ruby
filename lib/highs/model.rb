module Highs
  class Model
    def initialize
      @ptr = FFI.Highs_create
      @ptr.free = FFI["Highs_destroy"]

      check_status FFI.Highs_setBoolOptionValue(@ptr, +"output_flag", 0)
    end

    def solve(verbose: false, time_limit: nil)
      num_col = FFI.Highs_getNumCol(@ptr)
      num_row = FFI.Highs_getNumRow(@ptr)

      col_value = DoubleArray.new(num_col)
      col_dual = DoubleArray.new(num_col)
      row_value = DoubleArray.new(num_row)
      row_dual = DoubleArray.new(num_row)
      col_basis = IntArray.new(num_col)
      row_basis = IntArray.new(num_row)

      with_options(verbose: verbose, time_limit: time_limit) do
        check_status FFI.Highs_run(@ptr)
      end
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

    def write(filename)
      check_status FFI.Highs_writeModel(@ptr, +filename)
    end

    def to_ptr
      @ptr
    end

    private

    def check_status(status)
      Highs.send(:check_status, status)
    end

    def with_options(verbose:, time_limit:)
      check_status(FFI.Highs_setBoolOptionValue(@ptr, +"output_flag", 1)) if verbose
      check_status(FFI.Highs_setDoubleOptionValue(@ptr, +"time_limit", time_limit)) if time_limit
      yield
    ensure
      check_status(FFI.Highs_setBoolOptionValue(@ptr, +"output_flag", 0)) if verbose
      check_status(FFI.Highs_setDoubleOptionValue(@ptr, +"time_limit", Float::INFINITY)) if time_limit
    end
  end
end

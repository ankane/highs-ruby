module Highs
  module Methods
    def lp(sense:, offset: 0, col_cost:, col_lower:, col_upper:, row_lower:, row_upper:, a_format:, a_start:, a_index:, a_value:)
      num_col = col_cost.size
      num_row = row_lower.size
      num_nz = a_index.size
      a_format = FFI::MATRIX_FORMAT.fetch(a_format)
      sense = FFI::OBJ_SENSE.fetch(sense)

      model = Model.new
      check_status FFI.Highs_passLp(
        model, num_col, num_row, num_nz, a_format, sense, offset,
        DoubleArray.new(num_col, col_cost), DoubleArray.new(num_col, col_lower), DoubleArray.new(num_col, col_upper),
        DoubleArray.new(num_row, row_lower), DoubleArray.new(num_row, row_upper),
        IntArray.new(a_start.size, a_start), IntArray.new(num_nz, a_index), DoubleArray.new(num_nz, a_value),
      )
      model
    end

    def lp_call(**options)
      lp(**options).solve
    end

    def mip(sense:, offset: 0, col_cost:, col_lower:, col_upper:, row_lower:, row_upper:, a_format:, a_start:, a_index:, a_value:, integrality:)
      num_col = col_cost.size
      num_row = row_lower.size
      num_nz = a_index.size
      a_format = FFI::MATRIX_FORMAT.fetch(a_format)
      sense = FFI::OBJ_SENSE.fetch(sense)

      model = Model.new
      check_status FFI.Highs_passMip(
        model, num_col, num_row, num_nz, a_format, sense, offset,
        DoubleArray.new(num_col, col_cost), DoubleArray.new(num_col, col_lower), DoubleArray.new(num_col, col_upper),
        DoubleArray.new(num_row, row_lower), DoubleArray.new(num_row, row_upper),
        IntArray.new(a_start.size, a_start), IntArray.new(num_nz, a_index), DoubleArray.new(num_nz, a_value),
        IntArray.new(num_col, integrality)
      )
      model
    end

    def mip_call(**options)
      mip(**options).solve.slice(:status, :obj_value, :col_value, :row_value)
    end

    def qp(sense:, offset: 0, col_cost:, col_lower:, col_upper:, row_lower:, row_upper:, a_format:, a_start:, a_index:, a_value:, q_format:, q_start:, q_index:, q_value:)
      num_col = col_cost.size
      num_row = row_lower.size
      num_nz = a_index.size
      q_num_nz = q_index.size
      a_format = FFI::MATRIX_FORMAT.fetch(a_format)
      q_format = FFI::MATRIX_FORMAT.fetch(q_format)
      sense = FFI::OBJ_SENSE.fetch(sense)

      model = Model.new
      check_status FFI.Highs_passModel(
        model, num_col, num_row, num_nz, q_num_nz, a_format, q_format, sense, offset,
        DoubleArray.new(num_col, col_cost), DoubleArray.new(num_col, col_lower), DoubleArray.new(num_col, col_upper),
        DoubleArray.new(num_row, row_lower), DoubleArray.new(num_row, row_upper),
        IntArray.new(a_start.size, a_start), IntArray.new(num_nz, a_index), DoubleArray.new(num_nz, a_value),
        IntArray.new(q_start.size, q_start), IntArray.new(q_num_nz, q_index), DoubleArray.new(q_num_nz, q_value), nil
      )
      model
    end

    def qp_call(**options)
      qp(**options).solve
    end

    def read(filename)
      model = Model.new
      check_status FFI.Highs_readModel(model, filename)
      model
    end

    private

    def check_status(status)
      # TODO handle warnings (status = 1)
      if status == -1
        raise Error, "Bad status"
      end
    end
  end
end

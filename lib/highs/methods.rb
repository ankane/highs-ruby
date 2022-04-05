module Highs
  module Methods
    def lp_call(sense:, offset: 0, col_cost:, col_lower:, col_upper:, row_lower:, row_upper:, a_format:, a_start:, a_index:, a_value:)
      num_col = col_cost.size
      num_row = row_lower.size
      num_nz = a_index.size
      a_format = FFI::MATRIX_FORMAT.fetch(a_format)
      sense = FFI::OBJ_SENSE.fetch(sense)

      a_start_size = a_start.size

      col_value = DoubleArray.new(num_col)
      col_dual = DoubleArray.new(num_col)
      row_value = DoubleArray.new(num_row)
      row_dual = DoubleArray.new(num_row)
      col_basis = IntArray.new(num_col)
      row_basis = IntArray.new(num_row)
      model_status = IntArray.new(1)

      check_status FFI.Highs_lpCall(
        num_col, num_row, num_nz, a_format, sense, offset,
        DoubleArray.new(num_col, col_cost), DoubleArray.new(num_col, col_lower), DoubleArray.new(num_col, col_upper),
        DoubleArray.new(num_row, row_lower), DoubleArray.new(num_row, row_upper),
        IntArray.new(a_start_size, a_start), IntArray.new(num_nz, a_index), DoubleArray.new(num_nz, a_value),
        col_value, col_dual,
        row_value, row_dual,
        col_basis, row_basis,
        model_status
      )

      {
        status: FFI::MODEL_STATUS[model_status.to_a.first],
        col_value: col_value.to_a,
        col_dual: col_dual.to_a,
        row_value: row_value.to_a,
        row_dual: row_dual.to_a,
        col_basis: col_basis.to_a.map { |v| FFI::BASIS_STATUS[v] },
        row_basis: row_basis.to_a.map { |v| FFI::BASIS_STATUS[v] }
      }
    end

    def mip_call(sense:, offset: 0, col_cost:, col_lower:, col_upper:, row_lower:, row_upper:, a_format:, a_start:, a_index:, a_value:, integrality:)
      num_col = col_cost.size
      num_row = row_lower.size
      num_nz = a_index.size
      a_format = FFI::MATRIX_FORMAT.fetch(a_format)
      sense = FFI::OBJ_SENSE.fetch(sense)

      a_start_size = a_start.size

      col_value = DoubleArray.new(num_col)
      row_value = DoubleArray.new(num_row)
      model_status = IntArray.new(1)

      check_status FFI.Highs_mipCall(
        num_col, num_row, num_nz, a_format, sense, offset,
        DoubleArray.new(num_col, col_cost), DoubleArray.new(num_col, col_lower), DoubleArray.new(num_col, col_upper),
        DoubleArray.new(num_row, row_lower), DoubleArray.new(num_row, row_upper),
        IntArray.new(a_start_size, a_start), IntArray.new(num_nz, a_index), DoubleArray.new(num_nz, a_value),
        IntArray.new(num_col, integrality),
        col_value,
        row_value,
        model_status
      )

      {
        status: FFI::MODEL_STATUS[model_status.to_a.first],
        col_value: col_value.to_a,
        row_value: row_value.to_a
      }
    end

    def qp_call(sense:, offset: 0, col_cost:, col_lower:, col_upper:, row_lower:, row_upper:, a_format:, a_start:, a_index:, a_value:, q_format:, q_start:, q_index:, q_value:)
      num_col = col_cost.size
      num_row = row_lower.size
      num_nz = a_index.size
      q_num_nz = q_index.size
      a_format = FFI::MATRIX_FORMAT.fetch(a_format)
      q_format = FFI::MATRIX_FORMAT.fetch(q_format)
      sense = FFI::OBJ_SENSE.fetch(sense)

      a_start_size = a_start.size
      q_start_size = q_start.size

      col_value = DoubleArray.new(num_col)
      col_dual = DoubleArray.new(num_col)
      row_value = DoubleArray.new(num_row)
      row_dual = DoubleArray.new(num_row)
      col_basis = IntArray.new(num_col)
      row_basis = IntArray.new(num_row)
      model_status = IntArray.new(1)

      check_status FFI.Highs_qpCall(
        num_col, num_row, num_nz, q_num_nz, a_format, q_format, sense, offset,
        DoubleArray.new(num_col, col_cost), DoubleArray.new(num_col, col_lower), DoubleArray.new(num_col, col_upper),
        DoubleArray.new(num_row, row_lower), DoubleArray.new(num_row, row_upper),
        IntArray.new(a_start_size, a_start), IntArray.new(num_nz, a_index), DoubleArray.new(num_nz, a_value),
        IntArray.new(q_start_size, q_start), IntArray.new(q_num_nz, q_index), DoubleArray.new(q_num_nz, q_value),
        col_value, col_dual,
        row_value, row_dual,
        col_basis, row_basis,
        model_status
      )

      {
        status: FFI::MODEL_STATUS[model_status.to_a.first],
        col_value: col_value.to_a,
        col_dual: col_dual.to_a,
        row_value: row_value.to_a,
        row_dual: row_dual.to_a,
        col_basis: col_basis.to_a.map { |v| FFI::BASIS_STATUS[v] },
        row_basis: row_basis.to_a.map { |v| FFI::BASIS_STATUS[v] }
      }
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

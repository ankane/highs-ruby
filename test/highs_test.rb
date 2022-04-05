require_relative "test_helper"

class HighsTest < Minitest::Test
  def test_lp_call
    res =
      Highs.lp_call(
        sense: :minimize,
        col_cost: [8, 10],
        col_lower: [0, 0],
        col_upper: [1e30, 1e30],
        row_lower: [7, 12, 6],
        row_upper: [1e30, 1e30, 1e30],
        a_format: :colwise,
        a_start: [0, 3],
        a_index: [0, 1, 2, 0, 1, 2],
        a_value: [2, 3, 2, 2, 4, 1]
      )

    assert_equal :optimal, res[:status]
    assert_elements_in_delta [2.4, 1.2], res[:col_value]
    assert_elements_in_delta [0, 0], res[:col_dual]
    assert_elements_in_delta [7.2, 12, 6], res[:row_value]
    assert_elements_in_delta [0, 2.4, 0.4], res[:row_dual]
    assert_equal [:basic, :basic], res[:col_basis]
    assert_equal [:basic, :lower, :lower], res[:row_basis]
  end

  def test_mip_call
    res =
      Highs.mip_call(
        sense: :minimize,
        col_cost: [8, 10],
        col_lower: [0, 0],
        col_upper: [1e30, 1e30],
        row_lower: [7, 12, 6],
        row_upper: [1e30, 1e30, 1e30],
        a_format: :colwise,
        a_start: [0, 3],
        a_index: [0, 1, 2, 0, 1, 2],
        a_value: [2, 3, 2, 2, 4, 1],
        integrality: [1, 1]
      )

    assert_equal :optimal, res[:status]
    assert_elements_in_delta [4, 0], res[:col_value]
    assert_elements_in_delta [8, 12, 8], res[:row_value]
  end

  def test_qp_call
    res =
      Highs.qp_call(
        sense: :minimize,
        col_cost: [0, -1, 0],
        col_lower: [0, 0, 0],
        col_upper: [1e30, 1e30, 1e30],
        row_lower: [1, -1e30],
        row_upper: [1e30, 1e30],
        a_format: :colwise,
        a_start: [0, 1, 2],
        a_index: [0, 0, 0],
        a_value: [1, 1, 1],
        q_format: :colwise,
        q_start: [0, 2, 3],
        q_index: [0, 2, 1, 0, 2],
        q_value: [2, -1, 0.2, -1, 2]
      )

    assert_equal :optimal, res[:status]
    assert_elements_in_delta [0, 5, 0], res[:col_value]
    assert_elements_in_delta [0, 0, 0], res[:col_dual]
    assert_elements_in_delta [5, 0], res[:row_value]
    assert_elements_in_delta [0, 0], res[:row_dual]
    assert_equal [:lower, :lower, :lower], res[:col_basis]
    assert_equal [:lower, :lower], res[:row_basis]
  end
end

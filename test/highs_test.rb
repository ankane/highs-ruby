require_relative "test_helper"

class HighsTest < Minitest::Test
  def test_lp
    model =
      Highs.lp(
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

    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 31.2, res[:obj_value]
    assert_elements_in_delta [2.4, 1.2], res[:col_value]
    assert_elements_in_delta [0, 0], res[:col_dual]
    assert_elements_in_delta [7.2, 12, 6], res[:row_value]
    assert_elements_in_delta [0, 2.4, 0.4], res[:row_dual]
    assert_equal [:basic, :basic], res[:col_basis]
    assert_equal [:basic, :lower, :lower], res[:row_basis]

    path = "/tmp/lp.mps"
    model.write(path)
    model = Highs.read(path)

    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 31.2, res[:obj_value]
    assert_elements_in_delta [2.4, 1.2], res[:col_value]
    assert_elements_in_delta [0, 0], res[:col_dual]
    assert_elements_in_delta [7.2, 12, 6], res[:row_value]
    assert_elements_in_delta [0, 2.4, 0.4], res[:row_dual]
    assert_equal [:basic, :basic], res[:col_basis]
    assert_equal [:basic, :lower, :lower], res[:row_basis]
  end

  def test_mip
    model =
      Highs.mip(
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
        integrality: [:integer, :integer]
      )

    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 32, res[:obj_value]
    assert_elements_in_delta [4, 0], res[:col_value]
    assert_elements_in_delta [8, 12, 8], res[:row_value]

    path = "/tmp/mip.mps"
    model.write(path)
    model = Highs.read(path)

    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta 32, res[:obj_value]
    assert_elements_in_delta [4, 0], res[:col_value]
    assert_elements_in_delta [8, 12, 8], res[:row_value]
  end

  def test_qp
    model =
      Highs.qp(
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

    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta(-2.5, res[:obj_value])
    assert_elements_in_delta [0, 5, 0], res[:col_value]
    assert_elements_in_delta [0, 0, 0], res[:col_dual]
    assert_elements_in_delta [5, 0], res[:row_value]
    assert_elements_in_delta [0, 0], res[:row_dual]
    assert_equal [:lower, :basic, :lower], res[:col_basis]
    assert_equal [:nonbasic, :basic], res[:row_basis]

    path = "/tmp/qp.mps"
    model.write(path)
    model = Highs.read(path)

    res = model.solve
    assert_equal :optimal, res[:status]
    assert_in_delta(-2.5, res[:obj_value])
    assert_elements_in_delta [0, 5, 0], res[:col_value]
    assert_elements_in_delta [0, 0, 0], res[:col_dual]
    # second row dropped since -infinity to infinity
    assert_elements_in_delta [5], res[:row_value]
    assert_elements_in_delta [0], res[:row_dual]
    assert_equal [:lower, :basic, :lower], res[:col_basis]
    assert_equal [:nonbasic], res[:row_basis]
  end

  def test_time_limit
    model = Highs.read("test/support/lp.mps")
    res = model.solve(time_limit: 0.000001)
    assert_equal :time_limit, res[:status]
  end

  def test_copy
    model = Highs.read("test/support/lp.mps")
    model.dup
    model.clone
  end
end

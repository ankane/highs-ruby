# HiGHS Ruby

[HiGHS](https://www.maths.ed.ac.uk/hall/HiGHS/) - linear optimization software - for Ruby

[![Build Status](https://github.com/ankane/highs-ruby/workflows/build/badge.svg?branch=master)](https://github.com/ankane/highs-ruby/actions)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "highs"
```

## Getting Started

*The API is fairly low-level at the moment*

Load a linear program

```ruby
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
```

Load a mixed-integer program

```ruby
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
    integrality: [1, 1]
  )
```

Load a quadratic program

```ruby
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
```

Solve

```ruby
model.solve
```

Write the program to an MPS file

```ruby
model.write("model.mps")
```

Read a program from an MPS file

```ruby
model = Highs.read("model.mps")
```

## History

View the [changelog](https://github.com/ankane/highs-ruby/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/highs-ruby/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/highs-ruby/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/highs-ruby.git
cd highs-ruby
bundle install
bundle exec rake vendor:all
bundle exec rake test
```

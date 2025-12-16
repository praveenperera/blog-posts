==title==
Named Arguments with Default Values in Elixir

==author==
Praveen Perera

==tags==
elixir, tutorials

==description==
Since Ruby 2.0 you can easily have methods that have named parameters with default values. Today I wanted to find the best way to do this in elixir. Below is what I came up with.

==body==
Since Ruby 2.0 you can easily have methods that have named parameters with default values. Today I wanted to find the best way to do this in elixir. Below is what I came up with. In the comments please tell me if you have any suggestions and what your favourite version is.

## Ruby Version

First here is what I am talking about in Ruby

```ruby
def introduction(name: 'Sarah', birthday: "1985-12-30")
  puts "Hi my name is #{name} and I was born on #{birthday}"
end
```

This great because you can call it in many different ways:

```ruby
## use only the default parameters
irb> introduction()
# Hi my name is Sarah and I was born on 1985-12-30

## override one of the parameters
irb> introduction(name: "George")
# Hi my name is George and I was born on 1985-12-30

## pass in parameters out of order
irb> introduction(birthday: "1990-02-09", name: "George")
# Hi my name is George and I was born on 1990-02-09
```

## Elixir Version One - The Simplest

```elixir
defmodule Talk do
  def introduction(name: name, birthday: bday) do
    IO.puts "Hi my name is #{name} and I was born on #{birthday}"
  end
end
```

This version is very simple, looks good and works decently well. However it does have a few drawbacks. You can't have any defaults arguments and if you pass arguments in the wrong order (birthday before name) you will get a pattern match error.

## Elixir Version Two - Using a Map

```elixir
defmodule Talk do
  def introduction(options) do
	%{name: name, birthday: bday} = Enum.into(options, %{})

	IO.puts "Hi my name is #{name} and I was born on #{bday}"
  end
end
```

This version is similar to the first one except we make a map out of the passed in keyword list and we do the pattern matching in the function body instead of in the function head. This solves one of our problems, we can now pass in the arguments in any order we wish.

```elixir
iex> Talk.introduction(name: "Sarah", birthday: "1985-12-30")
# Hi my name is Sarah and I was born on 1985-12-30

iex> Talk.introduction(birthday: "1985-12-30", name: "Sarah")
# Hi my name is Sarah and I was born on 1985-12-30
```

## Elixir Version Three - Map with Defaults

```elixir
defmodule Talk do
  def introduction(options \\ []) do
   defaults = [name: "Sarah", birthday: "1985-12-15"]
   options = Keyword.merge(defaults, options) |> Enum.into(%{})
    %{name: name, birthday: bday} = options

	IO.puts "Hi my name is #{name} and I was born on #{bday}"
  end
end
```

This final version is the exact same as the one before but we merge a defaults keyword list with the keyword list that is passed in.

_Quick note: when merging two lists using Keyword.merge/2 the keys and values from the second list overrides the ones in the first, this allows us to have default values which are easily overridable._

```elixir
iex> Talk.introduction
# Hi my name is Sarah and I was born on 1985-12-30

iex> Talk.introduction(birthday: "1985-12-30", name: "Sarah")
# Hi my name is Sarah and I was born on 1985-12-30

iex> Talk.introduction(name: "George", birthday: "1990-12-30")
# Hi my name is George and I was born on 1990-12-30

iex> Talk.introduction(birthday: "1990-12-30")
# Hi my name is Sarah and I was born on 1990-12-30
```

Hope you enjoyed this post, let me know if you have a better way of doing this.

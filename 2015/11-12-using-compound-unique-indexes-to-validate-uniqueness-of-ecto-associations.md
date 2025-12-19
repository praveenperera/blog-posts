---
title: Validate Ecto Unique Associations with Compound Indexes
author: Praveen Perera
tags: phoenix, ecto, elixir, tutorials
description: In this short blog post I want to show you how easy it is to use Ecto validations together with PostgreSQL unique indexes to validate the uniqueness of an association.
---
In this short blog post I want to show you how easy it is to use Ecto validations together with PostgreSQL unique indexes to validate the uniqueness of an association.

First a little background on the problem [(scroll down, if you just want the solution)](#solution).

Today, I was working on a side project using Elixir and the Phoenix Framework. I wanted to know how to validate uniqueness on a association. For example, in an ecommerce application you would only want a user to be able to leave one review per product. You can't validate uniqueness of a review on just `user_id` or just `product_id`, because a user should be able to review many different products, and a product should be able to have many reviews from different users. I needed something like a scoped validation. For example in rails something like this

`validates_uniqueness_of :user_id, :scope => :product_id` in the review model would work.

I googled around for a bit but wasn't able to find what I needed. I thought I might have to do a custom validation, which runs a query to ensure uniqueness. But, I was hoping that there would be a better way so I asked in `#elixir-lang`. Chris McCord answered me right away and pointed me in the right direction, he suggested using compound unique indexes and the ecto unique_constraint function.

Turns out using ecto migrations you can easily create multi-column or compound indexes in postgres, and then you can validate on that using Ecto validations.

## Solution

Step 1: Add a new unique compound index to your Review table:
`create index(:reviews, [:user_id, :product_id], unique: true)`

Step 2: Call this new compound index in your Review model:
`unique_constraint(:user_id_product_id)`

And that's it, its that simple!!

I've included the full migration and model files below

```elixir
#[timestamp]_add_unique_index_to_review_table.exs
defmodule MyApp.Repo.Migrations.AddUniqueIndexToReviewTable do
  use Ecto.Migration

  def change do
    create index(:reviews, [:user_id, :product_id], unique: true)
  end
end
```

```elixir
#review.ex
defmodule MyApp.Review do
  use MyApp.Web, :model
  alias MyApp.Review

  import Ecto.Query

  schema "reviews" do
    field :rating, :integer
    field :comment, :string
    belongs_to :user, MyApp.User
    belongs_to :product, MyApp.Product
    timestamps
  end

....

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_number(:rating, less_than_or_equal_to: 5, greater_than_or_equal_to: 1)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:product_id)
    |> unique_constraint(:user_id_product_id)
  end

end
```

_Shoutout to Chris McCord and everyone over at #elixir-lang, for always being so helpful._

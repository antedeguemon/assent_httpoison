# assent_httposion
[![Hex.pm: version](https://img.shields.io/hexpm/v/assent_httpoison.svg?style=flat-square)](https://hex.pm/packages/assent_httpoison)
[![GitHub: CI status](https://img.shields.io/github/actions/workflow/status/antedeguemon/assent_httpoison/ci.yml?branch=main&style=flat-square)](https://github.com/antedeguemon/assent_httpoison/actions)
![License: MIT, same as Assent](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)

[Assent](https://hex.pm/packages/assent/) adapter for making requests using
[HTTPoison](https://hex.pm/packages/httpoison).

## Installation

Add `assent_httpoison` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:assent_httpoison, "~> 0.1.0"}
  ]
end
```

## Usage

To use the HTTPoison adapter with Assent, configure it in your application
settings:

```elixir
config :assent,
  http_client: {AssentHTTPoison.Adapter, []}
```

You can also pass [custom options to HTTPoison](https://hexdocs.pm/httpoison/HTTPoison.Request.html):

```elixir
config :assent,
  http_client: {AssentHTTPoison.Adapter, [
    timeout: 60_000,
    max_redirect: 10
  ]}
```

# BlameMe

https://blame-me.herokuapp.com/

See who contributes more many lines of code using `git blame`.

Paste in the `https` URL of your repo and we'll do the rest.

## Requirements

- Ruby 2.4.0
- Bundler
- `cmake` (for building the `rugged` gem)
- Redis (for Sidekiq)

## Development

### Setup

1. Install gems

    ```sh
    $ bundle install
    ```
2. Set environment variables

    ```sh
    $ cp .env.example .env
    ```

    and fill in values listed in `.env`

### Run development server

```sh
$ bundle exec foreman start
```

Then access the site by visiting http://localhost:5000

### Run tests

```sh
$ bundle exec rake test
```



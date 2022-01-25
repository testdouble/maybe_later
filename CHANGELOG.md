## [0.0.4] - 2022-01-24

- Add `invoke_even_if_server_is_unsupported` option to ensure tasks are invoked
  even if the server doesn't support rack.after_reply

## [0.0.3] - 2022-01-21

- Fix a bug where async tasks' after_each callbacks were called rack.after_reply

## [0.0.2] - 2022-01-20

- Only close HTTP connections when there are >0 inline tasks to be run

## [0.0.1] - 2022-01-19

- Initial release

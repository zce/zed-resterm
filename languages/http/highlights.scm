(method) @keyword

(header
  name: (_) @property)

(variable_declaration
  name: (identifier) @variable)

(variable
  name: (identifier) @variable.special)

(request
  url: (_) @string.special.url)

(http_version) @constant

(status_code) @number
(status_text) @string

[
  "{{"
  "}}"
] @punctuation.bracket

(header
  ":" @punctuation.delimiter)

(variable_declaration
  "=" @operator)

(comment
  "@" @keyword
  name: (_) @keyword)

(external_body
  path: (_) @string.special)

[
  (comment)
  (request_separator)
] @comment

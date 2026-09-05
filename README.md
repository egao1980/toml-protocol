# toml-protocol

CLOS TOML encode/decode for [cl-stack](https://github.com/egao1980/cl-stack). Same shape as `json-protocol`.

| System | Role |
|--------|------|
| `toml-protocol` | Generics, conditions, `encode` / `decode`, serdes `:toml` |
| `toml-backend-tomlet` | **Default** — [tomlet](https://github.com/fukamachi/tomlet) decode + first-party emit |

Nick `stack-toml`. Load the backend so `*toml-backend*` is bound.

```lisp
(asdf:load-system "toml-backend-tomlet")
(toml-protocol:decode "host = \"localhost\"")
(stack-toml:encode ht)
```

Lisp mapping: tables → `equal` string-key hash-tables; arrays → vectors; booleans `t`/`nil`; offset date-time → `datetime-protocol` `zoned-moment`; local date/time → `date` / `moment` / `time-of-day`. No JSON null — omit keys.

## License

MIT — see [LICENSE](LICENSE).

# Advent of Code 2023 :santa: :christmas_tree: 

## Quickstart

```shell
$ fd . --no-hidden --no-ignore | entr -c -s 'lua d6/main.lua < d6/input.txt'
```

## Progress (18/25)

|     | Lua    |
| --- | ------ |
| 1   | :bell: |
| 2   | :bell: |
| 3   | :bell: |
| 4   | :bell:  |
| 5   | :bell:  |
| 6   | :bell:  |
| 7   | :bell:  |
| 8   | :bell:  |
| 9   | :bell:  |
| 10  | :bell:  |
| 11  | :bell:  |
| 12  | :bell:  |
| 13  | :bell:  |
| 14  | :bell:  |
| 15  | :bell:  |
| 16  | :bell:  |
| 17  | :bell:  |
| 18  | :bell:  |
| 19  | :zzz:  |
| 20  | :zzz:  |
| 21  | :zzz:  |
| 22  | :zzz:  |
| 23  | :zzz:  |
| 24  | :zzz:  |
| 25  | :zzz:  |

## Make Reddit Code Snippet

For longer code snippets, use https://topaz.github.io/paste/. If it's short enough, do this:

```
$ cat code | sed 's/^/    /' | xsel -b
$ cat code | sed 's/^/    /' | pbcopy
```

## Reddit Comment Template

```text
[LANGUAGE: lua]

# [Lua]()

60 lines of code according to `tokei` when formatted with `stylua`.

- [GitHub Repository](https://github.com/cideM/aoc2023)
- [Topaz Paste]()
```

## Disable Copilot

Add `set exrc` to your Neovim configuration, then `echo 'let g:copilot_enabled=v:false' > .nvimrc`, open the file and `:trust` it.

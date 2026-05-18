# exo-can
CAN bus architecture files

# Documentation
Documentation is available as typst files in the `doc/` directory. It describes the format used for
our CAN frames.

## Compiling (documentation)
You can download the typst compiler on your computer from here:
https://typst.app/open-source/#download . You can then run
```bash
$ typst watch main.typ
```
to automatically rebuild on save or
```bash
$ typst compile main.typ
```
to comile only once whilst in the `doc/` directory, then open the `main.pdf` file.

There should be a typst plugin for most text editors.

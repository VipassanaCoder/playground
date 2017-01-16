## b0o/playground

Local Golang playground optimized for tmux/vim environments.

### Overview

`playground` is a tool powered by a collection of shell scripts facilitating 
quick experimentation in the Go programming language.

### Templates

`playground` ships with a large collection of templates for most basic Golang
functionality - from JSON encoding to Goroutines and everything in between. It
also offers the ability to add easily your own templates.

Most of the included templates are provided by the [Go by Example](https://github.com/mmcgrana/gobyexample)
project.

### Playgrounds

`playground` works by copying a template to your playground directory, and then
allowing you to easily edit, build, run, and watch these playgrounds.

This is all achieved through the `./play` script (which itself is a symlink to
`./scripts/play.sh`).

The usage and options are as follows:

    Usage: ./play [options]

    Options:
     -t <template>      Specify the template to use

     -l                 List the available templates

     -p <playground>    Specify the playground name to use

     -L                 List the existing playgrounds

     -j                 Use the most recently-edited playground

     -n                 Create a new playground.
                        If -p is specified, it will be used for
                        the name of the new playground. Otherwise,
                        the playground will be assigned a unique
                        sequential name.

     -o                 Open the playground source files in Vim.
                        The playground files will be opened in the
                        Vim servers whose ServerNames contain the
                        string 'PLAY'.

     -P <playground>    Print the playground path

     -q                 Run in quiet mode

     -h                 Print this message

     The following options must be used in conjunction with -p and/or -n:
     -b                 Build the playground

     -r                 Run the playground. Does not rebuild.

     -R                 Build & Run the playground

     -w                 Watch the playground, re-building & -running it
                        each time a source file changes.

### License

This project is released under the [MIT License](https://opensource.org/licenses/MIT)
which can be found in the LICENSE file of this repository.

This project also includes components from the following sources:
  - [Go by Example](https://github.com/mmcgrana/gobyexample) - [Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/)

(lang dune 3.19)

(name game)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "PiterDev <piterzdev@gmail.com>")

(maintainers "PiterDev <piterzdev@gmail.com>")

(license MIT)

(documentation https://url/to/documentation)

(package
 (name game)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml raylib)
 (tags
  ("add topics" "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html

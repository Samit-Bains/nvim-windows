; extends

;; Better Comments style highlights for Go

((comment) @comment.alert
  (#match? @comment.alert "^[[:space:]]*//!")
  (#set! priority 120))

((comment) @comment.highlight
  (#match? @comment.highlight "^[[:space:]]*//[*]")
  (#set! priority 120))

((comment) @comment.todo
  (#match? @comment.todo "^[[:space:]]*//[[:space:]]*TODO")
  (#set! priority 120))

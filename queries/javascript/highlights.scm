; extends

;; Important/Alert comments
((comment) @comment.alert
  (#match? @comment.alert "^[[:space:]]*//!")
  (#set! priority 120))

;; Highlight/Documentation comments
((comment) @comment.highlight
  (#match? @comment.highlight "^[[:space:]]*//[*]")
  (#set! priority 120))

;; TODO comments
((comment) @comment.todo
  (#match? @comment.todo "^[[:space:]]*//[[:space:]]*TODO")
  (#set! priority 120))

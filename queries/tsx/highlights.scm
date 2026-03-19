; extends

;; ═══════════════════════════════════════════════════════════════
;; TYPE CAPTURES - Make all type references visible to Tree-sitter
;; ═══════════════════════════════════════════════════════════════

;; Type annotations (e.g., `: MyType`)
(type_annotation (type_identifier) @type)

;; Type references in generics (e.g., `Array<MyType>`)
(generic_type (type_identifier) @type)

;; Interface declarations
(interface_declaration name: (type_identifier) @type)

;; Type alias declarations  
(type_alias_declaration name: (type_identifier) @type)

;; Type parameters (e.g., `<T>`)
(type_parameter name: (type_identifier) @type)

;; Standalone type identifiers
(type_identifier) @type

;; ═══════════════════════════════════════════════════════════════
;; COMMENT CAPTURES - Better Comments style
;; ═══════════════════════════════════════════════════════════════

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

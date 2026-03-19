; modifiers
((modifiers) @public    (#match? @public    "public"))
((modifiers) @private   (#match? @private   "private"))
((modifiers) @protected (#match? @protected "protected"))
((modifiers) @static    (#match? @static    "static"))

; class keyword
((class_declaration) @class_keyword (#match? @class_keyword "class"))

; return statement
((return_statement) @return (#match? @return "return"))

; void keyword
((method_declaration type: (void_type) @void) (#match? @void "void"))

; new keyword
((object_creation_expression) @new (#match? @new "new"))


;; extends

;; The Python parser captures every `in` as @keyword.operator, which chinolor
;; renders pink alongside `and` / `or` / `not`. In the Chinolor VS Code theme the
;; `in` of a for-loop is `keyword.control.flow` (teal) while the `in` of a
;; membership test stays an operator, so re-capture just the loop form.
(for_statement "in" @keyword.repeat)
(for_in_clause "in" @keyword.repeat)

# QA Checklist

## A. File Safety

- [ ] Translation was performed on copied file, not source file.
- [ ] Output file name ends with `翻译版.docx`.

## B. Structure Integrity

- [ ] Section order is preserved from source.
- [ ] Subsection boundaries are preserved.
- [ ] No section/subsection content is missing.

## C. Title Rules

- [ ] Every title follows `<编号> <English> <Chinese>`.
- [ ] English and Chinese title text are on same line.
- [ ] All titles are bold.

## D. Paragraph Rules

- [ ] Non-table content is translated paragraph by paragraph.
- [ ] For each source paragraph: English paragraph appears before Chinese paragraph.
- [ ] No cross-paragraph merge happened.

## E. Table Rules

- [ ] Header cells are `English Chinese` (single-line).
- [ ] Non-header cells keep same row/column mapping.
- [ ] For multi-paragraph cells: all English paragraphs appear first, then all Chinese paragraphs.

## F. Language Quality

- [ ] Medical/clinical terminology is professional and consistent.
- [ ] Numbers, units, dates, and identifiers are accurate.
- [ ] Logic and compliance meaning match source text.

## G. Formatting

- [ ] English font is Times New Roman.
- [ ] English size is 10.5 pt.
- [ ] English color is black.

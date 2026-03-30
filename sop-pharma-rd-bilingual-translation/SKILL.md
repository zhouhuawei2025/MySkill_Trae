---
name: sop-pharma-rd-bilingual-translation
description: Translate finalized Chinese pharmaceutical R&D SOP Word documents (.docx) into Chinese-English bilingual versions with strict section-by-section workflow control, title/paragraph/table formatting rules, and final QA checks. Use when the source document is already approved in Chinese and the output must preserve original structure (Purpose, Scope, Responsibilities, Procedure) while adding accurate clinical/medical English.
---

# Pharma SOP Bilingual Translation

## Overview

Convert a finalized Chinese SOP Word file into a bilingual (EN+ZH) version by operating on a copied file only. Translate in section order, preserve logic and layout, apply mandated bilingual formatting, then run final QA checks.

## Required Workflow

1. Locate the target Chinese SOP `.docx` in the requested folder.
2. Copy the source file; do not edit original.
3. Rename copied file by appending `翻译版` before `.docx`.
- Example: `XXX.docx` -> `XXX翻译版.docx`
4. Read full document and map section hierarchy from body start to end.
5. Translate in order by section and subsection; do not skip, merge, or reorder.
6. Apply bilingual formatting rules for titles, paragraphs, and tables.
7. Run QA checklist in [references/qa_checklist.md](references/qa_checklist.md).
8. Report completion with key validation outcomes.

## Section Parsing Rules

1. Start from body content, not cover/meta content.
2. Typical top-level order: `目的` -> `范围` -> `职责` -> `流程`.
3. Identify subsections to practical depth (for example `2.1`, `3.1`, `3.2`).
4. Translate by section/subsection boundaries.

## Translation Rules

1. Use professional medical and clinical-trial terminology.
2. Keep original structure and logic intact.
3. Keep terminology and phrasing consistent across full document.
4. Preserve numeric values, units, dates, identifiers, and references exactly unless user requests normalization.

## Title Formatting Rules

Use single-line bilingual title format:
- `<title-number> <English title> <Original Chinese title>`

Constraints:
- Keep English and Chinese on same line.
- Use English title capitalization (major words capitalized).
- Bold all titles after bilingual conversion.

Examples:
- `5 流程` -> `5 Procedure 流程`
- `5.1.2 既往项目数据集变量提取` -> `5.1.2 Variable Extraction from Datasets of Previous Projects 既往项目数据集变量提取`

## Paragraph Formatting Rules

For non-table body content:
1. Translate paragraph-by-paragraph.
2. For each source paragraph, output two paragraphs in this order:
- English translation paragraph
- Original Chinese paragraph
3. English and Chinese must be in separate paragraphs.
4. Do not merge adjacent source paragraphs.

## Table Formatting Rules

### Header-row cells

Format each header cell as:
- `English Chinese`

Constraints:
- Same cell line (no line break between EN/ZH).
- Join EN and ZH with one space.

### Non-header-row cells

1. Keep one source cell mapped to one output cell.
2. If a source cell has multiple paragraphs, reorder output to:
- all English paragraphs first (original order)
- then all Chinese paragraphs (original order)
3. Do not merge across cells.
4. Do not move content across rows/columns.

## Font and Platform Requirements

1. Target environment: Windows.
2. Prefer Python automation with `python-docx`.
3. English text style: Times New Roman, 10.5 pt (Chinese 五号), black.
4. Do not downgrade existing Chinese formatting unless needed to satisfy bilingual layout rules.
5. Reuse `docx` skill for generic Word operations; use SOP-specific snippets from [references/python_snippets.md](references/python_snippets.md) only for this workflow's special formatting rules.

## Output Requirements

At completion, provide:
1. Output file path (`*翻译版.docx`).
2. Confirmed section/subsection count processed.
3. QA result summary in the chat message using [references/qa_checklist.md](references/qa_checklist.md).
4. Full QA report file path as a clickable path (for example: `/abs/path/qa_report.md`).
5. Any unresolved ambiguities requiring user decision.

## QA Delivery Rules

1. Do not assume user will open files proactively.
2. Always show a short QA summary directly in the reply message.
3. Always generate a standalone QA report file and provide its absolute path.
4. Use [references/qa_report_template.md](references/qa_report_template.md) as report structure.

## Example Script

When you need a compact runnable example, use [scripts/minimal_example.py](scripts/minimal_example.py). It demonstrates three representative patterns only: bilingual titles, bilingual body paragraphs, and multi-line table cells with English paragraphs first and Chinese paragraphs second. It intentionally skips the leading approval table because that section is typically edited manually.

## Resources

- Execution template: [references/workflow_template.md](references/workflow_template.md)
- QA checklist: [references/qa_checklist.md](references/qa_checklist.md)
- Python snippets for SOP-specific formatting: [references/python_snippets.md](references/python_snippets.md)
- Minimal runnable example: [scripts/minimal_example.py](scripts/minimal_example.py)

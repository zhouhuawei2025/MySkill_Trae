# Workflow Template (SOP CN->EN Bilingual)

## Step 1: Input Discovery

1. Locate source `.docx` in target folder.
2. Confirm source is finalized Chinese SOP.
3. Record source file name and path.

## Step 2: Safe Copy and Rename

1. Copy source file in same folder.
2. Rename copied file by appending `翻译版` before extension.
3. Confirm original file remains unchanged.

## Step 3: Structure Mapping

1. Read body from first formal section.
2. Identify section and subsection boundaries.
3. Process in order, usually: `目的` -> `范围` -> `职责` -> `流程`.
4. Subsection depth target: around `2.1`, `3.1`, `3.2` level.

## Step 4: Title Translation

For every section/subsection title:
- Output format: `<编号> <English Title> <Chinese Title>`
- Keep EN+ZH in one line.
- Bold the final title.

## Step 5: Paragraph Translation

For each non-table paragraph:
1. Create one English paragraph first.
2. Keep original Chinese as next paragraph.
3. Do not merge source paragraphs.

## Step 6: Table Translation

Header-row cells:
- Format as `English Chinese` in one line.

Non-header-row cells:
1. Preserve same row/column mapping.
2. If multiple source paragraphs in one cell, output as:
- all translated English paragraphs first
- then all original Chinese paragraphs
3. Keep paragraph order inside each language block.

## Step 7: Typography

1. Apply English font as Times New Roman.
2. English size: 10.5 pt.
3. English color: black.


## Step 8: Final QA

Run full checklist in `references/qa_checklist.md`.

# Python Snippets (SOP-specific)

Use these snippets only for SOP-specific bilingual formatting. For generic `.docx` read/write/edit operations, follow `docx` skill first.

## 1) Set English run style

```python
from docx.shared import Pt, RGBColor


def style_english_run(run):
    run.font.name = "Times New Roman"
    run.font.size = Pt(10.5)
    run.font.color.rgb = RGBColor(0, 0, 0)
```

## 2) Bilingual title line and bold

```python
def build_bilingual_title(number: str, en_title: str, zh_title: str) -> str:
    return f"{number} {en_title} {zh_title}"


def write_bold_title(paragraph, number, en_title, zh_title):
    paragraph.clear()  # python-docx>=1.1 supports clear(); otherwise rebuild paragraph
    run = paragraph.add_run(build_bilingual_title(number, en_title, zh_title))
    run.bold = True
    style_english_run(run)
```

## 3) Non-table paragraph layout (EN paragraph first, ZH paragraph second)

```python
def insert_bilingual_paragraph(doc, en_text: str, zh_text: str):
    p_en = doc.add_paragraph(en_text)
    for r in p_en.runs:
        style_english_run(r)

    # Keep Chinese as separate paragraph after English
    doc.add_paragraph(zh_text)
```

## 4) Table header cell format (single line: EN ZH)

```python
def set_header_cell_bilingual(cell, en_text: str, zh_text: str):
    cell.text = ""
    p = cell.paragraphs[0]
    run = p.add_run(f"{en_text} {zh_text}")
    style_english_run(run)
```

## 5) Non-header cell multi-paragraph reorder (all EN first, then all ZH)

```python
def set_body_cell_bilingual(cell, en_paragraphs: list[str], zh_paragraphs: list[str]):
    cell.text = ""

    for en in en_paragraphs:
        p = cell.add_paragraph(en)
        for r in p.runs:
            style_english_run(r)

    for zh in zh_paragraphs:
        cell.add_paragraph(zh)
```

## 6) Output naming helper

```python
from pathlib import Path


def build_output_path(source_path: str) -> Path:
    src = Path(source_path)
    return src.with_name(f"{src.stem}翻译版{src.suffix}")
```

## Notes

- Translate body content only. Do not edit header/footer.
- Keep section and subsection order unchanged.
- Keep one-to-one mapping of source paragraphs/cells.

## 7) Idempotency helpers (skip already bilingual content)

```python
import re

TITLE_BILINGUAL_RE = re.compile(r"^\\d+(?:\\.\\d+)*\\s+[A-Za-z].+\\s+[\u4e00-\u9fff].+$")


def is_bilingual_title(text: str) -> bool:
    return bool(TITLE_BILINGUAL_RE.match(text.strip()))


def is_english_like(text: str) -> bool:
    s = text.strip()
    return bool(s) and sum(ch.isascii() and ch.isalpha() for ch in s) >= 3


def is_chinese_like(text: str) -> bool:
    return any('\u4e00' <= ch <= '\u9fff' for ch in text)
```

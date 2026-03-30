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
from docx.oxml import OxmlElement
from docx.text.paragraph import Paragraph


def insert_paragraph_after(paragraph, text: str) -> Paragraph:
    new_p = OxmlElement("w:p")
    paragraph._p.addnext(new_p)
    para = Paragraph(new_p, paragraph._parent)
    para.add_run(text)
    return para


def write_bilingual_paragraph(paragraph, en_text: str, zh_text: str):
    clear_paragraph(paragraph)
    run = paragraph.add_run(en_text)
    style_english_run(run)
    insert_paragraph_after(paragraph, zh_text)
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
- Leading approval/signature tables are often maintained manually and may be skipped.

---
name: dev-document
description: Document generation (PDF, DOCX, XLSX, PPTX). Trigger when the user wants to create a document, generate a report, export to PDF/Word/Excel/PowerPoint, or produce an office file.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Document Generation

## Goal

Create professional documents in different formats: PDF, DOCX, XLSX, PPTX.

## Supported formats

| Format | Extension | Recommended tool | Usage |
|--------|-----------|------------------|-------|
| **PDF** | `.pdf` | puppeteer, wkhtmltopdf, markdown-pdf | Reports, invoices, formal docs |
| **Word** | `.docx` | docx (npm), python-docx | Editable documents, specifications |
| **Excel** | `.xlsx` | exceljs, openpyxl | Tabular data, numeric reports |
| **PowerPoint** | `.pptx` | pptxgenjs, python-pptx | Presentations, pitch decks |

## Instructions per format

### PDF - Generation from HTML/Markdown

```bash
# Option 1: Puppeteer (Node.js)
npm install puppeteer

# Option 2: wkhtmltopdf (CLI)
wkhtmltopdf input.html output.pdf

# Option 3: markdown-pdf (Markdown -> PDF)
npm install markdown-pdf
```

```typescript
// Puppeteer - HTML to PDF
import puppeteer from 'puppeteer';

async function generatePDF(htmlContent: string, outputPath: string) {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.setContent(htmlContent, { waitUntil: 'networkidle0' });
  await page.pdf({
    path: outputPath,
    format: 'A4',
    margin: { top: '20mm', right: '15mm', bottom: '20mm', left: '15mm' },
    printBackground: true,
  });
  await browser.close();
}
```

### DOCX - Word documents

```typescript
// npm install docx
import { Document, Packer, Paragraph, TextRun, HeadingLevel } from 'docx';
import * as fs from 'fs';

async function generateDOCX(title: string, sections: Section[]) {
  const doc = new Document({
    sections: [{
      properties: {},
      children: [
        new Paragraph({
          text: title,
          heading: HeadingLevel.TITLE,
        }),
        ...sections.flatMap(section => [
          new Paragraph({
            text: section.heading,
            heading: HeadingLevel.HEADING_1,
          }),
          new Paragraph({
            children: [new TextRun(section.content)],
          }),
        ]),
      ],
    }],
  });

  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync('output.docx', buffer);
}
```

### XLSX - Spreadsheets

```typescript
// npm install exceljs
import ExcelJS from 'exceljs';

async function generateXLSX(data: Record<string, any>[]) {
  const workbook = new ExcelJS.Workbook();
  const sheet = workbook.addWorksheet('Data');

  // Headers from the keys of the first object
  const headers = Object.keys(data[0]);
  sheet.addRow(headers);

  // Header styling
  sheet.getRow(1).font = { bold: true };
  sheet.getRow(1).fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FF4472C4' },
  };

  // Data
  data.forEach(row => {
    sheet.addRow(headers.map(h => row[h]));
  });

  // Auto-width
  sheet.columns.forEach(col => {
    col.width = 15;
  });

  await workbook.xlsx.writeFile('output.xlsx');
}
```

### PPTX - Presentations

```typescript
// npm install pptxgenjs
import PptxGenJS from 'pptxgenjs';

function generatePPTX(slides: SlideData[]) {
  const pptx = new PptxGenJS();

  slides.forEach(slideData => {
    const slide = pptx.addSlide();

    // Title
    slide.addText(slideData.title, {
      x: 0.5, y: 0.5, w: 9, h: 1,
      fontSize: 28, bold: true, color: '363636',
    });

    // Content
    slide.addText(slideData.content, {
      x: 0.5, y: 1.8, w: 9, h: 4,
      fontSize: 16, color: '666666',
      bullet: slideData.bullets ? true: false,
    });
  });

  pptx.writeFile({ fileName: 'output.pptx' });
}
```

## Python alternatives

```python
# PDF with reportlab
pip install reportlab

# DOCX with python-docx
pip install python-docx

# XLSX with openpyxl
pip install openpyxl

# PPTX with python-pptx
pip install python-pptx
```

## Generation workflow

```
1. IDENTIFY the required format (PDF, DOCX, XLSX, PPTX)
        |
2. PREPARE the data and content
        |
3. CHOOSE the library suited to the runtime (Node.js or Python)
        |
4. GENERATE the document with professional formatting
        |
5. VALIDATE the output (opening, layout, data)
```

## Best practices

- Always use templates for visual consistency
- Separate data from formatting
- Handle encoding errors (UTF-8)
- Test with different data sizes
- Include metadata (author, date, subject)

## Rules

- ALWAYS ask for the desired format if not specified
- ALWAYS verify that dependencies are installed before generating
- NEVER hardcode file paths
- PREFER reusable templates over one-shot documents

---
name: dev-document
description: Generation de documents (PDF, DOCX, XLSX, PPTX). Declencher quand l'utilisateur veut creer un document, generer un rapport, exporter en PDF/Word/Excel/PowerPoint, ou produire un fichier bureautique.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Generation de Documents

## Objectif

Creer des documents professionnels dans differents formats : PDF, DOCX, XLSX, PPTX.

## Formats supportes

| Format | Extension | Outil recommande | Usage |
|--------|-----------|------------------|-------|
| **PDF** | `.pdf` | puppeteer, wkhtmltopdf, markdown-pdf | Rapports, factures, docs formels |
| **Word** | `.docx` | docx (npm), python-docx | Documents editables, specifications |
| **Excel** | `.xlsx` | exceljs, openpyxl | Donnees tabulaires, rapports chiffres |
| **PowerPoint** | `.pptx` | pptxgenjs, python-pptx | Presentations, pitch decks |

## Instructions par format

### PDF - Generation depuis HTML/Markdown

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

### DOCX - Documents Word

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

### XLSX - Feuilles de calcul

```typescript
// npm install exceljs
import ExcelJS from 'exceljs';

async function generateXLSX(data: Record<string, any>[]) {
  const workbook = new ExcelJS.Workbook();
  const sheet = workbook.addWorksheet('Donnees');

  // En-tetes depuis les cles du premier objet
  const headers = Object.keys(data[0]);
  sheet.addRow(headers);

  // Style des en-tetes
  sheet.getRow(1).font = { bold: true };
  sheet.getRow(1).fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FF4472C4' },
  };

  // Donnees
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

    // Titre
    slide.addText(slideData.title, {
      x: 0.5, y: 0.5, w: 9, h: 1,
      fontSize: 28, bold: true, color: '363636',
    });

    // Contenu
    slide.addText(slideData.content, {
      x: 0.5, y: 1.8, w: 9, h: 4,
      fontSize: 16, color: '666666',
      bullet: slideData.bullets ? true : false,
    });
  });

  pptx.writeFile({ fileName: 'output.pptx' });
}
```

## Python alternatives

```python
# PDF avec reportlab
pip install reportlab

# DOCX avec python-docx
pip install python-docx

# XLSX avec openpyxl
pip install openpyxl

# PPTX avec python-pptx
pip install python-pptx
```

## Workflow de generation

```
1. IDENTIFIER le format requis (PDF, DOCX, XLSX, PPTX)
        |
2. PREPARER les donnees et le contenu
        |
3. CHOISIR la librairie adaptee au runtime (Node.js ou Python)
        |
4. GENERER le document avec mise en forme professionnelle
        |
5. VALIDER la sortie (ouverture, mise en page, donnees)
```

## Bonnes pratiques

- Toujours utiliser des templates pour la coherence visuelle
- Separer les donnees de la mise en forme
- Gerer les erreurs d'encodage (UTF-8)
- Tester avec differentes tailles de donnees
- Inclure les metadonnees (auteur, date, sujet)

## Regles

- TOUJOURS demander le format souhaite si non specifie
- TOUJOURS verifier que les dependances sont installees avant de generer
- NE JAMAIS hardcoder les chemins de fichiers
- PREFERER les templates reutilisables aux documents one-shot

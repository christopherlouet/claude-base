# Agent DEV-DOCUMENT

Generation de documents professionnels dans differents formats bureautiques.

## Demande
$ARGUMENTS

## Objectif

Generer des documents de qualite professionnelle dans le format demande (PDF, DOCX, XLSX, PPTX).

## Formats supportes

```
┌─────────────────────────────────────────────────────────────┐
│                   DOCUMENT GENERATION                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PDF   → Rapports, factures, docs formels                  │
│  ═════   puppeteer, wkhtmltopdf, reportlab                 │
│                                                             │
│  DOCX  → Documents editables, specifications               │
│  ═════   docx (npm), python-docx                           │
│                                                             │
│  XLSX  → Donnees tabulaires, rapports chiffres             │
│  ═════   exceljs, openpyxl                                 │
│                                                             │
│  PPTX  → Presentations, pitch decks                        │
│  ═════   pptxgenjs, python-pptx                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Workflow

### 1. Identifier le format

| Format | Quand l'utiliser | Librairie Node.js | Librairie Python |
|--------|------------------|-------------------|------------------|
| **PDF** | Documents finaux, impression | puppeteer, pdf-lib | reportlab, weasyprint |
| **DOCX** | Documents editables | docx | python-docx |
| **XLSX** | Donnees, tableaux, calculs | exceljs | openpyxl |
| **PPTX** | Presentations | pptxgenjs | python-pptx |

### 2. Preparer le contenu

```markdown
## Contenu requis

**Titre:** [Titre du document]
**Format:** [PDF / DOCX / XLSX / PPTX]
**Sections/Pages:** [Liste des sections]
**Donnees:** [Sources de donnees si applicable]
**Style:** [Formel / Informel / Corporate]
```

### 3. Generer le document

#### PDF (via HTML + Puppeteer)

```typescript
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
    displayHeaderFooter: true,
    headerTemplate: '<div style="font-size:8px;text-align:center;width:100%;">Header</div>',
    footerTemplate: '<div style="font-size:8px;text-align:center;width:100%;"><span class="pageNumber"></span>/<span class="totalPages"></span></div>',
  });
  await browser.close();
}
```

#### DOCX

```typescript
import { Document, Packer, Paragraph, TextRun, HeadingLevel, Table, TableRow, TableCell } from 'docx';

async function generateDOCX(title: string, sections: { heading: string; content: string }[]) {
  const doc = new Document({
    sections: [{
      properties: { page: { margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } } },
      children: [
        new Paragraph({ text: title, heading: HeadingLevel.TITLE }),
        ...sections.flatMap(s => [
          new Paragraph({ text: s.heading, heading: HeadingLevel.HEADING_1 }),
          new Paragraph({ children: [new TextRun(s.content)] }),
        ]),
      ],
    }],
  });
  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync('output.docx', buffer);
}
```

#### XLSX

```typescript
import ExcelJS from 'exceljs';

async function generateXLSX(sheets: { name: string; headers: string[]; rows: any[][] }[]) {
  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'Generated';
  workbook.created = new Date();

  for (const sheetData of sheets) {
    const sheet = workbook.addWorksheet(sheetData.name);
    sheet.addRow(sheetData.headers);
    sheet.getRow(1).font = { bold: true };
    sheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF4472C4' } };
    sheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
    sheetData.rows.forEach(row => sheet.addRow(row));
    sheet.columns.forEach(col => { col.width = 18; });
  }

  await workbook.xlsx.writeFile('output.xlsx');
}
```

#### PPTX

```typescript
import PptxGenJS from 'pptxgenjs';

function generatePPTX(slides: { title: string; content: string; bullets?: string[] }[]) {
  const pptx = new PptxGenJS();
  pptx.layout = 'LAYOUT_WIDE';

  slides.forEach(s => {
    const slide = pptx.addSlide();
    slide.addText(s.title, { x: 0.5, y: 0.3, w: 12, h: 1, fontSize: 28, bold: true, color: '363636' });
    if (s.bullets) {
      slide.addText(s.bullets.map(b => ({ text: b, options: { bullet: true, fontSize: 16 } })),
        { x: 0.5, y: 1.5, w: 11, h: 5 });
    } else {
      slide.addText(s.content, { x: 0.5, y: 1.5, w: 11, h: 5, fontSize: 16, color: '666666' });
    }
  });

  pptx.writeFile({ fileName: 'output.pptx' });
}
```

### 4. Valider le document

```
[ ] Format correct (ouverture sans erreur)
[ ] Contenu complet (toutes les sections)
[ ] Mise en forme professionnelle
[ ] Metadonnees remplies (auteur, date, sujet)
[ ] Encodage correct (UTF-8, caracteres speciaux)
```

## Bonnes pratiques

- Separer les donnees de la mise en forme
- Utiliser des templates pour la coherence
- Gerer les erreurs d'encodage (UTF-8)
- Inclure les metadonnees (auteur, date, sujet)
- Tester avec differentes tailles de donnees

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/doc-generate` | Documentation technique (Markdown) |
| `/doc-api-spec` | Specification API (OpenAPI) |
| `/biz-pitch` | Presentation pitch deck |
| `/data-analytics` | Rapport d'analyse avec donnees |

---

IMPORTANT: Toujours demander le format souhaite si non specifie.

IMPORTANT: Verifier que les dependances sont installees avant de generer.

YOU MUST generer un document qui s'ouvre correctement dans le logiciel cible.

NEVER hardcoder les chemins de fichiers ou les donnees.

Think hard sur la mise en forme la plus adaptee au contenu et au public cible.

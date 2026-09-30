# clemson: accessible LaTeX in one package

`clemson.sty` makes LuaLaTeX write a tagged PDF that conforms to PDF/UA-2 (ISO 14289-2:2024) and
to Clemson's digital accessibility standard (WCAG 2.1 AA and the Clemson guidance pages). The
folder holds the package, `main.tex` (the starter), `example.tex` (every kind of content, with a
comment on each block and the clause it meets), `references.bib` and `resources/` (pictures).

## Requirements

1. TeX Live 2026 (MacTeX 2026 on a Mac), then `sudo tlmgr update --self --all`. The package
   needs LaTeX 2026-06-01; the first lines of the log show the release. On Windows use TeX Live
   inside WSL, not `apt`.
2. Java and veraPDF 1.30 or later on PATH (`verapdf --flavour ua2`).
3. Adobe Acrobat Pro for the checks by hand.
4. Overleaf: LuaLaTeX compiler and Rolling TeX Live; confirm `LaTeX2e <2026-06-01>` in the log.

## Quick start

Copy the folder, write in `main.tex`. Its first lines:

```latex
% !TEX program = lualatex
% !TEX TS-program = lualatex
\DocumentMetadata{
  lang          = en-US,
  pdfstandard   = ua-2,
  tagging       = on,
  tagging-setup = {math/setup=mathml-SE},
  check-tagging-status,
}
\documentclass{article}
\usepackage{booktabs}          % your packages
\usepackage{clemson}           % after your packages
\graphicspath{{resources/}}
\title{Title of the document}
\author{First Author \and Second Author}
```

- `\DocumentMetadata` goes above `\documentclass`. `lang` is the document language (ISO
  14289-2:2024 8.4.4). `pdfstandard=ua-2` declares the standard. `tagging=on` turns tagging on;
  `pdfstandard` alone does not, and LaTeX then writes an untagged PDF without a word, so the
  package stops instead. `tagging-setup` puts the MathML of every formula in the tag tree.
  `check-tagging-status` adds a package report to the log.
- `\usepackage{clemson}` comes after the other packages: it loads hyperref, which its manual asks
  to load last. `cleveref` goes after it. A hyperref option that works only at load time goes in
  `\PassOptionsToPackage{...}{hyperref}` before it.
- `report` gives chapters (`\chapter` is H2, `\section` H3). `book` works but has no abstract.
- A title with a comma: `\title[pdftitle={{A, B}}]{A, B}` on LaTeX 2026-06-01 (fixed in
  2026-11-01). Authors: `\and` between them, one metadata entry each.
- Build: `latexmk -lualatex main.tex`. Check: see Checking.

## What you write

1. `% !TEX program = lualatex` on the first line.
2. The `\DocumentMetadata` block above.
3. `alt={...}` on every `\includegraphics` and `tikzpicture`; `actualtext={the words}` for a
   picture of text; `artifact` for decoration.
4. The header cells of every table: `\tagpdfsetup{table/header-rows={1}}` or
   `table/header-columns={1}` (or both) on the line before `\begin{tabular}`, inside the `table`
   environment; `\tagpdfsetup{table/multirow=2}` at the start of a cell that spans rows.

Everything else is the package or LaTeX.

## What the package does

- Stops the build unless LuaLaTeX, LaTeX 2026-06-01 or newer and `\DocumentMetadata` with
  tagging are in use (`tagging=draft` builds and warns at the end).
- Loads unicode-math, graphicx, float, enotez, babel, hyperref and lua-ul.
- Tags the title as the only H1, every heading one level down, the abstract as a Sect with an H2
  (Clemson Headings page; ISO 14289-1:2014 7.4.2; Graduate School template).
- Keeps each figure and table in the tag tree where it is written and prints it there (`[H]`).
- Writes Scope, ColSpan, RowSpan and Headers as direct attributes on every `tabular` cell.
- Left-aligns text, footnotes included, and keeps the class's paragraph indent.
- Endnotes (enotez): marks link to notes and back, a numbered list, "Notes" in the contents.
- Keeps the MathML file list right when the file name holds a comma.
- Tags every `\foreignlanguage` phrase, `otherlanguage` block and `\selectlanguage` switch.
- Footnotes: adds NoteType Footnote; 9 pt note text, 7 pt marks.
- Links: black, underlined by LaTeX (as artifacts), no viewer box, plain in the contents lists.
- Tags `\strong` as Strong; bookmarks the contents lists; lists the bibliography in the
  contents; sets `\autoref` names; defines `\email`; ends proofs with QED.

## Commands and settings the package defines or changes

New:

- `\email{address}`: a mailto link whose text is the address.
- Environments `theorem`, `lemma`, `proposition`, `corollary`, `definition`, `example` and
  `remark` (one counter) and `algorithm`, each only if the preamble has not defined it. Each is
  also its `\autoref` name ("Lemma 2").
- Package option `justified`: keeps LaTeX's justified text.

Changed:

- The `proof` environment ends with the word QED instead of the open square; nothing to write.
  (`\renewcommand{\qedsymbol}{\openbox}` after the package brings the square back.)
- `abstract` (article, report): the class's own layout inside a Sect with an H2 heading and a
  bookmark.
- `\footnotesize` is `\small`; at 9 pt the script size is 7 pt (`\DeclareMathSizes{9}{9}{7}{5}`).
- `\raggedright` at `\begin{document}`, with the class's `\parindent` kept and `\\` a plain line
  break; the same in footnotes. Option `justified` turns it off.
- Default float placement `H` for `figure` and `table`; `figure*` and `table*` float in one column.
- hyperref: `pdfborder={0 0 0}`; `\strong` is allowed in bookmark text.
- `\autoref` names Section and Chapter (added to babel's names for the main language) and the
  theorem-like names above; hyperref's own names for figures, tables, equations, appendices,
  footnotes and items stay.
- enotez: `backref=true`, an enumerate list, roman marks, heading through `\section*[Notes]{Notes}`
  (`\chapter*` with chapters).
- babel: loaded with no options; the main language comes from `lang`; two babel hooks add the
  language tags.
- tagpdf keys: `float/here`; `math/mathml/sources` set again when the job name has a comma and
  files are read; roles `sec/N/title` one level down; the `title` socket plug `clemson-h1`; the
  table finalize plug `Table` replaced by a copy that also writes the cell attributes; NoteType
  added in the `fntext` hook.
- Kernel hooks, no command redefined: `cmd/strong/before|after`; `env/figure|table|figure*|table*/begin`;
  `cmd/href|url/before|after`; `hyp/link/link` (declared here) and `hyp/link/cite`;
  `cmd/tableofcontents|listoffigures|listoftables/before`; `env/thebibliography/before` with
  `cmd/section|chapter/after`; `fntext`; `fntext/para`; `begindocument/before`.

Internal names start with `clemson@`, `__clemson_` or `__hdrs_`. `\RemoveFromHook{<hook>}[clemson]`
drops a hook chunk; the bookmark chunks carry the label `clemson/bookmark`, the theorem
definitions `clemson/theorems`.

## Writing the document

Each item names the `%----` banner in `example.tex` that shows it.

- Headings. Use `\section`, `\subsection`, `\subsubsection` in order; never skip a level.
  `\section*[Acknowledgments]{Acknowledgments}` gives a starred heading a contents entry and a
  bookmark. A class with its own title page (ClemsonThesis.cls) tags the title as text and leaves
  no H1. TITLE, ABSTRACT, CONTENTS.
- Pictures. One or two sentences: what the picture shows and why it is here; not the caption, not
  the file name. Inside the braces write `\%`, `\#`, `\$`, `\&`, `\_`, `\{`, `\}`; type accents
  and quotation marks as real characters. A chart gets a short alt plus the description in the
  text or in a data table. Without `alt` LaTeX warns and uses the file name, and veraPDF passes,
  so the check by hand is the only guard. "Picture with alt text" to "Long description in appendix".
- Tables. Header rows are the top rows, header columns the leftmost. A group row after data rows
  (`table/header-rows={1,4}`) heads the rows to the next group. `\multicolumn` needs nothing;
  `multirow` is listed incompatible. `longtable` is compatible but tags its caption as a cell and
  gets no cell attributes. A layout `tabular` goes inside a group with
  `\tagpdfsetup{table/tagging=presentation}` or `=div`. Put `\caption` above the tabular. "Table:"
  blocks.
- Floats. `[H]` is the default; `\floatplacement{figure}{tbp}` lets figures float, and the tag
  position stays. `[!]` and `[]` stop the build. A `\caption` inside a minipage fails 8.2.5.27
  (tagging issue 1549). On LaTeX 2026-06-01, leave a blank line before a theorem or proof that
  follows a list, a display or a `center`, `quote` or `verbatim` environment (issues 1402, 1415;
  fixed in 2026-11-01).
- Lists. `itemize`, `enumerate`, `description` are tagged; `\begin{enumerate}[label=(\alph*)]`
  is a kernel key; `enumitem` cannot be loaded. Two levels at most. "Lists".
- Mathematics. `mathml-SE` puts MathML in the tag tree (the form Acrobat passes to a screen
  reader); `math/setup={mathml-SE,mathml-AF}` also attaches the file Foxit and Firefox read.
  Write `\symbf{v}`, `\symbfit{v}`, `\symcal{A}`; `bm` does not work with unicode-math, and
  `amssymb` after the package stops the build (load it before). Numbered `multline` warns (issue
  1407; use `multline*`). `\MathMLintent{mean($x)}{{...}}` names what a formula means. "Inline
  and display math" to "Chemistry, units, bra-ket".
- Theorems. `\newtheorem` adds a name; `\theoremstyle` and `proof` work as usual. `algorithm` is a
  theorem-like block, not a float. Leave `\qedhere` out after a display: the word QED would land
  inside the Formula. "Theorems and algorithm".
- Footnotes and endnotes. `\footnote{...}` and `\endnote{...}`; `\printendnotes` prints the list
  where it stands (nothing when there are none). "Emphasis, footnote, endnote".
- Links. Name the destination, never "click here". `\href{url}{words}`, `\url{...}`,
  `\email{...}`, `\autoref{sec:x}` ("Section 3"). To drop the underlines, remove the package's
  code from `hyp/link/link`, `hyp/link/cite`, `cmd/href/before`, `cmd/href/after`,
  `cmd/url/before` and `cmd/url/after`, and drop `\hypersetup{pdfborder={0 0 0}}`, or the links
  get no cue at all. "Links, citations", "Cross-references".
- Language. After the package, one `\babelprovide[import]{french}` per extra language. A phrase:
  `\foreignlanguage{french}{...}` (one paragraph at most). A passage: `otherlanguage` with a blank
  line before and after it. A `\usepackage[french]{babel}` line with options must come before the
  package; polyglossia cannot be used. "Rule, language, abbreviation, color".
- Code. `\verb` is tagged Code and each `verbatim` line is a code line; `listings` and `minted`
  are listed incompatible. "Code".
- Side by side. Two blocks of text side by side are minipages, not a table; each is a Div read to
  its end before the next. A tabular reads row by row. "Side by side, not a table".
- Two columns. `twocolumn` and `multicol` work; the tags follow the text column by column.
- Rules. `\rule` is decoration: an artifact from LaTeX 2026-11-01, content without text before.

## Checking

After `latexmk -lualatex main.tex`:

```
verapdf --flavour ua2 --format text main.pdf
grep -n -A2 '^!\|Package tagpdf Warning\|Package clemson\|Alternative text for graphic' main.log
grep -n 'luamml\|mathml' main.log | grep -i 'warning\|missing'
sed -n '/Status report of the tagging support/,/3\. Partially/p' main.log
```

The first line of the veraPDF output says PASS or FAIL and names each failed clause. The second
command lists errors, tagging warnings and every picture without `alt` (a tikz drawing without
`alt` is silent: search the source for `tikzpicture`). The third prints MathML warnings; under
`mathml-SE` there is no count, so look for a `math` element inside each Formula in Acrobat's tags
panel. The fourth prints the packages the status list marks unsupported or incompatible
(`float.sty` is listed for commands the kit does not use).

veraPDF does not test heading order, alt text quality, table header association beyond one
header, underlines or reading order, so these checks by hand are part of conformance (Clemson
[manual checks](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html)):

1. Every alt text says what the picture shows and why it is here.
2. In Acrobat Pro (Prepare for accessibility, Check for accessibility, Tags panel, Fix reading
   order): the title is the only H1, the sections start at H2, the reading order follows the page.
3. Every data table declared its header rows or columns; the Table Editor shows scope and headers.
4. Link text names the destination; Tab reaches every link.
5. Nothing is said by color alone; 4.5:1 contrast for text, 3:1 for graphics.

A screen reader (NVDA with Firefox or Acrobat) is the final test.

Acrobat's checker tests PDF/UA-1. It reports "Lbl and LBody - Failed" for every caption number,
theorem number and footnote mark: LaTeX tags them Lbl as ISO 32000-2:2020 Table 368 and the Tagged
PDF BPG expect, and Acrobat applies its list rule outside lists. It is a false positive; veraPDF
passes. "Headers" fails on a layout table tagged presentation. The Tags panel shows LaTeX's names
(`text`, `text-unit`, `float`, `footnote`, `theorem-like`) rather than the roles they map to (P,
Part, Aside, FENote, Sect); `tagging-setup={role/map-tags=pdf}` in `\DocumentMetadata` writes the
standard names instead, at the cost of the LaTeX names. "Cannot extract the embedded font" for
LMRoman17 is a known Acrobat message for CIDFontType0 fonts; the font passes every veraPDF rule.

## Packages by field

| Use | Avoid | Why |
| --- | --- | --- |
| `unicode-math`, `amsmath` (loaded by the package; `lua-unicode-math` loaded first is kept), the `amsthm` commands (built into LaTeX under tagging), `braket` | `amssymb` after the package, `bm`, `thmtools`, `ntheorem`, `tikz-cd` | `amssymb` after unicode-math stops the build, `bm` does not work with it (write `\symbf`); the rest are listed incompatible |
| `mhchem` (`$\ce{H2O}$`), `siunitx` | `chemfig`, `chemformula`, `physics` with `siunitx`, `\qtyrange` | `mhchem` and `physics` unchecked, `siunitx` partial (a number and its unit are separate formulas); `chemfig` and `chemformula` incompatible: draw structures as pictures with alt text; `\qtyrange` loses its numbers in the MathML |
| `verbatim`, `\verb`, `algpseudocode`, `algorithmicx` | `listings`, `minted`, `algorithm`, `algorithm2e`, `fancyvrb` | listed incompatible (`fancyvrb` partial); use the package's `algorithm` block |
| `booktabs`, `tabularx`, `longtable` | `multirow`, `tabularray`, `nicematrix`, `caption`, `subcaption`, `subfig` | listed incompatible; `longtable` tags its caption as a cell; spans come from `table/multirow`; panels share one caption ("Two panels") |
| `graphicx`, `float` (loaded by the package), `tikz` with `alt={...}`, `placeins` | `pgfplots`, `wrapfig`, `pdfpages`, `floatrow`, `\newfloat`, `\restylefloat`, `titlesec` | incompatible or unsupported; export a plot as a picture with alt text; `titlesec` stops tagging |
| the kernel's `label=` key | `enumitem` | cannot be loaded under tagging; its syntax is built in |
| `\footnote`; `enotez` (loaded by the package) | `endnotes`, `postnotes` | `endnotes` gives no link from mark to note; `postnotes` does not build; `enotez` is partial |
| `babel` (loaded by the package; `\babelprovide[import]{...}`) | `polyglossia` | cannot be loaded with babel |
| `multicol`, `geometry`, `fancyhdr`, `microtype`, `setspace`, `parskip`, `natbib`; `biblatex`, `cleveref` (after the package), `csquotes`, `acronym` (partial) | `memoir`; journal classes; `beamer`; `glossaries` | listed incompatible, unsupported or unchecked |

Any other package: look it up at <https://latex3.github.io/tagging-project/tagging-status/>; the
`check-tagging-status` report at the end of the log names what you load that the list marks
unsupported or incompatible.

## Bringing an existing document over

Work on a copy.

1. Copy `clemson.sty` next to the main `.tex` file.
2. Put the two `% !TEX` lines and the `\DocumentMetadata` block from `main.tex` at the top.
3. Build with `lualatex` everywhere (`latexmk -lualatex`).
4. Delete the lines that load `fontspec`, `unicode-math`, `hyperref`, `inputenc`, `fontenc`,
   `lmodern`, `amssymb`, `bm` and font packages such as `times` or `newtxmath`. hyperref options
   go in `\hypersetup{...}` after the package (load-time options in `\PassOptionsToPackage`
   before it). `enotez`, `float`, `graphicx`, `babel` and `amsthm` lines can go or stay before
   the package (a babel line with options must come before it); delete `polyglossia`.
   `\newtheorem` lines in the preamble can stay. A `\pdfbookmark` before `\tableofcontents` and
   a `\phantomsection` plus `\addcontentsline` before `\bibliography` go: the package does both.
   Add `\usepackage{clemson}` after the other packages (`cleveref` after it). Keep `\title` and
   `\author` unless the title has a comma.
5. Look up every remaining package in the table above and the status page. Replace `\bm{x}` by
   `\symbfit{x}` and rebuild each `subfigure` like "Two panels".
6. Build, then check. On LaTeX 2026-06-01 the first build often stops with "text para hooks
   differ": a theorem or proof right after a list, display or `center` needs a blank line before
   it. Then the veraPDF output and the log lines are the to-do list. Declare every table's header
   cells, move every caption above its picture or tabular, and do the five checks by hand.

## After a LaTeX update

Build `example.tex` and run veraPDF on it; PASS and a log without tagging warnings mean the
release still validates the whole example. Every block in `clemson.sty` that works around a LaTeX,
hyperref, babel or lua-ul gap carries a `REMOVE WHEN` line with the condition and the issue
number: the float `\par` hooks (tagging issue 1532), the MathML file list (job names with a
comma), the babel language tags (babel discussion 357, tagging issue 988), the table cell
attributes (Discussion 930; the block checks each latex-lab name it reads and warns instead of
failing), the `\strong` hooks (latex2e issue 1620), the `\pdfstringdef` line, the title plug
(issue 1625), NoteType (issue 728) and the underline artifact (issue 1581). The 2026-11-01
release renames the tags Acrobat shows (`text` to `text-block`, `text-unit` to `semantic-para`,
section numbers to `heading-number`, mapped to Lbl) and makes `\rule` an artifact.

## Presentations

The package does not cover slides. `beamer` cannot be tagged. The `ltx-talk` class is the tagged
replacement (`\DocumentMetadata{tagging=on, pdfstandard=ua-2}`, then `\documentclass{ltx-talk}`);
it is experimental.

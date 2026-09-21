# clemsona11y kit: LaTeX to accessible PDF

Drop this folder into a project. Two files do the work: `clemsona11y.cls` and
`clemsona11y.sty`. The output is a tagged PDF 2.0 that conforms to PDF/UA-2.
`main.tex` is a worked example of every kind of content; build it first.

## Requirements

- TeX Live 2026 (MacTeX 2026 on macOS), updated: `sudo tlmgr update --self --all`
- Compile with LuaLaTeX (pdfLaTeX and XeLaTeX are refused: no MathML)
- Optional: [veraPDF](https://verapdf.org/software/) for the automated PDF/UA-2 check

## Steps

1. Edit `main.tex`. Keep its first `\DocumentMetadata{...}` block; it must stay
   before `\documentclass`. Replace title, authors and content.
2. Give every picture alt text: `\includegraphics[alt={what it shows}]{file}`.
   Declare the header cells of every table before its `\begin{tabular}`:
   `\tagpdfsetup{table/header-rows={1}}` for a header row,
   `table/header-columns={1}` for a header column, both keys for both.
3. Build: `make -f Makefile.a11y` (or `latexmk -lualatex main.tex`).
4. Check: `make -f Makefile.a11y check`, then run Acrobat's accessibility checker
   (All tools > Prepare for accessibility > Check for accessibility) and read the
   Tags panel top to bottom.

Build with `make -f Makefile.a11y`, not with one editor pass: a single LuaLaTeX
run prints `??` for references and leaves their links empty; the `% !BIB` lines
at the top of `main.tex` make TeXShop and VS Code run the full cycle.

Optional: `make -f Makefile.a11y requirements` verifies the TeX installation;
`make -f Makefile.a11y TARGET=paper check` builds a file under another name.

## What main.tex shows

Front matter: a table of contents, a list of figures and a list of tables, all
tagged and linked, with short caption titles that keep the lists readable.
Text: emphasis, `\strong`, a footnote, an endnote, links, citations and
cross-references (`\ref`, `\pageref`, `\eqref`); bulleted, numbered, description
and nested lists; a block quotation; verbatim code and `\verb`. Mathematics:
inline and display math, `align`, matrices and cases, all written as MathML with
alt text, plus theorem, lemma, proof and definition.

Figures: a figure with alt text, a two-panel figure with per-panel alt text, an
image of text with `actualtext`, a decorative image marked `artifact`. For complex
images, a chart with short alt text, a full description in the text and the same
data as a table, and a second picture described in an appendix, linked both ways.
Also a decorative rule as an artifact, a phrase tagged with its own language, and
an abbreviation written out on first use.

Tables: every layout in Clemson's [tables guide](https://www.clemson.edu/accessibility/digital/concepts/tables.html)
— header row, header column, both (corner cell scope "both"), a two-level header
with merged header cells, merged row and column cells, header rows inside the
table, a table with its title and note outside and no empty cells, and a layout
grid tagged as presentation. Long tables (`longtable`) tag their caption as a
cell, so split them instead; sideways tables (`lscape`, `pdflscape`) are untested.
Back matter: an appendix with lettered numbering (Table A.1, Figure A.1), the
list of endnotes and the bibliography, both listed in the table of contents.

## Already have a Makefile or a class?

- Your own Makefile: keep it. Run `make -f Makefile.a11y check` after your build,
  or copy the `check` target into yours.
- No Makefile: rename `Makefile.a11y` to `Makefile` and use plain `make`.
- Your own class (based on article/report/book): keep it. Put the
  `\DocumentMetadata` block first in your main file and `\usepackage{clemsona11y}`
  as the last package. If your class redefines the title page, sections or
  captions, check the result in Acrobat.
- A journal class (IEEEtran, revtex, elsarticle, ...): not supported by LaTeX
  tagging yet. Build the accessible copy with this class; submit with theirs. A
  main file that already has `\DocumentMetadata`: merge the keys, keep one block.
- An existing paper: delete its `amsmath`, `amsthm`, `graphicx`, `float`,
  `fontspec`, `unicode-math`, `enotez` and `hyperref` lines, and its `\newtheorem`
  lines; the class loads all of them. Keep the rest, add alt text, build.

## Options

`\documentclass[report]{clemsona11y}` picks the base class (article, report or book); package options go in the same brackets:

| Option | Values (default first) | Effect |
| --- | --- | --- |
| `fonts` | `lm`, `termes`, `false` | Latin Modern, Times clone, or your own fonts |
| `floats` | `here`, `free` | figures/tables stay where written, or float |
| `headings` | `word`, `kernel` | title = only H1 and sections H2 (Word style), or LaTeX default |
| `links` | `keep`, `hidden` | dark blue link text (contrast 10.9:1 on white), or the body colour |
| `pagination` | `plain`, `typed` | typed page-number artifacts (PDF/UA-1 checkers) |
| `theorems` | `true`, `false` | predefined theorem, lemma, proposition, corollary, definition, example, remark |

Other options (`11pt`, `a4paper`, ...) go to the base class. `twocolumn` is refused.

## Packages by field

| Use | Avoid | Why |
| --- | --- | --- |
| `unicode-math` (loaded), `amsthm` (loaded), `braket` | `amssymb`, `bm`, `thmtools`, `ntheorem`, `tikz-cd` | not tagged or clash with unicode-math |
| `mhchem`: write `$\ce{H2O}$` | `chemfig`, `chemformula`, `chemmacros` | draw structures as images with alt text |
| `physics`, `siunitx` (not both) | | `\qty` clashes when both are loaded |
| `algpseudocode`; `verbatim` or `fancyvrb` | `listings`, `minted`, `algorithm2e` | not tagged; `algorithm` floats need `\tagpdfsetup{float/new=algorithm}` |
| `booktabs`, `tabularx` | `tabularray`, `nicematrix`, `multirow`, `caption`, `subcaption` | replace the table or caption code; use `\tagpdfsetup{table/multirow=2}` for row spans |
| `tikz` with `[alt={...}]` | `pgfplots` | export plots as images with alt text |
| `enotez` (loaded) | `endnotes` | `endnotes` marks carry no link to the note |
| `\tagstructbegin{tag=Span,lang=fr-FR}` | `babel` | its language files are reported incompatible, and `\foreignlanguage` writes no `/Lang` |

Full status list: https://latex3.github.io/tagging-project/tagging-status/

## What the checker will still say

Acrobat checks PDF/UA-1. On this PDF/UA-2 output it may show figure containers as
"Note" (the PDF 1.7 fallback for `Aside`) and MathML it cannot read. veraPDF's
`--flavour ua2` result is the authoritative one.

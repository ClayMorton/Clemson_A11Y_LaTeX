# clemsona11y kit: LaTeX to accessible PDF

Drop this folder into a project. `clemsona11y.cls` and `clemsona11y.sty` do the work; the output
is a tagged PDF 2.0 that conforms to PDF/UA-2 and PDF/A-4f. `main.tex` is a worked example; build
it first. Read Clemson's
[accessibility concepts](https://www.clemson.edu/accessibility/digital/concepts/) before you
start: the university states them as a prerequisite for its PDF guides, and they are what the
comments in `main.tex` cite.

## Requirements

- TeX Live 2026 (MacTeX 2026 on macOS), updated: `sudo tlmgr update --self --all`
- Compile with LuaLaTeX (pdfLaTeX and XeLaTeX are refused: no MathML)
- Optional: [veraPDF](https://verapdf.org/software/) for the automated PDF/UA-2 check

## Steps

1. Edit `main.tex`. Keep its first `\DocumentMetadata{...}` block; it must stay before
   `\documentclass`. Replace title, authors and content. The block's two `pdfstandard` keys give
   PDF/UA-2 and PDF/A-4f; drop `a-4f` if archiving is not wanted.
2. Give every picture alt text: `\includegraphics[alt={what it shows}]{file}`. Declare the header
   cells of every table before its `\begin{tabular}`: `\tagpdfsetup{table/header-rows={1}}` for a
   header row, `table/header-columns={1}` for a header column, both keys for both. Write
   `\mathalt{spoken text}` right before every formula, inline ones included, to set what a screen
   reader says (without it the alt text is the raw LaTeX source), and an email address as
   `\email{first.last@clemson.edu}`. Put `\caption` above the image or the table, not below: the
   tag tree always holds the caption first, so a caption printed below contradicts the page.
3. Build: `make -f Makefile.a11y` (or `latexmk -lualatex main.tex`), not one editor pass: a single
   LuaLaTeX run prints `??` for references and leaves their links empty; the `% !BIB` lines at the
   top of `main.tex` make TeXShop and VS Code run the full cycle.
4. Check: `make -f Makefile.a11y check`, then Acrobat (All tools > Prepare for accessibility >
   Check for accessibility) and the Tags panel top to bottom. No tool can finish the job, so do
   Clemson's [six manual
   checks](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html)
   by hand: use of color, descriptive link text, tags, reading order, tab order and form order,
   and alternative text. `make -f Makefile.a11y requirements` checks the TeX install first;
   `TARGET=paper` builds paper.tex.

## What main.tex shows

Front matter: a table of contents, a list of figures and a list of tables, all tagged and linked,
with short caption titles that keep the lists readable. Text: `\emph`, `\strong`, a footnote, an
endnote, links (`\href`, `\url`, a document link ending "(PDF)", `\email`), citations and
cross-references (`\autoref` for whole-phrase links, `\pageref`, `\eqref`, `\hyperref[label]{...}` for theorem-like blocks, `\cite[p.~3]{key}`); bulleted, numbered, lettered
(`[label=(\alph*)]`), description and nested lists; a block quotation; reserved characters, dashes,
`\textsuperscript`, `\texttt`, `\textsc`; verbatim code, `\verb`. Mathematics: inline and display
math, `align`, `subequations`, `gather`, `multline*`, matrices and cases, all as MathML with
`\mathalt` text, plus chemistry (`\ce`), units (`\qty`, `\num`), bra-ket notation, theorem, lemma,
corollary, proof, definition, example, remark and an algorithm.

Figures: alt text, a two-panel figure with per-panel alt text, a `tikz` diagram, an image of text
with `actualtext`, a decorative image (`artifact`); a chart with short alt text, its description in
the text and data as a table; a picture described in an appendix, linked both ways; a rule as an
artifact, a phrase in another language, and an abbreviation written out on first use. Tables: every
layout in Clemson's [tables
guide](https://www.clemson.edu/accessibility/digital/concepts/tables.html), one header row to merged
cells, one table per group instead of header rows inside a table (a second group row gets the wrong
`/Headers` today), a title and note outside the table, no empty cells, and a layout grid with table
tagging switched off (`longtable` tags its caption as a cell, so split long tables; `lscape`/`pdflscape`
untested). Back matter: appendix A.1, endnotes and bibliography, all in the contents.

## Already have a Makefile or a class?

- Your own Makefile: keep it. Run `make -f Makefile.a11y check` after your build, or copy the
  `check` target into yours. No Makefile: rename `Makefile.a11y` to `Makefile`.
- Your own class (based on article/report/book): keep it. Put the `\DocumentMetadata` block first in
  your main file and `\usepackage{clemsona11y}` as the last package. If your class redefines the
  title page, sections or captions, check the result in Acrobat.
- A journal class (IEEEtran, revtex, elsarticle, ...): not supported by LaTeX tagging yet. Build the
  accessible copy with this class; submit with theirs. A main file that already has
  `\DocumentMetadata`: merge the keys, keep one block.
- An existing paper: delete its `amsmath`, `amsthm`, `graphicx`, `float`, `fontspec`,
  `unicode-math`, `enotez` and `hyperref` lines, and its `\newtheorem` lines; the class loads all of
  them. Keep the rest, add alt text, build.

## Options

`\documentclass[report]{clemsona11y}` picks the base class (article, report or book); package
options go in the same brackets:

| Option | Values (default first) | Effect |
| --- | --- | --- |
| `fonts` | `lm`, `termes`, `false` | Latin Modern, Times clone, or your own fonts |
| `floats` | `here`, `free` | figures/tables stay where written, or float |
| `headings` | `word`, `kernel` | title = only H1 and sections H2 (Word style), or LaTeX default |
| `links` | `keep`, `hidden` | keep: black text, links underlined in running text by the PDF viewer; contents, list of figures and list of tables entries are links without the underline (every line there is one), and their page numbers link too. hidden: no marking at all |
| `align` | `ragged`, `justified` | left-aligned text (Clemson's rule), or LaTeX's justified look |
| `math` | `af`, `full` | af: MathML attached to each formula, one reading-order item per formula, clean in Acrobat; full: MathML structure elements in the tree as well (PDF/UA-2 readers; Acrobat shows empty spacing tags and one item per symbol) |
| `pagination` | `plain`, `typed` | plain: page numbers are untyped artifacts; typed: `/Pagination` artifacts for PDF/UA-1 checkers (adds two empty Artifact tags per page) |
| `title` | `h1`, `none` | tag the `\maketitle` title as the H1, or leave it for a class that tags its own title page |
| `theorems` | `true`, `false` | predefined theorem, lemma, proposition, corollary, definition, example, remark, algorithm |

Other options (`11pt`, `a4paper`, ...) go to the base class; `twocolumn` is refused.

## Packages by field

| Use | Avoid | Why |
| --- | --- | --- |
| `unicode-math` (loaded), `amsthm` (loaded), `braket` | `amssymb`, `bm`, `thmtools`, `ntheorem`, `tikz-cd` | not tagged or clash with unicode-math |
| `mhchem`: write `$\ce{H2O}$` | `chemfig`, `chemformula`, `chemmacros`; `\ce{^{14}C}` | draw structures as images with alt text; the isotope form raises a tagpdf warning |
| `physics`, `siunitx` (not both) | `\qtyrange` | `\qty` clashes when both are loaded; `\qtyrange` loses its numbers in the alt text |
| `algpseudocode`; `verbatim` or `fancyvrb` | `listings`, `minted`, `algorithm2e`, `algorithm` | not tagged; do not load the `algorithm` package, the class defines the environment |
| `booktabs`, `tabularx` | `tabularray`, `nicematrix`, `multirow`, `caption`, `subcaption` | replace the table or caption code; use `\tagpdfsetup{table/multirow=2}` for row spans (inside the `\multicolumn` text when a cell also spans columns); keep `table/tagging=false` (a layout grid) inside a group or it untags every later table |
| `tikz` with `[alt={...}]` | `pgfplots` | export plots as images with alt text |
| `enotez` (loaded) | `endnotes` | `endnotes` marks carry no link to the note |
| `\UseTaggingSocket{inline/begin}{tag=Span,lang=fr-FR}` ... `\UseTaggingSocket{inline/end}` | `babel` | its language files are reported incompatible, and `\foreignlanguage` writes no `/Lang` |
| numbered `equation`, `gather`, `multline*` | numbered `multline` | numbered `multline` raises a tagpdf structure-label warning |
| the expansion written into the text | `glossaries`, `acronym`, `makeidx` | not tested with tagging; write the expansion on first use, and set an index as a plain list |

Full status list: https://latex3.github.io/tagging-project/tagging-status/

## Workarounds, and what a LaTeX update does to them

The package works around five gaps in the LaTeX tagging code, each marked `A11Y WORKAROUND` with a
`REMOVE WHEN` line: the paragraph a float interrupts, spoken alt text for formulas (`\mathalt`), the
footnote-mark link box, the `NoteType` attribute on footnotes, and header-cell IDs and direct cell
attributes on tables. Separate from those, three role mappings keep Acrobat's list rule quiet by
tagging caption numbers, contents numbers and footnote marks `Span`. Every workaround checks
that the kernel piece it relies on still exists and otherwise does nothing and writes a
`Package clemsona11y Warning` to the log; `make -f Makefile.a11y check` then fails and names it.
After `tlmgr update`, build the kit's `main.tex` once: a clean `check` means every workaround still
works or is no longer needed. Everything else in the package uses documented interfaces only
(`\DocumentMetadata`, `\tagpdfsetup`, `\AssignStructureRole`, tagging sockets, hooks, hyperref).

## What the checker will still say

Acrobat checks PDF/UA-1. On this PDF/UA-2 output it may show figure containers as "Note" (the PDF
1.7 fallback for `Aside`) and MathML it cannot read.

The Tags panel shows LaTeX tag names, not the PDF names Clemson's manual check tells you to look
for: `text` = `P`, `text-unit` = `Part`, `itemize`/`enumerate`/`description`/`list` = `L`, `item` =
`LI`, `itemlabel` = `Lbl`, `itembody` = `LBody`, `quote` = `BlockQuote`, `verbatim` = `Code`,
`footnote` = `FENote`, `section-number` = `Span`. The role map makes these conformant, which is why
veraPDF passes; do not rename them by hand in Acrobat.

Known gaps, all of them outside `main.tex`. The Tagged PDF BPG marks `BBox` required on `Figure`,
`Formula` and `Table`; latex-lab writes it on figures only, so the 24 formulas and 10 tables have
none. Links are underlined by the annotation's border style, which Acrobat draws and Preview on
macOS does not; the link text names its destination in every viewer, and no link is marked by color.
`pagination=typed` would write `/Type /Pagination` on the folio as the BPG asks, but tagpdf
implements it with an empty `Artifact` element per header and footer, two of which land inside a
list item, so the kit keeps `plain`. PDF/A-4 allows only `ModDate` in the document information
dictionary, so the title travels in XMP and `/ViewerPreferences /DisplayDocTitle`.

Acrobat says "Cannot extract the embedded font 'LMRoman17-Regular'" when it opens the file. The
subset is valid — fontTools parses it, its outlines match the installed face, veraPDF passes, and a
bare `\documentclass{article}` with `\maketitle` produces the same subset — so nothing is broken
and printing and reading are unaffected. `\documentclass[fonts=termes]{clemsona11y}` uses TeX Gyre
Termes instead and the message stops.

Note text is 9 pt (8.97 pt as a PDF tool measures it) and raised marks 7 pt. Three kernel choices
PDF/UA-2 allows: `\ref`, `\pageref` and `\eqref` give a bare `Link` and only `\cite` adds
`Reference`; the steps of an `algorithmic` block (a generic `list` without `\usecounter`) are tagged
as an unordered list although the labels are line numbers; a nested list sits inside its parent item's
body (`LBody` > `Part` > `P`, `L`), the form ISO 32000-2 allows but calls "not part of the hierarchy",
rather than as a child of the parent `L`; the kernel's paragraph grouping (`Part`) is why. veraPDF
`--flavour ua2` and `--flavour 4f` are authoritative.

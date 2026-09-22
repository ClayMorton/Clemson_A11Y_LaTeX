# clemsona11y kit: LaTeX to accessible PDF

Drop this folder into a project. `clemsona11y.cls` and `clemsona11y.sty` do the work; the output
is a tagged PDF 2.0 that conforms to PDF/UA-2 and PDF/A-4f. `main.tex` is a worked example of every
kind of content; build it first. Pictures go in `resources/` (the class looks there and beside the
`.tex` file); `references.bib` holds the bibliography; `Makefile.a11y` builds and checks. Clemson's [accessibility
concepts](https://www.clemson.edu/accessibility/digital/concepts/) are the rules its comments cite.

## Requirements

- TeX Live 2026 (MacTeX 2026 on macOS), updated: `sudo tlmgr update --self --all`
- Compile with LuaLaTeX (pdfLaTeX and XeLaTeX are refused: no MathML)
- Optional: [veraPDF](https://verapdf.org/software/) for the automated PDF/UA-2 and PDF/A-4f checks

## Steps

1. Edit `main.tex`. Keep its first `\DocumentMetadata{...}` block above `\documentclass`; its two
   `pdfstandard` keys give PDF/UA-2 and PDF/A-4f (drop `a-4f` if archiving is not wanted).
2. Give every picture alt text: `\includegraphics[alt={what it shows}]{file}`. Declare the header
   cells of every table before its `\begin{tabular}`: `\tagpdfsetup{table/header-rows={1}}`,
   `table/header-columns={1}`, or both. Write `\mathalt{spoken text}` right before every formula
   (without it the alt text is the raw LaTeX source), an email as `\email{first.last@clemson.edu}`,
   and put `\caption` above the image or table: the tag tree always holds the caption first.
3. Build: `make -f Makefile.a11y`, not one editor pass (a single LuaLaTeX run prints `??` and leaves
   links empty; the `% !BIB` lines at the top of `main.tex` make TeXShop and VS Code run the cycle).
4. Check: `make -f Makefile.a11y check` (log, veraPDF), then Acrobat's checker and Clemson's [six
   manual checks](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html):
   color, link text, tags, reading order, tab order, alt text. `make -f Makefile.a11y requirements`
   tests the TeX install; `TARGET=paper` builds paper.tex.

## What main.tex shows

Contents, list of figures and list of tables, all tagged and linked; text with `\emph`, `\strong`,
a footnote, an endnote, links (`\href`, `\url`, a "(PDF)" document link, `\email`), citations and
cross-references (`\autoref`, `\pageref`, `\eqref`, `\hyperref[label]{...}`, `\cite[p.~3]{key}`);
bulleted, numbered, lettered, description and nested lists; a block quotation; reserved characters,
dashes, `\textsuperscript`, `\texttt`, `\textsc`; code. Mathematics with `\mathalt` spoken text:
inline and display, `align`, `subequations`, `gather`, `multline*`, matrices, cases, chemistry
(`\ce`), units (`\qty`, `\num`), bra-ket; theorem, lemma, corollary, proof, definition, example,
remark, algorithm. Figures with alt text, two panels, a `tikz` diagram, an image of text
(`actualtext`), a decorative image (`artifact`), a chart with its description and data table, a
picture described in an appendix and linked both ways, an artifact rule, a French phrase, an
abbreviation. Every table layout in Clemson's [tables
guide](https://www.clemson.edu/accessibility/digital/concepts/tables.html): header row, header
column, both, two-level and merged headers, merged cells, one table per group, title and note
outside, no empty cells, a layout grid with table tagging off (`longtable` tags its caption as a
cell, so split long tables). Appendix A.1, endnotes and a bibliography, all in the contents.

## Already have a Makefile or a class?

- Your own Makefile: keep it and run `make -f Makefile.a11y check` after your build, or copy the
  `check` target. No Makefile: rename `Makefile.a11y` to `Makefile`.
- Your own class (based on article/report/book): keep it; put the `\DocumentMetadata` block first and
  `\usepackage{clemsona11y}` last. If the class redefines the title page, sections or captions,
  check the result in Acrobat. A journal class (IEEEtran, revtex, elsarticle, ...) is not supported
  by LaTeX tagging yet: build the accessible copy with this class, submit with theirs.
- An existing paper: delete its `amsmath`, `amsthm`, `graphicx`, `float`, `fontspec`,
  `unicode-math`, `enotez`, `hyperref` and `\newtheorem` lines; the class loads them. Add alt text.

## Options

`\documentclass[report]{clemsona11y}` picks the base class (article, report or book); package
options go in the same brackets:

| Option | Values (default first) | Effect |
| --- | --- | --- |
| `fonts` | `termes`, `lm`, `false` | Times clone, Latin Modern, or your own fonts (Acrobat reports a spurious "cannot extract the embedded font" on the Latin Modern 17 pt title face; the file is valid) |
| `floats` | `here`, `free` | figures/tables stay where written, or float |
| `headings` | `word`, `kernel` | title = only H1 and sections H2 (Word style), or LaTeX default |
| `links` | `keep`, `hidden` | keep: black text, links underlined in running text by the viewer, contents entries plain but linked including page numbers; hidden: no marking |
| `align` | `ragged`, `justified` | left-aligned text (Clemson's rule), or justified |
| `math` | `af`, `full` | MathML attached to each formula (clean in Acrobat), or also as structure elements (PDF/UA-2 readers; Acrobat shows empty spacing tags) |
| `pagination` | `plain`, `typed` | untyped page-number artifacts, or `/Pagination` artifacts for PDF/UA-1 checkers (adds empty Artifact tags) |
| `title` | `h1`, `none` | tag the `\maketitle` title as the H1, or leave it to a class with its own title page |
| `theorems` | `true`, `false` | theorem, lemma, proposition, corollary, definition, example, remark, algorithm |

Other options (`11pt`, `a4paper`, ...) go to the base class; `twocolumn` is refused; a misspelt
value stops the build.

## Packages by field

| Use | Avoid | Why |
| --- | --- | --- |
| `unicode-math` (loaded), `amsthm` (loaded), `braket` | `amssymb`, `bm`, `thmtools`, `ntheorem`, `tikz-cd` | not tagged or clash with unicode-math |
| `mhchem`: write `$\ce{H2O}$` | `chemfig`, `chemformula`, `chemmacros`; `\ce{^{14}C}` | draw structures as images with alt text; the isotope form warns |
| `physics`, `siunitx` (not both) | `\qtyrange` | `\qty` clashes when both are loaded; `\qtyrange` loses its numbers in the alt text |
| `algpseudocode`; `verbatim`, `fancyvrb` | `listings`, `minted`, `algorithm2e`, `algorithm` | not tagged; the class defines the `algorithm` environment |
| `booktabs`, `tabularx` | `tabularray`, `nicematrix`, `multirow`, `caption`, `subcaption` | replace table or caption code; `\tagpdfsetup{table/multirow=2}` for row spans (inside `\multicolumn` when a cell spans both ways); keep `table/tagging=false` inside a group |
| `tikz` with `[alt={...}]` | `pgfplots` | export plots as images with alt text |
| `enotez` (loaded) | `endnotes` | `endnotes` marks carry no link to the note |
| `\UseTaggingSocket{inline/begin}{tag=Span,lang=fr-FR}` ... `{inline/end}` | `babel` | its language files are reported incompatible and write no `/Lang` |
| numbered `equation`, `gather`, `multline*` | numbered `multline` | raises a tagpdf structure-label warning |
| the expansion written into the text | `glossaries`, `acronym`, `makeidx` | untested; write the expansion on first use, set an index as a plain list |

Full status list: https://latex3.github.io/tagging-project/tagging-status/

## Workarounds, and what a LaTeX update does to them

The package works around five gaps in the LaTeX tagging code, each marked `A11Y WORKAROUND` with a
`REMOVE WHEN` line: header-cell IDs and direct cell attributes on tables, spoken alt text for
formulas, the footnote-mark link box, the `NoteType` attribute on footnotes, and the role mappings
that keep Acrobat's list rule quiet (caption numbers, contents numbers, footnote marks and labels as
`Span`). Each checks that the kernel piece it relies on still exists and otherwise does nothing and
writes a `Package clemsona11y Warning`; `make -f Makefile.a11y check` then fails and names it. After
`tlmgr update`, build `main.tex` once: a clean check means every workaround still works or is no
longer needed. Everything else uses documented interfaces only.

## What the checker will still say

Acrobat checks PDF/UA-1: it may show figure containers as "Note" (the PDF 1.7 fallback for
`Aside`), and its Tags panel shows the LaTeX names the role map turns into standard ones (`text` =
`P`, `text-unit` = `Part`, `item` = `LI`, `itemlabel` = `Lbl`, `itembody` = `LBody`, `quote` =
`BlockQuote`, `verbatim` = `Code`, `footnote` = `FENote`); do not rename them by hand. Known kernel
choices, all valid: `BBox` is written on figures only; `\ref`, `\pageref` and `\eqref` give a bare
`Link` and only `\cite` adds `Reference`; algorithm steps are tagged as an unordered list although
the labels are numbers; a nested list sits inside its parent item's body (`LBody` > `Part` > `P`,
`L`) rather than beside the parent `L`; `pagination=typed` adds an empty `Artifact` element per
header and footer, so the kit keeps `plain`. Link underlines come from the annotation border
style, which Acrobat draws and macOS Preview does not; the link text names its destination in every
viewer. Note text is 9 pt (8.97 pt as PDF tools measure) and raised marks 7 pt. veraPDF
`--flavour ua2` and `--flavour 4f` are authoritative.

# clemsona11y kit

LaTeX to accessible PDF in one folder. `clemsona11y.cls` and `clemsona11y.sty` do the work; the
output is a tagged PDF 2.0 that passes PDF/UA-2. `example.tex` is the worked example
of every kind of content, built by the rules in Clemson's
[accessibility concepts](https://www.clemson.edu/accessibility/digital/concepts/); `main.tex` is the
blank starter for your own document.

```
clemsona11y.cls  clemsona11y.sty  main.tex  example.tex  references.bib  README.md  Makefile.a11y  resources/
```

## Requirements

- TeX Live 2026 (MacTeX 2026 on macOS), updated with `sudo tlmgr update --self --all`
- LuaLaTeX (pdfLaTeX and XeLaTeX are refused: no MathML)
- `make` (macOS: the Xcode Command Line Tools, `xcode-select --install`; Windows: use WSL). Without
  it, `latexmk -lualatex main.tex` builds, but the checks below need `make`.
- [veraPDF](https://verapdf.org/software/), optional, for the automated PDF/UA-2 check;
  it needs Java, and the folder holding the `verapdf` script must be on PATH

## Quick start

1. **Edit `main.tex`.** Keep the `\DocumentMetadata{...}` block above `\documentclass`; replace the
   title, authors and content. Pictures go in `resources/` (only `\includegraphics` looks there;
   `references.bib` and `\input` files stay beside `main.tex`). To add a figure,
   a table, a formula or a note, find it in `example.tex` by its `%----` banner and copy the
   block (and its `\usepackage` line from the PACKAGES block, if it needs one).
2. **Tag as you write.**
   - Pictures: `\includegraphics[alt={what it shows}]{file}`; decorative ones get `artifact`.
   - Tables: `\tagpdfsetup{table/header-rows={1}}` and/or `table/header-columns={1}` before
     `\begin{tabular}`; `\caption` above the table.
   - Inside a figure or table: only `\centering`, `\includegraphics`, `tabular`, `\caption`, `\label`
     and `\tagpdfsetup`. A `center` environment, a list or `\[ \]` there stops the build; loose text
     drops out of the tags, so a source note goes in the caption or in a paragraph after the float.
   - Formulas: `\mathalt{spoken text}` right before each one, inline ones too.
   - Links: `\autoref{label}` for cross-references, `\email{name@clemson.edu}` for addresses.
3. **Build:** `make -f Makefile.a11y` builds `main.tex`. One editor pass is not enough (it prints
   `??` and leaves links empty). VS Code runs the whole cycle from the `% !TEX` and `% !BIB` lines at
   the top of `example.tex` (copy the `% !BIB` pair into `main.tex` once it cites something); TeXShop
   typesets once per click, so there run Typeset, BibTeX, Typeset, Typeset.
4. **Check:** `make -f Makefile.a11y check` runs what a script can verify (errors, alt text present
   in every `.tex` file the build read, tagging warnings, the package report, veraPDF PDF/UA-2) and
   then prints what only a person can judge: every alt text and every spoken formula to read over,
   structure, reading order, links, color. Finish in Acrobat Pro's accessibility checker (Reader
   cannot show tags or reading order) and Clemson's [six manual checks](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html).

`make -f Makefile.a11y example` builds and checks the worked example (`example.tex` -> `example.pdf`);
`make -f Makefile.a11y requirements` tests the TeX install; `TARGET=paper` builds `paper.tex`.

## What `example.tex` shows

| Area | Contents |
| --- | --- |
| Front and back matter | contents, list of figures, list of tables, appendix, endnotes, bibliography, all tagged and linked |
| Text | emphasis, footnote, endnote, links, citations, every cross-reference kind, lists (nested, lettered, description), block quote, special characters, code |
| Mathematics | inline and display math, `align`, `subequations`, `gather`, `multline*`, matrices, cases, chemistry, units, bra-ket, theorems, proofs, an algorithm; spoken alt text on every formula |
| Pictures | alt text, two panels, a `tikz` diagram, an image of text, a decorative image, a chart with its description and data table, a long description in an appendix linked both ways |
| Tables | every layout in Clemson's [tables guide](https://www.clemson.edu/accessibility/digital/concepts/tables.html): header row, header column, both, two-level and merged headers, merged cells, one table per group, notes outside, no empty cells, a layout grid left untagged |
| Odds and ends | an artifact rule, a phrase in another language, an abbreviation written out, QED as a proof ending (one line in the class) |

Every example sits under a `%----` banner line that labels it, so searching the source for `%----`
steps from one to the next, and each carries a short comment that says why it is written that way
and which standard it meets. `clemsona11y.cls` and `clemsona11y.sty` are divided the same way.

## Already have a project?

- **Your own Makefile:** keep it; run `make -f Makefile.a11y TARGET=paper check` after your build, or copy the
  `check` target. No Makefile: rename `Makefile.a11y` to `Makefile`.
- **Your own class** (article, report or book based): keep it; put the `\DocumentMetadata` block first
  and `\usepackage{clemsona11y}` last. Journal classes (IEEEtran, revtex, elsarticle, ...) are not
  supported by LaTeX tagging yet: build the accessible copy with this class, submit with theirs.
- **An existing paper:** delete its `amsmath`, `amsthm`, `graphicx`, `float`, `fontspec`,
  `unicode-math`, `enotez`, `hyperref` and `\newtheorem` lines; the class loads them. Add alt text.

## Options

`\documentclass[report]{clemsona11y}` picks the base class (article, report or book). Package options
go in the same brackets; a misspelt value stops the build.

| Option | Values (default first) | Effect |
| --- | --- | --- |
| `fonts` | `termes`, `lm`, `false` | Times clone, Latin Modern, or your own fonts |
| `align` | `ragged`, `justified` | left-aligned text (Clemson's rule) or justified |
| `links` | `keep`, `hidden` | black text with underlined links, contents entries plain but linked; or no marking |
| `math` | `af`, `full` | MathML attached to each formula; or also in the tag tree (empty spacing tags in Acrobat) |
| `floats` | `here`, `free` | figures and tables stay where written, or float |
| `headings` | `word`, `kernel` | title is the only H1 and sections start at H2, or LaTeX's own levels |
| `pagination` | `plain`, `typed` | plain page-number artifacts, or typed ones for PDF/UA-1 checkers |
| `title` | `h1`, `none` | tag the `\maketitle` title as H1, or leave it to a class with its own title page |
| `theorems` | `true`, `false` | theorem, lemma, proposition, corollary, definition, example, remark, algorithm |

## Packages by field

| Use | Avoid | Why |
| --- | --- | --- |
| `unicode-math`, `amsthm` (both loaded), `braket` | `amssymb`, `bm`, `thmtools`, `ntheorem`, `tikz-cd` | not tagged, or clash with unicode-math |
| `mhchem` (`$\ce{H2O}$`) | `chemfig`, `chemformula`, `chemmacros` | draw structures as pictures with alt text |
| `siunitx` or `physics` (not both) | `\qtyrange` | loses its numbers in the alt text |
| `algpseudocode`, `verbatim`, `fancyvrb` | `listings`, `minted`, `algorithm2e`, `algorithm` | not tagged; the class defines `algorithm` |
| `booktabs`, `tabularx` | `tabularray`, `nicematrix`, `multirow`, `caption`, `subcaption` | replace the table or caption code |
| `tikz` with `[alt={...}]` | `pgfplots` | export plots as pictures with alt text |
| `enotez` (loaded) | `endnotes`, `babel` | no link from mark to note; no language tag |
| `equation`, `gather`, `multline*` | numbered `multline` | tagging warning |
| the expansion in the text | `glossaries`, `acronym`, `makeidx` | untested with tagging |

Full list: <https://latex3.github.io/tagging-project/tagging-status/>. Row spans: `\tagpdfsetup{table/multirow=2}`
(inside the `\multicolumn` when a cell spans both ways); split long tables (`longtable` tags its caption as a cell).

## After a LaTeX update

The package works around five gaps in the tagging code (header-cell IDs and cell attributes, spoken
formula alt text, the footnote-mark link box, the footnote `NoteType`, and the `Span` mappings that
keep Acrobat's list rule quiet). Each is marked `A11Y WORKAROUND` with a `REMOVE WHEN` line, checks
that the kernel piece it needs still exists, and otherwise does nothing and writes a
`Package clemsona11y Warning`, which fails `make -f Makefile.a11y check`. After `tlmgr update`, build
`example.tex` once (`make -f Makefile.a11y example`): a clean check means every workaround still
works or is no longer needed.

## What the checkers still say

- **Acrobat** checks PDF/UA-1: figure containers may show as "Note" (the PDF 1.7 fallback for
  `Aside`), and the Tags panel shows LaTeX names that the role map turns into standard ones
  (`text` = `P`, `text-unit` = `Part`, `item` = `LI`, `itemlabel` = `Lbl`, `itembody` = `LBody`,
  `quote` = `BlockQuote`, `verbatim` = `Code`, `footnote` = `FENote`, `itemize`, `enumerate`,
  `description` and `list` = `L`). Do not rename them by hand.
  With `fonts=lm`, Acrobat reports "cannot extract the embedded font" on the 17 pt title face; the
  file is valid.
- **Kernel choices**, all valid: `BBox` only on figures; `\ref`, `\pageref` and `\eqref` give a bare
  `Link`, only `\cite` adds `Reference`; algorithm steps tag as an unordered list; a nested list sits
  inside its parent item's body; `pagination=typed` adds an empty artifact element per header and footer.
- **Viewers:** link underlines come from the annotation border style, which Acrobat draws and macOS
  Preview does not; the link text names its destination everywhere. Note text is 9 pt, raised marks 7 pt.

veraPDF `--flavour ua2` is authoritative.

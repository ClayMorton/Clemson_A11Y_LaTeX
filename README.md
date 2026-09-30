# clemson: accessible LaTeX in one package

`clemson.sty` makes LuaLaTeX write a tagged PDF that conforms to PDF/UA-2 and to
[Clemson's digital accessibility standard](https://www.clemson.edu/accessibility/).
`main.tex` is the starter, `example.tex` every kind of content with its source,
`Clemson_LaTeX_Accessibility_Talk.tex` the same examples as slides.

## Requirements

- [TeX Live 2026](https://www.tug.org/texlive/), then `sudo tlmgr update --self --all`. On Windows, TeX Live in WSL.
- [veraPDF](https://verapdf.org/) 1.30 or later on PATH.
- Adobe Acrobat Pro for the checks by hand.
- Overleaf: LuaLaTeX and Rolling TeX Live.

## Quick start

Copy the folder and write in `main.tex`, or drop `clemson.sty` next to an existing document and
put these lines at the top:

```latex
% !TEX program = lualatex
% !TEX TS-program = lualatex
\DocumentMetadata{
  lang          = en-US,
  pdfstandard   = {ua-2,a-4f},
  tagging       = on,
  check-tagging-status,
}
\documentclass{article}
\usepackage{booktabs}          % your packages
\usepackage{clemson}           % after your packages
\graphicspath{{resources/}}
\title{Title of the document}
\author{First Author \and Second Author}
```

Build: `latexmk -lualatex main.tex`. `report` gives chapters. `cleveref` goes after the package.

## What you write

1. `alt={...}` on every `\includegraphics` and `tikzpicture`; `actualtext={...}` for a picture
   of text; `artifact` for decoration.
2. `\tagpdfsetup{table/header-rows={1}}` or `table/header-columns={1}` on the line before
   `\begin{tabular}`; `\tagpdfsetup{table/multirow=2}` at the start of a cell that spans rows.
3. `\section`, `\subsection`, `\subsubsection` in order; no `[htbp]` on floats.

Everything else is plain LaTeX. `example.tex` shows each case under a `%----` banner.

## Packages

Look up supported packages at <https://latex3.github.io/tagging-project/tagging-status/>

## Checking

```
verapdf --flavour ua2 --format text main.pdf
grep -n -A2 '^!\|tagpdf Warning\|Package clemson\|Alternative text' main.log
```

Then [Clemson's checks by hand](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html)
in Acrobat Pro: alt text says what and why; one H1 and no skipped level; every table's header
cells declared; link text names the destination; nothing said by color alone.

Acrobat's checker tests PDF/UA-1 and reports "Lbl and LBody" for caption numbers, theorem
numbers and note marks. That is a false positive; veraPDF passes.

## What the package does

- Stops the build when tagging is off.
- Puts every formula's MathML in the tag tree.
- Tags the title as the only H1, every heading one level down, the abstract as a Sect with an H2.
- Keeps every figure and table where it is written, caption first.
- Writes Scope and Headers on every table cell.
- Underlines every link but contents entries and note marks; no viewer boxes.
- Tags footnotes as notes; endnotes with links both ways; foreign phrases with their language.
- Sets the text ragged right; notes at 9 pt.

## Commands and settings the package defines or changes

New:

- `\email{address}`: a mailto link whose text is the address.
- Environments `theorem`, `lemma`, `proposition`, `corollary`, `definition`, `example`, `remark`
  and `algorithm`, unless the preamble defines them; each has its `\autoref` name.
- Option `justified`: keeps LaTeX's justified text.

Changed:

- `proof` ends with the word QED (`\renewcommand{\qedsymbol}{\openbox}` after the package brings
  the square back).
- `abstract` (article, report): the class's layout inside a Sect with an H2 and a bookmark.
- `\footnotesize` is `\small`.
- `\raggedright` at `\begin{document}`, with the class's `\parindent` and `\\` kept.
- Float placement `H` for `figure` and `table`.
- hyperref: `pdfborder={0 0 0}`; `\strong` allowed in bookmarks.
- enotez: `backref`, an enumerate list, roman marks, a "Notes" heading.
- babel: loaded without options; the main language comes from `lang`.
- tagpdf: `math/setup=mathml-SE`, `float/here`, heading roles one level down, the title plug,
  the table finalize plug, NoteType on footnotes; in ltx-talk the title page tags (H1) and the
  `frametitle` role (H2, or H3 under `\section`).
- Kernel hooks only, no command redefined; `\RemoveFromHook{<hook>}[clemson]` drops a chunk.
  Every workaround in `clemson.sty` has a `REMOVE WHEN` line; after a LaTeX update, build
  `example.tex` and search the package for `REMOVE WHEN`.

## Presentations

`beamer` cannot be tagged; use [ltx-talk](https://ctan.org/pkg/ltx-talk) with the same
`\DocumentMetadata` block and `\usepackage{clemson}`. The package tags the title H1 and frame
titles H2 (H3 under `\section`). `\pause` is fine: only a frame's last slide is tagged.
`Clemson_LaTeX_Accessibility_Talk.tex` is a worked deck; its look uses the class's own templates.

## References

- [Clemson Digital Accessibility](https://www.clemson.edu/accessibility/)
- [LaTeX tagging project](https://latex3.github.io/tagging-project/)
- [veraPDF](https://verapdf.org/)
- [PDF Association best practice guides](https://pdfa.org/resources/)

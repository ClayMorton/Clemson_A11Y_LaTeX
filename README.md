# clemson: accessible LaTeX in one package

`clemson.sty` makes LuaLaTeX write a tagged PDF that conforms to PDF/UA-2 and to
[Clemson's digital accessibility standards](https://www.clemson.edu/accessibility/).
`main.tex` is the starter, `example.tex` every kind of content with its source,
`Clemson_LaTeX_Accessibility_Talk.tex` the same examples as slides, which is also
accessible, and can be used as a template accessible presentation in LaTeX.

## Requirements

- [TeX Live 2026](https://www.tug.org/texlive/), then `sudo tlmgr update --self --all`. On Windows, TeX Live in WSL.
- Adobe Acrobat Pro for the checks by hand (Known false positive as of 10/2/26: Lbl body check
is failed but is actually compliant, so this is an acrobat issue).
- Overleaf: LuaLaTeX and Rolling TeX Live.

## Quick start

Copy the folder and write in `main.tex`, or drop `clemson.sty` next to an existing document and
put these lines at the top of your main .tex file of your project. MAKE SURE that these are
the first lines of the whole document, the magic comments will not work otherwise:

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
\usepackage{booktabs}          % your packages (check supported pacakges!)
\usepackage{clemson}           % after your packages
\graphicspath{{resources/}}
\title{Title of the document}
\author{First Author \and Second Author}
```

Build: `latexmk -lualatex main.tex`. You can also use VSCode "save to build" settings,
and it should work properly as well.

## What you need to write

1. `alt={...}` on every `\includegraphics` and `tikzpicture`; `actualtext={...}` for a picture
   of text; `artifact` for decoration.
2. `\tagpdfsetup{table/header-rows={1}}` or `table/header-columns={1}` on the line before
   `\begin{tabular}`; `\tagpdfsetup{table/multirow=2}` at the start of a cell that spans rows.
3. `\section`, `\subsection`, `\subsubsection` in order.
4. We're using default `[H]` settings on all figures and tables, please REMOVE any 
other tags you may have on yours IF you're importing this into an existing project.

See the code in `example.tex` for all of these things and more! Each example is under a `%----` 
banner for ease of searching.

## Supported Packages

Look up supported packages at <https://latex3.github.io/tagging-project/tagging-status/>

## Checking

See the things you need to check using [Clemson's manual check guide](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html)

Acrobat's checker tests PDF/UA-1 and reports "Lbl and LBody" for caption numbers, theorem
numbers and note marks. That is a false positive in Acrobat, do not worry about that.

## Commands and settings the package defines or changes

**New:**

- `\email{address}`: a mailto link whose text is the address.
- Environments `theorem`, `lemma`, `proposition`, `corollary`, `definition`, `example`, `remark`
  and `algorithm`, unless the preamble defines them; each has its `\autoref` name.
- Option `justified`: keeps LaTeX's justified text.

**Changed behaviors:**

- `proof` ends with QED (`\renewcommand{\qedsymbol}{\openbox}` after the package brings
  the square back if you prefer).
- `abstract` (article, report): the class's layout inside a Sect with an H2 and a bookmark.
- `\footnotesize` is `\small`.
- `\raggedright` at `\begin{document}`.
- Float placement set to `H` for `figure` and `table`.
- hyperref: `pdfborder={0 0 0}`.
- Strong: `\strong` is tagged as Strong (use in place of `\textbf` for screen reader purposes).
- tagpdf: `math/setup=mathml-SE`, `float/here`, heading roles one level down, the title plug,
  the table finalize plug, NoteType on footnotes; in ltx-talk the title page tags (H1) and the
  `frametitle` role (H2, or H3 under `\section`).
- Kernel hooks: `\RemoveFromHook{<hook>}[clemson]` drops a chunk.


Every workaround in `clemson.sty` has a `REMOVE WHEN` line so that after a LaTeX update, 
parts of the package can be removed as the kernel will now contain the fixes. Some
changes have active issue numbers linked, so upon resolution, the fix can be removed from
the package.

## Presentations

`beamer` cannot be tagged properly, use [ltx-talk](https://ctan.org/pkg/ltx-talk) with the same
`\DocumentMetadata` block and `\usepackage{clemson}`. The package tags the title H1 and frame
titles H2 (H3 under `\section`). `\pause` is fine: only a frame's last slide is tagged (that's neat!).
`Clemson_LaTeX_Accessibility_Talk.tex` is a worked deck, where its look uses the class's own templates,
you can change the colors if you would like using the top block, just make sure you fit the contrast
requirements.

## References

- [Clemson Digital Accessibility](https://www.clemson.edu/accessibility/)
- [LaTeX tagging project](https://latex3.github.io/tagging-project/)
- [PDF Association best practice guides](https://pdfa.org/resources/)

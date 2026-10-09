# The Clemson LaTeX Package

The Clemson package `clemson.sty` makes LuaLaTeX write an accessible PDF,
provided you follow the set of rules that the package enforces, and meet the
requirements laid out in [Clemson's digital accessibility concepts](https://www.clemson.edu/accessibility/digital/concepts/).

## Files provided

- `main.tex` is a good starting place for your accessible document.
- `example.tex` is a worked version of commonly used tools and layouts that you can
compile into an accessible PDF and see the source code for, so you can replicate
things as needed.
- `Clemson_LaTeX_Accessibility_Talk.tex` is a worked presentation file that has
almost all the `example.tex` examples, but in presentation form. This is a good
starting place for your own accessible presentation.

*Note:* See the comments inside `example.tex` and 
`Clemson_LaTeX_Accessibility_Talk.tex` for customizations to the package and the
presentation to fit your needs.

## Requirements

- [TeX Live](https://www.tug.org/texlive/) for windows/linux or 
[MacTex](https://www.tug.org/mactex/mactex-download.html) if you're on MacOS.
- Adobe Acrobat Pro for hand checking your document after PDF conversion.

*Note:* Overleaf is a safe alternative if you prefer browser-based LaTeX.

## Starter Guide

1. Copy the folder and write your `main.tex`, or you can copy `clemson.sty` into an
existing project.
2. Use `sudo tlmgr update --self --all` to update your packages. Lots of
packages are being updated to support tagging, so this keeps you up to date.
3. **MAKE SURE** these are the first lines of your document. The magic comments
should be on line 1 of your document:

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

\usepackage{booktabs}          % your packages (check supported packages!)
\usepackage{clemson}           % ALWAYS after your packages

\graphicspath{{resources/}}

\title{Title of the document}
\author{First Author \and Second Author}
```

If you're using a `.bib` file, add these two line after the magic comments 
(`% !TEX...`) and before the document metadata tag.

```latex
% !BIB program = bibtex
% !BIB TS-program = bibtex
```

4. Write your LaTeX! There are a few new commands we provide, and some other
changes to what you're likely used to writing, so we recommend reading through
the example documents before getting too far.

5. Build using `latexmk -lualatex <your_main_file>.tex`

## Changes to the Way You Write

You'll need to do a few things you're not used to so you can be successful in 
authoring an accessible document using our package. These are the things you
may not be used to doing:

### Adding Alt Text

1. `alt={...}` on every `\includegraphics` and `tikzpicture`.
2. `actualtext={...}` for a picture of text.
3. `artifact` for decorative images.

### Marking Headers in Tables

1. `table/header-columns={1}` on the line before `\begin{tabular}`
2. `\tagpdfsetup{table/multirow=2}` at the start of a cell that spans rows.

### Proper Section/Subsection/... Structure
1. `\section`, `\subsection`, `\subsubsection` should always be written in 
order. **DO NOT** skip from `\section` to `\subsubsection`, use a logical 
ordering instead.


*Note:* IF you're importing this into an existing project, please know, we're 
using default `[H]` settings on all figures and tables, so you'll need to REMOVE
any other tags you may have on yours, so that the PDF can be properly generated.

See the code in `example.tex` for all of these things and more! Each example is under a `%----` 
banner for ease of searching.

## Supported Packages

You may require a package we don't import, but before using another package,
please check its support status on the tagging project's page. Look up supported
packages at [the LaTeX Tagging Project](https://latex3.github.io/tagging-project/tagging-status/).

## Checking Your PDF

See the things you need to check using [Clemson's manual check guide](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html)

*Note:* You can ignore Acrobat's checker report for "Lbl and LBody" being wrong.

## New Commands

- `\email{address}`: a mailto link whose text is the address.
- `\begin{<something>}` supports: `theorem`, `lemma`, `proposition`, `corollary`, `definition`, 
`example`, `remark` and `algorithm`, are all provided unless your preamble 
redefines them, and they each have their own `\autoref` name as well.
- Option `justified`: keeps LaTeX's justified text.

## Changed behaviors

- `proof` ends with QED (you can get the square back by using 
`\renewcommand{\qedsymbol}{\openbox}` after the package, if you prefer).
- Float placement set to `H` for all `figure` and `table` structures.
- `\strong` is used in place of `\textbf` for screen reader purposes.

## References

- [Clemson Digital Accessibility](https://www.clemson.edu/accessibility/)
- [LaTeX tagging project](https://latex3.github.io/tagging-project/)
- [PDF Association best practice guides](https://pdfa.org/resources/)


**DISCLAIMER: We cannot guarantee the compliance of your project simply by using the package, you still need to write your own alt text and turn on the proper tagging structure inside your preamble. It is also your responsibility to check any extraneous packages you use for compatibility and support by the tagging project.**
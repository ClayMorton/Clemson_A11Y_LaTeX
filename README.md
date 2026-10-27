# The Clemson LaTeX Package

The Clemson package `clemson.sty` helps ensure LuaLaTeX outputs an accessible PDF,
provided you follow accessibility best practices and the rules that the package
enforces. For an overview of accessibility standards and fundamentals, view Clemson's
[digital accessibility guide](https://www.clemson.edu/accessibility/digital/concepts/).

## Files Provided

- `clemson.sty` is the Clemson LaTeX package. This package helps ensure LuaLaTeX
can output an accessible PDF, with minimal changes to the way you write your code.
- `main.tex` is a good starting place for your accessible document.
- `example.tex` is a sample of commonly used tools and layouts that you can compile
into an accessible PDF. Review the source code, and replicate patterns as needed.
- `presentation.tex` is a sample presentation file that includes most of the
`example.tex` examples, but in presentation form. This is a good starting place
for your own accessible presentation.

*Note:* See the comments inside `example.tex` and `presentation.tex` for
customizations to the package and the presentation to fit your needs.

## Requirements

Ensure you have the latest version of [TeX Live](https://www.tug.org/texlive/)
for Windows/Linux or [MacTex](https://www.tug.org/mactex/mactex-download.html)
for MacOS. The LuaLaTeX compiler is required.

Ensure all packages are updated, e.g., `sudo tlmgr update --self --all`.

Alternatively, Overleaf supports compiling accessible PDFs.

## Supported Packages

The [LaTeX Tagging Project](https://latex3.github.io/tagging-project/tagging-status/)
identifies PDF tagging support for over 2,000 packages and classes. Ensure packages
you use are supported.

## Starter Guide

Copy the folder and write your `main.tex`, or you can copy `clemson.sty` into an
existing project.

Enforce the LuaLaTeX compiler using the magic comments below. The `\DocumentMetadata`
command **must** be present at the beginning of the preamable.

```latex
% !TEX program = lualatex
% !TEX TS-program = lualatex
\DocumentMetadata{
  lang          = en-US,
  pdfstandard   = {ua-2,a-4f},
  tagging       = on,
  check-tagging-status,
}

% The above command must be present.

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

Write your LaTeX! There are a few new commands we provide, and some other
changes to what you're likely used to writing, so we recommend reading through
the example documents before getting too far.

Compile using LuaLaTeX, e.g., `latexmk -lualatex <your_main_file>.tex`.

### Changes to the Way You Write

You'll need to do a few things you're not used to so you can be successful in 
authoring an accessible document using our package.

#### Provide Heading Structure

Use `\section`, `\subsection`, `\subsubsection` to provide a heading structure
for your documents. Avoid skipping sections.

#### Add Alt Text to Images

- Include `alt={...}` on every `\includegraphics` and `tikzpicture`.
- Include `actualtext={...}` for a picture of text.
- Include `artifact` for decorative images.

#### Avoid Floating Figures

When positioning figures and tables, this package uses the default `[H]` placement
option to ensure reading order. Other placement options are not allowed.

#### Identify Table Headers and Cell Spans

1. Include `table/header-columns={1}` on the line before `\begin{tabular}`
2. Include `\tagpdfsetup{table/multirow=2}` at the start of a cell that spans rows.

See `example.tex` for other examples of complex tables.

### Checking Your PDF

Visit the [PDF Guide](https://www.clemson.edu/accessibility/digital/guides/pdf/) for
details on checking PDF accessibility.

*Note:* Adobe Acrobat may flag an error regarding "Lbl and LBody". This error
can safely be ignored.

### New Commands

- `\email{address}`: a mailto link; text is the email address.
- `\begin{<something>}` support: `theorem`, `lemma`, `proposition`, `corollary`, `definition`, 
`example`, `remark` and `algorithm` are defined by the package. Each have their own
 `\autoref` name.

### Changed Behaviors

- Text is left-aligned by default. Use package option `justified` to revert to justified text.
- `proof` ends with QED. Use `\renewcommand{\qedsymbol}{\openbox}` after the package
to revert to the open box symbol.
- Float placement set to `H` for all `figure` and `table` structures.
- `\strong` is used in place of `\textbf`.

## References

- [Clemson Digital Accessibility](https://www.clemson.edu/accessibility/)
- [LaTeX Tagging Project](https://latex3.github.io/tagging-project/)
- [PDF Association Best Practice Guides](https://pdfa.org/resources/)
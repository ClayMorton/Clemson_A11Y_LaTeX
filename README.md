# clemson: accessible LaTeX in one package

A tagged PDF carries, besides the printed page, a tree that names what each part of the document
is: title, headings, paragraphs, lists, tables, pictures with alt text, formulas. A screen reader
follows that tree. ISO 14289-2:2024 (PDF/UA-2) is the standard for accessible PDF 2.0 files, and
LaTeX 2026-06-01 writes such files itself once tagging is turned on. This folder holds what a
Clemson author needs to do that:

```
clemson.sty  main.tex  example.tex  references.bib  README.md  Makefile.a11y  resources/
```

`clemson.sty` is the package. `main.tex` is the starter to write in. `example.tex` is the worked
example: every kind of content, tagged, with a comment on each block that says why it is written
that way and which clause it meets; comment lines that start with `%----` name the blocks. It
cites `references.bib` and shows the pictures in `resources/`. `Makefile.a11y` builds and checks
either document. The package needs LuaLaTeX and LaTeX 2026-06-01 or newer and stops otherwise.

## What you need

Install these first, in this order. Type the commands in a terminal (on a Mac, Terminal in
Applications > Utilities). `sudo` asks for your Mac password and shows nothing while you type it.

1. **TeX Live 2026** (MacTeX 2026 on a Mac), from [tug.org/texlive](https://tug.org/texlive/).
   `lualatex --version` prints the year of an installed TeX Live at the end of its first line; an
   older year cannot be upgraded in place, so install 2026 next to it. Then update it, because
   the package needs the June 2026 LaTeX release:

   ```
   sudo tlmgr update --self --all
   ```

   On Windows, work inside WSL (Ubuntu). There and on Linux, install TeX Live 2026 with the
   installer from tug.org, not with `apt`, whose TeX Live is years too old.

2. **Java and veraPDF** (optional). veraPDF checks a PDF against the PDF/UA-2 rules a program can
   check; without it the check skips that step and says so. Install a Java runtime (for example
   Temurin from adoptium.net), run the installer from [verapdf.org](https://verapdf.org/software/)
   and add its folder to your PATH (on a Mac, an `export PATH=...` line in `~/.zshrc`). The check
   needs a version that accepts `--flavour ua2`; 1.30 does.

3. **make** (optional). On a Mac it comes with the Xcode Command Line Tools
   (`xcode-select --install`); on Ubuntu and in WSL, `sudo apt install make`.

4. **Adobe Acrobat Pro** for the part of the check done by hand. The free Acrobat Reader cannot
   show tags or reading order.

Overleaf: choose the LuaLaTeX compiler and the Rolling TeX Live option in the compiler settings.
The tagging project's usage instructions (dated 2026-06-11) say Overleaf then offered LaTeX
2025-11-01, that 2026 support was expected, and that a `latexmkrc` file with the four lines they
give (`$max_repeat = 1;`, `$force_mode = 1;`, and `$pdflatex` and `$lualatex` set to the `-dev`
engines with `-synctex=1 -interaction=nonstopmode`) builds with the development release instead.
Either way, confirm `LaTeX2e <2026-06-01>` or later on the first line of the log.

## Quick start

Copy the folder, rename it after the project, and write in `main.tex`. Its first lines are the
ones every accessible document needs:

```latex
% !TEX program = lualatex
% !TEX TS-program = lualatex
\DocumentMetadata{
  lang          = en-US,
  pdfstandard   = ua-2,
  tagging       = on,
  tagging-setup = {math/setup={mathml-SE,mathml-AF}},
  check-tagging-status,
}
\documentclass{article}
\usepackage{graphicx}          % your packages
\usepackage{clemson}           % last
\title[pdftitle={{Title of the document}}]{Title of the document}
\author[pdfauthor={First Author, Second Author}]{First Author and Second Author}
```

The two `% !TEX` lines tell VS Code, TeXShop and other editors to use LuaLaTeX, the one engine that
writes MathML. `\DocumentMetadata` goes above `\documentclass`. `lang` is the language of the whole
PDF (ISO 14289-2:2024 8.4.4). `pdfstandard=ua-2` declares PDF/UA-2, the standard veraPDF tests.
`tagging=on` turns tagging on; without it LaTeX writes an untagged PDF for `pdfstandard=ua-2` and
says nothing, which is why the package stops instead. `tagging-setup` writes the MathML of every
formula as structure elements and as an attached file (see "Mathematics"). `check-tagging-status`
appends a report on the loaded packages to the log. Use `report` for chapters (`\chapter` is H1,
`\section` H2); `book` works too but has no abstract. `\usepackage{clemson}` comes last, because it
loads hyperref, which must follow every other package. `pdftitle` and `pdfauthor` set the metadata
a screen reader announces when the file opens (ISO 14289-2:2024 8.11); the doubled braces keep a
comma in the title from splitting it, and the names in `pdfauthor` are separated by commas.

Build with `latexmk -lualatex main.tex` or `make -f Makefile.a11y`; check with
`make -f Makefile.a11y check` or `verapdf --flavour ua2 main.pdf`. `latexmk` repeats LuaLaTeX and
BibTeX until every reference and link is resolved; a single run leaves `??` in the text and
formulas without MathML, and `main.tex` says how VS Code and TeXShop run the extra passes. For a
file with another name add `TARGET=name` (no `.tex`) to each `make` line.

What the package does: it stops the build unless LuaLaTeX, LaTeX 2026-06-01 or newer and
`\DocumentMetadata` with tagging are in use; loads unicode-math, so every formula gets MathML; tags
`\strong` as Strong; keeps each figure and table in the tag tree where it is written; keeps the
MathML attached when the file name holds a comma; tags babel's language switches when babel is
loaded; and loads hyperref with black underlined links. What it cannot do for you: the `% !TEX`
line, the `\DocumentMetadata` block, `alt={...}` on every picture, and the header rows or columns
of every table. Everything else is LaTeX's own tagging, and the package has no options. The next
section gives, for each kind of content, the rule, the reason and the `%----` banner in
`example.tex` that shows it.

## Writing the document

### Headings and title

LaTeX tags the printed title as the PDF 2.0 Title element, not as a heading, and `\section` as H1,
`\subsection` as H2 and `\subsubsection` as H3; in `report` and `book`, `\chapter` is H1 and the
rest move down one level. Use them in order and never skip a level: veraPDF has no rule on skipped
levels, but Acrobat's checker and WCAG 2.1 technique G141 expect H1 then H2. The title is not an
H1 because a document title is not a heading, and PDF 2.0 added Title for it (Tagged PDF BPG 1.0.1
4.2.2.2). `\section*[Acknowledgments]{Acknowledgments}` gives a starred heading a contents entry
and a bookmark (a kernel key; `toc=` and `bookmark=` set the two texts separately). The `article`
abstract is tagged BlockQuote with "Abstract" as a plain paragraph (tagging-project issue 1327 is
open). Block: TITLE, ABSTRACT, CONTENTS.

### Pictures

Every informative picture needs `alt={...}`; a picture of words, such as a logo, takes
`actualtext={the words}`; a decoration takes `artifact` and is skipped (ISO 32000-2:2020
14.8.4.8.5, 14.9.4; WCAG 2.1 1.1.1, 1.4.5). A `tikzpicture` takes the same keys and warns about
nothing when they are missing, so check every drawing yourself. Write alt text as if describing
the picture to a friend, in one or two sentences: what it shows and why it is in the document; do
not repeat the caption, which the reader hears anyway, and do not describe the file. Clemson's
pattern for people is "[name] and [name] [action] [location]". A chart or diagram gets a short
alt that states its point and says where the full description is, then the description in the
text or in a data table. Inside the braces, type `\%`, `\#`, `\$`, `\&`, `\_`, `\{` and `\}` with
a backslash (a bare `%` stops the build); type accents, quotation marks and dashes as the real
characters, since `` `` '' `` and `--` are written as typed; `~` becomes a space, and
`\textbackslash` lands as its own name, so write the word instead. Banners: "Picture with alt
text" through "Long description in appendix".

### Tables

Declare the header cells on the line before `\begin{tabular}`, inside the `table` environment so
the setting ends with it: `\tagpdfsetup{table/header-rows={1}}`, `table/header-columns={1}` or
both. The cells become TH with a Scope of Column, Row or Both (ISO 32000-2:2020 14.8.4.8.3).
Header rows are the top rows and header columns the leftmost ones; a group row in the middle of a
table is not supported, so keep one table per group, as Clemson's tables guide asks.
`\multicolumn` needs nothing. A cell that spans rows starts with `\tagpdfsetup{table/multirow=2}`
(at the start of the row for a first-column cell, or inside the braces of `\multicolumn`; placed
before `\multicolumn` it aborts the build), and the covered cells stay empty; the `multirow`
package is listed incompatible. `longtable` is listed compatible but tags its caption as a table
cell. A `tabular` kept for layout goes inside a group with
`\tagpdfsetup{table/tagging=presentation}` (the tagging project's choice for a layout table) or
`=div`; `=false` suits only `l`, `c` and `r` columns, and any of the three left open changes the
tables that follow. LaTeX writes Scope as attribute classes, which veraPDF checks; Acrobat's Table
Editor shows "scope none" for them (tagging-project issue 1324), and Acrobat's checker reports a
presentation table under its Headers rule. Banners: the eight "Table:" blocks.

### Figures and tables in the text

LaTeX tags each `figure` and `table` as an Aside whose first child is the Caption, but by default
it defers those structures to the end of the tree, its choice for PDF 1.7 readers that show an
Aside as a Note. The package sets `float/here`, so each structure stays where the float is
written, next to the text that cites it (WCAG 2.1 1.3.2; Tagged PDF BPG 1.0.1 3.7). To print
floats where they are written as well, copy
the five `float` lines from the PACKAGES block of `example.tex`: `\usepackage{float}`, two
`\floatplacement` lines and two `\AddToHook{env/.../begin}{\par}` lines. The `\par` lines end the
paragraph before an `[H]` float; without them an `[H]` float right after a list or a displayed
formula writes its Caption outside the float, which veraPDF reports under 8.2.5.27 with no
warning from LaTeX. Put `\caption` above the picture or tabular, because the Caption is written
first either way. Leave a blank line before a theorem, proof or other theorem-like block that
follows a list, a displayed formula or a `quote`, `center` or `verbatim` environment; without it
the build stops with "text para hooks differ" (tagging-project issues 1402 and 1415).

### Lists

`itemize`, `enumerate` and `description` are tagged L, with Lbl and LBody for each item (ISO
32000-2:2020 14.8.4.8.2). Lettered items come from the kernel's own key,
`\begin{enumerate}[label=(\alph*)]`; the `enumitem` package cannot be loaded under tagging, but
its syntax is built in. Each item body holds its text as `LBody > Part > P`; that form is valid
(ISO 32000-2:2020 Annex L) and veraPDF accepts it. Keep nesting to two levels. Banner: "Lists".

### Mathematics

LaTeX tags every formula as a Formula and writes its MathML itself, which is what ISO 14289-2:2024
8.2.5.29.1 asks; the package loads unicode-math so that happens on LuaLaTeX. The MathML is written
on the first run and read back on the next, so a document needs two runs; `latexmk` does that, and
the log ends with `==> N math fragments found` and `==> N MathML AF attached`, which must match.
The `math/setup` key in `\DocumentMetadata` chooses the form: `mathml-SE` puts the MathML into the
tag tree as structure elements, `mathml-AF` attaches it as a file. The tagging project's screen
reader recordings show Acrobat with NVDA reading the structure elements, and Foxit with NVDA and
Firefox with NVDA or JAWS reading the attached file; no recording shows the reverse. With no key
LaTeX attaches the file only, and the project's usage instructions show `mathml-SE`; the kit asks
for both so that every recorded viewer reads the same MathML from one file. Two known warnings
under `mathml-SE`: a numbered `multline` reports "structure with label 0 is unknown" (issue 1407;
use `multline*`), and an mhchem prescript such as `\ce{^{14}C}` reports a reused label (issue
793; write it out in words). `\MathMLintent{mean($x)}{{...}}` and `\MathMLarg{x}{...}` name what
a formula means (Math in PDF BPG 1.0 p. 15); keep the double braces, because a scripted single
atom loses the intent silently. Write `\symbf{v}`, `\symbfit{v}` and `\symcal{A}` for bold and
script letters; `bm` does not work with unicode-math, and `amssymb` loaded after the package stops
the build (load it before the package if a command name is missing). A file name with a comma
makes LaTeX split the list of MathML files and drop every formula's MathML; the package resets
the list in that case. Banners: "Inline and display math" through "Chemistry, units, bra-ket".

### Theorems and proofs

Load `amsthm` for `\theoremstyle` and `proof` and write `\newtheorem` lines as in any document.
LaTeX tags each theorem, lemma and proof as a theorem-like block, role-mapped to Sect, with its
head as a Caption and its number as a Lbl (ISO 32000-2:2020 14.8.4.8.4; Tagged PDF BPG 1.0.1
4.2.4). amsthm's open
square at the end of a proof announces nothing; `\renewcommand{\qedsymbol}{\textup{QED}}` ends
proofs with a word instead, which is optional, since the block's end is conveyed by the structure.
`\autoref` prints only the number for an environment on a shared counter; write
`\hyperref[lem:x]{Lemma~\ref*{lem:x}}` or define `\lemmaautorefname`. Banner: "Theorems and
algorithm".

### Footnotes and endnotes

`\footnote{...}` is all LaTeX needs: the note is tagged FENote, the mark is a Lbl holding the link,
and the tree cross-references mark and note (Ref) both ways, which PDF/UA-2 asks for (veraPDF
rules 8.2.5.14). With the default `10pt` option footnote text is 8 pt; Clemson's text concept says
to avoid sizes under 9 points, and the `11pt` class option gives 9 pt notes with 11 pt body text.
LaTeX has no endnote support. `enotez`, listed partially compatible, gives a link both ways and a
tagged list; the PACKAGES block of `example.tex` configures it. The `endnotes` package gives no
link from mark to note. Banners: "Emphasis, footnote, endnote" and the FOOTNOTE AND ENDNOTE block.

### Links and bookmarks

The package loads hyperref last, so every `\ref`, `\cite`, `\href`, `\url` and contents entry is a
link annotation inside a Link or Reference element with a structure destination, and every page
has a structure tab order (ISO 14289-2:2024 8.2.5.20, 8.8, 8.9.3.3). Link text stays black and the
underline comes from the annotation's border style, so no link is marked by color alone (WCAG 2.1
1.4.1); viewers differ in whether they draw it, and the link text names the destination in every
viewer. `\hypersetup{hidelinks}` after the package removes it. Name the destination in the link
text, never "click here"; give an email address as its own link,
`\href{mailto:name@clemson.edu}{name@clemson.edu}`. `\autoref{sec:x}` links the whole phrase and
prints "section 2"; `\renewcommand*\sectionautorefname{Section}` capitalizes it. The headings of
`\tableofcontents`, `\listoffigures` and `\listoftables` get no bookmark; write
`\pdfbookmark[1]{\contentsname}{toc}` on the line before, level 1 in `article` and in `report`,
and add `\clearpage` first only in `report` or `book`, where the heading starts a new page.
Banners: "Links, citations", "Cross-references".

### Language

`lang=en-US` in `\DocumentMetadata` sets the language of the whole PDF, which is all PDF/UA-2
checks. WCAG 2.1 3.1.2 also wants each phrase in another language marked (ISO 32000-2:2020
14.9.2), and babel hyphenates but writes no such tag. So write `\usepackage[french]{babel}` with
the other languages only (the main one comes from `lang`; repeating it as an option earns a
warning), and the package's LANGUAGES block does the rest: its hooks wrap every `\foreignlanguage`
phrase in a Span with its language and give every `otherlanguage` block or `\selectlanguage`
switch its language through tagpdf's `text/lang` key. The recipe comes from babel discussion 357
and the tagging project's max-moritz example; a later babel or tagpdf release may write the tag
itself, and the block says when it can go. The main language gets no tag of its own, since the
catalog `Lang` already names it, so an English document with one French phrase carries a language
tag on that phrase only. With these hooks `\foreignlanguage` holds one paragraph at most; longer
passages go in `otherlanguage`, with a blank line before `\begin{otherlanguage}` and after
`\end{otherlanguage}`, or the neighboring English paragraph joins the block. A heading inside the
block gives its whole section the block's language, so keep such a section inside the block up to
the next heading. To switch back by hand, use the main language's babel name, which the log prints
in its "Passing ... to babel" line (`american` for `en-US`). Without babel, the kernel's inline
socket tags a phrase:
`\UseTaggingSocket{inline/begin}{tag=Span,lang=fr}` ... `{inline/end}`. polyglossia is not
supported by the package; it writes no tag either, and the kernel's `cmd/` and `env/` hooks with a
hand-written tag are the way to tag it. The check lists `french.ldf` as incompatible; that entry
is stale (issue 932, closed in May 2026). Banner: "Rule, language, abbreviation, color".

### Code

`\verb` text is tagged Code and each line of a `verbatim` block is a code line (Sub in PDF 2.0),
which PDF/UA-2 accepts (ISO 32000-2:2020 14.8.6.1; Tagged PDF BPG 1.0.1 4.2.11). A screen reader
reads the characters at the listener's symbol level: NVDA skips a backslash and braces at its
default level and speaks them at "most" or "all". `listings` and `minted` are listed incompatible.
The tagging project's larger example uses an experimental `verbatim-alt` module,
`tagging-setup={extra-modules=verbatim-alt}`, which gives every symbol in a code block an Alt
text ("open brace") and marks each line break; TeX Live 2026 ships it, its header calls it highly
experimental, and a test file built with it passes veraPDF. Banner: "Code".

### Side by side text and boxes

Two author blocks side by side are not a table. Put each in a `minipage` inside
`\par\begingroup\tagpdfsetup{para/tagging=false}` ... `\par\endgroup`, as the example does: each
block is a Div read to its end before the next, and the group removes the empty paragraph tags
LaTeX otherwise leaves around the boxes (Tagged PDF BPG 1.0.1 3.5; issue 986). Both `\par` are
required, and anything typed between the boxes inside the group is an artifact; `\parbox` behaves
the same way. A minipage inside a saved box (`lrbox`, `\sbox`) closes the current section early;
use the form the kernel's own rotating.sty uses (tagging-project issue 781 tracks the cause):

```latex
\begin{lrbox}{\mybox}%
\SuspendTagging{}\begin{minipage}{7.5em}\ResumeTagging{}\UseTaggingSocket{para/restore}
  content, still tagged
\par\SuspendTagging{}\end{minipage}\ResumeTagging{}
\end{lrbox}
```

The box is read where it is created, so create it right before the paragraph that uses it.
`\SuspendTagging` and `\ResumeTagging` switch the whole tagging machinery off and on inside the
current group, which LaTeX uses for trial typesetting. Whatever is typeset while tagging is
suspended is an artifact that veraPDF passes and a screen reader never hears. So never suspend
tagging around content a reader needs, and never across a page break. Banner: "Side by side, not
a table".

### Two columns

`twocolumn` and the `multicol` package are allowed; the tags follow the text through the columns,
column one before column two, and veraPDF passes. ISO 32000-2:2020 14.8.5.4.7 says column
attributes shall be present on content divided into columns, and LaTeX writes none; PDF/UA-2 as
veraPDF tests it and the Tagged PDF BPG 1.0.1 do not require them.

### Text alignment and size

LaTeX justifies text. Clemson's text concept says to use left-aligned text as a best practice and
to avoid justified text and sizes under 9 points; WCAG 2.1 1.4.8 is a AAA criterion, outside
Clemson's WCAG 2.1 AA standard, and no PDF/UA-2 rule reads alignment. `main.tex` therefore sets
`\AtBeginDocument{\raggedright\setlength{\parindent}{1.5em}}`, which LaTeX records as TextAlign
Start on each paragraph; theorem and proof bodies keep their justified templates. Delete the line
for justified text. Do not use `ragged2e`. Place a vector chart at its natural size, because
scaling it scales the type inside.

## Checking

`make -f Makefile.a11y check` rebuilds quietly, reads the log and prints one line per test, each
marked `OK`, `WARN`, `FAIL` or `SKIP`: `build` (a LaTeX error, quoted), `references` (something
prints as `??`), `pictures` (every `\includegraphics` has `alt` or `artifact`; tikz drawings are
not counted), `formulas` (the number found equals the number with MathML attached), `tags` (no
warning from LaTeX's tagging or from the package), `packages` (nothing in sections 1 and 2 of the
`check-tagging-status` report, except `float.sty`, which the example loads for `[H]`), and
`PDF/UA-2` (veraPDF's verdict, `SKIP` when veraPDF is not on PATH). The `RESULT` line at the end
reads `FAIL. Fix the FAIL lines and check again.` (make then adds its own `Error 1` line),
`automatic checks passed with warnings`, `automatic checks passed; a step was skipped`, or
`automatic checks passed. The five checks by hand are yours.` Without make:

```
verapdf --flavour ua2 --format text main.pdf
grep -n -A2 '^!\|Package tagpdf Warning\|mathml missing\|luamml has been' main.log
```

The first line of veraPDF's output says PASS or FAIL and names the ISO 14289-2 clause of each
failed rule. veraPDF passes a picture whose alt text is only its file name, so the five checks by
hand are part of PDF/UA-2 conformance, not an extra: (1) every alt text says what the picture
shows and why it is here; (2) in Acrobat Pro (All tools, Prepare for accessibility, Check for
accessibility, then the Tags panel and Fix reading order) the title is a Title element, sections
start at H1 and the reading order follows the page; (3) every data table declared its header rows
or columns; (4) link text names the destination, and Tab reaches every link; (5) nothing is said
by color alone, with 4.5:1 contrast for text and 3:1 for graphics. Clemson's
[manual checks](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html)
are the source of the five, and a screen reader (NVDA with Firefox or Acrobat) is the final test.

### What Acrobat's checker says

Acrobat's checker tests PDF/UA-1, an older standard, so some of its remarks are expected on a
PDF/UA-2 file. "Lbl and LBody - Failed" appears for every caption number, theorem number and
footnote mark: LaTeX tags them Lbl, as ISO 32000-2:2020 Table 368 and the Tagged PDF BPG 1.0.1
expect, and Acrobat applies its list rule outside lists. It is a false positive; veraPDF passes.
For a clean Acrobat run, uncomment the three `\AssignStructureRole{...}{Span}` lines in
`main.tex`, which turn those labels into Span at the cost of their meaning. "Headers" fails on a
layout table tagged presentation. The Tags panel shows the names LaTeX writes (`text`,
`text-unit`, `item`, `float`, `footnote`, `theorem-like`) rather than the standard roles its role
map assigns (P, Part, LI, Aside, FENote, Sect). The documented key
`tagging-setup={role/map-tags=pdf}` in `\DocumentMetadata` writes the standard names instead,
keeps the PDF 2.0 namespaces and the MathML, and passes veraPDF; its cost is that the LaTeX
names are gone, so a theorem is a plain Sect and a figure container a plain Aside. Acrobat may
also say it "cannot extract the embedded font" for LMRoman17, the face of the title; that is a
known Acrobat message for fonts embedded as CIDFontType0, the way LuaLaTeX embeds every OpenType
font, and the font passes every veraPDF font rule.

## What the package does and what LaTeX does

| Behavior | Who does it | Clause |
| --- | --- | --- |
| Engine and release guard; no PDF without tagging | clemson.sty | ISO 14289-2:2024 6.2, 8.2.1 |
| Title as Title element; metadata title and author | LaTeX 2026-06-01 | Tagged PDF BPG 1.0.1 4.2.2.2; ISO 14289-2:2024 8.11 |
| Headings H1 to H6, bookmarks, linked contents | LaTeX 2026-06-01 with hyperref | ISO 32000-2:2020 14.8.4.5, Annex M; Tagged PDF BPG 1.0.1 4.1.4 |
| Lists L, LI, Lbl, LBody | LaTeX 2026-06-01 | ISO 32000-2:2020 14.8.4.8.2 |
| Tables TH, TD, Scope, spans | LaTeX 2026-06-01, from the author's keys | ISO 32000-2:2020 14.8.4.8.3 |
| Floats as Aside with Caption first; structure kept where written | LaTeX 2026-06-01; clemson.sty (`float/here`) | ISO 32000-2:2020 14.8.4.8.4; WCAG 2.1 1.3.2; Tagged PDF BPG 1.0.1 3.7 |
| Figure with Alt, ActualText or artifact | LaTeX 2026-06-01, from the author's keys | ISO 32000-2:2020 14.8.4.8.5, 14.9.4 |
| Formula with MathML, kept when the file name holds a comma | LaTeX 2026-06-01 with unicode-math; clemson.sty | ISO 14289-2:2024 8.2.5.29.1 |
| Theorems as Sect with Caption and Lbl | LaTeX 2026-06-01 | ISO 32000-2:2020 14.8.4.8.4 |
| Footnotes as FENote with Ref both ways | LaTeX 2026-06-01 | ISO 14289-2:2024 8.2.5.14 |
| Links in Link elements, structure destinations, tab order; black underline | LaTeX 2026-06-01 with hyperref; clemson.sty | ISO 14289-2:2024 8.2.5.20, 8.8, 8.9.3.3; WCAG 2.1 1.4.1 |
| `\emph` as Em; `\strong` as Strong, in headings too | LaTeX 2026-06-01; clemson.sty | WCAG 2.1 1.3.1 (failure F2) |
| Document language | LaTeX 2026-06-01, from `lang` | ISO 14289-2:2024 8.4.4; WCAG 2.1 3.1.1 |
| Language of phrases and blocks with babel | clemson.sty (LANGUAGES block) | ISO 32000-2:2020 14.9.2; WCAG 2.1 3.1.2 |
| Code and code lines | LaTeX 2026-06-01 | ISO 32000-2:2020 14.8.6.1 |
| Page numbers and running heads as artifacts | LaTeX 2026-06-01 | ISO 14289-2:2024 8.2.2 |
| Fonts embedded with ToUnicode | LuaLaTeX and LaTeX 2026-06-01 | ISO 14289-2:2024 8.4.5.8 |

## Packages by field

| Use | Avoid | Why |
| --- | --- | --- |
| `unicode-math`, `amsmath` (both loaded; `lua-unicode-math` loaded first is kept instead), `braket` | `amssymb` after the package, `bm`, `thmtools`, `ntheorem`, `tikz-cd` | `amssymb` after unicode-math stops the build and `bm` does not work with it (load `amssymb` before the package if a name is missing; write `\symbf`); the rest are listed currently incompatible |
| `mhchem` (`$\ce{H2O}$`), `siunitx` | `chemfig`, `chemformula`, `physics` with `siunitx`, `\qtyrange` | `mhchem` and `physics` are unchecked on the status page and `siunitx` partially compatible (a number and its unit are separate formulas); `chemfig` and `chemformula` are incompatible, so draw structures as pictures with alt text; `\qtyrange` loses its numbers in the MathML |
| `verbatim`, `\verb`, `algpseudocode`, `algorithmicx` | `listings`, `minted`, `algorithm`, `algorithm2e`, `fancyvrb` | listed incompatible (`fancyvrb` partial); `algorithm` is a float that aborts with `[H]`; use a theorem-like `algorithm` block, as the example does |
| `booktabs`, `tabularx`, `longtable` | `multirow`, `tabularray`, `nicematrix`, `caption`, `subcaption`, `subfig` | listed incompatible; `longtable` is compatible but tags its caption as a cell; spans come from `table/multirow`; panels share one caption, as in "Two panels" |
| `graphicx`, `tikz` with `alt={...}`; `float` for `[H]` with the two `\par` hooks; `placeins` | `pgfplots`, `wrapfig`, `pdfpages`, `floatrow`, `\newfloat` and `\restylefloat` from `float`, `titlesec` | incompatible or unsupported; export a plot as a picture with alt text; `float` is listed incompatible for those two commands only; `titlesec` stops tagging and writes no PDF |
| the kernel's `label=` key | `enumitem` | the package cannot be loaded under tagging; its syntax is built in |
| `\footnote`; `enotez` for endnotes | `endnotes`, `postnotes` | `endnotes` gives no link from mark to note; `postnotes` does not build under LaTeX 2026-06-01; `enotez` is partially compatible |
| `babel`, tagged by the package (`babel-english` compatible, `babel-spanish` partial) | `polyglossia` | not supported by the package: it writes no language tag and is unchecked; the kernel's `cmd/` and `env/` hooks with a hand-written tag work |
| `multicol`, `geometry`, `fancyhdr`, `microtype`, `setspace`, `parskip`, `natbib`, `bookmark`; `biblatex`, `cleveref` (after `amsmath`), `csquotes`, `acronym` (all four partial) | `memoir`; journal classes (`IEEEtran`, `revtex4-2`, `llncs`); `beamer`; `glossaries` | listed incompatible or unsupported, and `glossaries` unchecked; send a journal the copy built with its own class; write an abbreviation out in the text |

For any other package, look it up at <https://latex3.github.io/tagging-project/tagging-status/>;
a package that is not listed has not been checked, and the `packages` line of the check names any
package you load that the list marks unsupported or currently incompatible.

## Bringing an existing document over

Work on a copy of the project.

1. Copy `clemson.sty` and `Makefile.a11y` next to the document's main `.tex` file.
2. Put the two `% !TEX` lines and the `\DocumentMetadata{...}` block from `main.tex` at the very
   top, above `\documentclass`. Without the block, tagging is off.
3. Switch the engine everywhere: `pdflatex` becomes `lualatex` and `latexmk -pdf` becomes
   `latexmk -lualatex`, in a Makefile or an editor setting.
4. Delete the lines that load `fontspec`, `unicode-math`, `hyperref`, `inputenc`, `fontenc`,
   `lmodern`, `amssymb` and `bm`, and font packages such as `times` or `newtxmath`; the package
   loads the first three, and the rest clash with unicode-math or the Unicode font setup.
   hyperref options go in `\hypersetup{...}` after `\usepackage{clemson}`. Keep the rest,
   including `babel`, `graphicx`, `amsmath` and `amsthm`. Add `\usepackage{clemson}` as the last
   `\usepackage` line and the `pdftitle` and `pdfauthor` brackets to `\title` and `\author`. A
   class of your own built on `article`, `report` or `book` can stay; journal classes are listed
   incompatible.
5. Look up every remaining package in "Packages by field" and the status page. Most papers need
   `\bm{x}` replaced by `\symbfit{x}`, and each `subfigure` rebuilt like "Two panels".
6. Build, then check. The first build of an older document often stops with "text para hooks
   differ"; the cause is a theorem, proof or abstract right after a list, display or `center`
   with no blank line before it. Then the `FAIL` lines are the to-do list. The check cannot see
   two things, so do them yourself: give every data table its `\tagpdfsetup` header line, and
   move every caption above its picture or tabular. Finish with the five checks by hand.

## After a LaTeX update

Three things in the kit are tied to a LaTeX or babel version, and each carries a `REMOVE WHEN`
line. The package's two blocks marked `A11Y WORKAROUND` in `clemson.sty` reset the MathML file
list when the file name holds a comma (only then, with a documented key) and tag babel's language
switches (until babel or tagpdf writes the tag itself). The two `\par` hook lines beside `[H]`
placement in `example.tex` and `main.tex` cover a gap that a later release may close. Everything
else is LaTeX's own tagging; the table keys `table/header-rows`, `table/header-columns` and
`table/multirow` are marked preliminary in the latex-lab table documentation. After every
`tlmgr update`, run `make -f Makefile.a11y example` once; a clean `RESULT` line means the release
still builds and validates the whole example. When something changes, read `changes.txt` in TeX
Live's `doc/latex/latex-lab/` folder and the status page. The 2026-11-01 release renames the tags
Acrobat shows (`text` to `text-block`, `text-unit` to `semantic-para`, section numbers to
`heading-number` with role Lbl) and makes `\rule` an artifact by itself.

## Presentations

The package does not cover slides. `beamer` cannot be tagged (status page: no support). The
`ltx-talk` class is the tagged replacement: `\DocumentMetadata{tagging=on, pdfstandard=ua-2}`,
then `\documentclass{ltx-talk}`. Overlays (`\pause`, `\item<2->`) are safe: the frame option
`tag-slides` decides which slides of a frame are tagged, its default `n` tags only the last one,
and the earlier slides are artifacts, so the tree holds each frame once. Frame titles are tagged
H4 by design, which the class manual says may draw a warning from some checkers;
`\tagpdfsetup{role/new-tag=frametitle/H1}` changes that. The class is experimental and its manual
says sources may need changes.

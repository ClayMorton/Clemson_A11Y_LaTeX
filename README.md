# clemson: accessible LaTeX in one package

A tagged PDF carries, besides the printed page, a tree that names what each part of the document
is: title, headings, paragraphs, lists, tables, pictures with alt text, formulas. A screen reader
follows that tree. ISO 14289-2:2024 (PDF/UA-2) is the standard for accessible PDF 2.0 files, and
LaTeX 2026-06-01 writes such files itself once tagging is turned on. This folder holds what a
Clemson author needs to do that:

```
clemson.sty  main.tex  example.tex  references.bib  README.md  resources/
```

`clemson.sty` is the package. `main.tex` is the starter to write in. `example.tex` is the worked
example: every kind of content, tagged, with a comment on each block that says why it is written
that way and which clause it meets; comment lines that start with `%----` name the blocks. It
cites `references.bib` and shows the pictures in `resources/`. The package needs LuaLaTeX and LaTeX
2026-06-01 or newer and stops otherwise.

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

2. **Java and veraPDF**. veraPDF checks a PDF against the PDF/UA-2 rules a program can
   check. Install a Java runtime (for example
   Temurin from adoptium.net), run the installer from [verapdf.org](https://verapdf.org/software/)
   and add its folder to your PATH (on a Mac, an `export PATH=...` line in `~/.zshrc`). Use a
   version that accepts `--flavour ua2`; 1.30 does.

3. **Adobe Acrobat Pro** for the part of the check done by hand. The free Acrobat Reader cannot
   show tags or reading order.

Overleaf: choose the LuaLaTeX compiler and the Rolling TeX Live option in the compiler settings.
The tagging project's usage instructions (dated 2026-06-11) say Overleaf then offered LaTeX
2025-11-01, that 2026 support was expected, and that a `latexmkrc` file with the four lines they
give (`$max_repeat = 1;`, `$force_mode = 1;`, and `$pdflatex` and `$lualatex` set to the `-dev`
engines with `-synctex=1 -interaction=nonstopmode`) builds with the development release instead.
Either way, confirm `LaTeX2e <2026-06-01>` or later in the first lines of the log.

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
  tagging-setup = {math/setup=mathml-SE},
  check-tagging-status,
}
\documentclass{article}
\usepackage{booktabs}          % your packages
\usepackage{clemson}           % last
\title{Title of the document}
\author{First Author \and Second Author}
```

The two `% !TEX` lines tell VS Code, TeXShop and other editors to use LuaLaTeX, the one engine that
writes MathML. `\DocumentMetadata` goes above `\documentclass`. `lang` is the language of the whole
PDF (ISO 14289-2:2024 8.4.4). `pdfstandard=ua-2` declares PDF/UA-2, the standard veraPDF tests.
`tagging=on` turns tagging on (`tagging-setup` alone would too); `pdfstandard=ua-2` by itself does
not, and LaTeX then writes an untagged PDF without a word, which is why the package stops instead.
`tagging-setup` writes the MathML of every formula into the tag tree (see "Mathematics").
`check-tagging-status` appends a report on the loaded packages to the log. Use `report` for chapters
(`\chapter` is H2, `\section` H3); `book` works too but has no abstract. `\usepackage{clemson}`
comes last, because it loads hyperref, which must follow every other package. LaTeX writes the title
and the authors into the metadata a screen reader announces when the file opens (ISO 14289-2:2024
8.11); `\and` between authors gives one entry each. A title that contains a comma needs
`\title[pdftitle={{The title, with a comma}}]{The title, with a comma}` on LaTeX 2026-06-01, which
otherwise cuts the metadata title at the comma; the 2026-11-01 release fixes this, and the key can
then be dropped; `\author[pdfauthor={A, B}]{A and B}` lists the authors when the printed line says
"and". The example shows both.

Build with `latexmk -lualatex main.tex`. `latexmk` repeats LuaLaTeX and BibTeX until every
reference and link is resolved; a single run leaves `??` in the text and formulas without MathML,
and `main.tex` says how VS Code and TeXShop run the extra passes. Then check with
`verapdf --flavour ua2 --format text main.pdf` and the log commands under "Checking".

What the package does: it stops the build unless LuaLaTeX, LaTeX 2026-06-01 or newer and
`\DocumentMetadata` with tagging are in use; loads unicode-math, so every formula gets MathML;
loads amsthm with the environments theorem, lemma, proposition, corollary, definition, example,
remark and algorithm, enotez for endnotes, graphicx with `resources/` as the picture folder,
float with `[H]` as the default placement, babel (add languages with `\babelprovide`) and
hyperref with black underlined links; tags the title as the only H1 with the headings one level
down, and the abstract as a Sect with an H2; keeps each figure and table in the tag tree where it
is written; writes Scope, spans and Headers on every table cell; sets left-aligned text; tags
`\strong` and babel's language switches; keeps the MathML file list right when the file name
holds a comma; and adds bookmarks for the front matter, `\autoref` names, `\email` and the word
QED at the end of a proof. Its one option, `\usepackage[justified]{clemson}`, keeps justified text.
What it cannot do for you: the `% !TEX` line, the `\DocumentMetadata` block, `alt={...}` on every
picture, and the header rows or columns of every table. Everything else is LaTeX's own tagging. The
next section gives, for each kind of content, the rule, the reason and the `%----` banner in
`example.tex` that shows it.

## Writing the document

### Headings and title

The package tags the printed title as the only H1 and moves every heading down one level:
`\section` is H2, `\subsection` H3 and `\subsubsection` H4; in `report` and `book`, `\chapter` is
H2, `\section` H3 and so on, as in the Graduate School's Word template. LaTeX's own choice is the
PDF 2.0 Title element with `\section` as H1 (Tagged PDF BPG 1.0.1 4.2.2.2); both forms pass
PDF/UA-2. The title plug works on the kernel's `\maketitle`, so a class with its own title page
keeps its title untagged. Use the heading commands in order and never skip a level: veraPDF has
no rule on skipped levels, but Acrobat's checker and WCAG 2.1 technique G141 expect H1 then H2.
`\section*[Acknowledgments]{Acknowledgments}` gives a starred heading a contents entry and a
bookmark (a kernel key; `toc=` and `bookmark=` set the two texts separately). In `article` and
`report` the abstract is tagged as a Sect with an H2 heading under the H1 title and gets a
bookmark (LaTeX alone tags it BlockQuote; tagging-project issue 1327 is open). Put `\maketitle`
before it: a hand-made `center` block right before the abstract stops the build with "text para
hooks differ". In `report` the abstract prints in the text flow, not on a page of its own.
Block: TITLE, ABSTRACT, CONTENTS.

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
`\textbackslash` lands as its own name, so write the word instead. The package loads graphicx and
looks for pictures in `resources/` next to the document, then beside the `.tex` file; a
`\graphicspath` line in the document replaces that list. Banners: "Picture with alt text" through
"Long description in appendix".

### Tables

Declare the header cells on the line before `\begin{tabular}`, inside the `table` environment so
the setting ends with it: `\tagpdfsetup{table/header-rows={1}}`, `table/header-columns={1}` or
both. The cells become TH with a Scope of Column, Row or Both (ISO 32000-2:2020 14.8.4.8.3).
Header rows are the top rows and header columns the leftmost ones. A group row such as "Fall
semester" after data rows is a header row too, `table/header-rows={1,4}`: it applies to the rows
that follow it until the next group row, and the top header rows apply to every data cell and row
header below them (a group cell itself lists no headers), so a table with group rows is supported
next to the one table per group that Clemson's tables guide asks for. `\multicolumn` needs nothing.
A cell that spans rows starts with `\tagpdfsetup{table/multirow=2}` (at the start of the row for a
first-column cell, or inside the braces of `\multicolumn`; placed before `\multicolumn` it aborts
the build), and the covered cells stay empty; the `multirow` package is listed incompatible.
`longtable` is listed compatible but tags its caption as a table cell, and the package's cell
attributes do not cover it. A `tabular` kept for layout goes inside a group with
`\tagpdfsetup{table/tagging=presentation}` (the tagging project's choice for a layout table) or
`=div`; `=false` suits only `l`, `c` and `r` columns, and any of the three left open changes the
tables that follow. LaTeX writes Scope as attribute classes, which veraPDF checks but Acrobat's
Table Editor shows as "scope none" (tagging-project issue 1324), so the package writes on every
cell, next to those classes, a direct attribute dictionary: Scope on each header cell, ColSpan and
RowSpan on each spanning cell, and on each data cell a Headers array with the IDs of the header
cells that apply to it, row headers first, then column headers, most specific first (ISO
32000-2:2020 Table 384). Acrobat's Table Editor and PAC read these, so the cell properties show
there and a screen reader working through Acrobat gets the header association. Presentation and div
tables get nothing; Acrobat's checker reports a presentation table under its Headers rule. Banners:
the "Table:" blocks and "Side by side, not a table".

### Figures and tables in the text

LaTeX tags each `figure` and `table` as an Aside whose first child is the Caption, but by default
it defers those structures to the end of the tree, its choice for PDF 1.7 readers that show an
Aside as a Note. The package sets `float/here`, so each structure stays where the float is
written, next to the text that cites it (WCAG 2.1 1.3.2; Tagged PDF BPG 1.0.1 3.2.2). The
package also loads `float` and makes `[H]` the default placement for `figure` and `table`, so
each one prints where it is written; `\floatplacement{figure}{tbp}` in the document lets figures
float again, and the tag-tree position stays the same either way. The package's two `\par` hooks
end the paragraph before a float; without them an `[H]` float right after a list or a displayed
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
8.2.5.29.1 asks; the package loads unicode-math so that happens on LuaLaTeX. MathML can sit in a
PDF in two forms, and the `math/setup` key in `\DocumentMetadata` chooses. `mathml-SE` (structure
elements) writes the MathML into the tag tree itself: inside each Formula element sits a `math`
element with `mrow`, `mi`, `mo`, `mfrac` and the other MathML elements as tags, so the reader
walks the formula the way it walks a list or a table. `mathml-AF` (associated file) leaves the
Formula element empty and attaches a small MathML file to it, one per distinct formula, which the
reader has to open. The Math in PDF BPG and the tagging project's usage instructions both put
`mathml-SE` first, and it is the form Acrobat passes to a screen reader (NVDA with MathCAT in the
tagging project's recordings); the kit therefore asks for `math/setup=mathml-SE`, and every file
in this folder uses it. Its cost: the recordings show Foxit and Firefox (with NVDA or JAWS) reading
the attached file, not the structure elements, so a document meant for those readers can add the
file with `math/setup={mathml-SE,mathml-AF}` (about five percent larger). With no key at all LaTeX
attaches the file only. Under `mathml-SE` the MathML is written during the run, so it needs no
second pass and no count appears in the log; a `math` element inside every Formula in the tag
tree is the proof. Two known warnings under `mathml-SE`: a numbered `multline` reports "structure
with label 0 is unknown" (issue 1407; use `multline*`), and an mhchem prescript such as
`\ce{^{14}C}` reports a reused label (issue 793; write it out in words).
`\MathMLintent{mean($x)}{{...}}` and `\MathMLarg{x}{...}` name what a formula means (Math in PDF
BPG 1.0 p. 15); keep the double braces, because a scripted single atom loses the intent silently.
Write `\symbf{v}`, `\symbfit{v}` and `\symcal{A}` for bold and script letters; `bm` does not work
with unicode-math, and `amssymb` loaded after the package stops the build (load it before the
package if a command name is missing). With `mathml-AF`, a file name with a comma makes LaTeX
split its list of MathML files and drop every formula's MathML; the package resets the list in
that case. Banners: "Inline and display math" through "Chemistry, units, bra-ket".

### Theorems and proofs

The package loads `amsthm` and, when the document starts, defines `theorem`, `lemma`,
`proposition`, `corollary`, `definition`, `example` and `remark` on one counter and `algorithm` on
its own, each only if the document has not defined that environment itself; `\newtheorem` adds
any other name, and `\theoremstyle` and `proof` work as in any document. `algorithm` is a
theorem-like block with an optional title, not a float, because the `algorithm` package cannot be
tagged; put the steps in an `algorithmic` body. LaTeX tags each theorem, lemma and proof as a
theorem-like block, role-mapped to Sect, with its head as a Caption and its number as a Lbl (ISO
32000-2:2020 14.8.4.8.4; Tagged PDF BPG 1.0.1 4.2.4). A proof ends with the word QED, which a
screen reader reads; amsthm's open square is drawn with rules and announces nothing, and
`\renewcommand{\qedsymbol}{\openbox}` after the package restores it. `\autoref` prints only the
number for an environment on the shared counter; write `\hyperref[lem:x]{Lemma~\ref*{lem:x}}` or
define `\lemmaautorefname`. Banner: "Theorems and algorithm".

### Footnotes and endnotes

`\footnote{...}` is all LaTeX needs: the note is tagged FENote, the mark is a Lbl holding the link,
and the tree cross-references mark and note (Ref) both ways, which PDF/UA-2 asks for (veraPDF
rules 8.2.5.14). The package adds two things. It writes `NoteType Footnote` on each note, through
LaTeX's own footnote hook, so a tool can tell footnotes from other notes. And it makes the link box
of the raised mark the mark itself: LaTeX's link plug wraps the whole mark box, which is as tall as
the line, so the underline would land under the text next to the mark; the package runs that plug
inside the raised box instead, and the underline sits under the numeral (the same holds for
endnote marks, whose link already sits inside the raised box). Note text is set at 9 pt, Clemson's
floor, with 7 pt raised marks; with the `10pt` option LaTeX's own size would be 8 pt.
LaTeX has no endnote support. The package loads `enotez`, listed partially compatible, and
configures it: `\endnote{...}` writes a note, `\printendnotes` prints the list where it stands
(nothing when there are none) and adds "Notes" to the contents, the mark links to the note and
the note's number links back, the list is tagged, and the marks are roman so they stay apart from
the arabic footnote marks. The `endnotes` package gives no link from mark to note. Banners:
"Emphasis, footnote, endnote" and the FOOTNOTE AND ENDNOTE EXAMPLES section.

### Links and bookmarks

The package loads hyperref last, so every `\ref`, `\cite`, `\href`, `\url` and contents entry is a
link annotation inside a Link or Reference element with a structure destination, and every page
has a structure tab order (ISO 14289-2:2024 8.2.5.20, 8.8, 8.9.3.3). Link text stays black and the
underline comes from the annotation's border style, drawn by the viewer with the geometry of
LaTeX's own `\underline`: a 0.4 pt rule 1.2 pt below the text (hyperref's `pdflinkmargin` pads
the link box, which is otherwise the line box, so the rule would cross the letters). No link is
marked by color alone (WCAG 2.1 1.4.1); viewers differ in whether they draw the border, and the
link text names the destination in every viewer. The contents and the lists of figures and tables
stay plain, because every line there is a link. `\hypersetup{hidelinks}` after the package removes
the underline everywhere. Name the destination in the link
text, never "click here"; `\email{name@clemson.edu}` (or `\href{mailto:...}{...}`, as the
example does) gives an email address as its own link whose text is the address. `\autoref{sec:x}`
links the whole phrase and prints "Section 3": the package sets the names Section, Chapter,
Figure, Table, Equation, Appendix and Algorithm at the end of `\begin{document}`, after babel has
reset them, so the document needs no line for them; a name of your own, such as
`\lemmaautorefname`, goes inside `\AddToHook{begindocument/end}{...}` for the same reason.
`\tableofcontents`, `\listoffigures` and `\listoftables` print starred headings with no outline
entry, so the package adds a level 1 bookmark before each, and before the abstract; in `report`
and `book` it turns the page first, so the bookmark points at the heading's page. Banners:
"Links, citations", "Cross-references".

### Language

`lang=en-US` in `\DocumentMetadata` sets the language of the whole PDF, which is all PDF/UA-2
checks. WCAG 2.1 3.1.2 also wants each phrase in another language marked (ISO 32000-2:2020
14.9.2), and babel hyphenates but writes no such tag. The package therefore loads babel itself,
with the main language taken from `lang`, and adds the tag: after `\usepackage{clemson}`, add each
other language with `\babelprovide[import]{french}`, and the package's hooks wrap every
`\foreignlanguage` phrase in a Span with its language and give every `otherlanguage` block or
`\selectlanguage` switch its language through tagpdf's `text/lang` key. (A document that already
loads babel with options, `\usepackage[french]{babel}`, keeps that line before the package; after
the package it is an option clash. The main language still comes from `lang`, so French is then a
secondary language, not the document's.) The recipe comes from babel discussion 357 and the tagging
project's max-moritz example; a later babel or tagpdf release may write the tag itself, and the
block says when it can go. The main language gets no tag of its own, since the
catalog `Lang` already names it, so an English document with one French phrase carries a language
tag on that phrase only. With these hooks `\foreignlanguage` holds one paragraph at most; longer
passages go in `otherlanguage`, with a blank line before `\begin{otherlanguage}` and after
`\end{otherlanguage}`. Without the first, the block's opening paragraph joins the English paragraph
before it and loses its language tag; without the second, the English text after the block joins
the block and is tagged with its language. Both build without a warning. A heading inside the
block gives its whole section the block's language, so keep such a section inside the block up to
the next heading. To switch back by hand, use the main language's babel name, which the log prints
in its "Passing ... to babel" line (`american` for `en-US`). For a language that has no
`\babelprovide` line, the kernel's inline socket tags a phrase, without hyphenation for it:
`\UseTaggingSocket{inline/begin}{tag=Span,lang=fr}` ... `{inline/end}`. polyglossia cannot be used
with the package: loaded after it, it warns that babel and polyglossia are exclusive and tags
nothing; loaded before it, the build stops. With the `\usepackage[french]{babel}` form, the status
report in the log lists `french.ldf` as incompatible; that entry is stale (issue 932, closed in May
2026), and the `\babelprovide` form loads no `.ldf` file at all.
Banner: "Rule, language, abbreviation, color".

### Code

`\verb` text is tagged Code and each line of a `verbatim` block is a code line (Sub in PDF 2.0),
which PDF/UA-2 accepts (ISO 32000-2:2020 14.8.4.6, 14.8.4.7; Tagged PDF BPG 1.0.1 4.2.11). A screen
reader reads the characters at the listener's symbol level: NVDA skips a backslash and braces at its
default level and speaks them at "most" or "all". `listings` and `minted` are listed incompatible.
The tagging project's larger example uses an experimental `verbatim-alt` module,
`tagging-setup={extra-modules=verbatim-alt}`, which gives every symbol in a code block an Alt text
("open brace") and marks each line break; TeX Live 2026 ships it, its header calls it highly
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
Clemson's WCAG 2.1 AA standard, and no PDF/UA-2 rule reads alignment. The package therefore sets
`\raggedright` with a 1.5em paragraph indent when the document starts, which LaTeX records as
TextAlign Start on each paragraph; theorem and proof bodies keep their justified templates.
`\usepackage[justified]{clemson}`, the package's only option, keeps justified text. Do not use
`ragged2e`. Place a vector chart at its natural size, because scaling it scales the type inside.

## Checking

Four commands cover what a program can check. Run them after `latexmk -lualatex main.tex`:

```
verapdf --flavour ua2 --format text main.pdf
grep -n -A2 '^!\|Package tagpdf Warning\|Package clemson\|Alternative text for graphic' main.log
grep -n 'luamml\|mathml' main.log | grep -i 'warning\|missing'
sed -n '/Status report of the tagging support/,/3\. Partially/p' main.log
```

The second command lists LaTeX errors, warnings from LaTeX's tagging code and from the package,
and every `\includegraphics` without `alt` or `artifact` (a tikz drawing without `alt` is silent,
so search the source for `tikzpicture` as well). The third prints any warning from the MathML
code; under `mathml-SE` there is no count to compare, so open the PDF in Acrobat's tags panel
and look for a `math` element inside each Formula. The fourth prints sections 1 and 2 of the
`check-tagging-status` report, which name packages to replace (`float.sty`, which the package
loads, is listed for two commands the kit does not use).

The first line of veraPDF's output says PASS or FAIL and names the ISO 14289-2 clause of each
failed rule. veraPDF passes a picture whose alt text is only its file name, so the five checks by
hand are part of PDF/UA-2 conformance, not an extra: (1) every alt text says what the picture
shows and why it is here; (2) in Acrobat Pro (All tools, Prepare for accessibility, Check for
accessibility, then the Tags panel and Fix reading order) the title is the only H1, the sections
start at H2 and the reading order follows the page; (3) every data table declared its header rows
or columns, and the Table Editor shows scope and headers on its cells; (4) link text names the
destination, and Tab reaches every link; (5) nothing is said by color alone, with 4.5:1 contrast
for text and 3:1 for graphics. Clemson's
[manual checks](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html)
are the source of the five, and a screen reader (NVDA with Firefox or Acrobat) is the final test.

### What Acrobat's checker says

Acrobat's checker tests PDF/UA-1, an older standard, so some of its remarks are expected on a
PDF/UA-2 file. "Lbl and LBody - Failed" appears for every caption number, theorem number and
footnote mark: LaTeX tags them Lbl, as ISO 32000-2:2020 Table 368 and the Tagged PDF BPG 1.0.1
expect, and Acrobat applies its list rule outside lists. It is a false positive; veraPDF passes.
For a clean Acrobat run, uncomment the three `\AssignStructureRole{...}{Span}` lines in
`main.tex`, which turn those labels into Span at the cost of their meaning. "Headers" fails on a
layout table tagged presentation. The Table Editor shows Scope and Headers on the cells of a
data table, because the package writes them as direct attributes next to LaTeX's attribute
classes (see "Tables"). The Tags panel shows the names LaTeX writes (`text`, `text-unit`, `item`,
`float`, `footnote`, `theorem-like`) rather than the standard roles its role map assigns (P,
Part, LI, Aside, FENote, Sect). The documented key
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
| Title as the only H1; metadata title and author | clemson.sty (title plug); LaTeX 2026-06-01 | ISO 32000-2:2020 14.8.4.5; ISO 14289-2:2024 8.11 |
| Headings H2 to H6, one level below the title; heading bookmarks; linked contents | clemson.sty (levels); LaTeX 2026-06-01 with hyperref | ISO 32000-2:2020 14.8.4.5, Annex M; Tagged PDF BPG 1.0.1 4.1.4 |
| Abstract as Sect with an H2 heading; bookmarks for abstract, contents, list of figures and list of tables | clemson.sty | ISO 32000-2:2020 14.8.4.4; Tagged PDF BPG 1.0.1 7.2 |
| Lists L, LI, Lbl, LBody | LaTeX 2026-06-01 | ISO 32000-2:2020 14.8.4.8.2 |
| Tables TH, TD, Scope and spans as attribute classes | LaTeX 2026-06-01, from the author's keys | ISO 32000-2:2020 14.8.4.8.3 |
| Scope, ColSpan, RowSpan and Headers as direct attributes on every cell | clemson.sty (TABLE CELLS) | ISO 32000-2:2020 14.8.4.8.3, Table 384 |
| Floats as Aside with Caption first; structure kept where written; `[H]` placement with the `\par` hooks | LaTeX 2026-06-01; clemson.sty (`float/here`, float) | ISO 32000-2:2020 14.8.4.8.4; WCAG 2.1 1.3.2; Tagged PDF BPG 1.0.1 3.2.2; ISO 14289-2:2024 8.2.5.27 |
| Figure with Alt, ActualText or artifact | LaTeX 2026-06-01, from the author's keys | ISO 32000-2:2020 14.8.4.8.5, 14.9.4 |
| Formula with MathML, kept when the file name holds a comma | LaTeX 2026-06-01 with unicode-math; clemson.sty | ISO 14289-2:2024 8.2.5.29.1 |
| Theorems as Sect with Caption and Lbl; the environments and the word QED | LaTeX 2026-06-01; clemson.sty (amsthm) | ISO 32000-2:2020 14.8.4.8.4 |
| Footnotes as FENote with Ref both ways, typed Footnote, link box on the mark, 9 pt notes; endnotes linked both ways in a tagged list | LaTeX 2026-06-01; clemson.sty (NoteType, mark box, size, enotez) | ISO 14289-2:2024 8.2.5.14; ISO 32000-2:2020 14.8.4.7 |
| Links in Link elements, structure destinations, tab order; black underline in the text, none in the contents; `\email`; `\autoref` names | LaTeX 2026-06-01 with hyperref; clemson.sty | ISO 14289-2:2024 8.2.5.20, 8.8, 8.9.3.3; WCAG 2.1 1.4.1, 2.4.4 |
| `\emph` as Em; `\strong` as Strong, in headings too | LaTeX 2026-06-01; clemson.sty | WCAG 2.1 1.3.1 (failure F2) |
| Document language | LaTeX 2026-06-01, from `lang` | ISO 14289-2:2024 8.4.4; WCAG 2.1 3.1.1 |
| Language of phrases and blocks with babel | clemson.sty (LANGUAGES block) | ISO 32000-2:2020 14.9.2; WCAG 2.1 3.1.2 |
| Code and code lines | LaTeX 2026-06-01 | ISO 32000-2:2020 14.8.4.6, 14.8.4.7 |
| Page numbers and running heads as artifacts | LaTeX 2026-06-01 | ISO 14289-2:2024 8.2.2 |
| Left-aligned text, TextAlign Start on each paragraph | clemson.sty (option `justified` turns it off) | Clemson text concept; WCAG 2.1 1.4.8 (advisory) |
| Fonts embedded with ToUnicode | LuaLaTeX and LaTeX 2026-06-01 | ISO 14289-2:2024 8.4.5.8 |

## Packages by field

| Use | Avoid | Why |
| --- | --- | --- |
| `unicode-math`, `amsmath`, `amsthm` (all loaded by the package; `lua-unicode-math` loaded first is kept instead), `braket` | `amssymb` after the package, `bm`, `thmtools`, `ntheorem`, `tikz-cd` | `amssymb` after unicode-math stops the build and `bm` does not work with it (load `amssymb` before the package if a name is missing; write `\symbf`); the rest are listed currently incompatible |
| `mhchem` (`$\ce{H2O}$`), `siunitx` | `chemfig`, `chemformula`, `physics` with `siunitx`, `\qtyrange` | `mhchem` and `physics` are unchecked on the status page and `siunitx` partially compatible (a number and its unit are separate formulas); `chemfig` and `chemformula` are incompatible, so draw structures as pictures with alt text; `\qtyrange` loses its numbers in the MathML |
| `verbatim`, `\verb`, `algpseudocode`, `algorithmicx` | `listings`, `minted`, `algorithm`, `algorithm2e`, `fancyvrb` | listed incompatible (`fancyvrb` partial); `algorithm` is a float that aborts with `[H]`; use the package's theorem-like `algorithm` block, as the example does |
| `booktabs`, `tabularx`, `longtable` | `multirow`, `tabularray`, `nicematrix`, `caption`, `subcaption`, `subfig` | listed incompatible; `longtable` is compatible but tags its caption as a cell and gets no cell attributes from the package; spans come from `table/multirow`; panels share one caption, as in "Two panels" |
| `graphicx` and `float` (both loaded by the package, with `[H]` and the two `\par` hooks), `tikz` with `alt={...}`, `placeins` | `pgfplots`, `wrapfig`, `pdfpages`, `floatrow`, `\newfloat` and `\restylefloat` from `float`, `titlesec` | incompatible or unsupported; export a plot as a picture with alt text; `float` is listed incompatible for those two commands only; `titlesec` stops tagging and writes no PDF |
| the kernel's `label=` key | `enumitem` | the package cannot be loaded under tagging; its syntax is built in |
| `\footnote`; `enotez` for endnotes (loaded by the package) | `endnotes`, `postnotes` | `endnotes` gives no link from mark to note; `postnotes` does not build under LaTeX 2026-06-01; `enotez` is partially compatible |
| `babel` (loaded by the package; add languages with `\babelprovide[import]{...}`; `babel-english` compatible, `babel-spanish` partial) | `polyglossia` | cannot be loaded together with babel, so it cannot be used with the package |
| `multicol`, `geometry`, `fancyhdr`, `microtype`, `setspace`, `parskip`, `natbib`, `bookmark`; `biblatex`, `cleveref` (after `amsmath`), `csquotes`, `acronym` (all four partial) | `memoir`; journal classes (`IEEEtran`, `revtex4-2`, `llncs`); `beamer`; `glossaries` | listed incompatible or unsupported, and `glossaries` unchecked; send a journal the copy built with its own class; write an abbreviation out in the text |

For any other package, look it up at <https://latex3.github.io/tagging-project/tagging-status/>;
a package that is not listed has not been checked, and the `check-tagging-status` report at the end
of the log names any package you load that the list marks unsupported or currently incompatible.

## Bringing an existing document over

Work on a copy of the project.

1. Copy `clemson.sty` next to the document's main `.tex` file.
2. Put the two `% !TEX` lines and the `\DocumentMetadata{...}` block from `main.tex` at the very
   top, above `\documentclass`. Without the block, tagging is off.
3. Switch the engine everywhere: `pdflatex` becomes `lualatex` and `latexmk -pdf` becomes
   `latexmk -lualatex`, in the project's own build script or editor setting.
4. Delete the lines that load `fontspec`, `unicode-math`, `hyperref`, `inputenc`, `fontenc`,
   `lmodern`, `amssymb` and `bm`, and font packages such as `times` or `newtxmath`; the package
   loads the first three, and the rest clash with unicode-math or the Unicode font setup.
   hyperref options go in `\hypersetup{...}` after `\usepackage{clemson}`. The package also
   loads `amsthm`, `enotez`, `float`, `graphicx` and `babel`: delete those lines or keep them
   before the package (a `\usepackage[...]{babel}` line with options must come before it);
   delete `polyglossia`. `\newtheorem` lines can stay, because the package skips every theorem
   environment the document defines itself; a `\graphicspath` line replaces the package's
   `resources/` list; a `\pdfbookmark` line before `\tableofcontents` goes, since the package
   adds that bookmark. Keep the rest, including `amsmath`. Add `\usepackage{clemson}` as the last
   `\usepackage` line; keep `\title` and `\author` as they are unless the title has a comma. A
   class of your own built on `article`, `report` or `book` can stay; journal classes are listed
   incompatible.
5. Look up every remaining package in "Packages by field" and the status page. Most papers need
   `\bm{x}` replaced by `\symbfit{x}`, and each `subfigure` rebuilt like "Two panels".
6. Build, then check. The first build of an older document often stops with "text para hooks
   differ"; the cause is a theorem, proof or abstract right after a list, display or `center`
   with no blank line before it. Then the veraPDF output and the log lines under "Checking" are
   the to-do list. No program can see two things, so do them yourself: give every data table its
   `\tagpdfsetup` header line, and
   move every caption above its picture or tabular. Finish with the five checks by hand.

## After a LaTeX update

Six things in `clemson.sty` are tied to a LaTeX or babel version. The four blocks marked
`A11Y WORKAROUND` each carry a `REMOVE WHEN` line: MATHML FILE NAME resets the MathML file list
when the file name holds a comma (only then, with a documented key); LANGUAGES tags babel's
language switches (until babel or tagpdf writes the tag itself); TABLE CELLS reads latex-lab-table
internals to write the direct cell attributes, checks that each one still exists and, when a
LaTeX update has removed one, warns in the log and skips the attributes, so the build finishes
and LaTeX's attribute classes remain; FOOTNOTES puts the mark's link inside the raised box (until
LaTeX sizes the link box to the mark itself). The title plug in TITLE AND HEADINGS and the two
`\par` hooks in FLOATS use kernel sockets and hooks that a later release may change or make
unnecessary.
Everything else is LaTeX's own tagging; the table keys `table/header-rows`, `table/header-columns`
and `table/multirow` are marked preliminary in the latex-lab table documentation. After every `tlmgr
update`, build `example.tex` once and run veraPDF on it; a PASS and a log without tagging warnings
mean the release still builds and validates the whole example. When something changes, read
`changes.txt` in TeX Live's `doc/latex/latex-lab/` folder and the status page. The 2026-11-01
release renames the tags Acrobat shows (`text` to `text-block`, `text-unit` to `semantic-para`,
section numbers to `heading-number` with role Lbl) and makes `\rule` an artifact by itself.

## Presentations

The package does not cover slides. `beamer` cannot be tagged (status page: no support). The
`ltx-talk` class is the tagged replacement: `\DocumentMetadata{tagging=on, pdfstandard=ua-2}`,
then `\documentclass{ltx-talk}`. Overlays (`\pause`, `\item<2->`) are safe: the frame option
`tag-slides` decides which slides of a frame are tagged, its default `n` tags only the last one,
and the earlier slides are artifacts, so the tree holds each frame once. Frame titles are tagged
H4 by design, which the class manual says may draw a warning from some checkers;
`\tagpdfsetup{role/new-tag=frametitle/H1}` changes that. The class is experimental and its manual
says sources may need changes.

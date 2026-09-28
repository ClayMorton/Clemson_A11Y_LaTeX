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
\usepackage{clemson}           % after your packages
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
comes after the other packages, because it loads hyperref, which its manual asks to load last; a
package that must follow hyperref, such as `cleveref`, goes after it, and a hyperref option that
works only at load time goes in `\PassOptionsToPackage{...}{hyperref}` above it. LaTeX writes the title
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
`\DocumentMetadata` with tagging are in use (`tagging=draft` builds, with a warning); loads
unicode-math, which gives LaTeX's MathML the right characters; defines the environments theorem,
lemma, proposition, corollary, definition, example, remark and algorithm (LaTeX supplies amsthm's
commands itself under tagging); loads enotez for endnotes, graphicx, float with `[H]` as the
default placement, babel (add languages with `\babelprovide`), hyperref and lua-ul (links
underlined by LaTeX, black, plain in the contents); tags the title as the only H1 with the headings
one level down, and the abstract as a Sect with an H2; keeps each figure and table in the tag tree
where it is written; writes Scope, spans and Headers on the cells of every `tabular`; sets
left-aligned text; tags `\strong` and babel's language switches; keeps the MathML file list right
when the file name holds a comma; adds NoteType to footnotes; and adds bookmarks for the front
matter, `\autoref` names, `\email` and the word QED at the end of a proof. Its one option, `\usepackage[justified]{clemson}`, keeps justified text. What
it cannot do for you: the `% !TEX` line, the `\DocumentMetadata` block, `alt={...}` on every
picture, and the header rows or columns of every table. Everything else is LaTeX's own tagging. The
next section gives, for each kind of content, the rule, the reason and the `%----` banner in
`example.tex` that shows it.

## Writing the document

### Headings and title

The package tags the printed title as the only H1 and moves every heading down one level:
`\section` is H2, `\subsection` H3 and `\subsubsection` H4; in `report` and `book`, `\chapter` is
H2, `\section` H3 and so on, as in the Graduate School's Word template. LaTeX's own choice is the
PDF 2.0 Title element with `\section` as H1 (Tagged PDF BPG 1.0.1 4.2.2.2); both forms pass
PDF/UA-2. The title plug works on the kernel's `\maketitle` and puts the whole title, even one
written on two lines, in one H1; a class with its own title page (ClemsonThesis.cls) tags its title
as ordinary text, and the document then has no H1. Use the heading commands in order and never skip a level: veraPDF has
no rule on skipped levels, but Acrobat's checker and WCAG 2.1 technique G141 expect H1 then H2.
`\section*[Acknowledgments]{Acknowledgments}` gives a starred heading a contents entry and a
bookmark (a kernel key; `toc=` and `bookmark=` set the two texts separately). In `article` and
`report` the abstract is tagged as a Sect with an H2 heading under the H1 title and gets a
bookmark that targets the abstract itself (LaTeX alone tags the article abstract BlockQuote and
report's title-page abstract as plain text; tagging-project issue 1327 is open). The layout is the
class's own. In `report` the abstract prints in the text flow, not on a page of its own.
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
`\textbackslash` lands as its own name, so write the word instead. The package loads graphicx;
`main.tex` sets `\graphicspath{{resources/}}`, and LaTeX looks beside the `.tex` file first, then
in `resources/`. Banners: "Picture with alt text" through
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
tables that follow. LaTeX writes Scope, ColSpan and RowSpan as attribute classes, which ISO
32000-2:2020 14.7.6.2 counts as attached to the cell and veraPDF reads, but PAC ignores
(tagging-project Discussion 1324) and Acrobat's Table Editor shows as "scope none", so the package
writes on every cell, next to those classes, a direct attribute dictionary: Scope on each header
cell, ColSpan and RowSpan on each spanning cell, and on each data cell a Headers array with the IDs
of the header cells that apply to it, row headers first, then column headers, most specific first
(ISO 32000-2:2020 Table 384). No standard requires the direct copies; the Headers arrays matter for
tables with group rows, where the ISO 32000-2 header search loses the top headers (ISO 14289-2:2024
8.2.5.26; Tagged PDF BPG 1.0.1 5.4.1). veraPDF does not check the Headers arrays, so the Table
Editor check is their only test. Presentation and div tables get nothing; Acrobat's checker reports
a presentation table under its Headers rule. Banners:
the "Table:" blocks and "Side by side, not a table".

### Figures and tables in the text

LaTeX tags each `figure` and `table` as an Aside whose first child is the Caption, but by default
it defers those structures to the end of the tree, its choice for PDF 1.7 readers that show an
Aside as a Note. The package sets `float/here`, so each structure stays where the float is
written, next to the text that cites it (house style: Clemson's PDF manual checks ask that tag
order match the page, and ISO 32000-2:2020 14.8.2.5.1 says it should; LaTeX's deferred form
passes too). The package also loads `float` and makes `[H]` the default placement for `figure`
and `table`, so each one prints where it is written; `\floatplacement{figure}{tbp}` in the
document lets figures float again, and the tag-tree position stays the same either way. `[!]` and
`[]` stop the build with `[H]` as default, and an `[H]` float with its caption inside a minipage
fails 8.2.5.27 (tagging-project issue 1549). The package's `\par` hooks end the paragraph before
a float; without them an `[H]` float right after a list or a displayed formula writes its Caption
outside the float, which veraPDF reports under 8.2.5.27 with no warning from LaTeX (issue 1532).
`figure*` and `table*` get the same hook; in a one-column document they float, because the float
package drops an `[H]` starred float from the page. Put `\caption` above the picture or tabular,
because the Caption is written first either way. On LaTeX 2026-06-01, leave a blank line before a
theorem, proof or other theorem-like block that follows a list, a displayed formula or a `quote`,
`center` or `verbatim` environment; without it the build stops with "text para hooks differ"
(tagging-project issues 1402 and 1415, fixed in the 2026-11-01 release).

### Lists

`itemize`, `enumerate` and `description` are tagged L, with Lbl and LBody for each item (ISO
32000-2:2020 14.8.4.8.2). Lettered items come from the kernel's own key,
`\begin{enumerate}[label=(\alph*)]`; the `enumitem` package cannot be loaded under tagging, but
its syntax is built in. Each item body holds its text as `LBody > Part > P`; that form is valid
(ISO 32000-2:2020 Annex L) and veraPDF accepts it. Keep nesting to two levels. Banner: "Lists".

### Mathematics

LaTeX tags every formula as a Formula and writes its MathML itself, which is what ISO 14289-2:2024
8.2.5.29.1 asks (the Math in PDF BPG 1.0 p. 4 states the clause; veraPDF tests only that math sits
inside a Formula); the package loads unicode-math so the MathML gets the right characters. MathML can sit in a
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
attaches the MathML file and the TeX source. Under `mathml-SE` the MathML is written during the run, so it needs no
second pass and no count appears in the log; a `math` element inside every Formula in the tag
tree is the proof. Two known warnings under `mathml-SE`: a numbered `multline` reports "structure
with label 0 is unknown" (issue 1407; use `multline*`), and an mhchem prescript such as
`\ce{^{14}C}` reports a reused label (issue 793; write it out in words).
`\MathMLintent{mean($x)}{{...}}` and `\MathMLarg{x}{...}` name what a formula means (Math in PDF
BPG 1.0 p. 15); keep the double braces, because a scripted single atom loses the intent silently.
Write `\symbf{v}`, `\symbfit{v}` and `\symcal{A}` for bold and script letters; `bm` does not work
with unicode-math, and `amssymb` loaded after the package stops the build (load it before the
package if a command name is missing). When LaTeX reads MathML from files (`mathml-AF`, no key at
all, or both forms), a file name with a comma makes LaTeX split its list of MathML files and drop
every formula's MathML; the package resets the list in that case and leaves it alone under
`mathml-SE`. Banners: "Inline and display math" through "Chemistry, units, bra-ket".

### Theorems and proofs

Under tagging LaTeX supplies amsthm's `\newtheorem`, `\theoremstyle` and `proof` itself and never
reads amsthm.sty. When the document starts, the package defines `theorem`, `lemma`,
`proposition`, `corollary`, `definition`, `example` and `remark` on one counter and `algorithm` on
its own, each only if the preamble has not defined that environment itself (a `\newtheorem` for
one of these names later in the document stops with "already defined"); `\newtheorem` adds any
other name. `algorithm` is a theorem-like block with an optional title, not a float, because the
`algorithm` package is listed currently incompatible; put the steps in an `algorithmic` body.
LaTeX tags each theorem, lemma and proof as a theorem-like block, role-mapped to Sect, with its
head as a Caption and its number as a Lbl (ISO 32000-2:2020 14.8.4.8.4; Tagged PDF BPG 1.0.1
4.2.4). A proof ends with the word QED (house style), which a screen reader reads; LaTeX's open
square is drawn with rules and announces nothing, and `\renewcommand{\qedsymbol}{\openbox}` after
the package restores it. Each of these environments is also its `\autoref` name, so
`\autoref{lem:x}` reads "Lemma 2"; an environment of your own gets one with
`\providecommand{\fooautorefname}{Foo}`. For a proof that ends with a displayed formula, leave
`\qedhere` out: with it the word QED sits inside the Formula ahead of the MathML, and inside
`align*` it is not read at all. Banner: "Theorems and algorithm".

### Footnotes and endnotes

`\footnote{...}` is all LaTeX needs: the note is tagged FENote, the mark is a Lbl holding the link,
and the tree cross-references mark and note (Ref) both ways, which PDF/UA-2 asks for (veraPDF
rules 8.2.5.14). The package adds the optional `NoteType Footnote` on each note through LaTeX's
footnote hook (Well-Tagged PDF 1.0; PDF/UA-2 8.2.5.14 only limits the value, and a missing one
reads as None), and sets note text at 9 pt, as Clemson's text page advises, with 7 pt raised marks
(with the `10pt` option LaTeX's own sizes would be 8 and 6 pt). `\footnotesize` becomes `\small`
everywhere, so `\thanks`, the endnote list and any `\footnotesize` text follow. The raised mark is
a link to the note and is underlined like every other link, at its own size.
LaTeX has no endnote support. The package loads `enotez`, listed partially compatible, and
configures it: `\endnote{...}` writes a note, `\printendnotes` prints the list where it stands
(nothing when there are none) under a heading that puts "Notes" in the contents and the bookmarks,
the mark links to the note and the note's number links back, the list is tagged as a numbered list
(not as FENote elements, which enotez does not write; tagging-project issue 728), and the marks are
roman so they stay apart from the arabic footnote marks. The `endnotes` package gives no link from
mark to note. Banners:
"Emphasis, footnote, endnote" and the FOOTNOTE AND ENDNOTE EXAMPLES section.

### Links and bookmarks

The package loads hyperref, and LaTeX then makes every `\ref`, `\cite`, `\href`, `\url` and contents
entry a link annotation inside a Link or Reference element with a structure destination, and gives
every page a structure tab order (ISO 14289-2:2024 8.2.5.20, 8.8, 8.9.3.3). Link text stays black
and is underlined by LaTeX itself, not by the viewer: the package loads `lua-ul`, which draws the
underline in the text (under the descenders, across line breaks, in the size of the current font,
so a footnote mark gets a mark-sized line), and switches it on inside hyperref's own link hooks,
`hyp/link/link` and `hyp/link/cite` for internal links and the `\href` and `\url` hook pairs for web
links; the rules are artifacts, like LaTeX's own rules. Every viewer shows the same underline and
no viewer border is drawn. This is Clemson's link style (the Links page asks for underlined links);
WCAG 2.1 1.4.1 holds either way, because the links are black. The contents and the lists of figures
and tables stay plain, because every line there is a link. To drop the underlines, remove the
package's code from all six hooks: `\RemoveFromHook{hyp/link/link}[clemson]` and the same for
`hyp/link/cite`, `cmd/href/before`, `cmd/href/after`, `cmd/url/before` and `cmd/url/after` (the
`\href` and `\url` pairs open and close a group, so both halves must go), and drop
`\hypersetup{pdfborder={0 0 0}}` as well, or the links get no visual cue at all. Name the
destination in the link text, never "click here"; `\email{name@clemson.edu}` (or
`\href{mailto:...}{...}`, as the example does) gives an email address as its own link whose text is
the address. `\autoref{sec:x}` links the whole phrase and prints "Section 3": the package adds the
names Section and Chapter to babel's names for the main language (hyperref's own are lowercase
there, and babel re-applies its names at every switch back to the main language) and names each of
its theorem-like environments; hyperref already names figures, tables, equations, appendices,
footnotes and items. A name of your own for a section-level counter goes into
`\addto\extrasamerican{...}` (for `lang=en-US`). `\tableofcontents`, `\listoffigures` and
`\listoftables` print starred headings with no outline entry, so the package adds a bookmark
before each (at chapter level in `report` and `book`, where it also turns the page first, so the
bookmark points at the heading's page) and one inside the abstract. Banners: "Links, citations",
"Cross-references".

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
`\raggedright` when the document starts and keeps the paragraph indent the class or the document
set, which LaTeX records as TextAlign Start on body paragraphs; footnotes get the same setting.
Text in minipages, parboxes, floats and `p` columns stays justified, because LaTeX resets it
there, and theorem and proof bodies keep their justified templates.
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
| Scope, ColSpan, RowSpan and Headers as direct attributes on every `tabular` cell (for Acrobat and PAC; no standard requires the copies, Headers matter for group rows) | clemson.sty (TABLE CELLS) | ISO 32000-2:2020 14.8.4.8.3, Table 384; ISO 14289-2:2024 8.2.5.26 |
| Floats as Aside with Caption first; structure kept where written; `[H]` placement with the `\par` hooks | LaTeX 2026-06-01; clemson.sty (`float/here`, float) | ISO 32000-2:2020 14.8.4.8.4, 14.8.2.5.1 (house style); ISO 14289-2:2024 8.2.5.27 |
| Figure with Alt, ActualText or artifact | LaTeX 2026-06-01, from the author's keys | ISO 32000-2:2020 14.8.4.8.5, 14.9.4 |
| Formula with MathML, kept when the file name holds a comma | LaTeX 2026-06-01 with unicode-math; clemson.sty | ISO 14289-2:2024 8.2.5.29.1 |
| Theorems as Sect with Caption and Lbl; the environments, their `\autoref` names and the word QED | LaTeX 2026-06-01 (amsthm's commands built in); clemson.sty (environments, QED) | ISO 32000-2:2020 14.8.4.8.4; ISO 14289-2:2024 8.2.5.27 |
| Footnotes as FENote with Ref both ways, optional NoteType, 9 pt notes; endnotes linked both ways in a numbered list with a contents entry | LaTeX 2026-06-01; clemson.sty (NoteType, size, enotez) | ISO 14289-2:2024 8.2.5.14, 8.2.5.8, 8.2.5.25 |
| Links in Link elements, structure destinations, tab order; underline drawn by LaTeX in the text as artifacts, none in the contents; `\email`; `\autoref` names | LaTeX 2026-06-01 with hyperref; clemson.sty with lua-ul | ISO 14289-2:2024 8.2.5.20, 8.8, 8.9.3.3, 8.2.2; WCAG 2.1 1.4.1, 2.4.4; Clemson Links page |
| `\emph` as Em; `\strong` as Strong, in headings too | LaTeX 2026-06-01; clemson.sty | WCAG 2.1 1.3.1 (failure F2) |
| Document language | LaTeX 2026-06-01, from `lang` | ISO 14289-2:2024 8.4.4; WCAG 2.1 3.1.1 |
| Language of phrases and blocks with babel | clemson.sty (LANGUAGES block) | ISO 32000-2:2020 14.9.2; WCAG 2.1 3.1.2 |
| Code and code lines | LaTeX 2026-06-01 | ISO 32000-2:2020 14.8.4.6, 14.8.4.7 |
| Page numbers and running heads as artifacts | LaTeX 2026-06-01 | ISO 14289-2:2024 8.2.2 |
| Left-aligned text, TextAlign Start on body paragraphs and footnotes | clemson.sty (option `justified` turns it off) | Clemson text page; WCAG 2.1 1.4.8 (Level AAA, not required) |
| Fonts embedded with ToUnicode | LuaLaTeX and LaTeX 2026-06-01 | ISO 14289-2:2024 8.4.5.8 |

## Packages by field

| Use | Avoid | Why |
| --- | --- | --- |
| `unicode-math`, `amsmath` (both loaded by the package; `lua-unicode-math` loaded first is kept instead), the `amsthm` commands (built into LaTeX under tagging), `braket` | `amssymb` after the package, `bm`, `thmtools`, `ntheorem`, `tikz-cd` | `amssymb` after unicode-math stops the build and `bm` does not work with it (load `amssymb` before the package if a name is missing; write `\symbf`); the rest are listed currently incompatible |
| `mhchem` (`$\ce{H2O}$`), `siunitx` | `chemfig`, `chemformula`, `physics` with `siunitx`, `\qtyrange` | `mhchem` and `physics` are unchecked on the status page and `siunitx` partially compatible (a number and its unit are separate formulas); `chemfig` and `chemformula` are incompatible, so draw structures as pictures with alt text; `\qtyrange` loses its numbers in the MathML |
| `verbatim`, `\verb`, `algpseudocode`, `algorithmicx` | `listings`, `minted`, `algorithm`, `algorithm2e`, `fancyvrb` | listed incompatible (`fancyvrb` partial); `algorithm` is a float that aborts with `[H]`; use the package's theorem-like `algorithm` block, as the example does |
| `booktabs`, `tabularx`, `longtable` | `multirow`, `tabularray`, `nicematrix`, `caption`, `subcaption`, `subfig` | listed incompatible; `longtable` is compatible but tags its caption as a cell and gets no cell attributes from the package; spans come from `table/multirow`; panels share one caption, as in "Two panels" |
| `graphicx` and `float` (both loaded by the package, with `[H]` and the two `\par` hooks), `tikz` with `alt={...}`, `placeins` | `pgfplots`, `wrapfig`, `pdfpages`, `floatrow`, `\newfloat` and `\restylefloat` from `float`, `titlesec` | incompatible or unsupported; export a plot as a picture with alt text; `float` is listed incompatible (status 2): those two commands break the tagging, `[!]` and `[]` stop the build with `[H]` as default, and an `[H]` float with its caption in a minipage fails 8.2.5.27 (tagging-project issue 1549); `titlesec` stops tagging and writes no PDF |
| the kernel's `label=` key | `enumitem` | the package cannot be loaded under tagging; its syntax is built in |
| `\footnote`; `enotez` for endnotes (loaded by the package) | `endnotes`, `postnotes` | `endnotes` gives no link from mark to note; `postnotes` does not build under LaTeX 2026-06-01; `enotez` is partially compatible |
| `babel` (loaded by the package; add languages with `\babelprovide[import]{...}`; `babel-english` compatible, `babel-spanish` partial) | `polyglossia` | cannot be loaded together with babel, so it cannot be used with the package |
| `multicol`, `geometry`, `fancyhdr`, `microtype`, `setspace`, `parskip`, `natbib`, `bookmark`; `biblatex`, `cleveref` (after `\usepackage{clemson}`), `csquotes`, `acronym` (all four partial) | `memoir`; journal classes (`IEEEtran`, `revtex4-2`, `llncs`); `beamer`; `glossaries` | listed incompatible or unsupported, and `glossaries` unchecked; send a journal the copy built with its own class; write an abbreviation out in the text |

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
   hyperref options go in `\hypersetup{...}` after `\usepackage{clemson}`, except the few that
   work only at load time, which go in `\PassOptionsToPackage{...}{hyperref}` before it. The
   package also loads `enotez`, `float`, `graphicx` and `babel`, and LaTeX supplies `amsthm`:
   delete those lines or keep them before the package (a `\usepackage[...]{babel}` line with
   options must come before it); delete `polyglossia`. `\newtheorem` lines in the preamble can
   stay, because the package skips every theorem environment the preamble defines; a
   `\graphicspath` line stays as it is; a `\pdfbookmark` line before `\tableofcontents` goes,
   since the package adds that bookmark. Keep the rest, including `amsmath`. Add
   `\usepackage{clemson}` after the other `\usepackage` lines (`cleveref`, if used, goes after
   it); keep `\title` and `\author` as they are unless the title has a comma. A
   class of your own built on `article`, `report` or `book` can stay; journal classes are listed
   incompatible.
5. Look up every remaining package in "Packages by field" and the status page. Most papers need
   `\bm{x}` replaced by `\symbfit{x}`, and each `subfigure` rebuilt like "Two panels".
6. Build, then check. On LaTeX 2026-06-01 the first build of an older document often stops with
   "text para hooks differ"; the cause is a theorem or proof right after a list, display or
   `center` with no blank line before it. Then the veraPDF output and the log lines under "Checking" are
   the to-do list. No program can see two things, so do them yourself: give every data table its
   `\tagpdfsetup` header line, and
   move every caption above its picture or tabular. Finish with the five checks by hand.

## After a LaTeX update

Several things in `clemson.sty` are tied to a LaTeX, hyperref or babel version, and each carries a
`REMOVE WHEN` line. The four blocks marked `A11Y WORKAROUND`: FLOATS adds a `\par` before each
float (tagging-project issue 1532); MATHML FILE NAME resets the MathML file list when the file name
holds a comma (only when LaTeX reads MathML files, with a documented key); LANGUAGES tags babel's
language switches (until babel or tagpdf writes the tag itself); TABLE CELLS reads latex-lab-table
internals to write the direct cell attributes, checks that each one still exists and, when a
LaTeX update has removed one, warns in the log and skips the attributes, so the build finishes
and LaTeX's attribute classes remain. The `\strong` hooks go when LaTeX ships `\strongemph`
(latex2e issue 1620), the `\pdfstringdef` line when hyperref handles `\strong`, the title plug
when issue 1625 makes an H1 title the default, the NoteType hook when LaTeX writes it (issue 728),
and the underline artifact when lua-ul marks its rules (issue 1581).
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

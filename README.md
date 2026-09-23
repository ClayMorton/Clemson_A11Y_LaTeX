# clemsona11y kit

This folder turns a LaTeX document into an accessible PDF. Accessible here means tagged. Besides
the printed page, a tagged PDF carries a description of the document's structure (headings,
paragraphs, lists, tables, pictures with alt text, formulas) that a screen reader can follow.
The current standard for such files is PDF/UA-2, and the kit's output meets it as far as a
validator can tell. The kit also follows Clemson's
[accessibility concepts](https://www.clemson.edu/accessibility/digital/concepts/).

The class and package, `clemsona11y.cls` and `clemsona11y.sty`, do the work. `main.tex` is a
one-page document for you to replace with your own. `example.tex` shows every kind of content the
kit handles, with a comment on each saying why it is written that way. Its parts are marked with
comment lines that start with `%----`: a three-line banner names each section of the file, and a
one-line banner names each example inside a section, so you can search the file for the one you
need. `Makefile.a11y` builds and checks either document. The text is set in Latin Modern, LaTeX's
standard face, and the kit has no option to change that.

```
clemsona11y.cls  clemsona11y.sty  main.tex  example.tex  references.bib  README.md  upstream.md  Makefile.a11y  resources/
```

## What you need

Install these first, in this order. The commands are typed in a terminal: on a Mac that is
Terminal, in Applications > Utilities. `sudo` asks for your Mac password and shows nothing while
you type it.

1. **TeX Live 2026** (MacTeX 2026 on a Mac), from [tug.org/texlive](https://tug.org/texlive/).
   If you already have TeX Live, `lualatex --version` prints its year at the end of the first
   line. An older year cannot be upgraded in place, so install 2026 next to it. Then bring 2026
   up to date, because the kit needs the LaTeX release of June 2026:

   ```
   sudo tlmgr update --self --all
   ```

   The kit builds only with LuaLaTeX, because only LuaLaTeX can write the MathML it needs. Under
   pdfLaTeX or XeLaTeX it stops with an error. On Windows, work inside WSL (Ubuntu). There, and
   on Linux, install TeX Live 2026 with the installer from tug.org, not with `apt`, whose TeX Live
   is years too old and cannot be updated.

2. **make**. On a Mac it comes with the Xcode Command Line Tools (`xcode-select --install`). On
   Ubuntu and in WSL, `sudo apt install make`.

3. **veraPDF**, which is optional. It is the program that checks a PDF against the PDF/UA-2 rules
   a program can check, and without it the check skips that step and says so. It runs on Java,
   so install a Java runtime first (for example Temurin from adoptium.net). Then run the installer
   from [verapdf.org](https://verapdf.org/software/) and put the folder you installed veraPDF into
   on your PATH. If that folder is `~/verapdf` on a Mac, run
   `echo 'export PATH="$HOME/verapdf:$PATH"' >> ~/.zshrc` and open a new Terminal window.
   `verapdf --version` should then print its version.

4. **Adobe Acrobat Pro** for the last part of the check. The free Acrobat Reader cannot show tags
   or reading order.

## Starting from scratch

1. Copy the whole folder and rename it after your project. Open a terminal and go into that
   folder, for example `cd ~/Documents/my-thesis`. Every `make` command in this README is typed
   there. Start by checking the TeX install:

   ```
   make -f Makefile.a11y requirements
   ```

   It answers `OK: LaTeX 2026-06-01 or newer`, or a `FAIL` line that says what to install.

2. Build the worked example once, to see what a finished document looks like:

   ```
   make -f Makefile.a11y example
   ```

   The terminal stays quiet for a minute or two while it builds (longer the very first time,
   when LuaLaTeX builds its font database), then prints the check report and ends with a
   `RESULT` line. Open `example.pdf` beside `example.tex` and keep both open while you write.
   Whenever you need a table, a figure, a formula, a footnote or a citation, search `example.tex`
   for the `%----` banner that names it and copy the block. If the block needs a package, copy
   its `\usepackage` line too, from the PACKAGES block near the top of `example.tex`, where a
   comment says what each one is for.

3. Write in `main.tex`. Leave the `\DocumentMetadata{...}` block at the top exactly as it is,
   because it turns tagging on. Change the title and the authors in both places they appear: the
   printed text, and the `[pdftitle=...]` and `[pdfauthor=...]` brackets. The PDF viewer's title
   bar shows what is in the brackets, and a screen reader announces it. The doubled braces around
   the title keep a comma from splitting it. The plain `\documentclass{clemsona11y}` is an
   article, whose headings are `\section`, `\subsection` and `\subsubsection`. A thesis with
   chapters needs `\documentclass[report]{clemsona11y}`, and its headings start at `\chapter`.
   Use the levels in order and never skip one.

   Pictures go in `resources/`, where `\includegraphics{name}` finds them by file name;
   `references.bib` and any `\input` files stay next to `main.tex`. When you cite something,
   uncomment the four bibliography lines at the end of `main.tex` and put your entries in
   `references.bib`, which ships with the three entries the example cites. With `[report]` or
   `[book]`, change `{section}{\refname}` in the second of those lines to `{chapter}{\bibname}`,
   as its comment says. If you rename `main.tex`, say to `thesis.tex`, add `TARGET=thesis` (no
   `.tex`) to every `make` command that follows.

4. Mark up as you write. This is the part a screen reader depends on, and `example.tex` shows
   each item once.

   Every picture gets alt text: `\includegraphics[alt={what the picture shows}]{file}`. A picture
   that is only decoration gets `\includegraphics[artifact]{file}` instead and is skipped. A
   drawing made with `tikz` takes the same key, `\begin{tikzpicture}[alt={...}]`.

   Every table says which cells are headers, with `\tagpdfsetup{table/header-rows={1}}`,
   `\tagpdfsetup{table/header-columns={1}}` or both on the line before `\begin{tabular}`. A
   `tabular` that only lines text up, with no data in it, gets
   `\begingroup\tagpdfsetup{table/tagging=false}` ... `\endgroup` around it instead.

   The caption of every figure and table goes above the picture or the tabular, because that is
   the order in which the tags are written. Leave a blank line before `\begin{figure}` and
   `\begin{table}`. Inside the environment use only `\centering`, `\includegraphics`,
   `tikzpicture`, `tabular`, `\hfill`, `\caption`, `\label` and `\tagpdfsetup`. A `center`
   environment, a list or `\[ \]` inside a float stops the build. Text written inside a float,
   other than the caption, is dropped from the tags, so a source note belongs in the caption or
   in the paragraph after the float.

   Cross-references use `\autoref{label}`, which makes the whole phrase ("Section 3", "Figure 2")
   the link. Lemmas, corollaries and the other theorem-like blocks share the theorem counter, so
   `\autoref` has no name for them and prints only the number; point at those with
   `\hyperref[label]{Lemma~\ref*{label}}`, as `example.tex` does. Email addresses use
   `\email{name@clemson.edu}`.

5. Build:

   ```
   make -f Makefile.a11y
   ```

   This runs latexmk, which repeats LuaLaTeX and BibTeX until every reference and link is
   resolved. A single LuaLaTeX pass is not enough, because it leaves `??` where the references
   go. If you build from an editor, check how many passes it runs. VS Code with LaTeX Workshop
   reads the `% !TEX` lines at the top of `main.tex` and builds with LuaLaTeX, but it runs a
   single pass unless the two `% !BIB` lines are there as well. Once you cite something, copy
   those two lines from the top of `example.tex`. Until then leave them out, because with
   nothing cited BibTeX stops the build. TeXShop always runs one pass per click, so press
   Typeset, then BibTeX, then Typeset twice. Whichever editor you use, build with `make` once
   more before you hand the PDF in.

6. Check:

   ```
   make -f Makefile.a11y check
   ```

   The check builds the document again quietly, then prints a report in two parts. The first
   part, "Checked automatically", is what a script can verify. It tests that the document builds,
   that every picture has alt text, that no reference
   prints as `??`, that neither LaTeX's tagging nor the kit's own guards raised a warning, and
   that you load no package LaTeX cannot tag yet. It also gives veraPDF's PDF/UA-2 verdict. Each line is marked `OK`, `WARN`,
   `FAIL` or `SKIP`, and the report ends with a `RESULT` line (after a `FAIL`, make adds a line of
   its own ending in `Error 1` or `Error 2`; that is make reporting the failed check, not a second
   problem). A `FAIL` line names what to fix in
   the source. Fix it and run the check again, which rebuilds the document. A `WARN` line is
   something to look at. A `SKIP` line means a step could not run, because veraPDF is not
   installed or `check-tagging-status` was taken out of `\DocumentMetadata`.

   The second part, "Check by hand", is what only a person can judge. The report prints every
   alt text with its line number, so that you can read them back, and
   then lists what to look at in the PDF: the tags and the reading order in Acrobat Pro, the
   links by pressing Tab through them in any viewer, and the use of color. When the `RESULT`
   line says the automatic checks passed, open the PDF in Acrobat Pro, run All tools > Prepare
   for accessibility > Check for accessibility, and go through Clemson's
   [manual checks](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html).
   The report's five items are adapted from them. Acrobat's checker tests the older PDF/UA-1, and
   Acrobat's Tags panel shows LaTeX's own tag names, so some of what Acrobat shows is expected;
   "What the checkers still say" below lists it.

From then on, steps 3 to 6 repeat: write, build when you want to see the page, check before you
share it.

## Bringing an existing document over

Work on a copy of the project. The steps below get an existing paper or thesis to build with
the kit. After that, its text needs the same markup as step 4 of "Starting from scratch", and the
check tells you where it is missing.

1. Copy `clemsona11y.cls`, `clemsona11y.sty` and `Makefile.a11y` into the folder that holds the
   document's main `.tex` file. The check needs the Makefile beside that file. Open a terminal in
   the folder and run `make -f Makefile.a11y requirements`, as in step 1 of "Starting from
   scratch".

2. Put the `\DocumentMetadata{...}` block from `main.tex` at the very top of the main file, above
   `\documentclass`. Without it, tagging is off.

3. Change the class. If the document uses `article`, `report` or `book`, write
   `\documentclass{clemsona11y}`, `\documentclass[report]{clemsona11y}` or
   `\documentclass[book]{clemsona11y}`. Options such as `11pt` or `letterpaper` can stay in the
   brackets, but `twocolumn` cannot, because two columns break the reading order. The kit sets
   the text in Latin Modern and ragged right, and keeps figures and tables where they are
   written; the `align=justified` and `floats=free` options under "Options" below switch the last
   two off.

   If the document uses a class of its own built on one of the three, such as the Graduate
   School's `ClemsonThesis`, keep it and add `\usepackage{clemsona11y}` as the last line of the
   preamble. The theorem environments, endnotes, `\email` and the `resources/` picture folder come
   only with the kit's class, so in that case keep your own preamble lines for any of these you
   use. A class that prints its own title page, as `ClemsonThesis` does, leaves the title untagged
   and the thesis without an H1; the HEADINGS block of `clemsona11y.sty` says how to tag that
   title line yourself.

   Journal classes (IEEEtran, revtex, elsarticle and the like) are not supported by LaTeX's
   tagging yet. Build the accessible copy with the kit's class, and send the journal the copy
   built with its own class.

4. Clean up the preamble. Delete the lines that load `amsmath`, `graphicx`, `float`, `fontspec`,
   `unicode-math` or `hyperref`; the kit loads all six. If one of them had options, move them
   into a `\PassOptionsToPackage{options}{package}` line above the class or package line. Delete
   `inputenc`, `fontenc` and font packages such as `times`, `mathptmx`, `newtxtext`, `newtxmath`
   or `lmodern`, because the kit sets Latin Modern itself through fontspec and unicode-math, and
   those packages would override that setup (`lmodern`, for one, keeps the text in Latin Modern but
   redeclares the maths fonts as the older Type 1 ones). Delete `babel`; the `lang` key in `\DocumentMetadata` already
   sets the language. If you switched to `\documentclass{clemsona11y}`, also delete `amsthm`,
   `enotez` and every `\newtheorem` for theorem, lemma, proposition, corollary, definition,
   example, remark or algorithm, since the class defines them.

   Then look up every other package you load in the table under "Packages by field". Each row
   of that table is one field: "Use" lists what tags correctly there, "Avoid" what does not, and
   "Why" says what goes wrong with the avoided ones. Three changes come up in most papers.
   Delete `amssymb`, because the kit's maths font already has its symbols and loading `amssymb`
   stops the build. Replace `\bm{x}` with `\symbfit{x}`, or with `\symbf{x}` for bold upright.
   Rebuild each `subfigure` like the "Two panels" block in `example.tex`, with one
   `\includegraphics` and its own alt text per panel, `\hfill` between the panels and one
   caption that names (a) and (b).

5. If the project has its own Makefile, keep it, but switch it to LuaLaTeX: `pdflatex` becomes
   `lualatex`, and `latexmk -pdf` becomes `latexmk -lualatex`. The kit's check runs its own build,
   so you can run `make -f Makefile.a11y TARGET=paper check` (for a main file called
   `paper.tex`) at any time. To run it from your own Makefile, add a target whose recipe is
   `$(MAKE) -f Makefile.a11y TARGET=paper check`. Do not copy the `check` recipe itself, because
   it depends on settings earlier in `Makefile.a11y`. If the project has no Makefile, rename
   `Makefile.a11y` to `Makefile` and change its `TARGET ?= main` line to your file's name without
   `.tex`, for example `TARGET ?= paper`. From then on, `make` and `make check` are all you type.

6. Build, then check:

   If you left your paper as main.tex, then simply do

   ```
   make -f Makefile.a11y
   make -f Makefile.a11y check
   ```

   OR if you titled it something else, use

   ```
   make -f Makefile.a11y TARGET=<paper>
   make -f Makefile.a11y TARGET=<paper> check
   ```

   Expect the first build of an older document to stop. The usual cause is a `center`
   environment, a list or `\[ \]` inside a `figure` or `table`, and LaTeX reports it only at
   `\end{document}`, as "text para hooks differ", without naming the float, so search every
   float for them. Step 4 of "Starting from scratch" says what a float may hold. Once the
   document builds, the `FAIL` and `WARN` lines of the check are the to-do list: pictures without
   alt text, references that print as `??`, packages LaTeX cannot
   tag, and whatever else LaTeX's tagging complains about. The check cannot see two things, so do
   them yourself: give every table its `\tagpdfsetup` header line, and move every caption above
   its picture or tabular. Fix what the check lists and run it again until the `RESULT` line says
   the automatic checks passed. Then do the checks by hand, as in step 6 of "Starting from
   scratch".

## What the Makefile does

Every command starts with `make -f Makefile.a11y` and is typed in the folder that holds the
Makefile. It works on `main.tex` unless you add `TARGET=name` for `name.tex`.
`make -f Makefile.a11y help` prints this list.

| Command | What it does |
| --- | --- |
| `make -f Makefile.a11y requirements` | tests the TeX install: LuaLaTeX, latexmk and a LaTeX of 2026-06-01 or newer |
| `make -f Makefile.a11y example` | builds the worked example, `example.tex` into `example.pdf`, and runs the check on it |
| `make -f Makefile.a11y` (or `... build`) | builds your document, `main.tex` into `main.pdf`, showing the full latexmk output |
| `make -f Makefile.a11y check` | builds quietly, runs the automatic checks and prints the list of what to check by hand |
| `make -f Makefile.a11y open` | builds and opens `main.pdf` |
| `make -f Makefile.a11y clean` | removes the build files (`.aux`, `.log`, `.toc` and so on) and keeps `main.pdf` |
| `make -f Makefile.a11y cleanall` | removes the build files and `main.pdf` |
| `make -f Makefile.a11y cleanex` | removes everything the example produced, `example.pdf` included |
| `make -f Makefile.a11y help` | prints this list |

## How to write great alt text

A screen reader speaks alt text word for word, so write what a listener needs to hear.

For a picture, say what it shows and why it is in the document, in one or two sentences, the way
you would describe it to a friend over the phone. Do not repeat the caption, which the reader
hears anyway, and do not describe the file. For a picture of people, Clemson's pattern is
"[name] and [name] [action] [location]". A chart, a map or a diagram carries more than one
sentence of meaning, so give it a short alt text that states its point and says where the full
description is, then put the description in the document as text or as a table (`example.tex`
shows this under "Chart, description, data table"). A rule or an ornament that says nothing gets
`artifact` instead of alt text, and the reader skips it.

Formulas need nothing from you. LaTeX writes the MathML for each one and its own alt text,
the formula's source, and the kit adds no direction of its own.


The check prints every alt text in the document with its line number.
Reading them back is the check; no tool can do it for you.

## What `example.tex` shows

| Area | Contents |
| --- | --- |
| Front and back matter | contents, list of figures, list of tables, appendix, endnotes, bibliography, all tagged and linked |
| Text | emphasis, footnote, endnote, links, citations, every cross-reference kind, lists (nested, lettered, description), block quote, special characters, code |
| Mathematics | inline and display math, `align`, `subequations`, `gather`, `multline*`, matrices, cases, chemistry, units, bra-ket, theorems, proofs, an algorithm; MathML on every formula |
| Pictures | alt text, two panels, a `tikz` diagram, an image of text, a decorative image, a chart with its description and data table, a long description in an appendix linked both ways |
| Tables | every layout in Clemson's [tables guide](https://www.clemson.edu/accessibility/digital/concepts/tables.html): header row, header column, both, two-level and merged headers, merged cells, one table per group, notes outside, no empty cells, a layout grid left untagged |
| Odds and ends | an artifact rule, a phrase in another language, an abbreviation written out, QED as a proof ending (one line in the class) |

The class and package files are divided by the same three-line banners, so a search for `%----`
steps through any of the three files block by block.

## Options

With `\documentclass{clemsona11y}`, the base class (`article`, `report` or `book`) and all of the
options below go in the `\documentclass` brackets. With your own class and
`\usepackage{clemsona11y}`, the options go in the `\usepackage` brackets, except `align` and
`theorems`, which belong to the class and are not available with `\usepackage`. A misspelt value
stops the build rather than being ignored.

| Option | Values (default first) | Effect |
| --- | --- | --- |
| `align` | `ragged`, `justified` | left-aligned text (Clemson's rule) or justified |
| `links` | `keep`, `hidden` | black text with underlined links, contents entries plain but linked; or no marking |
| `math` | `af`, `full` | MathML attached to each formula; or also in the tag tree (empty spacing tags in Acrobat) |
| `floats` | `here`, `free` | figures and tables stay where written, or float |
| `headings` | `word`, `kernel` | title is the only H1 and sections start at H2, or LaTeX's own levels |
| `pagination` | `plain`, `typed` | plain page-number artifacts, or typed ones for PDF/UA-1 checkers |
| `title` | `h1`, `none` | tag the title that LaTeX's own `\maketitle` prints as H1; or tag no title, for a class that prints its own title page, whose title line you then tag yourself (the HEADINGS block of `clemsona11y.sty` shows how) |
| `theorems` | `true`, `false` | theorem, lemma, proposition, corollary, definition, example, remark, algorithm |

## What the kit adds and changes

Everything below is done by `clemsona11y.cls` and `clemsona11y.sty`; the source of each item
sits under the `%----` banner named in the last column. `upstream.md` lists which of these are
stop-gaps for gaps in LaTeX's tagging code and how to contribute them, so that the kit can
shrink as LaTeX catches up.

Commands and environments the kit adds:

| Command | What it does | Where |
| --- | --- | --- |
| `\email{addr}` | a `mailto:` link whose visible text is the address | class, LINKS AND EMAIL |
| `theorem`, `lemma`, `proposition`, `corollary`, `definition`, `example`, `remark` | amsthm environments on one shared counter, their labels tagged `Span`; off with `theorems=false` | class, THEOREMS |
| `algorithm` | a theorem-like block with an optional title, `\begin{algorithm}[Title]`, for an `algorithmic` body; it is not a float | class, THEOREMS |
| `\endnote{...}`, `\printendnotes` | from `enotez`, which the class loads and configures | class, ENDNOTES |
| the `\documentclass` options | `align`, `theorems`, `floats`, `headings`, `title`, `links`, `pagination`, `math`; a wrong value stops the build | class, OPTIONS; package, OPTIONS |

Everything else an author writes is plain LaTeX: `\includegraphics[alt={...}]`,
`\tagpdfsetup{table/header-rows={1}}`, `\autoref`, `\strong`, `\caption[short]{long}` are the
kernel's, `graphicx`'s, `hyperref`'s and `fontspec`'s own commands.

Behaviour the kit changes, compared with a plain `article`, `report` or `book`:

| Behaviour | Plain LaTeX | With the kit | Where |
| --- | --- | --- | --- |
| Engine and release | any | LuaLaTeX and LaTeX 2026-06-01 or newer; the build stops otherwise, and also when `\DocumentMetadata` is missing or tagging is off | package, TOOLCHAIN GUARDS |
| Fonts | Computer Modern, Type 1 | Latin Modern through `fontspec` and `unicode-math`, small caps from Latin Modern Roman Caps; no option to change it | package, FONTS |
| Text alignment | justified | ragged right, in theorem bodies, proofs and lists too (`align=justified` restores) | class, TEXT ALIGNMENT |
| Floats | placed by LaTeX, tagged at the end of the tree | placed where written (`[H]`; `floats=free` restores) and tagged where written; the container is `Aside`; paragraph tagging is off inside a float, which limits what a float may hold | package, FLOATS |
| Headings | title `Title`, `\section` H1 | title is the only H1, chapters H2, sections H2 (article) or H3 (report, book), and so on down (`headings=kernel` restores) | package, HEADINGS |
| Links | colored boxes | black text, underline drawn by the viewer from the border style, none in the contents and lists; link boxes padded below the text; the footnote mark's link box sized to the raised numeral (`links=hidden` removes all marking) | package, LINKS AND BOOKMARKS, FOOTNOTES |
| Link descriptions | none | every link annotation carries a generic `/Contents` string for PDF/UA-1 checkers | package, LINK DESCRIPTIONS |
| `\autoref` names | hyperref's defaults | "Section", "Figure", "Table", "Equation", "Appendix", "Algorithm", "Chapter" | package, AUTOREF NAMES |
| Bookmarks | none for the front matter | numbered, open, three levels deep; the window shows the document title; contents, lists and abstract get entries | package, LINKS AND BOOKMARKS; class, FRONT-MATTER BOOKMARKS |
| Caption numbers, contents numbers, footnote marks and labels, theorem labels | tagged `Lbl` | tagged `Span`, so Acrobat's list rule stays quiet | package, LABELS AS SPAN; class, THEOREMS |
| Footnotes | note without a type; 8 pt text | `NoteType /Footnote`; note text 9 pt, raised marks 7 pt | package, FOOTNOTES; class, NOTE TEXT SIZE |
| Endnotes | not available | `enotez` with a link both ways, a tagged list, roman marks, "Notes" in the contents | class, ENDNOTES |
| Tables | `Scope` and spans only as attribute classes, no `/Headers` | `Scope`, `ColSpan`, `RowSpan` as direct attributes and `/Headers` with the IDs of the header cells on every cell | package, TABLE CELLS |
| Formulas | MathML off | MathML attached to every formula (`math=full` also puts it in the tag tree); LaTeX's own alt text | package, MATH |
| `\strong` | a font switch | tagged `Strong` | package, FONTS |
| Abstract | `BlockQuote` with a plain-text heading | a `Sect` with an H2 heading and a bookmark | class, ABSTRACT |
| Proofs | end with an open square | end with the word QED | class, THEOREMS |
| Pictures | found beside the `.tex` file | found in `resources/` first (`\graphicspath`) | class, PACKAGE AND PICTURES |
| Page numbers | artifacts | artifacts; `pagination=typed` marks them `/Pagination` for PDF/UA-1 checkers | package, PAGE NUMBERS |
| `twocolumn` | allowed | refused, because two columns break the reading order | class, OPTIONS |
| Long URLs | break only at `/` and `.` | break at hyphens too | class, BASE PACKAGES |
| A renamed tag name in a new LaTeX release | silently unmapped | a `Package clemsona11y Warning`, which fails the check | package, ROLE MAPPING GUARD |

## Packages by field

| Use | Avoid | Why |
| --- | --- | --- |
| `unicode-math`, `amsthm` (both loaded), `braket` | `amssymb`, `bm`, `thmtools`, `ntheorem`, `tikz-cd` | not tagged, or clash with unicode-math |
| `mhchem` (`$\ce{H2O}$`) | `chemfig`, `chemformula`, `chemmacros` | draw structures as pictures with alt text |
| `siunitx` or `physics` (not both) | `\qtyrange` | loses its numbers in the alt text |
| `algpseudocode`, `verbatim`, `fancyvrb` | `listings`, `minted`, `algorithm2e`, `algorithm` | not tagged; the class defines `algorithm` |
| `booktabs`, `tabularx` | `tabularray`, `nicematrix`, `multirow`, `caption`, `subcaption` | replace the table or caption code |
| `tikz` with `[alt={...}]` | `pgfplots` | export plots as pictures with alt text |
| `enotez` (loaded) | `endnotes` | no link from mark to note |
| the `lang` key in `\DocumentMetadata`; for a phrase, the Span in the "Rule, language, abbreviation, color" block | `babel` | `\foreignlanguage` writes no language tag |
| `equation`, `gather`, `multline*` | numbered `multline` | tagging warning |
| the expansion in the text | `glossaries`, `acronym` | unchecked, or only partly tagged |

For a package in neither column, look it up in LaTeX's own list at
<https://latex3.github.io/tagging-project/tagging-status/>; one that is not listed has not been
checked. The check's `packages` line names any package you load that the list marks unsupported
or currently incompatible, except `float.sty`, which the kit loads for `[H]` placement and which
LaTeX 2026-06-01 tags in place.

Without `multirow`, a cell that spans two rows starts with `\tagpdfsetup{table/multirow=2}`, and
the cell below it stays empty; for a cell in the first column that is the line before its row,
as in the example. When the cell spans columns as well, the key goes inside the `\multicolumn`
text. The "Table: merged cells" block in `example.tex` shows the first case in its rows and the
second in its comment. Do not use `longtable` for a table that runs over a page break, because it
tags its caption as a cell. Split the table into page-sized tables instead, each with its own
caption.

## After a LaTeX update

LaTeX's tagging code is still being finished, and the package works around four gaps in the
current release: the empty paragraph LaTeX would otherwise wrap around the picture or tabular in
a float, the clickable area of a footnote mark, the type of each
footnote, and the attributes that tie each table cell to its headers and record its spans. Each
one is marked `A11Y WORKAROUND` in `clemsona11y.sty`, with a `REMOVE WHEN` line that names the
LaTeX change that will make it unnecessary. All but the float fix first check that the part of
LaTeX they patch still exists; if it has gone, the workaround switches itself off and writes a
`Package clemsona11y Warning`, which makes the check fail. The package's tag renamings, the `Span`
labels among them, are guarded the same way.

So after every `tlmgr update`, run `make -f Makefile.a11y example` once, or the check on your own
document in a project that has no `example.tex`. A clean result means the parts of LaTeX the
workarounds rely on are still there. It does not tell you whether a workaround can be dropped.
For that, compare its `REMOVE WHEN` line with the LaTeX release notes. If the check fails after an
update, look up the workaround the warning names in `clemsona11y.sty` and fix it there. Your
document does not need to change.

## What the checkers still say

Acrobat's checker tests PDF/UA-1, an older standard, so a few of its remarks are expected. Figure
containers may show up as "Note", which is the PDF 1.7 fallback for `Aside`. The Tags panel shows
LaTeX's own names, which the role map turns into the standard ones: `text` is `P`, `text-unit` is
`Part`, `item` is `LI`, `itemlabel` is `Lbl`, `itembody` is `LBody`, `quote` is `BlockQuote`,
`verbatim` is `Code`, `footnote` is `FENote`, and `itemize`, `enumerate`, `description` and `list`
are all `L`. Leave those names alone. Acrobat also reports that it "cannot extract the embedded
font" for LMRoman17, the Latin Modern design used for titles. The font is valid (veraPDF and
fontTools both accept it), so ignore the message.

Some of what a checker lists is LaTeX's decision and is valid as it stands. `BBox` appears only on
figures. In the text, `\ref`, `\pageref`, `\eqref` and `\autoref` produce a plain `Link`, while
`\cite` wraps its link in a `Reference`, as each contents and list entry does. The steps of an
algorithm are tagged as an unordered list. A nested list sits inside the body of its parent item.
With `pagination=typed`, every header and footer gets an empty artifact element.

Link underlines come from the annotation's border style, which Acrobat draws and macOS Preview
does not. Readers in Preview still know where a link goes, because the link text names its
destination in every viewer.

Footnote and endnote text is set at 9 pt, Clemson's minimum. A PDF tool measures it as 8.97 pt,
because a TeX point is slightly smaller than a PDF point. The raised note marks are 7 pt, below
that minimum on purpose, since a mark is not text a reader reads.

veraPDF with `--flavour ua2` tests every PDF/UA-2 rule a program can check. It passes a picture
whose alt text is only its file name, so meeting PDF/UA-2 takes that PASS and the checks by hand.

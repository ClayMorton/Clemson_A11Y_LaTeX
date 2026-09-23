# clemsona11y kit

This folder turns a LaTeX document into an accessible PDF. Accessible here means a tagged PDF:
one that carries, next to the printed page, a description of its structure (headings, paragraphs,
lists, tables, pictures with alt text, formulas) that a screen reader can follow. The standard for
such files is PDF/UA-2, and the kit's output meets it as far as a validator can tell, following
Clemson's [accessibility concepts](https://www.clemson.edu/accessibility/digital/concepts/) along
the way.

The class and package, `clemsona11y.cls` and `clemsona11y.sty`, do the work. `main.tex` is a
one-page document for you to replace with your own. `example.tex` shows every kind of content the
kit handles, with a comment on each saying why it is written that way; every example in it sits
under a comment line that starts with `%----` and names it, so you can search the file for the one
you need. `Makefile.a11y` builds and checks either document.

```
clemsona11y.cls  clemsona11y.sty  main.tex  example.tex  references.bib  README.md  Makefile.a11y  resources/
```

## What you need

Install these first, in this order.

1. **TeX Live 2026** (MacTeX 2026 on a Mac), from [tug.org/texlive](https://tug.org/texlive/).
   If you already have TeX Live, `lualatex --version` prints its year at the end of the first
   line. An older year cannot be upgraded in place, so install 2026 next to it. Then bring 2026
   up to date, because the kit needs the LaTeX release of June 2026:

   ```
   sudo tlmgr update --self --all
   ```

   The kit builds only with LuaLaTeX, since only LuaLaTeX can write the MathML it needs, and
   stops with an error under pdfLaTeX or XeLaTeX. On Windows, work inside WSL (Ubuntu) and
   install TeX Live 2026 there with the installer from tug.org, not with `apt`, whose TeX Live is
   years too old and cannot be updated. On Linux the same applies.

2. **make**. On a Mac it comes with the Xcode Command Line Tools (`xcode-select --install`). On
   Ubuntu and in WSL, `sudo apt install make`.

3. **veraPDF**, optional but worth having, because it is the program that verifies PDF/UA-2; without
   it the check skips that step and says so. It runs on Java, so install a Java runtime first (for
   example Temurin from adoptium.net), then the installer from
   [verapdf.org](https://verapdf.org/software/), and put the folder you installed it into on your
   PATH. For `~/verapdf` on a Mac that is
   `echo 'export PATH="$HOME/verapdf:$PATH"' >> ~/.zshrc`, then a new Terminal window;
   `verapdf --version` should answer.

4. **Adobe Acrobat Pro** for the last part of the check. The free Acrobat Reader cannot show tags
   or reading order.

## Starting from scratch

1. Copy the whole folder and rename it after your project. Open a terminal (Terminal on a Mac)
   and go into that folder, for example `cd ~/Documents/my-thesis`. Every command in this README
   is typed there. Start by checking the TeX install:

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
   `RESULT` line. Open `example.pdf` beside `example.tex`, and keep both open while you write:
   whenever you need a table, a figure, a formula, a footnote or a citation, search `example.tex`
   for the `%----` line that names it and copy the block. If the block needs a package, its
   `\usepackage` line is at the top of `example.tex` under `%---- PACKAGES`.

3. Write in `main.tex`. Leave the `\DocumentMetadata{...}` block at the top exactly as it is; that
   is what turns tagging on. Change the title and the authors in both places they appear, the
   `[pdftitle=...]` and `[pdfauthor=...]` brackets as well as the printed text, because the
   brackets are what the PDF's title bar and a screen reader announce (the doubled braces around
   the title keep a comma from splitting it). A thesis with chapters needs
   `\documentclass[report]{clemsona11y}`; the plain `\documentclass{clemsona11y}` is an article
   with sections. Use `\section`, `\subsection` and `\subsubsection` in that order and never skip
   a level. Pictures go in `resources/`, where `\includegraphics{name}` finds them by file name;
   `references.bib` and any `\input` files stay next to `main.tex`. When you cite something,
   uncomment the four bibliography lines at the end of `main.tex` and put your entries in
   `references.bib` (it ships with the three entries the example cites). If you rename
   `main.tex`, say to `thesis.tex`, add `TARGET=thesis` (no `.tex`) to every `make` command that
   follows.

4. Mark up as you write. This is the part a screen reader depends on, and `example.tex` shows
   each item once.

   Every picture gets alt text: `\includegraphics[alt={what the picture shows}]{file}`. A picture
   that is only decoration gets `\includegraphics[artifact]{file}` instead and is skipped. A
   drawing made with `tikz` takes the same key, `\begin{tikzpicture}[alt={...}]`.

   Every table says which cells are headers, with `\tagpdfsetup{table/header-rows={1}}`,
   `\tagpdfsetup{table/header-columns={1}}` or both on the line before `\begin{tabular}`. A
   `tabular` that only lines text up, with no data in it, gets
   `\begingroup\tagpdfsetup{table/tagging=false}` ... `\endgroup` around it instead.

   Every formula, inline ones included, has its spoken text right in front of it:
   `\mathalt{x squared plus one}$x^2+1$`. "How to write great alt text" below says how to word it.

   The caption of every figure and table goes above the picture or the tabular, because that is
   the order in which the tags are written. Inside a `figure` or `table` environment use only
   `\centering`, `\includegraphics`, `tikzpicture`, `tabular`, `\hfill`, `\caption`, `\label` and
   `\tagpdfsetup`. A `center` environment, a list or `\[ \]` in there stops the build, and any loose
   text is dropped from the tags, so a source note belongs in the caption or in the paragraph
   after the float.

   Cross-references use `\autoref{label}`, which makes the whole phrase ("Section 3", "Figure 2")
   the link, and email addresses use `\email{name@clemson.edu}`.

5. Build:

   ```
   make -f Makefile.a11y
   ```

   This runs latexmk, which repeats LuaLaTeX and BibTeX until every reference and link is
   resolved. A single LuaLaTeX pass is not enough; it leaves `??` where the references go. If you
   build from an editor, know what it does. VS Code with LaTeX Workshop reads the `% !TEX` lines at
   the top of `main.tex` and builds with LuaLaTeX, but runs a single pass unless the two `% !BIB`
   lines are there as well; copy them from the top of `example.tex` once you cite something (with
   nothing cited, BibTeX would stop the build). TeXShop always runs one pass per click, so press
   Typeset, then BibTeX, then Typeset twice. Whichever editor you use, build with `make` once more
   before you hand the PDF in.

6. Check:

   ```
   make -f Makefile.a11y check
   ```

   The check builds the document again quietly, then prints a report in two parts. "Checked
   automatically" is what a script can verify: the build, that every picture has alt text, that
   every formula has its spoken text, that no reference prints as `??`, that LaTeX's tagging
   raised no warning, that no package you load is one LaTeX cannot tag yet, and veraPDF's PDF/UA-2
   verdict. Each line is marked `OK`, `WARN`, `FAIL` or `SKIP`, and the report ends with a `RESULT`
   line. A `FAIL` names what to fix in the source; fix it, build, and run the check again. A
   `WARN` is something to look at; `SKIP` means veraPDF did not run.

   "Check by hand" is what only a person can judge. The report prints every alt text and every
   spoken formula with its line number, so that you can read them back, and then lists what to
   look at in the PDF: the tags and the reading order in Acrobat Pro, the links by pressing Tab
   through them in any viewer, and the use of color. When the `RESULT` line says the automatic
   checks passed, open the PDF in Acrobat Pro, run All tools > Prepare for accessibility > Check
   for accessibility, and go through Clemson's
   [manual checks](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html),
   which the report's six items follow. Acrobat's checker tests the older PDF/UA-1 and shows LaTeX's
   own tag names; "What the checkers still say" below explains what is expected there.

From then on, steps 3 to 6 repeat: write, build when you want to see the page, check before you
share it.

## Bringing an existing document over

Work on a copy of the project. The steps below get an existing paper or thesis to build with
the kit; after that, its text needs the same markup as step 4 above, and the check tells you where
it is missing.

1. Copy `clemsona11y.cls`, `clemsona11y.sty` and `Makefile.a11y` into the folder that holds the
   document's main `.tex` file. The check needs the Makefile beside that file. Open a terminal in
   the folder and run `make -f Makefile.a11y requirements` as in step 1 above.

2. Put the `\DocumentMetadata{...}` block from `main.tex` at the very top of the main file,
   above `\documentclass`. Without it, tagging is off.

3. Change the class. If the document uses `article`, `report` or `book`, write
   `\documentclass{clemsona11y}`, `\documentclass[report]{clemsona11y}` or
   `\documentclass[book]{clemsona11y}`. Options such as `11pt` or `letterpaper` can stay in the
   brackets; `twocolumn` cannot, because two columns break the reading order. Be aware that the
   kit changes the look: text set ragged right, and figures and tables where they are written.
   The options under "Options" below switch each of those off. If the document uses a class of
   your own built on one of the three, keep it and add `\usepackage{clemsona11y}` as the last line
   of the preamble; the theorem environments, endnotes, `\email` and the `resources/` picture
   folder come with the class only, so on this route you keep your own. Journal classes (IEEEtran,
   revtex, elsarticle and the like) are not supported by LaTeX's tagging yet, so build the
   accessible copy with this class and give the journal the copy built with theirs.

4. Clean up the preamble. Delete the lines that load `amsmath`, `graphicx`, `float`, `fontspec`,
   `unicode-math` or `hyperref`; the kit loads all six. If one of them had options, move them
   into a `\PassOptionsToPackage{options}{package}` line above the class or package line. Delete
   `inputenc`, `fontenc` and font packages such as `times`, `mathptmx`, `newtxtext`, `newtxmath`
   or `lmodern`, because the kit sets its fonts itself and those packages would quietly switch
   the text to a different font. Delete `babel`; the `lang` key in `\DocumentMetadata` already
   sets the language. If you switched to `\documentclass{clemsona11y}`, also delete `amsthm`,
   `enotez` and every `\newtheorem` for theorem, lemma, proposition, corollary, definition,
   example or remark, since the class defines them.

   Then look up every other package you load in the table under "Packages by field". A package in
   the "Avoid" column is replaced by the one in the "Use" column of its row; the "Why" column
   says what goes wrong otherwise. The ones most papers have: `amssymb` is deleted (the kit's
   maths font already has its symbols, and loading it stops the build); `\bm{x}` becomes
   `\symbfit{x}`, or `\symbf{x}` for bold upright; and each `subfigure` is rebuilt as the "Two
   panels" block in `example.tex`, one `\includegraphics` with its own alt text per panel,
   `\hfill` between them and one caption that names (a) and (b).

5. If the project has its own Makefile, keep it, but switch it to LuaLaTeX: `pdflatex` becomes
   `lualatex`, and `latexmk -pdf` becomes `latexmk -lualatex`. The kit's check runs its own build,
   so `make -f Makefile.a11y TARGET=paper check` works whenever you like; to start it from your
   Makefile, add a target whose recipe is `$(MAKE) -f Makefile.a11y TARGET=paper check` (do not
   copy the `check` recipe itself, which depends on the settings above it). If the project has
   no Makefile, rename `Makefile.a11y` to `Makefile`, change its `TARGET ?= main` line to your
   file's name, and from then on `make` and `make check` are all you type.

6. Build, then check, naming the file (`paper` stands for `paper.tex`):

   ```
   make -f Makefile.a11y TARGET=paper
   make -f Makefile.a11y TARGET=paper check
   ```

   Expect the first build of an older document to stop, and the usual cause is a `center`
   environment, a list or `\[ \]` inside a `figure` or `table`; step 4 of "Starting from scratch"
   says what a float may hold. Once the document builds, the `FAIL` and `WARN` lines of the check
   are the to-do list: pictures without alt text, formulas without `\mathalt`, references that
   print as `??`, packages LaTeX cannot tag, and whatever else LaTeX's tagging complains about.
   Two things the check cannot see and you have to do yourself: every table needs its
   `\tagpdfsetup` header line, and every caption has to move above its picture or tabular. Fix,
   build, check, and repeat until the `RESULT` line says the automatic checks passed; then do the
   checks by hand as in step 6 above.

## What the Makefile does

Every command starts with `make -f Makefile.a11y` and is typed in the folder that holds the
Makefile. It works on `main.tex` unless you add `TARGET=name` for `name.tex`.
`make -f Makefile.a11y help` prints this list.

| Command | What it does |
| --- | --- |
| `make -f Makefile.a11y requirements` | tests the TeX install: LuaLaTeX, latexmk and a LaTeX of 2026-06-01 or newer |
| `make -f Makefile.a11y example` | builds the worked example, `example.tex` into `example.pdf`, and runs the check on it |
| `make -f Makefile.a11y` | builds your document, `main.tex` into `main.pdf`, showing the full latexmk output |
| `make -f Makefile.a11y check` | builds quietly, runs the automatic checks and prints the list of what to check by hand |
| `make -f Makefile.a11y open` | builds and opens `main.pdf` |
| `make -f Makefile.a11y clean` | removes the build files (`.aux`, `.log`, `.toc` and so on) and keeps `main.pdf` |
| `make -f Makefile.a11y cleanall` | removes the build files and `main.pdf` |
| `make -f Makefile.a11y cleanex` | removes everything the example produced, `example.pdf` included |

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

For a formula the spoken text has to do two jobs at once: say the formula the way you would read
it aloud in front of a class, and name every letter and symbol the page shows, in the order it
shows them, so that a listener could write the formula down from your words. A good text for the
Gaussian integral is `\mathalt{the integral from minus infinity to infinity of e to the minus x
squared, d x, equals the square root of pi}`. "The Gaussian integral" is not enough, because it
says what the formula means rather than what it says, and "integral of e to the minus x squared"
is not enough either, because it drops the limits, the d x and the result. Letters are read as
letters ("x", "n", "capital A"), Greek letters by name ("pi", "theta"), subscripts the same way
throughout ("a sub 1"), and grouping in words ("the fraction one over k squared", "a plus b, all
squared"). A formula without `\mathalt` makes the reader hear the LaTeX source.

The check prints every alt text and every spoken formula in the document with its line number.
Reading them back is the check; no tool can do it for you.

## What `example.tex` shows

| Area | Contents |
| --- | --- |
| Front and back matter | contents, list of figures, list of tables, appendix, endnotes, bibliography, all tagged and linked |
| Text | emphasis, footnote, endnote, links, citations, every cross-reference kind, lists (nested, lettered, description), block quote, special characters, code |
| Mathematics | inline and display math, `align`, `subequations`, `gather`, `multline*`, matrices, cases, chemistry, units, bra-ket, theorems, proofs, an algorithm; spoken alt text on every formula |
| Pictures | alt text, two panels, a `tikz` diagram, an image of text, a decorative image, a chart with its description and data table, a long description in an appendix linked both ways |
| Tables | every layout in Clemson's [tables guide](https://www.clemson.edu/accessibility/digital/concepts/tables.html): header row, header column, both, two-level and merged headers, merged cells, one table per group, notes outside, no empty cells, a layout grid left untagged |
| Odds and ends | an artifact rule, a phrase in another language, an abbreviation written out, QED as a proof ending (one line in the class) |

The class and package files are divided by the same `%----` lines, so a search for `%----` steps
through any of the three files block by block.

## Options

With `\documentclass{clemsona11y}`, the base class (`article`, `report` or `book`) and all of the
options below go in the `\documentclass` brackets. With your own class and
`\usepackage{clemsona11y}`, the options go in the `\usepackage` brackets, except `align` and
`theorems`, which belong to the class and are not available on that route. A misspelt value stops
the build rather than being ignored.

| Option | Values (default first) | Effect |
| --- | --- | --- |
| `fonts` | `lm`, `termes`, `false` | Latin Modern (LaTeX's standard face), a Times clone for the Graduate School's thesis format, or your own fonts |
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

A package in neither column is in LaTeX's own list at
<https://latex3.github.io/tagging-project/tagging-status/>, and the check's `packages` line names
any package you load that LaTeX lists as not tagging yet.

Two things about tables that come up when `multirow` goes. A cell that spans rows is written as
`\tagpdfsetup{table/multirow=2}` on the line before the row, with the cell below it left empty;
when the cell spans columns as well, the key goes inside the `\multicolumn` text. The "Table:
merged cells" block in `example.tex` shows both. And a table that runs over a page break is split
into page-sized tables, each with its own caption, because `longtable` tags its caption as a cell.

## After a LaTeX update

LaTeX's tagging code is still being finished, and the package works around five gaps in the
current release: the empty paragraph LaTeX would otherwise wrap around the picture or tabular in
a float, the spoken text of formulas, the clickable area of a footnote mark, the type of each
footnote, and the attributes that tie each table cell to its headers and record its spans. Each
one is marked `A11Y WORKAROUND` in `clemsona11y.sty`, with a `REMOVE WHEN` line that names the
LaTeX change that will make it unnecessary. All but the float fix first check that the part of
LaTeX they patch still exists; if it has gone, the workaround switches itself off and writes a
`Package clemsona11y Warning`, which makes the check fail. The package's tag renamings, the `Span`
labels among them, are guarded the same way.

So after every `tlmgr update`, run `make -f Makefile.a11y example` once (or the check on your own
document, in a project that has no `example.tex`). A clean result means the parts of LaTeX the
workarounds rely on are still there. It does not mean a workaround can be dropped; for that,
compare its `REMOVE WHEN` line with the LaTeX release notes. If the check fails after an update,
the warning names the workaround, and the fix is in the package.

## What the checkers still say

Acrobat's checker tests PDF/UA-1, an older standard, so a few of its remarks are expected. Figure
containers may show up as "Note", which is the PDF 1.7 fallback for `Aside`. The Tags panel shows
LaTeX's own names, which the role map turns into the standard ones: `text` is `P`, `text-unit` is
`Part`, `item` is `LI`, `itemlabel` is `Lbl`, `itembody` is `LBody`, `quote` is `BlockQuote`,
`verbatim` is `Code`, `footnote` is `FENote`, and `itemize`, `enumerate`, `description` and `list`
are all `L`. Leave those names alone. Acrobat also reports that it "cannot extract the embedded
font" LMRoman17, the Latin Modern design used for titles; the font is valid (veraPDF and
fontTools both accept it) and the message can be ignored, or avoided with `fonts=termes`.

Some of what a checker lists is LaTeX's decision and is valid as it stands. `BBox` appears only on
figures. `\ref`, `\pageref` and `\eqref` produce a plain `Link`, and only `\cite` adds a `Reference`
around it. The steps of an algorithm are tagged as an unordered list. A nested list sits inside
the body of its parent item. With `pagination=typed`, every header and footer gets an empty
artifact element.

Link underlines come from the annotation's border style, which Acrobat draws and macOS Preview
does not; the link text names its destination in every viewer. Note text is set at 9 pt, which is
Clemson's minimum and which a PDF tool measures as 8.97 pt because a TeX point is slightly
smaller, and the raised footnote marks at 7 pt are below that minimum on purpose, since a mark
is not text a reader reads.

veraPDF with `--flavour ua2` is the authoritative verdict on PDF/UA-2.

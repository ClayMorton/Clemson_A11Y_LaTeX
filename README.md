# clemsona11y kit

This folder turns a LaTeX document into an accessible PDF. Accessible here means tagged: besides
the printed page, the PDF carries a description of the document's structure (headings,
paragraphs, lists, tables, pictures with alt text, formulas) that a screen reader can follow.
The current standard for accessible PDF is PDF/UA-2, and the kit's output meets it as far as a
validator can check. The kit also follows Clemson's
[accessibility concepts](https://www.clemson.edu/accessibility/digital/concepts/).

The class and package, `clemsona11y.cls` and `clemsona11y.sty`, do the work. `main.tex` is a
one-page document to replace with your own. `example.tex` shows every kind of content the kit
handles, with a comment on each explaining why it is written that way. Comment lines that start
with `%----` mark its parts: a three-line banner names each section of the file and a one-line
banner names each example in a section, so you can search the file for the one you need.
`Makefile.a11y` builds and checks either document. Text is set in Latin Modern, LaTeX's standard
face, and there is no option to change that.

```
clemsona11y.cls  clemsona11y.sty  main.tex  example.tex  references.bib  README.md  Makefile.a11y  resources/
```

## What you need

Install these first, in this order. Type the commands in a terminal (on a Mac, Terminal in
Applications > Utilities). `sudo` asks for your Mac password and shows nothing while you type it.

1. **TeX Live 2026** (MacTeX 2026 on a Mac), from [tug.org/texlive](https://tug.org/texlive/).
   If you already have TeX Live, `lualatex --version` prints its year at the end of the first
   line. An older year cannot be upgraded in place, so install 2026 next to it. Then update
   TeX Live 2026, because the kit needs the June 2026 LaTeX release:

   ```
   sudo tlmgr update --self --all
   ```

   The kit builds only with LuaLaTeX, because no other engine can write the MathML it needs.
   Under pdfLaTeX or XeLaTeX it stops with an error. On Windows, work inside WSL (Ubuntu). There
   and on Linux, install TeX Live 2026 with the installer from tug.org, not with `apt`: its
   TeX Live is years too old and cannot be updated.

2. **make**. On a Mac it comes with the Xcode Command Line Tools (`xcode-select --install`). On
   Ubuntu and in WSL, run `sudo apt install make`.

3. **veraPDF** (optional). It checks a PDF against the PDF/UA-2 rules a program can check.
   Without it, the check skips that step and says so. veraPDF runs on Java, so install a Java
   runtime first (for example Temurin from adoptium.net). Then run the installer from
   [verapdf.org](https://verapdf.org/software/) and add its install folder to your PATH. If that
   folder is `~/verapdf` on a Mac, run `echo 'export PATH="$HOME/verapdf:$PATH"' >> ~/.zshrc` and
   open a new Terminal window. Check that `verapdf --version` prints its version.

4. **Adobe Acrobat Pro** for the last part of the check. The free Acrobat Reader cannot show tags
   or reading order.

## Starting from scratch

1. Copy the whole folder and rename it after your project. Open a terminal and go into that
   folder, for example with `cd ~/Documents/my-thesis`. Run every `make` command in this README
   from there. Start by checking the TeX install:

   ```
   make -f Makefile.a11y requirements
   ```

   It prints `OK: LaTeX 2026-06-01 or newer`, or a `FAIL` line that says what to install.

2. Build the worked example once to see what a finished document looks like:

   ```
   make -f Makefile.a11y example
   ```

   The build prints nothing for a minute or two (longer the first time, when LuaLaTeX builds its
   font database), then prints the check report, which ends with a `RESULT` line. Open
   `example.pdf` next to `example.tex` and keep both open while you write. When you need a table,
   figure, formula, footnote or citation, search `example.tex` for the `%----` banner that names
   it and copy the block. If the block needs a package, also copy its `\usepackage` line from the
   PACKAGES block near the top of `example.tex`, where a comment says what each package is for.

3. Write in `main.tex`. Leave the `\DocumentMetadata{...}` block at the top exactly as it is; it
   turns tagging on. Change the title and the authors in both places: the printed text, and the
   `[pdftitle=...]` and `[pdfauthor=...]` brackets. The PDF viewer's title bar shows what is in
   the brackets, and a screen reader announces it. The doubled braces around the title keep a
   comma from splitting it. Plain `\documentclass{clemsona11y}` is an article, with the headings
   `\section`, `\subsection` and `\subsubsection`. A thesis with chapters needs
   `\documentclass[report]{clemsona11y}`, whose headings start at `\chapter`. Use the heading
   levels in order and never skip one.

   Put pictures in `resources/`, where `\includegraphics{name}` finds them by file name. Keep
   `references.bib` and any `\input` files next to `main.tex`. When you cite something, uncomment
   the four bibliography lines at the end of `main.tex` and put your entries in `references.bib`,
   which ships with the three entries the example cites. With `[report]` or `[book]`, change
   `{section}{\refname}` in the second of those lines to `{chapter}{\bibname}`, as its comment
   says. If you rename `main.tex`, say to `thesis.tex`, add `TARGET=thesis` (no `.tex`) to every
   `make` command that follows.

4. Mark up as you write. A screen reader depends on this markup, and `example.tex` shows each
   item once.

   Give every picture alt text: `\includegraphics[alt={what the picture shows}]{file}`. A picture
   that is only decoration gets `\includegraphics[artifact]{file}` instead, and a screen reader
   skips it. A `tikz` drawing takes the same key: `\begin{tikzpicture}[alt={...}]`.

   Mark the header cells of every table with `\tagpdfsetup{table/header-rows={1}}`,
   `\tagpdfsetup{table/header-columns={1}}` or both, on the line before `\begin{tabular}`. Do not
   line text up with a `tabular`: it is read row by row, so two authors over two universities are
   read name, name, university, university. Put each block in a `minipage`, inside
   `\par\begingroup\tagpdfsetup{para/tagging=false}` ... `\par\endgroup`, as `example.tex` does
   under "Side by side, not a table". Without the group, LaTeX leaves an empty paragraph tag
   before, between and after the minipages. Inside the group, text outside the minipages is
   dropped from the tags. A `tabular` that has to stay for layout gets
   `\begingroup\tagpdfsetup{table/tagging=false}` ... `\endgroup` around it, with `l`, `c` and `r`
   columns only. `table/tagging=presentation` does not help, because Acrobat fails a table without
   headers and ignores the presentation role.

   Put the caption of every figure and table above the picture or tabular, because the tags are
   written in that order. Leave a blank line before `\begin{figure}` and `\begin{table}`, and one
   before a theorem, proof or other theorem-like block that directly follows a list, a displayed
   formula or another environment set off from the text, such as `quote`, `center`, `flushright`,
   `verse`, `tabbing` or `verbatim`. Inside a float use only `\centering`, `\includegraphics`,
   `tikzpicture`, `tabular`, `\hfill`, `\caption`, `\label` and `\tagpdfsetup`. A `center`
   environment, a list or `\[ \]` inside a float stops the build. Text inside a float, other than
   the caption, is dropped from the tags, so put a source note in the caption or in the paragraph
   after the float.

   Use `\autoref{label}` for cross-references; it makes the whole phrase ("Section 3", "Figure 2")
   the link. Lemmas, corollaries and the other theorem-like blocks share the theorem counter, so
   `\autoref` has no name for them and prints only the number. Link to those with
   `\hyperref[label]{Lemma~\ref*{label}}`, as `example.tex` does. Write email addresses as
   `\email{name@clemson.edu}`.

5. Build:

   ```
   make -f Makefile.a11y
   ```

   This runs latexmk, which repeats LuaLaTeX and BibTeX until every reference and link is
   resolved. A single LuaLaTeX pass is not enough; it leaves `??` where the references go. If you
   build from an editor, check how many passes it runs. VS Code with LaTeX Workshop reads the
   `% !TEX` lines at the top of `main.tex` and builds with LuaLaTeX, but runs a single pass unless
   the two `% !BIB` lines are there too. Once you cite something, copy those two lines from the
   top of `example.tex`. Leave them out until then, because with nothing cited BibTeX stops the
   build. TeXShop runs one pass per click, so press Typeset, then BibTeX, then Typeset twice.
   Whatever editor you use, build with `make` once more before you hand in the PDF.

6. Check:

   ```
   make -f Makefile.a11y check
   ```

   The check rebuilds the document quietly and prints a report in two parts. The first part,
   "Checked automatically", covers what a script can verify: the document builds, every picture
   has alt text, every formula has its MathML attached, no reference prints as `??`, neither
   LaTeX's tagging nor the kit's own guards raised a warning, and you load no package LaTeX
   cannot tag yet. It also gives veraPDF's PDF/UA-2 verdict. Each line is marked `OK`, `WARN`,
   `FAIL` or `SKIP`, and the report ends with a `RESULT` line. After a `FAIL`, make adds its own
   line ending in `Error 1` or `Error 2`; that is make reporting the failed check, not a second
   problem. A `FAIL` line names what to fix in the source. Fix it and run the check again, which
   rebuilds the document. A `WARN` line is something to look at. A `SKIP` line means a step could
   not run because veraPDF is not installed or `check-tagging-status` was removed from
   `\DocumentMetadata`.

   The second part, "Check by hand", covers what only a person can judge. It prints every alt
   text with its line number so you can read them back, then lists what to look at in the PDF:
   the tags and reading order in Acrobat Pro, the links (press Tab through them in any viewer)
   and the use of color. When the `RESULT` line says the automatic checks passed, open the PDF in
   Acrobat Pro, run All tools > Prepare for accessibility > Check for accessibility, and go
   through Clemson's
   [manual checks](https://www.clemson.edu/accessibility/digital/guides/pdf/check-accessibility/manual-checks.html).
   The report's five items are adapted from them. Acrobat's checker tests the older PDF/UA-1,
   and its Tags panel shows LaTeX's own tag names, so some of what Acrobat shows is expected;
   "What the checkers still say" below lists it.

From then on, repeat steps 3 to 6 as you write: build when you want to see the page, and check
before you share it.

## Bringing an existing document over

Work on a copy of the project. The steps below get an existing paper or thesis to build with the
kit. After that, its text needs the markup from step 4 of "Starting from scratch", and the check
tells you where it is missing.

1. Copy `clemsona11y.cls`, `clemsona11y.sty` and `Makefile.a11y` into the folder that holds the
   document's main `.tex` file. The check needs the Makefile next to that file. Open a terminal
   in that folder and run `make -f Makefile.a11y requirements`, as in step 1 of
   "Starting from scratch".

2. Put the `\DocumentMetadata{...}` block from `main.tex` at the very top of the main file, above
   `\documentclass`. Without it, tagging is off.

3. Change the class. If the document uses `article`, `report` or `book`, write
   `\documentclass{clemsona11y}`, `\documentclass[report]{clemsona11y}` or
   `\documentclass[book]{clemsona11y}`. Options such as `11pt` or `letterpaper` can stay in the
   brackets, but `twocolumn` cannot, because two columns break the reading order. The kit sets
   the text in Latin Modern and ragged right, and keeps figures and tables where they are
   written. `align=justified` turns off ragged right and `floats=free` lets figures and tables
   float (see "Options" below).

   If the document uses its own class built on one of the three, such as the Graduate School's
   `ClemsonThesis`, keep it and add `\usepackage{clemsona11y}` as the last line of the preamble.
   The theorem environments, endnotes, `\email` and the `resources/` picture folder come only
   with the kit's class, so in that case keep your own preamble lines for any of these you use.
   A class that prints its own title page, as `ClemsonThesis` does, leaves the title untagged and
   the thesis without an H1. The HEADINGS block of `clemsona11y.sty` says how to tag that title
   line yourself.

   LaTeX's tagging does not support journal classes (IEEEtran, revtex, elsarticle and similar)
   yet. Build the accessible copy with the kit's class, and send the journal the copy built with
   its own class.

4. Clean up the preamble. Delete the lines that load `amsmath`, `graphicx`, `float`, `fontspec`,
   `unicode-math` or `hyperref`; the kit loads all six. If one of them had options, move them
   into a `\PassOptionsToPackage{options}{package}` line above the class or package line. Delete
   `inputenc`, `fontenc` and font packages such as `times`, `mathptmx`, `newtxtext`, `newtxmath`
   or `lmodern`. The kit sets Latin Modern itself through fontspec and unicode-math, and those
   packages override that setup (`lmodern`, for one, keeps the text in Latin Modern but
   redeclares the math fonts as the older Type 1 ones). Delete `babel`; the `lang` key in
   `\DocumentMetadata` already sets the language. If you switched to
   `\documentclass{clemsona11y}`, also delete `amsthm`, `enotez` and every `\newtheorem` for
   theorem, lemma, proposition, corollary, definition, example, remark or algorithm, since the
   class defines them.

   Then look up every other package you load in the table under "Packages by field". Each row of
   that table is one field: "Use" lists what tags correctly there, "Avoid" what does not, and
   "Why" says what goes wrong with the avoided ones. Most papers need three changes. Delete
   `amssymb`: the kit's math font already has its symbols, and loading `amssymb` stops the build.
   Replace `\bm{x}` with `\symbfit{x}`, or with `\symbf{x}` for bold upright. Rebuild each
   `subfigure` like the "Two panels" block in `example.tex`, with one `\includegraphics` and its
   own alt text per panel, `\hfill` between the panels and one caption that names (a) and (b).

5. If the project has its own Makefile, keep it but switch it to LuaLaTeX: `pdflatex` becomes
   `lualatex`, and `latexmk -pdf` becomes `latexmk -lualatex`. The kit's check runs its own
   build, so you can run `make -f Makefile.a11y TARGET=paper check` (for a main file called
   `paper.tex`) at any time. To run it from your own Makefile, add a target whose recipe is
   `$(MAKE) -f Makefile.a11y TARGET=paper check`. Do not copy the `check` recipe itself, because
   it depends on settings earlier in `Makefile.a11y`. If the project has no Makefile, rename
   `Makefile.a11y` to `Makefile` and change its `TARGET ?= main` line to your file's name without
   `.tex`, for example `TARGET ?= paper`. After that, `make` and `make check` are all you type.

6. Build, then check. If the main file is `main.tex`:

   ```
   make -f Makefile.a11y
   make -f Makefile.a11y check
   ```

   If it has another name, put that name, without `.tex`, in place of `<paper>`:

   ```
   make -f Makefile.a11y TARGET=<paper>
   make -f Makefile.a11y TARGET=<paper> check
   ```

   Expect the first build of an older document to stop. The usual cause is a `center`
   environment, a list or `\[ \]` inside a `figure` or `table`; the other is a theorem, proof or
   algorithm right after a list, a display or another such environment, with no blank line
   before it. LaTeX reports both only at `\end{document}`, as "text para hooks differ", without
   naming the place, so search every float, and the line before every theorem and proof. Step 4
   of "Starting from scratch" says what a float may hold. Once the
   document builds, the `FAIL` and `WARN` lines of the check are the to-do list: pictures without
   alt text, references that print as `??`, packages LaTeX cannot tag, and any other warning
   from LaTeX's tagging. The check cannot see two things, so do them yourself: give every table
   its `\tagpdfsetup` header line, and move every caption above its picture or tabular. Fix what
   the check lists and run it again until the `RESULT` line says the automatic checks passed.
   Then do the checks by hand, as in step 6 of "Starting from scratch".

## What the Makefile does

Run every command in the folder that holds the Makefile. Each one starts with
`make -f Makefile.a11y` and works on `main.tex` unless you add `TARGET=name` for `name.tex`.
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
| `make -f Makefile.a11y cleanex` | removes everything the example produced, including `example.pdf` |
| `make -f Makefile.a11y help` | prints this list |

## How to write alt text

A screen reader speaks alt text word for word, so write what a listener needs to hear.

For a picture, say what it shows and why it is in the document, in one or two sentences, the
way you would describe it to a friend over the phone. Do not repeat the caption, which the
listener hears anyway, and do not describe the file. For a picture of people, Clemson's pattern
is "[name] and [name] [action] [location]". A chart, a map or a diagram carries more than one
sentence of information. Give it a short alt text that states its point and says where the full
description is, then put the description in the document as text or as a table (`example.tex`
shows this under "Chart, description, data table"). A rule or an ornament that carries no
meaning gets `artifact` instead of alt text, and the screen reader skips it.

Formulas need nothing from you. LaTeX writes the MathML for each formula and uses the formula's
source as its alt text. The kit adds no alt text of its own. The check counts the formulas that
got their MathML and fails when none did.

The check prints every alt text in the document with its line number. Read them back yourself;
no tool can judge them for you.

## What `example.tex` shows

| Area | Contents |
| --- | --- |
| Front and back matter | contents, list of figures, list of tables, appendix, endnotes, bibliography, all tagged and linked |
| Text | emphasis, footnote, endnote, links, citations, every kind of cross-reference, lists (nested, lettered, description), block quote, special characters, code |
| Mathematics | inline and display math, `align`, `subequations`, `gather`, `multline*`, matrices, cases, chemistry, units, bra-ket, theorems, proofs, an algorithm; MathML on every formula |
| Pictures | alt text, two panels, a `tikz` diagram, an image of text, a decorative image, a chart with its description and data table, a long description in an appendix linked both ways |
| Tables | every layout in Clemson's [tables guide](https://www.clemson.edu/accessibility/digital/concepts/tables.html): header row, header column, both, two-level and merged headers, merged cells, one table per group, notes outside, no empty cells, two authors side by side without a table |
| Other | an artifact rule, a phrase in another language, an abbreviation written out, QED as a proof ending (one line in the class) |

The class and package files use the same three-line banners, so a search for `%----` steps
through any of the three files block by block.

## Options

With `\documentclass{clemsona11y}`, the base class (`article`, `report` or `book`) and all the
options below go in the `\documentclass` brackets. With your own class and
`\usepackage{clemsona11y}`, the options go in the `\usepackage` brackets, except `align` and
`theorems`, which belong to the class and are not available with `\usepackage`. A misspelled
value stops the build instead of being ignored.

| Option | Values (default first) | Effect |
| --- | --- | --- |
| `align` | `ragged`, `justified` | left-aligned text (Clemson's rule) or justified |
| `links` | `keep`, `hidden` | black text with underlined links, contents entries plain but linked; or no marking |
| `math` | `af`, `full` | MathML attached to each formula; or also in the tag tree (empty spacing tags in Acrobat) |
| `floats` | `here`, `free` | figures and tables stay where written, or float |
| `headings` | `word`, `kernel` | title is the only H1 and sections start at H2, or LaTeX's own levels |
| `pagination` | `plain`, `typed` | plain page-number artifacts, or typed ones for PDF/UA-1 checkers |
| `title` | `h1`, `none` | tag the title printed by LaTeX's own `\maketitle` as H1; or tag no title, for a class that prints its own title page, and tag its title line yourself (the HEADINGS block of `clemsona11y.sty` shows how) |
| `theorems` | `true`, `false` | define the theorem, lemma, proposition, corollary, definition, example, remark and algorithm environments, or not |

## What the kit adds and changes

`clemsona11y.cls` and `clemsona11y.sty` do everything below. The code for each item is under the
`%----` banner named in the last column. The items that work around gaps in LaTeX's tagging
code carry an `A11Y WORKAROUND` comment with a `REMOVE WHEN` condition; when a LaTeX release
meets it, the block can be deleted.

Commands and environments the kit adds:

| Command | What it does | Where |
| --- | --- | --- |
| `\email{addr}` | a `mailto:` link whose visible text is the address | class, LINKS AND EMAIL |
| `theorem`, `lemma`, `proposition`, `corollary`, `definition`, `example`, `remark` | amsthm environments on one shared counter, their labels tagged `Span`; off with `theorems=false` | class, THEOREMS |
| `algorithm` | a theorem-like block with an optional title, `\begin{algorithm}[Title]`, for an `algorithmic` body; it is not a float | class, THEOREMS |
| `\endnote{...}`, `\printendnotes` | from `enotez`, which the class loads and configures | class, ENDNOTES |
| the `\documentclass` options | `align`, `theorems`, `floats`, `headings`, `title`, `links`, `pagination`, `math`; a wrong value stops the build | class, OPTIONS; package, OPTIONS |

Everything else an author writes is plain LaTeX: `\includegraphics[alt={...}]`,
`\tagpdfsetup{table/header-rows={1}}`, `\autoref`, `\strong` and `\caption[short]{long}` are the
kernel's, `graphicx`'s, `hyperref`'s and `fontspec`'s own commands.

Behavior the kit changes, compared with a plain `article`, `report` or `book`:

| Behavior | Plain LaTeX | With the kit | Where |
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
| Caption numbers, contents numbers, footnote marks and labels, theorem labels | tagged `Lbl` | tagged `Span`, so Acrobat's list rule does not flag them | package, LABELS AS SPAN; class, THEOREMS |
| Footnotes | note without a type; 8 pt text | `NoteType /Footnote`; note text 9 pt, raised marks 7 pt | package, FOOTNOTES; class, NOTE TEXT SIZE |
| Endnotes | not available | `enotez` with a link both ways, a tagged list, roman marks, "Notes" in the contents | class, ENDNOTES |
| Tables | `Scope` and spans only as attribute classes, no `/Headers` | `Scope`, `ColSpan`, `RowSpan` as direct attributes and `/Headers` with the IDs of the header cells on every cell | package, TABLE CELLS |
| Formulas | MathML off | MathML attached to every formula (`math=full` also puts it in the tag tree); LaTeX's own alt text; the MathML file is found even when the file name has a comma | package, MATH |
| Code lines | `Justify` alignment on lines that print flush left | `TextAlign Start` | package, CODE LINES |
| List items | each item body `LBody > Part > P` | the item's text straight in `LBody` as `P`, a nested list or formula next to it, in `itemize`, `enumerate`, `description`, `list`, `trivlist` and the bibliography; footnote text, theorem, proof and quote bodies and minipage paragraphs inside an item drop their `Part` too | package, LIST ITEMS |
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
| `algpseudocode`, `verbatim` | `listings`, `minted`, `algorithm2e`, `algorithm`, `fancyvrb`, `verbatim*` | not tagged, or the text loses its spaces (`fancyvrb` also stops the build with two `Verbatim` blocks in a row); the class defines `algorithm` |
| `booktabs`, `tabularx` | `tabularray`, `nicematrix`, `multirow`, `caption`, `subcaption` | replace the table or caption code |
| `tikz` with `[alt={...}]` | `pgfplots` | export plots as pictures with alt text |
| `enotez` (loaded) | `endnotes` | no link from mark to note |
| the `lang` key in `\DocumentMetadata`; for a phrase, the Span in the "Rule, language, abbreviation, color" block | `babel` | `\foreignlanguage` writes no language tag |
| `equation`, `gather`, `multline*` | numbered `multline` | tagging warning |
| the expansion in the text | `glossaries`, `acronym` | unchecked, or only partly tagged |

For a package in neither column, look it up in LaTeX's own list at
<https://latex3.github.io/tagging-project/tagging-status/>. A package that is not listed has not
been checked. The check's `packages` line names any package you load that the list marks
unsupported or currently incompatible, except `float.sty`, which the kit loads for `[H]`
placement and which LaTeX 2026-06-01 tags in place.

Without `multirow`, start a cell that spans two rows with `\tagpdfsetup{table/multirow=2}` and
leave the cell below it empty. For a cell in the first column, the key goes on the line before
its row, as in the example. When the cell spans columns as well, the key goes inside the
`\multicolumn` text. The "Table: merged cells" block in `example.tex` shows the first case in its
rows and the second in its comment. Do not use `longtable` for a table that runs over a page
break, because it tags its caption as a cell. Split the table into page-sized tables instead,
each with its own caption.

## After a LaTeX update

LaTeX's tagging code is still in development, and the package works around six gaps in the
current release: the empty paragraph LaTeX would otherwise wrap around the picture or tabular in
a float, the text alignment written on code lines, the MathML file LaTeX cannot find when the
document's file name contains a comma, the clickable area of a footnote mark, the type of each
footnote, and the attributes that tie each table cell to its headers and record its spans. Each
one is marked `A11Y WORKAROUND` in `clemsona11y.sty`, with a `REMOVE WHEN` line that names the
LaTeX change that will make it unnecessary. The code-line, footnote and table fixes first check
that the part of LaTeX they patch still exists. If it is gone, the workaround turns itself off
and writes a `Package clemsona11y Warning`, which fails the check. The list-item change and the
package's tag renamings, including the `Span` labels, are guarded the same way. The MathML fix
sets a documented key, so a LaTeX release that drops the key stops the build with an error, and
the check's formulas line fails when no MathML was attached.

After every `tlmgr update`, run `make -f Makefile.a11y example` once, or run the check on your
own document if the project has no `example.tex`. A clean result means the parts of LaTeX the
workarounds rely on are still there. It does not tell you whether a workaround can be removed;
for that, compare its `REMOVE WHEN` line with the LaTeX release notes. If the check fails after
an update, find the workaround the warning names in `clemsona11y.sty` and fix it there. Your
document does not need to change.

## What the checkers still say

Acrobat's checker tests PDF/UA-1, an older standard, so a few of its remarks are expected. Figure
containers can show up as "Note", the PDF 1.7 fallback for `Aside`. The Tags panel shows LaTeX's
own tag names, which the role map turns into the standard ones: `text` is `P`, `text-unit` is
`Part`, `item` is `LI`, `itemlabel` is `Lbl`, `itembody` is `LBody`, `quote` is `BlockQuote`,
`verbatim` is `Code`, `footnote` is `FENote`, and `itemize`, `enumerate`, `description` and
`list` are all `L`. Leave those names alone. Acrobat also reports that it "cannot extract the
embedded font" for LMRoman17, the Latin Modern design used for titles. The font is valid
(veraPDF and fontTools both accept it), so ignore the message.

Some of what a checker lists is LaTeX's own choice and is valid as it is. `BBox` appears only on
figures. In the text, `\ref`, `\pageref`, `\eqref` and `\autoref` produce a plain `Link`, while
`\cite` wraps its link in a `Reference`, as each contents and list entry does. Algorithm steps
are tagged as an unordered list. With `pagination=typed`, every header and footer gets an empty
artifact element.

A list item's body holds its text as `P`, one per paragraph, with a nested list or a formula
next to it. Acrobat's own tagging and Clemson's remediation guide put one-line item text straight
into `LBody`; both forms are valid (ISO 32000-2 Annex L), and the `P` keeps the paragraphs of a
longer item apart. A nested list sits in its parent item's body, as Clemson's guide shows. ISO
32000-2 14.8.4.8.2 allows a list there, but counts a list as a sub-list only when it is a direct
child of its parent `L`, or of a `Div` that belongs to that `L`; a list inside `LBody` is not part
of the hierarchy. LaTeX's list code has no option to write that form.

Each theorem, lemma, proof and algorithm is tagged `theorem-like`, which the role map turns into
`Sect`, and its head, such as "Theorem 1.", is that block's first child, tagged `Caption`. In PDF
2.0 a caption belongs to the element that holds it (ISO 32000-2 14.8.4.8.4), so the head names its
own theorem and is not linked to any figure. It is not a heading on purpose: PDF/UA-2 forbids `H`,
and `H1` to `H6` would put every lemma and proof in the heading list. To tag the heads as plain
paragraphs instead, add `\AssignStructureRole{block/theorem-like/caption}{P}` after
`\documentclass`. Leave a blank line before a theorem-like block or a proof that directly follows
a list, quote, quotation, verse, center, flushleft, flushright, tabbing, verbatim or displayed
math; without it the build stops with "text para hooks differ", a LaTeX bug (tagging-project
issues 1402 and 1415) fixed for the next release.

`\verb` text is tagged `Code`, and each line of a `verbatim` block is a `codeline`, `Sub` in PDF
2.0 and `Span` in the PDF 1.7 role map that Acrobat reads. `Code` is a PDF 1.7 standard type that
PDF 2.0 keeps as standard (ISO 32000-2 14.8.6.1) and PDF/UA-2 accepts. NVDA does not announce it,
and the Tagged PDF BPG 1.0.1 (4.2.11) does not expect screen readers to. NVDA reads the characters
at the listener's punctuation level: at the default level, Some, it skips a backslash, braces and
brackets, which it speaks at Most or All, or when the listener reads by character. The same BPG
clause asks tools that reflow or convert the page not to justify the code or tidy its white
space, and says the tag does not promise usable code when the text is extracted.

Link underlines come from the annotation's border style, which Acrobat draws and macOS Preview
does not. Readers in Preview still know where a link goes, because the link text names its
destination in every viewer.

Footnote and endnote text is set at 9 pt, Clemson's minimum. PDF tools measure it as 8.97 pt
because a TeX point is slightly smaller than a PDF point. The raised note marks are 7 pt, below
that minimum on purpose, since a mark is not text a reader reads.

veraPDF with `--flavour ua2` tests every PDF/UA-2 rule a program can check. It passes a picture
whose alt text is only its file name, so meeting PDF/UA-2 takes both that PASS and the checks by
hand.

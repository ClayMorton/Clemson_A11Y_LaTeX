% clemsona11y.cls: accessible (tagged PDF/UA-2) class for papers and reports.
% Usage:   \DocumentMetadata{...}  (above \documentclass; see example.tex)
%          \documentclass[options]{clemsona11y}
% Options: article (default) | report | book;  theorems=false;
%          align=ragged (default) | justified;  package options
%          floats=here|free, headings=word|kernel,
%          title=h1|none, links=keep|hidden, pagination=plain|typed,
%          math=af|full;  any other key=value goes to the package, which stops
%          on an unknown key or value; a bare option (10pt, a4paper, ...) goes
%          to the base class; twocolumn is refused.
% Defines: \email{addr} (a mailto link whose text is the address) and, with
%          theorems=true, theorem, lemma, proposition, corollary, definition,
%          example, remark and algorithm.
% Loads:   base class, amsmath, amsthm (the environments above, with tagged
%          labels), enotez (endnotes), an accessible abstract, and
%          clemsona11y.sty last.
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{clemsona11y}[2026/09/21 v1.0 Accessible LaTeX class (Clemson A11Y)]

%------------------------------------------------------------------------------
% OPTIONS
%------------------------------------------------------------------------------
\newcommand*{\clemsonacls@base}{article}
\newcommand*{\clemsonacls@theorems}{true}
\newcommand*{\clemsonacls@align}{ragged}
\newcommand*{\clemsonacls@passed}{}
\DeclareOption{article}{\renewcommand*{\clemsonacls@base}{article}}
\DeclareOption{report}{\renewcommand*{\clemsonacls@base}{report}}
\DeclareOption{book}{\renewcommand*{\clemsonacls@base}{book}}
\DeclareOption{theorems=false}{\renewcommand*{\clemsonacls@theorems}{false}}
\DeclareOption{theorems=true}{\renewcommand*{\clemsonacls@theorems}{true}}
\DeclareOption{align=ragged}{\renewcommand*{\clemsonacls@align}{ragged}}
\DeclareOption{align=justified}{\renewcommand*{\clemsonacls@align}{justified}}
% twocolumn is refused. Two columns need column attributes and break the
% reading order in PDF/UA-1 tools.
% Meets: ISO 32000-2:2020 14.8.5.4.7 (column attributes).
\DeclareOption{twocolumn}{\ClassError{clemsona11y}{twocolumn is not supported}
  {Use one column. Two-column layout breaks the reading order in PDF/UA-1 tools.}}
% The options below go to clemsona11y.sty. The class default is links=keep
% (black text, underlined links). The font is always Latin Modern and no
% option changes it. pagination stays plain: typed writes /Type /Pagination
% on the folio as the BPG asks, but tagpdf adds an empty Artifact element per
% header and footer, some inside list items.
% Meets: ISO 32000-2:2020 14.8.2.2 (artifacts).
\PassOptionsToPackage{links=keep}{clemsona11y}
\DeclareOption{floats=here}{\PassOptionsToPackage{floats=here}{clemsona11y}}
\DeclareOption{floats=free}{\PassOptionsToPackage{floats=free}{clemsona11y}}
\DeclareOption{headings=word}{\PassOptionsToPackage{headings=word}{clemsona11y}}
\DeclareOption{headings=kernel}{\PassOptionsToPackage{headings=kernel}{clemsona11y}}
\DeclareOption{title=h1}{\PassOptionsToPackage{title=h1}{clemsona11y}}
\DeclareOption{title=none}{\PassOptionsToPackage{title=none}{clemsona11y}}
\DeclareOption{links=hidden}{\PassOptionsToPackage{links=hidden}{clemsona11y}}
\DeclareOption{links=keep}{\PassOptionsToPackage{links=keep}{clemsona11y}}
\DeclareOption{pagination=plain}{\PassOptionsToPackage{pagination=plain}{clemsona11y}}
\DeclareOption{pagination=typed}{\PassOptionsToPackage{pagination=typed}{clemsona11y}}
\DeclareOption{math=full}{\PassOptionsToPackage{math=full}{clemsona11y}}
\DeclareOption{math=af}{\PassOptionsToPackage{math=af}{clemsona11y}}
% Any other key=value option goes to the package, which errors on an unknown
% key or value. A bare option (10pt, a4paper) goes to the base class.
% align= and theorems= belong to the class, so a misspelled value stops the
% build here instead of ending up in the log as "Unused global option(s)".
\newcommand*{\clemsonacls@route}[1]{%
  \in@{=}{#1}%
  \ifin@
    \in@{align=}{#1}\ifin@
      \ClassError{clemsona11y}{Unknown value in '#1': use align=ragged or align=justified}{}%
    \else\in@{theorems=}{#1}\ifin@
      \ClassError{clemsona11y}{Unknown value in '#1': use theorems=true or theorems=false}{}%
    \else
      \PassOptionsToPackage{#1}{clemsona11y}%
    \fi\fi
  \else
    \edef\clemsonacls@passed{\clemsonacls@passed,#1}%
  \fi}
\DeclareOption*{\expandafter\clemsonacls@route\expandafter{\CurrentOption}}
\ProcessOptions\relax
\edef\clemsonacls@load{\noexpand\PassOptionsToClass{\clemsonacls@passed}{\clemsonacls@base}%
  \noexpand\LoadClass{\clemsonacls@base}}
\clemsonacls@load

%------------------------------------------------------------------------------
% BASE PACKAGES
%------------------------------------------------------------------------------
% url's hyphens option lets long URLs break at hyphens too. hyperref loads url
% later, so the option has to be passed now. Without it a long URL runs into
% the margin (an overfull box).
\PassOptionsToPackage{hyphens}{url}
\RequirePackage{amsmath}
% \clemsonacls@ragged: left-aligned text that keeps the paragraph indent.
% Used below for body text and for theorem and proof bodies (align=ragged).
\newcommand*{\clemsonacls@ragged}{\raggedright\setlength{\parindent}{1.5em}}

%------------------------------------------------------------------------------
% THEOREMS
%------------------------------------------------------------------------------
% Theorems use amsthm, with the label ("Lemma 2") tagged Span instead of Lbl.
% Acrobat's checker applies its list rule (Lbl only inside LI) to every Lbl.
% Span is valid for a label.
% Meets: ISO/TS 32005 (structure nesting); Tagged PDF BPG 1.0.1 4.2.4.
\ifx\clemsonacls@theorems\@empty\else
\def\clemsonacls@tmp{true}\ifx\clemsonacls@theorems\clemsonacls@tmp
  \RequirePackage{amsthm}
  \AssignStructureRole{block/theorem-like/label}{Span}
  % align=ragged: tagged amsthm justifies each theorem body itself, so the
  % \raggedright from \begin{document} does not reach it. A style's body font
  % comes after the justification, so the three amsthm styles are redeclared
  % with \raggedright in the body font, using amsthm's own \newtheoremstyle.
  % Meets: Clemson text concept (left-aligned text); WCAG 2.1 1.4.8 (advisory).
  \def\clemsonacls@tmp{ragged}
  \ifx\clemsonacls@align\clemsonacls@tmp
    \newtheoremstyle{plain}{}{}{\itshape\clemsonacls@ragged}{}{\bfseries}{.}{5pt plus 1pt minus 1pt}{}
    \newtheoremstyle{definition}{}{}{\normalfont\clemsonacls@ragged}{}{\bfseries}{.}{5pt plus 1pt minus 1pt}{}
    \newtheoremstyle{remark}{}{}{\normalfont\clemsonacls@ragged}{}{\itshape}{.}{5pt plus 1pt minus 1pt}{}
  \fi
  \theoremstyle{plain}
  \newtheorem{theorem}{Theorem}
  \newtheorem{lemma}[theorem]{Lemma}
  \newtheorem{proposition}[theorem]{Proposition}
  \newtheorem{corollary}[theorem]{Corollary}
  \theoremstyle{definition}
  \newtheorem{definition}[theorem]{Definition}
  \newtheorem{example}[theorem]{Example}
  % algorithm is a theorem-like block instead of a float. The algorithm package
  % is "Currently incompatible" on the LaTeX tagging status list: it tags its
  % caption as plain text and raises tagpdf warnings. This environment gets a
  % tagged Caption, a Span label and a counter for \ref. Put the steps in an
  % algorithmic body (algpseudocode).
  % Meets: ISO 32000-2:2020 14.8.4.6 (Caption); Tagged PDF BPG 1.0.1 4.2.4.
  \newtheorem{algorithm}{Algorithm}
  \theoremstyle{remark}
  \newtheorem{remark}[theorem]{Remark}
  % Proofs end with the word QED, which a screen reader reads aloud. amsthm's
  % open square is drawn with rules and is not announced. To get the square
  % back, comment out the next line.
  \renewcommand{\qedsymbol}{\textup{QED}}
\fi\fi

%------------------------------------------------------------------------------
% ABSTRACT
%------------------------------------------------------------------------------
% article and report tag the abstract as a BlockQuote and its "Abstract"
% heading as a plain P. The version below keeps the layout, tags it Sect with
% an H2 heading and gives it a bookmark.
% Meets: ISO 32000-2:2020 14.8.4.4 (Sect);
%        Tagged PDF BPG 1.0.1 4.2.2 (heading hierarchy).
\@ifundefined{abstract}{}{%
  \renewenvironment{abstract}{%
    \pdfbookmark[1]{\abstractname}{clemsona.abstract}%
    \begin{quotation}[tag-name=Sect, tagging-recipe=standalone]\small
    \begin{center}\AssignStructureRole{para/textblock}{H2}\bfseries\abstractname\end{center}%
  }{\end{quotation}}}

%------------------------------------------------------------------------------
% NOTE TEXT SIZE
%------------------------------------------------------------------------------
% Set note text to 9 pt, the floor in Clemson's text concept. \footnotesize
% is 8 pt on a 10 pt base and is the size both \footnote and enotez use for
% note text, so raising it here covers both. A TeX point is 1/72.27 in and a
% PDF point 1/72 in, so a PDF tool measures these 9 pt as 8.97.
% Meets: Clemson text concept (no text under 9 pt);
%        WCAG 2.1 1.4.4 (resize text).
\renewcommand{\footnotesize}{\small}
% The label in front of a footnote's text is a superscript in that 9 pt text,
% and LaTeX's script size for 9 pt is 6 pt. Declare 7 pt instead, so every
% raised mark, in the text and at the foot, is the same 7 pt. A raised mark is
% not body text; Clemson's floor is written for text a reader reads.
% Meets: Clemson text concept (no text under 9 pt);
%        WCAG 2.1 1.4.4 (resize text).
\DeclareMathSizes{9}{9}{7}{5}

%------------------------------------------------------------------------------
% ENDNOTES
%------------------------------------------------------------------------------
% \endnote{...} writes an endnote and \printendnotes prints them all. enotez is
% used because its mark links to the note and the note's number links back.
% list-style=description tags the list L/LI/Lbl/LBody, totoc=auto puts "Notes"
% in the table of contents, and counter-format=roman keeps endnote marks apart
% from the arabic footnote marks on the same page.
% Meets: ISO 32000-2:2020 14.8.4.7 (Link); Tagged PDF BPG 1.0.1 4.2.9 (lists).
\RequirePackage{enotez}
\setenotez{backref=true, list-style=description, totoc=auto,
  counter-format=roman}

%------------------------------------------------------------------------------
% PACKAGE AND PICTURES
%------------------------------------------------------------------------------
% Load the package last because it loads hyperref.
\RequirePackage{clemsona11y}
% Pictures go in resources/ next to the document. \includegraphics finds them
% there or beside the .tex file (the package above loads graphicx).
% \graphicspath replaces this list, so a document that adds a folder has to
% repeat resources/ in it: \graphicspath{{resources/}{figures/}}.
\graphicspath{{resources/}{./}}

%------------------------------------------------------------------------------
% TEXT ALIGNMENT
%------------------------------------------------------------------------------
% Clemson's text concept prefers left-aligned text and says to avoid justified
% text, so align=ragged is the default. \raggedright calls latex-lab's para
% instance, which writes TextAlign/Start into the paragraph's layout attribute;
% ragged2e's \RaggedRight does not. The indent is put back so paragraphs can
% still be told apart. Captions and headings stay centered.
% Meets: Clemson text concept; WCAG 2.1 1.4.8 (AAA, advisory).
\def\clemsonacls@tmp{ragged}
\ifx\clemsonacls@align\clemsonacls@tmp
  \AtBeginDocument{\clemsonacls@ragged}
  % Two blocks set their own alignment after \begin{document}: proof (its
  % template justifies it) and a plain list in a theorem, which inherits the
  % theorem block's justify para instance (itemize does not). \EditInstance is
  % the kernel's documented template command, but the instance names are
  % latex-lab's and can change with a kernel release: re-check after updates.
  % Meets: Clemson text concept.
  \IfInstanceExistsTF{captionedtext}{proof}
    {\EditInstance{captionedtext}{proof}{body-decls=\clemsonacls@ragged}}
    {\ClassWarningNoLine{clemsona11y}{Instance captionedtext/proof not found:
      proofs stay justified}}
  % enumerate and description inside a theorem inherit the justify too and
  % are not fixed yet (kit bug, upstream.md section 5).
  \IfInstanceExistsTF{blockenv}{list}
    {\EditInstance{blockenv}{list}{para-instance=}}
    {\ClassWarningNoLine{clemsona11y}{Instance blockenv/list not found: lists
      inside theorems stay justified}}
\fi

%------------------------------------------------------------------------------
% FRONT-MATTER BOOKMARKS
%------------------------------------------------------------------------------
% \clemsonacls@bookmarkpage: with chapters the heading starts a new page after
% the hooks below run, so turn the page before writing the bookmark, or it
% would point at the page before its heading.
\newcommand*{\clemsonacls@bookmarkpage}{\ifdefined\chapter
  \if@openright\cleardoublepage\else\clearpage\fi\fi}
% The contents and the two lists are H2 headings but write no outline entry,
% so a reader navigating by bookmarks cannot reach the front matter. Add one
% with hyperref's documented \pdfbookmark before each heading, so the entry
% lands on the right page. The abstract gets one in its own definition above.
% Meets: Tagged PDF BPG 1.0.1 7.2 (outlines).
\AddToHook{cmd/tableofcontents/before}{\clemsonacls@bookmarkpage\pdfbookmark[1]{\contentsname}{clemsona.toc}}
\AddToHook{cmd/listoffigures/before}{\clemsonacls@bookmarkpage\pdfbookmark[1]{\listfigurename}{clemsona.lof}}
\AddToHook{cmd/listoftables/before}{\clemsonacls@bookmarkpage\pdfbookmark[1]{\listtablename}{clemsona.lot}}

%------------------------------------------------------------------------------
% LINKS AND EMAIL
%------------------------------------------------------------------------------
% Link styling comes from the package (links=keep): black text, a viewer-drawn
% underline in running text, none in the contents. The class sets nothing more
% about links: a \hypersetup{colorlinks=...} here would clear that underline.
% \email{addr} makes a mailto link whose visible text is the address itself,
% as Clemson's links guidance asks, so a screen reader hears the address.
% Meets: Clemson links concept (email links); Tagged PDF BPG 1.0.1 4.2.12.1.
\providecommand{\email}[1]{\href{mailto:#1}{#1}}
\endinput

% clemsona11y.cls -- accessible (tagged PDF/UA-2) class for papers and reports.
% Usage:   \DocumentMetadata{...}      (first line of the .tex file; see main.tex)
%          \documentclass[options]{clemsona11y}
% Options: article (default) | report | book;  theorems=false;  package options
%          fonts=lm|termes|false, floats=here|free, headings=word|kernel,
%          title=h1|none, links=keep|hidden, pagination=plain|typed;
%          anything else (10pt, a4paper, ...) goes to the base class.
% Loads:   base class, amsmath, amsthm (+ theorem/lemma/... environments, tagged
%          labels), enotez (endnotes), an accessible abstract, and
%          clemsona11y.sty last.
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{clemsona11y}[2026/09/21 v1.0 Accessible LaTeX class (Clemson A11Y)]
\newcommand*{\clemsonacls@base}{article}
\newcommand*{\clemsonacls@theorems}{true}
\newcommand*{\clemsonacls@passed}{}
\DeclareOption{article}{\renewcommand*{\clemsonacls@base}{article}}
\DeclareOption{report}{\renewcommand*{\clemsonacls@base}{report}}
\DeclareOption{book}{\renewcommand*{\clemsonacls@base}{book}}
\DeclareOption{theorems=false}{\renewcommand*{\clemsonacls@theorems}{false}}
\DeclareOption{theorems=true}{\renewcommand*{\clemsonacls@theorems}{true}}
% twocolumn: refused. Two columns need column attributes and break the reading
% order in PDF/UA-1 tools. Meets: ISO 32000-2:2020 14.8.5.4.7 (column attributes).
\DeclareOption{twocolumn}{\ClassError{clemsona11y}{twocolumn is not supported}
  {Use one column. Two-column layout breaks the reading order in PDF/UA-1 tools.}}
% Package options are forwarded to clemsona11y.sty. The class defaults are
% fonts=lm and links=keep (the package colours and underlines links).
\PassOptionsToPackage{fonts=lm,links=keep}{clemsona11y}
\DeclareOption{fonts=lm}{\PassOptionsToPackage{fonts=lm}{clemsona11y}}
\DeclareOption{fonts=termes}{\PassOptionsToPackage{fonts=termes}{clemsona11y}}
\DeclareOption{fonts=false}{\PassOptionsToPackage{fonts=false}{clemsona11y}}
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
\DeclareOption*{\edef\clemsonacls@passed{\clemsonacls@passed,\CurrentOption}}
\ProcessOptions\relax
\edef\clemsonacls@load{\noexpand\PassOptionsToClass{\clemsonacls@passed}{\clemsonacls@base}%
  \noexpand\LoadClass{\clemsonacls@base}}
\clemsonacls@load
% url breaks long URLs at hyphens too; hyperref loads url later, so the option
% must be passed now. Without it a long URL runs into the margin (an overfull box).
\PassOptionsToPackage{hyphens}{url}
\RequirePackage{amsmath}
% Theorems: amsthm with the label ("Lemma 2") tagged Span, not Lbl. Acrobat's
% checker applies its list rule (Lbl only inside LI) to every Lbl; Span is valid
% for a label. Meets: ISO/TS 32005 (structure nesting); Tagged PDF BPG 1.0.1 4.2.4.
\ifx\clemsonacls@theorems\@empty\else
\def\clemsonacls@tmp{true}\ifx\clemsonacls@theorems\clemsonacls@tmp
  \RequirePackage{amsthm}
  \AssignStructureRole{block/theorem-like/label}{Span}
  \theoremstyle{plain}
  \newtheorem{theorem}{Theorem}
  \newtheorem{lemma}[theorem]{Lemma}
  \newtheorem{proposition}[theorem]{Proposition}
  \newtheorem{corollary}[theorem]{Corollary}
  \theoremstyle{definition}
  \newtheorem{definition}[theorem]{Definition}
  \newtheorem{example}[theorem]{Example}
  \theoremstyle{remark}
  \newtheorem{remark}[theorem]{Remark}
  % Proofs end with amsthm's open square, drawn with rules, so a screen reader
  % announces nothing at the end of a proof. To end proofs with the word QED
  % instead (read aloud, and preferred by some authors), uncomment the next line.
  % \renewcommand{\qedsymbol}{\textup{QED}}
\fi\fi
% Abstract: article/report tag it BlockQuote with "Abstract" as a plain P. This
% keeps the layout and tags it Sect with an H2 heading. Meets: ISO 32000-2:2020
% 14.8.4.4 (Sect); Tagged PDF BPG 1.0.1 4.2.2 (heading hierarchy).
\@ifundefined{abstract}{}{%
  \renewenvironment{abstract}{%
    \begin{quotation}[tag-name=Sect, tagging-recipe=standalone]\small
    \begin{center}\AssignStructureRole{para/textblock}{H2}\bfseries\abstractname\end{center}%
  }{\end{quotation}}}
% Endnotes: \endnote{...} writes one, \printendnotes prints them all. enotez is
% used because its mark is a link to the note and the note's number is a link
% back; list-style=description tags the list L/LI/Lbl/LBody, totoc=auto puts
% "Notes" in the table of contents, and roman numbering keeps endnote marks
% apart from the arabic footnote marks on the same page.
% Meets: ISO 32000-2:2020 14.8.4.7 (Link); Tagged PDF BPG 1.0.1 4.2.9 (lists).
\RequirePackage{enotez}
\setenotez{backref=true, list-style=description, totoc=auto,
  counter-format=roman}
% The package goes last: it loads hyperref.
\RequirePackage{clemsona11y}
% Link styling comes from the package (links=keep): black text, viewer-drawn
% underline in running text, none in the contents. A \hypersetup{colorlinks=...}
% here would clear that underline, so the class sets nothing more about links.
% \email: an address as a mailto link whose visible text is the address itself,
% the form Clemson's links guidance asks for; a screen reader hears the address.
% Meets: Clemson links concept (email links); Tagged PDF BPG 1.0.1 4.2.12.1.
\providecommand{\email}[1]{\href{mailto:#1}{#1}}
\endinput

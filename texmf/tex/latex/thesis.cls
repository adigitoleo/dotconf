% vim:fdm=marker
% ---------------------------------------------
% LaTeX Class for KOMA-script thesis documents.
% ---------------------------------------------
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{thesis}
\LoadClass[DIV=14]{scrbook}

% Page layout {{{1
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage[english]{babel}
\RequirePackage[stretch=10,shrink=10]{microtype}
\RequirePackage{setspace}
\RequirePackage[% Replaces fancyhdr
    automark,
    % headsepline
    ]{scrlayer-scrpage}

    % Set up a default header/footer style.
    \clearpairofpagestyles{}
    \cfoot[\pagemark]{\pagemark}
    \lehead{\headmark}
    \rohead{\headmark}
    \pagestyle{scrheadings}

% Fonts {{{1
\RequirePackage[autostyle=true]{csquotes}
\RequirePackage{libertine}
\RequirePackage[libertine]{newtxmath}
\RequirePackage{lettrine}

% Mathematics {{{1
\RequirePackage{mathtools}
\RequirePackage[italicdiff]{physics}
\RequirePackage{tensor}
\RequirePackage{siunitx}
    \sisetup{%
        range-units=single,
        separate-uncertainty=true,
    }

% Tables, figures & lists {{{1
\RequirePackage{booktabs}
\RequirePackage{multirow}
\RequirePackage{multicol}
\RequirePackage{graphicx}
    \setkeys{Gin}{width=.75\linewidth}
\RequirePackage[format=plain]{caption}
\RequirePackage{subcaption}
    \captionsetup*[table]{%
        labelfont={bf,it}, textfont=it,
    }
    \captionsetup*[figure]{%
        labelfont={bf,it}, textfont=it,
        subrefformat=parens,
        width=.75\linewidth,
    }
    \captionsetup*[subfigure]{%
        singlelinecheck=false,
        position=top,
    }
\RequirePackage{float}
    \floatplacement{figure}{ht!}
    \floatplacement{table}{ht}
\RequirePackage{wrapfig}
% \RequirePackage[shortlabels]{enumitem}
%     \setlist[enumerate]{noitemsep}

% Diagrams {{{1
\RequirePackage[table]{xcolor}
\RequirePackage{tikz}
    \usetikzlibrary{backgrounds}
    \usetikzlibrary{through}
    \usetikzlibrary{calc}
    \usetikzlibrary{shapes}
    \usetikzlibrary{arrows.meta}
    \tikzset{>=Latex}
    \usetikzlibrary{angles}
    \usetikzlibrary{quotes}
    \usetikzlibrary{optics}
    \usetikzlibrary{3d}
    \tikzset{%
    % Meta style to apply decorations to each
    % segment of a path.
    on each segment/.style={%
    decorate,
    decoration={%
        show path construction,
        moveto code={},
        lineto code={%
            \path[#1]
            (\tikzinputsegmentfirst) --
            (\tikzinputsegmentlast);},
        curveto code={%
            \path[#1]
            (\tikzinputsegmentfirst) .. controls
            (\tikzinputsegmentsupporta) and
            (\tikzinputsegmentsupportb) ..
            (\tikzinputsegmentlast);},
        closepath code={%
            \path[#1]
            (\tikzinputsegmentfirst) --
            (\tikzinputsegmentlast);},
}},}

% Citations {{{1
\RequirePackage[
    % Replaces natbib.
    backend=biber,
    % Use backrefs.
    % backref=true,
    % Better authoryear.
    style=ext-authoryear,
    % Initialize given names.
    uniquename=init,
    giveninits=true,
    % Names before et al. in bibliography.
    maxbibnames=99,
    % Names before et al. in text.
    maxcitenames=3,
    % Date: {year,short,long,terse,comp,ymd,iso}
    date=year,
    % Boolean options:
    bibwarn=true, % Warn about bad bibtex fields.
    articlein=false, % No "In:" before journals.
    url=false,
    isbn=false,
    eprint=false,
    dashed=false, % Don't replace authors with -.
    %
    % WIP refactor and comment:
    % urldate=long,
    % articletitle=false,
    % biblabel=brackets,
    % chaptertitle=false,
    % pageranges=false,
    ]{biblatex}

% WIP: Comment the extended citation options.
% vvv

\DeclareNameAlias{sortname}{family-given}

\DeclareFieldFormat{titlecase:title}{%
    \MakeSentenceCase*{#1}%
}

\DeclareFieldFormat{biblabeldate}{%
    % Formatting for the date in the ref list:
    #1\addcomma% Bare, with comma.
    % (#1)\addcomma% In parentheses, with comma.
}

\DeclareFieldFormat[article]{volume}{% Add "vol."
    \bibstring{jourvol}\addnbspace{}#1
}

\DeclareFieldFormat[article]{number}{% Add "no."
    \bibstring{number}\addnbspace{}#1
}

\renewbibmacro*{volume+number+eid}{%
    % Apply customizations of volume and number.
    \printfield{volume}
    % \setunit{\adddot}
    \setunit{\addcomma\space}
    \printfield{number}
    % \setunit{\adddot}
    \setunit{\addcomma\space}
    \printfield{eid}
}

\renewbibmacro*{journal+issuetitle}{%
    % Separate journal name and vol. with comma.
    % https://tex.stackexchange.com/a/134229
    \usebibmacro{journal}
    % \setunit*{\addspace}
    \setunit*{\addcomma\space}
    \iffieldundef{series}
    {}
    {%
        \newunit
        \printfield{series}
        % \setunit*{\addspace}
        \setunit{\addcomma\space}
    }
    \usebibmacro{volume+number+eid}
    \setunit{\addspace}
    \usebibmacro{issue+date}
    \setunit{\addcolon\space}
    \usebibmacro{issue}
    \newunit
}

\AtBeginBibliography{%
    % Define general delimiter.
    \renewrobustcmd*{\newunitpunct}{%
        \addcomma\space
    }
    % Make initials bare (no period or spacing).
    \renewrobustcmd*{\bibinitperiod}{}
    \renewrobustcmd*{\bibinitdelim}{}
    \renewrobustcmd*{\bibinithyphendelim}{}
    % Use "&" before last author IN REFERENCE.
    \renewrobustcmd*{\finalnamedelim}{%
        \space\&\space
    }
    % Use normal font for ulr/doi links.
    \urlstyle{same}
    % Single quotes for title if quoted.
    \setquotestyle{british}
}

% Use "&" before last author in \parencite.
\let\origparencite\parencite
\renewrobustcmd{\parencite}{%
    \AtNextCite{%
        \renewcommand*{\finalnamedelim}{%
            % Only if et al. is not applicable.
            \ifnumgreater{\value{liststop}}{2}{\finalandcomma}{}%
            \addspace\&\space
        }%
    }%
    \origparencite%
}

% \RequirePackage[warnundef]{jabbrv}

\RequirePackage[final]{hyperref}
    \hypersetup{%
        colorlinks=true,
        linkcolor=black,
        citecolor=blue,
        filecolor=magenta,
        urlcolor=blue,
    }
\RequirePackage{bookmark}
\RequirePackage[nameinlink]{cleveref}
    \Crefname{figure}{Figure}{Figures}
    \newcommand\crefrangeconjunction{--}

% Symbolic footnote markers.
% \renewcommand*{\thefootnote}{\fnsymbol{footnote}}
% \setcounter{footnote}{0}

% Frontmatter {{{1
% % WIP: make this section a class option.
% \RequirePackage{titling}
% \RequirePackage[intoc]{nomencl}
%     \makenomenclature{}
% \RequirePackage[
%     symbols,
%     nogroupskip,
%     nonumberlist,
%     automake,
%     ]{glossaries-extra}
%     \makeglossaries{}

% \RequirePackage{abstract}
%     \renewcommand{\abstractnamefont}{%
%         \normalfont \bfseries
%     }
%     \renewcommand{\abstracttextfont}{\itshape}

% Macros {{{1
\RequirePackage{xparse}

\let\TOC\tableofcontents
\renewcommand*{\tableofcontents}{%
    \microtypesetup{protrusion=false}
    % \clearpage\phantomsection\pdfbookmark{\contentsname}{toc}\TOC{}
    % \pdfbookmark{\contentsname}{toc}
    \TOC{}
    \microtypesetup{protrusion=false}
}
\BeforeTOCHead[toc]{%
    {% Add PDF bookmark for TOC.
        \cleardoublepage% Change if single-sided.
        \pdfbookmark[0]{\contentsname}{toc}
    }
}

\NewDocumentCommand\tightlist{}{%
    \setlength{\itemsep}{1pt}
    \setlength{\parskip}{0pt}
    \setlength{\parsep}{0pt}
}

% Like \today but suppress day of month.
\newcommand{\monthyear}{%
    \ifcase\month{}
        \or{January}\or{February}%
        \or{March}\or{April}\or{May}%
        \or{June}\or{July}\or{August}%
        \or{September}\or{October}%
        \or{November}\or{December}%
    \fi,
    \number\year{}
}

% Example custom macro, with one [optional] and
% one {mandatory} argument. Also provides a
% default value to the optional argument.
\NewDocumentCommand\MacroTest{O{red}m}{%
    \color{#1} #2
}

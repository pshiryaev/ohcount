// cshtml.rl written by Mitchell Foral. mitchell<att>caladbolg<dott>net.

/************************* Required for every parser *************************/
#ifndef RAGEL_CSHTML_PARSER
#define RAGEL_CSHTML_PARSER

#include "ragel_parser_macros.h"

// the name of the language
const char *CSHTML_LANG = "html";

// the languages entities
const char *cshtml_entities[] = {
  "space", "comment", "doctype",
  "tag", "entity", "any"
};

// constants associated with the entities
enum {
  CSHTML_SPACE = 0, CSHTML_COMMENT, CSHTML_DOCTYPE,
  CSHTML_TAG, CSHTML_ENTITY, CSHTML_ANY
};

/*****************************************************************************/

#include "css_parser.h"
#include "javascript_parser.h"
#include "clearsilver_parser.h"

%%{
  machine cshtml;
  write data;
  include common "common.rl";
  #EMBED(css)
  #EMBED(javascript)
  #EMBED(clearsilver)

  # Line counting machine

  action cshtml_ccallback {
    switch(entity) {
    case CSHTML_SPACE:
      ls
      break;
    case CSHTML_ANY:
      code
      break;
    case INTERNAL_NL:
      emb_internal_newline(CSHTML_LANG)
      break;
    case NEWLINE:
      emb_newline(CSHTML_LANG)
      break;
    case CHECK_BLANK_ENTRY:
      check_blank_entry(CSHTML_LANG)
    }
  }

  cshtml_comment := (
    newline %{ entity = INTERNAL_NL; } %cshtml_ccallback
    |
    ws
    |
    ^(space | [\-<]) @comment
    |
    '<' '?cs' @{ saw(CS_LANG); fcall cshtml_cs_line; }
    |
    '<' !'?cs'
  )* :>> '-->' @comment @{ fgoto cshtml_line; };

  cshtml_sq_str := (
    newline %{ entity = INTERNAL_NL; } %cshtml_ccallback
    |
    ws
    |
    [^\r\n\f\t '\\<] @code
    |
    '\\' nonnewline @code
    |
    '<' '?cs' @{ saw(CS_LANG); fcall cshtml_cs_line; }
    |
    '<' !'?cs'
  )* '\'' @{ fgoto cshtml_line; };
  cshtml_dq_str := (
    newline %{ entity = INTERNAL_NL; } %cshtml_ccallback
    |
    ws
    |
    [^\r\n\f\t "\\<] @code
    |
    '\\' nonnewline @code
    |
    '<' '?cs' @{ saw(CS_LANG); fcall cshtml_cs_line; }
    |
    '<' !'?cs'
  )* '"' @{ fgoto cshtml_line; };

  ws_or_inl = (ws | newline @{ entity = INTERNAL_NL; } %cshtml_ccallback);

  cshtml_css_entry = '<' /style/i [^>]+ :>> 'text/css' [^>]+ '>' @code;
  cshtml_css_outry = '</' /style/i ws_or_inl* '>' @check_blank_outry @code;
  cshtml_css_line := |*
    cshtml_css_outry @{ p = ts; fret; };
    # unmodified CSS patterns
    spaces       ${ entity = CSS_SPACE; } => css_ccallback;
    css_comment;
    css_string;
    newline      ${ entity = NEWLINE;   } => css_ccallback;
    ^space       ${ entity = CSS_ANY;   } => css_ccallback;
  *|;

  cshtml_js_entry = '<' /script/i [^>]+ :>> 'text/javascript' [^>]+ '>' @code;
  cshtml_js_outry = '</' /script/i ws_or_inl* '>' @check_blank_outry @code;
  cshtml_js_line := |*
    cshtml_js_outry @{ p = ts; fret; };
    # unmodified Javascript patterns
    spaces      ${ entity = JS_SPACE; } => js_ccallback;
    js_comment;
    js_string;
    newline     ${ entity = NEWLINE;  } => js_ccallback;
    ^space      ${ entity = JS_ANY;   } => js_ccallback;
  *|;

  cshtml_cs_entry = '<?cs' @code;
  cshtml_cs_outry = '?>' @check_blank_outry @code;
  cshtml_cs_line := |*
    cshtml_cs_outry @{ p = ts; fret; };
    # unmodified Clearsilver patterns
    spaces      ${ entity = CS_SPACE; } => cs_ccallback;
    cs_comment;
    cs_string;
    newline     ${ entity = NEWLINE;  } => cs_ccallback;
    ^space      ${ entity = CS_ANY;   } => cs_ccallback;
  *|;

  cshtml_line := |*
    cshtml_css_entry @{ entity = CHECK_BLANK_ENTRY; } @cshtml_ccallback
      @{ saw(CSS_LANG); } => { fcall cshtml_css_line; };
    cshtml_js_entry @{ entity = CHECK_BLANK_ENTRY; } @cshtml_ccallback
      @{ saw(JS_LANG); } => { fcall cshtml_js_line; };
    cshtml_cs_entry @{ entity = CHECK_BLANK_ENTRY; } @cshtml_ccallback
      @{ saw(CS_LANG); } => { fcall cshtml_cs_line; };
    # standard CSHTML patterns
    spaces       ${ entity = CSHTML_SPACE; } => cshtml_ccallback;
    '<!--'       @comment                    => { fgoto cshtml_comment; };
    '\''         @code                       => { fgoto cshtml_sq_str;  };
    '"'          @code                       => { fgoto cshtml_dq_str;  };
    newline      ${ entity = NEWLINE;      } => cshtml_ccallback;
    ^space       ${ entity = CSHTML_ANY;   } => cshtml_ccallback;
  *|;

  # Entity machine

  action cshtml_ecallback {
    callback(CSHTML_LANG, entity, cint(ts), cint(te));
  }

  cshtml_entity := 'TODO:';
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with Clearsilver code (in HTML).
 *
 * @param *buffer The string to parse.
 * @param length The length of the string to parse.
 * @param count Integer flag specifying whether or not to count lines. If yes,
 *   uses the Ragel machine optimized for counting. Otherwise uses the Ragel
 *   machine optimized for returning entity positions.
 * @param *callback Callback function. If count is set, callback is called for
 *   every line of code, comment, or blank with 'lcode', 'lcomment', and
 *   'lblank' respectively. Otherwise callback is called for each entity found.
 */
void parse_cshtml(char *buffer, int length, int count,
  void (*callback) (const char *lang, const char *entity, int start, int end)
  ) {
  init

  const char *seen = 0;

  %% write init;
  cs = (count) ? cshtml_en_cshtml_line : cshtml_en_cshtml_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(CSHTML_LANG) }
}

#endif

/*****************************************************************************/

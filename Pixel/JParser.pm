package Pixel::JParser;
# file: Pixel/JParser.pm
#
# This file is part of the Pixel Policy Expression Languagge
use strict;
#use warnings;
use lib qw(..);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [
qw(
    rq
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;
use vars qw(%VARIABLE);

our $PARSER;


#---------------------------------------------------------------------------------
# Structure to incorporate ANTLR parser's java code into PERL
#---------------------------------------------------------------------------------
my $wdir;
BEGIN {
#    my $jroot = Pixel::Configure::get_config("JAVA_ROOT") || '/web/lib/perl/parser';
    my $jroot = '/Users/pjw/prog/kynetx/PolicyLanguage/parser';
    $wdir = "$jroot";
    my $libdir = $jroot;
    my $pclasses = $jroot . '/' . 'output/classes';
    my @jars = ();
    opendir LIBDIR,$libdir or warn $1;
    while (my $fname = readdir(LIBDIR)) {
        next unless $fname =~ m@\.jar$@;
        push @jars,$libdir."/".$fname;
    }
    push @jars,$pclasses;
    $ENV{CLASSPATH} = join (":",@jars);
    warn $ENV{CLASSPATH};
}


my $cp = $ENV{CLASSPATH};

use Inline (Java => <<'END',
    import java.util.*;
    import org.antlr.runtime.*;
    import java.io.*;
    import org.json.*;

    class Antlr_ {
        public Antlr_() {
        }


        /**
          * Given the input string with escaped unicode characters convert them
          * to their native unicode characters and return the result. This is quite
          * similar to the functionality found in property file handling. White space
          * escapes are not processed (as they are consumed by the template library).
          * Any bogus escape codes will remain in place.
          * <p>
          * When files are provided in another encoding, they can be converted to ascii using
          * the native2ascii tool (a java sdk binary). This tool will escape all the
          * non Latin1 ASCII characters and convert the file into Latin1 with unicode escapes.
          *
          * @param source
          *      string with unicode escapes
          * @return
          *      string with all unicode characters, all unicode escapes expanded.
          *
          * @author Caleb Lyness
          */
        private static String unescapeUnicode(String source) {
            /* could use regular expression, but not this time... */
            final int srcLen = source.length();
            char c;

            StringBuffer buffer = new StringBuffer(srcLen);

            // Must have format \\uXXXX where XXXX is a hexadecimal number
            int i=0;
            while (i <srcLen-5) {

                    c = source.charAt(i++);

                    if (c=='\\') {
                        char nc = source.charAt(i);
                        if (nc == 'u') {

                            // Now we found the u we need to find another 4 hex digits
                            // Note: shifting left by 4 is the same as multiplying by 16
                            int v = 0; // Accumulator
                            for (int j=1; j < 5; j++) {
                                nc = source.charAt(i+j);
                                switch(nc)
                                {
                                    case 48: // '0'
                                    case 49: // '1'
                                    case 50: // '2'
                                    case 51: // '3'
                                    case 52: // '4'
                                    case 53: // '5'
                                    case 54: // '6'
                                    case 55: // '7'
                                    case 56: // '8'
                                    case 57: // '9'
                                        v = ((v << 4) + nc) - 48;
                                        break;

                                    case 97: // 'a'
                                    case 98: // 'b'
                                    case 99: // 'c'
                                    case 100: // 'd'
                                    case 101: // 'e'
                                    case 102: // 'f'
                                        v = ((v << 4)+10+nc)-97;
                                        break;

                                    case 65: // 'A'
                                    case 66: // 'B'
                                    case 67: // 'C'
                                    case 68: // 'D'
                                    case 69: // 'E'
                                    case 70: // 'F'
                                        v = ((v << 4)+10+nc)-65;
                                        break;
                                    default:
                                        // almost but no go
                                        j = 6;  // terminate the loop
                                        v = 0;  // clear the accumulator
                                        break;
                                }
                            } // for each of the 4 digits

                            if (v > 0) {      // We got a full conversion
                                c = (char)v;  // Use the converted char
                                i += 5;      // skip the numeric values
                            }
                        }
                    }
                    buffer.append(c);
                }

            // Fill in the remaining characters from the buffer
            while (i <srcLen) {
                buffer.append(source.charAt(i++));
            }
            return buffer.toString();
        }


        public String pixel(String pxl) throws org.antlr.runtime.RecognitionException {
            try {
                System.out.println("In Java: " + pxl);
                org.antlr.runtime.ANTLRStringStream input = new org.antlr.runtime.ANTLRStringStream(pxl);
                com.kynetx.PersonalChannelPolicyLexer lexer = new com.kynetx.PersonalChannelPolicyLexer(input);
                CommonTokenStream tokens = new CommonTokenStream(lexer);
                com.kynetx.PersonalChannelPolicyParser parser = new com.kynetx.PersonalChannelPolicyParser(tokens);
                parser.policy();
                HashMap map = new HashMap();
                JSONObject js = new JSONObject(parser.policy);
                if (parser.parse_errors.size() > 0) {
                    ArrayList elist = new ArrayList();
                    for (int i = 0;i< parser.parse_errors.size(); i++) {
                        elist.add(parser.parse_errors.get(i));
                    }
                    map.put("error",elist);
                    JSONObject error = new JSONObject(map);
                    return error.toString();
                }
                //return unescapeUnicode(js.toString());
                return js.toString();
            } catch(Exception e) {
                StringBuffer sb = new StringBuffer();
                sb.append("Parser Exception (" + e.getMessage() + "): ");
                sb.append(e.getStackTrace()[0].getClassName()).append(":");
                sb.append(e.getStackTrace()[0].getMethodName()).append(":");
                sb.append(e.getStackTrace()[0].getLineNumber()).append(":");
                return (sb.toString());
            }
        }

        public String exceptionMessage(String s) {
            StackTraceElement stackTraceElements[] =
                (new Throwable()).getStackTrace();
            StringBuffer sb = new StringBuffer();
            sb.append("{\"error\":[\"");
            sb.append("Parser Exception (" + s + "): ");
            sb.append(stackTraceElements[1].toString()).append("\"]}");
            return (sb.toString());
        }
    }
END
    CLASSPATH=>$ENV{CLASSPATH},
    SHARED_JVM => 1,
    DIRECTORY => $wdir,
    START_JVM  => 0,
    AUTOSTUDY  => 1,
    DEBUG      => 0,
    STUDY      => ['org.json.JSONObject',
        'Antlr_'
    ],
    PACKAGE => 'main',
);

use Inline::Java qw(cast);

# sub env {
#     my $logger = get_logger();
#     foreach my $key (keys %ENV) {
#         $logger->info("$key -> ", $ENV{$key});
#     }
# }


sub get_antlr_parser {
    return new Antlr_();
}

1;

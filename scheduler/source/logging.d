
module logging;

import std.stdio;
import std.datetime;
import std.file;
import std.path;
import std.array;
import std.format;


/*
Type    Level    Description
'a'     ALL      All levels including custom levels.
'd'     DEBUG    Designates fine-grained informational events that are most useful to debug an application.
'e'     ERROR    Designates error events that might still allow the application to continue running.
'f'     FATAL    Designates very severe error events that will presumably lead the application to abort.
'i'     INFO     Designates informational messages that highlight the progress of the application at coarse-grained level.
'o'     OFF      The highest possible rank and is intended to turn off logging.
't'     TRACE    Designates finer-grained informational events than the DEBUG.
'w'     WARN     Designates potentially harmful situations.
*/


class logging {
    string filename;
	string dir_current;
	protected char dir_separator;
	
    this() {
		version (Linux) {
			this.dir_separator = '/';
		}
		version (Windows) {
			this.dir_separator = '\\';
		}

        this.dir_current = dirName(thisExePath());
		this.filename = baseName(stripExtension((thisExePath())));
    }

    void save(char type, string msg) {
        auto level = "INFO";

        if (type == 'a') {
            level = "ALL";
        } else if (type == 'd') {
            level = "DEBUG";
        } else if (type == 'e') {
            level = "ERROR";
        } else if (type == 'f') {
            level = "FATAL";
        } else if (type == 'o') {
            level = "OFF";
        } else if (type == 't') {
            level = "TRACE";
        } else if (type == 'w') {
            level = "WARN";
        }
 
        string file_log = this.filename ~ ".log";

        //auto fh = File(this.dir_current ~ this.dir_separator ~ file_log, "a");
		auto fh = File(file_log, "a");
        try {
            fh.write(datetime_to_string() ~ "  " ~ level ~ "    " ~ msg ~ "\n");
        } catch( StdioException e ) {
            writeln("error: save log in file ", file_log, " ", e);
        }
    }

    private string datetime_to_string() {
        auto _datetime = Clock.currTime().toISOExtString.split(".");
        auto date = format("%s", _datetime[0]).replace("T", " ");
		auto msec = format("%s", _datetime[1])[0..3];
        //auto datetime = date ~ ' ' ~ time;
        //writeln(msec[0..3]);
        return date ~ "." ~ msec;
    }
}

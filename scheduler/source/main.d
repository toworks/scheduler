/*import std.stdio;

void main()
{
	writeln("Edit source/app.d to start your project.");
}
*/
/*
//module std.database.sqlite.test;
module dstddb;
import std.database.sqlite;
import std.database.util;
import std.stdio;


void main()
{
	auto db = createDatabase("path:///testdb.sdb");
    //auto rows = db.connection().statement("select name,score from score").query.rows;
    auto rows = db.connection().query("select name,score from score").rows;
    foreach (r; rows) {
        writeln(r[0].as!string,",",r[1].as!int);
        //writeln(r[0],", ",r[1]);
    }

    writefln("Enter something: ");
    char entered;
    do{ 
        readf(" %c\n", &entered);
        writefln("Entered: %s", entered);
    }while(entered != 'y');

}
*/

/*
//module dstddb;
import std.database.freetds;
import std.datetime;
import std.stdio;


void main() {
	auto db = createDatabase("freetds");
	auto con = db.connection();
//    auto db = createDatabase("freetds://krr-tst-pahwl02:1433/test?username=sa&password=admin");
//--    auto db = createDatabase("freetds://krr-tst-pahwl02:1433/terra_skladskaya");
//--    auto con = db.connection();
    //con.query("drop table d1");
    //con.query("create table d1(a date)");
    //con.query("insert into d1 values ('2016-01-15')");
    //auto rows = con.query("select * from d1").rows;
//--	auto rows = con.query("select @@VERSION as ver").rows;
//--	rows.writeRows;
}
*/

/*
//module dstddb;
import std.database.testsuite;
import std.database.testsuite;
import std.database.odbc;
import std.database.util;
import std.stdio;

void main() {
    alias DB = Database!DefaultPolicy;
    //testAll!DB("odbc");
    auto dr = Driver.showDrivers();
	//auto db = createDatabase("Driver={SQL Server Native Client 11.0};Server=KRR-TST-PAHWL02\\SQLEXPRESS;Database=terra_skladskaya;Trusted_Connection=Yes");
    //auto con = db.connection();
	//db.showDrivers();
	writeln("< 999 >");
}
*/

//module arsd;
//module mssql;

import arsd.mssql;
import std.stdio;

void main() {
	//auto db = new MsSql("Driver={SQL Server};Server=<host>[\\<optional-instance-name>]>;Database=dbtest;Trusted_Connection=Yes");
	//auto db = new MsSql("Driver={SQL Server Native Client 11.0};Server=KRR-TST-PAHWL02\\SQLEXPRESS;Database=terra_skladskaya;Trusted_Connection=Yes");
	auto db = new MsSql("Driver={SQL Server};Server=KRR-TST-PAHWL02;Database=KRR-PA-DEV-Development;Trusted_Connection=Yes");

//	db.query("INSERT INTO users (id, name) values (30, 'hello mang')");
/*	
		foreach(line; db.query("SELECT * FROM users")) {
		writeln(line[0], line["name"]);
	}
*/	
    // loop
    for ( ; ; ) {  
    	//foreach (line; db.query("select 11, @@VERSION as name") ) {
    	//	writeln(line[0], line["name"]);
        foreach (line; db.query("select * from [KRR-PA-DEV-Development]..[stage]") ) {
            writeln("id: ",line[0], " | ", line["id"], " dt: ", line["dt_begin"]);
    	}
    }
}




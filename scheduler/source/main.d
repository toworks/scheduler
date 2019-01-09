/*
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
/*    for ( ; ; ) {  
    	//foreach (line; db.query("select 11, @@VERSION as name") ) {
    	//	writeln(line[0], line["name"]);
        foreach (line; db.query("select * from [KRR-PA-DEV-Development]..[stage]") ) {
            writeln("id: ",line[0], " | ", line["id"], " dt: ", line["dt_begin"]);
    	}
    }
}
*/

//import configuration;
//import logging;
import arsd.mssql;
import std.stdio;
//import core.thread;
import std.format;

/*
void main(string[] args)
{
    auto log_ = new logging();
//    log_.save('f', "ttyutyuty");
	//auto db = new MsSql("Driver={SQL Server Native Client 11.0};Server=KRR-TST-PAHWL02;Database=KRR-PA-GLB-SERVICE;Trusted_Connection=Yes;Regional=No;");

    while (true) {
        log_.save('i', "ttyutyuty");
        log_.save('w', "-+");
        auto log = new logging();
        log.save('e', "---->");
        destroy(log);
//    }
	
		auto db = new MsSql("Driver={SQL Server Native Client 11.0};Server=KRR-TST-PAHWL02;Database=KRR-PA-GLB-SERVICE;Trusted_Connection=Yes");
	
		for (int i = 0; i < 10; i++) {
			//writeln(i);
			//log_.save('w', format("%s", i));
			try {
                log_.save('i', "start exec");
                foreach (line; db.query("declare @q nvarchar(max); select @q=[execute] from [KRR-PA-GLB-SERVICE]..[scheduler] where id = 46; exec(@q);select 0 as id, N'ola-la-la' as name;") ) {
				//foreach (line; db.query("select id, [execute] from [KRR-PA-GLB-SERVICE]..[scheduler] where id = 46") ) {
				//foreach (line; db.query("select id, name from [KRR-PA-GLB-SERVICE]..scheduler") ) {
				//foreach (line; db.query("exec [KRR-PA-ANL-Analytics]..ARMP_TRENDS") ) {
					//writeln("id: ",line[0], " | ", line["id"], " name: ", line["name"]);
					//writeln("id: ",line[0]);
					//log_.save('i', "id: " ~ line[0] ~ " name: " ~ line[1]);
					//log_.save('i', "EXEC");
					log_.save('i', "id: " ~ line[0] ~ " exec: " ~ line[1]);
                    log_.save('i', "end exec");
				}
			} catch (Exception e) {
				log_.save('e', e.msg);
			}
		}
		destroy(db);
		//destroy(log);
		 //Thread.sleep(1.seconds);
         Thread.sleep(5.msecs);
         }
/*    auto arr = split(dirName(thisExePath()), "/");
    string name = arr[arr.length-1];
    writeln(arr.length, " | ", name);*/

//    auto conf = new configuration("7-7-");
//    writeln(conf.filename);
//}








void main() {
	import std.c.stdlib;
	import std.string;
	import std.conv;
    import std.database.odbc;
	//auto db = createDatabase("odbc");
	//auto con = db.connection("Driver={SQL Server Native Client 11.0};Server=KRR-TST-PAHWL02;Database=master;Trusted_Connection=yes");
	//auto db = createDatabase("Driver={SQL Server Native Client 11.0};Server=KRR-TST-PAHWL02;Database=master;Trusted_Connection=yes");
	//auto con = db.connection("Driver={SQL Server Native Client 11.0};Server=KRR-TST-PAHWL02;Database=master;Trusted_Connection=yes");
	//auto con = db.connection();
    auto db = new MsSql("Driver={SQL Server Native Client 11.0};Server=KRR-TST-PAHWL02;Database=KRR-PA-GLB-SERVICE;Trusted_Connection=Yes");

/*   string homeDrive, homePath;
   homeDrive = to!string(getenv("HOMEDRIVE")).dup;
   homePath = to!string(getenv("HOMEPATH")).dup;
   writefln("| %s | %s |", homeDrive, homePath);
*/

	for (int i = 0; i < 10; i++) {
		//auto line = db.query("SELECT 1,2,'abc'");
		auto line = db.query("select id, /*error*/ [execute] as ww from [KRR-PA-GLB-SERVICE]..[scheduler] where id = 2");
//		auto stmt = con.statement("SELECT 1,2,'abc'");

/*auto stmt = con.statement("SELECT 1,2,'abc'");
auto rows = stmt.query.rows;
foreach (row; rows) {
    for(size_t col = 0; col != row.width; ++col) write(row[col], " ");
    writeln();
}*/

		
		//auto line = db.query( "SELECT 1,2,'abc'" );
        //auto stmt = conn.prepare( "SELECT Name FROM Person" );
//        auto line = stmt.open();
		
		foreach (r; line) {
			writeln("count: " ~ to!string(i) ~ " id: " ~ r[0] ~ " exec: " ~ to!string(r[1]));
		}
	}
	
/*	
    import std.database.odbc;
    //auto db = createDatabase("freetds://server/test?username=sa&password=admin");
    //auto db = createDatabase("odbc");
	auto db = createDatabase("Driver={SQL Server Native Client 11.0};Server=KRR-TST-PAHWL02;Database=master;Trusted_Connection=yes");

	auto rows = db.connection.query("select @@VERSION").rows;
	foreach (r; rows) {
		writeln(r[0].as!string,",",r[1].as!int);
	}
*/
	//auto stmt = db.query("select @@VERSION");
/*	foreach(line; db.query("select @@VERSION as name")) {
		writeln(line[0], line["name"]);
	}
*/	
	
	//auto con = db.connection("Driver={SQL Server Native Client 11.0};Server=KRR-TST-PAHWL02;Database=master;Trusted_Connection=yes");
	//auto con = db.connection("Driver={SQL Server Native Client 11.0};Server=KRR-TST-PAHWL02;Database=master");
	
//	auto stmt = Statement(con, "select name,score from score");
/*    auto stmt = con.statement("select name,score from score where score>? and name=?",
    1,"jo");*/
//    writeln("binds: ", stmt.binds());
/*    auto res = stmt.result();
    writeln("columns: ", res.columns());
    auto range = res.range();
*/	
}



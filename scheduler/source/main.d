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

import configuration;
import logging;
import arsd.mssql;
import std.stdio;
import core.thread;
import std.format;


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
                db.query("declare @q nvarchar(max); select @q=[execute] from [KRR-PA-GLB-SERVICE]..[scheduler] where id = 46; exec(@q);select 0 as id, N'ola-la-la' as name;");
				//foreach (line; db.query("select id, [execute] from [KRR-PA-GLB-SERVICE]..[scheduler] where id = 46") ) {
				//foreach (line; db.query("select id, name from [KRR-PA-GLB-SERVICE]..scheduler") ) {
				//foreach (line; db.query("exec [KRR-PA-ANL-Analytics]..ARMP_TRENDS") ) {
					//writeln("id: ",line[0], " | ", line["id"], " name: ", line["name"]);
					//writeln("id: ",line[0]);
					//log_.save('i', "id: " ~ line[0] ~ " name: " ~ line[1]);
					//log_.save('i', "EXEC");
					//log_.save('i', "id: " ~ line[0] ~ " exec: " ~ line[1]);
                    log_.save('i', "end exec");
				//}
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
}

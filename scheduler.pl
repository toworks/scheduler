#!D:\bin\perl\perl\bin\perl.exe


package LOG;{
  use strict;
  use warnings;
  use utf8;
  binmode(STDOUT,':utf8');
  use open(':encoding(utf8)');
  use File::Basename;
  use Data::Dumper;
  use Time::HiRes qw(time);
  use POSIX qw(strftime);

  sub new {
    # получаем имя класса
    my($class) = @_;
    # создаем хэш, содержащий свойства объекта
    my $self = {
#	  filename => basename($0).".log",
	  filename => get_name().".log",
	};

    # хэш превращается, превращается хэш...
    bless $self, $class;
    # ... в элегантный объект!

    # эта строчка - просто для ясности кода
    # bless и так возвращает свой первый аргумент
	
	#$self->set_log;

    return $self;
  }

  sub get_name {
	my ( $name, $path, $suffix ) = fileparse( $0, qr{\.[^.]*$} );
#	print "NAME=$name\n";
#	print "PATH=$path\n";
#	print "SFFX=$suffix\n";
	return $name;
  }

=pod
Type	Level	Description
0		ALL		All levels including custom levels.
1		DEBUG	Designates fine-grained informational events that are most useful to debug an application.
2		ERROR	Designates error events that might still allow the application to continue running.
3		FATAL	Designates very severe error events that will presumably lead the application to abort.
4		INFO	Designates informational messages that highlight the progress of the application at coarse-grained level.
5		OFF		The highest possible rank and is intended to turn off logging.
6		TRACE	Designates finer-grained informational events than the DEBUG.
7		WARN	Designates potentially harmful situations.
=cut

  sub save {
    my($self, $type, $log) = @_; # ссылка на объект

	my ($level, $log_file);
	
	if ($type eq 0) {
		$level = 'ALL';
	} elsif ($type eq 1) {
		$level = 'DEBUG';
	} elsif ($type eq 2) {
		$level = 'ERROR';
	} elsif ($type eq 3) {
		$level = 'FATAL';
	} elsif ($type eq 4) {
		$level = 'INFO';
	} elsif ($type eq 5) {
		$level = 'OFF';
	} elsif ($type eq 6) {
		$level = 'TRACE';
	} elsif ($type eq 7) {
		$level = 'WARN';
	} else {
		$level = 'INFO';
	}
	
	unless($log) { $log = ''; }

	my $t = time;
	my $date = strftime "%Y-%m-%d %H:%M:%S", localtime $t;
	$date .= sprintf ".%03d", ($t-int($t))*1000;
	
	my $date_to_file = strftime "%Y%m%d_", localtime $t;
	$log_file = $date_to_file.$self->{'filename'};
	
	open(my $fh, '>>', $log_file) or die "Не могу открыть файл: '$log_file' $!";
	print $fh "$date $level\t$log\n";
	close $fh;
  }
}
1;


package CONF;{
  use strict;
  use warnings;
  use utf8;
  binmode(STDOUT,':utf8');
  use open(':encoding(utf8)');
  use YAML::XS qw/LoadFile/;

  sub new {
    # получаем имя класса
    my($class) = @_;
    # создаем хэш, содержащий свойства объекта
    my $self = {
		'log' => LOG->new(),
	};

    # хэш превращается, превращается хэш...
    bless $self, $class;
    # ... в элегантный объект!

    # эта строчка - просто для ясности кода
    # bless и так возвращает свой первый аргумент
	
	$self->set_conf;

    return $self;
  }

  sub set_conf {
    my($self) = @_; # ссылка на объект
	my($config);

	eval{ $config = LoadFile('configuration.yml') };# обработка ошибки
	if($@) { $self->{log}->save(2, $!); exit 1; }

	for (keys %{$config}) {
		if ($_ =~ /mssql/){
			$self->{$_}->{host} = $config->{$_}->{host};
			$self->{$_}->{database} = $config->{$_}->{database};
			#$self->{$name}->{username} = $config->{$name}->{username};
			#$self->{$name}->{password} = $config->{$name}->{password};
		}
	}
  }
  
  sub get_conf {
    my($self, $name) = @_; # ссылка на объект
	my ($mssql);

	if ($name =~ /mssql/){
		$mssql->{host} = $self->{$name}->{host};
		$mssql->{database} = $self->{$name}->{database};
		#$mssql->{username} = $self->{$name}->{username};
		#$mssql->{password} = $self->{$name}->{password};
		return $mssql;
	}
  } 
}
1;


package mssql;{
  use DBI;
  use utf8;
#  binmode(STDOUT,':utf8');
#  use open(':encoding(utf8)');
  use DBI qw(:sql_types);
  use Data::Dumper;

  sub new {
    # получаем имя класса
    my($class) = @_;
    # создаем хэш, содержащий свойства объекта
    my $self = {
		'error' => 1,
		'log' => LOG->new(),
	};

    # хэш превращается, превращается хэш...
    bless $self, $class;
    # ... в элегантный объект!

    # эта строчка - просто для ясности кода
    # bless и так возвращает свой первый аргумент
    return $self;
  }
 
  sub set_con {
    my($self, $host, $database, $username, $password) = @_; # ссылка на объект
	$self->{host} = $host;
	$self->{database} = $database;
	$self->{username} = $username;
	$self->{password} = $password;
	$self->{dsn} = "Driver={SQL Server};Server=$self->{host};Database=$self->{database};Trusted_Connection=yes";
  }

  sub conn {
	my($self) = @_; # ссылка на объект
	eval{ $self->{dbh} = DBI->connect("dbi:ODBC:$self->{dsn}") || die $self->{log}->save(2, $DBI::errstr);
		  $self->{dbh}->{LongReadLen} = 512 * 1024; # We are interested in the first 512 KB of data
		  $self->{dbh}->{LongTruncOk} = 1; # We're happy to truncate any excess
		  $self->{dbh}->{RaiseError} = 1;
	};# обработка ошибки
	if($@) { $self->{error} = 1; } else { $self->{error} = 0; 		
										  $self->{log}->save(4, "connected mssql");	}
  }

  sub set_table {
    my($self, $table) = @_; # ссылка на объект
	$self->{table} = $table;
  }

  sub get_host {
    my($self) = @_; # ссылка на объект
	return $self->{host};
  }

  sub get_database {
    my($self) = @_; # ссылка на объект
	return $self->{database};
  }

  sub get_username {
    my($self) = @_; # ссылка на объект
	return $self->{username};
  }

  sub get_password {
    my($self) = @_; # ссылка на объект
	return $self->{password};
  }

  sub get_dsn {
    my($self) = @_; # ссылка на объект
	return $self->{dsn};
  }

  sub get_error {
	my($self) = @_; # ссылка на объект
	return $self->{error};
  }

  sub get_table {
    my($self) = @_; # ссылка на объект
	return $self->{table};
  }

  sub get_values {
	my($self) = @_;
	my($sth, $ref, $query);

	if($self->{error} == 1) {
		$self->conn();
	}	

	$query = 'SELECT * FROM config_scheduler';
	
	eval{ $sth = $self->{dbh}->prepare($query) || die $self->{log}->save(2, "mssql prepare: " . $DBI::errstr);
		  $sth->execute() || die $self->{log}->save(2, "mssql execute: " . $DBI::errstr);	};# обработка ошибки

	unless($@) {
		while ($ref = $sth->fetchrow_hashref()) {
			if ( $ref->{'name'} =~ /database/ ) {
				my($name, $table) = split("::", $ref->{'value'});
				$self->{$ref->{'name'}}->{name} = lc($name);
				$self->{$ref->{'name'}}->{table} = lc($table);
			}
		}
	} else { $self->{error} = 1; }
  }

  sub get_scheduler {
	my($self) = @_;
	my($sth, $ref, $query, %values);

	if($self->{error} == 1) {
		$self->conn();
	}

	$query = "SELECT *, datediff(s, '1970', getdate()) as [current_timestamp] FROM [$self->{'database'}->{'name'}]..$self->{'database'}->{'table'}";

	eval{ $sth = $self->{dbh}->prepare($query) || die $self->{log}->save(2, "mssql prepare: " . $DBI::errstr);
		  $sth->execute() || die $self->{log}->save(2, "mssql execute: " . $DBI::errstr);	};# обработка ошибки

	unless($@) {
		while ($ref = $sth->fetchrow_hashref()) {
				$values->{$ref->{'id'}}->{'name'} = $ref->{'name'};
				$values->{$ref->{'id'}}->{'execute'} = $ref->{'execute'};
				$values->{$ref->{'id'}}->{'enable'} = $ref->{'enable'};
				$values->{$ref->{'id'}}->{'status'} = $ref->{'status'};
				$values->{$ref->{'id'}}->{'interval'} = $ref->{'interval'};
				$values->{$ref->{'id'}}->{'timestamp'} = $ref->{'timestamp'};
				$values->{$ref->{'id'}}->{'current_timestamp'} = $ref->{'current_timestamp'};
		}
	} else { $self->{error} = 1; }
	return($values);
  }

  sub mssql_send {
	my($self, $id, $value) = @_;
	my($sth, $ref, $query, $error_message);
	  
	if($self->{error} == 1) {
		$self->conn();
	}

	$query  = "update [$self->{database}->{name}]..$self->{database}->{table} set timestamp = datediff(s, '1970', getdate()) ";
	$query .= ", status = 0 ";
	$query .= "where id = $id ";

	eval{ $sth = $self->{dbh}->prepare($query) || die $self->{log}->save(2, "mssql prepare: ". $DBI::errstr);
		  $sth->execute() || die $self->{log}->save(2, "mssql execute: ". $DBI::errstr); };# обработка ошибки

	$dbh->{AutoCommit} = 0;
	$query  = "$value";
#	$self->{log}->save(4, "$query");
	
	DEADLOCK: while (1) {
        eval{ $sth = $self->{dbh}->prepare($query) || die $self->{log}->save(2, "mssql prepare: ". $DBI::errstr);
		$sth->execute() || die $self->{log}->save(2, "mssql execute: ". $DBI::errstr); };# обработка ошибки
#		if ($@) { $self->{error} = 1;  $self->{log}->save(2, "mssql execute: ". $DBI::errstr); }
		
		if($DBI::errstr =~ /SQL-40001/) { # deadlock
			$self->{log}->save(1, "last: ". $DBI::errstr);
			next DEADLOCK;
		}
		last;
    }
	if ($@) { $self->{error} = 1;
			  $self->{log}->save(2, "mssql execute: ". $DBI::errstr); 
			  $error_message = $DBI::errstr;
	}
	$dbh->{AutoCommit} = 1;

	my $query_error = $query;

	$query = "update [$self->{database}->{name}]..$self->{database}->{table} set ";
	if ($self->{error} == 1){
		$self->{log}->save(1, "$query_error");
		$query .= "status = -9999 ";
		$error_message =~ s/'/''/g;
		$query .= ", error = '$error_message' ";
	} else {
		$query .= "status = 1 ";
		$query .= ", error = '' ";
	}
	$query .= ", duration = datediff(s, dateadd(s, [timestamp], '1970'), getdate()) ";
	$query .= "where id = $id ";

#	$self->{log}->save(4, "$query");

	eval{ $sth = $self->{dbh}->prepare($query) || die $self->{log}->save(2, "mssql prepare: ". $DBI::errstr);
		  $sth->execute() || die $self->{log}->save(2, "mssql execute: ". $DBI::errstr);
		  $sth->finish() || die $self->{log}->save(2, "mssql finish: ". $DBI::errstr); 
		  $self->{dbh}->disconnect() || die $self->{log}->save(2, "mssql disconnect: ". $DBI::errstr); };# обработка ошибки
  }
}
1;


package main;
  use strict;
  use warnings;
  use utf8;
#  binmode(STDOUT,':utf8');
#  use open(':encoding(utf8)');
  use threads;
  use DateTime;
  use Data::Dumper;

  # если не работает -> добавить в виндовс окружение или в переменную службы
  #$ENV{'PATH'} = "$ENV{'PATH'};C:\\bin\\perl\\perl\\site\\bin\\;C:\\bin\\perl\\perl\\bin\\;C:\\bin\\perl\\c\\bin\\";
  
  $| = 1; #flushing output

  my $conf = CONF->new();

#close(STDOUT);
#close(STDERR);

  # В этом массиве будут храниться ссылки на
  # созданные нити 
  my @threads;

  push @threads, threads->create(\&execute, 'main');

  foreach my $thread (@threads) {
      # Обратите внимание, что $thread является не объектом, а ссылкой,
      # поэтому управление ему передано не будет.
      $thread->join();
  }

sub execute {
	$0 =~ m/.*[\/\\]/g;
	my ($id) = @_;
	
	# В этом массиве будут храниться ссылки на
	# созданные нити 
	my @threads;

	my $first_run = 1;

	my $log = LOG->new();
	$log->save(4, "thread -> $id");

	# mssql create object
	my $mssql = mssql->new();
	$mssql->set_con($conf->get_conf('mssql')->{host}, $conf->get_conf('mssql')->{database});
	$mssql->get_values; # get all settings for mssql
  
	while(1) {
		my $values = $mssql->get_scheduler;
		#print  Dumper($values);
		#print  Dumper($conf->get_conf('mssql'));
		#print $values->{'database'}->{'name'};

		#my $thread_count = threads->list();
		#my @running = threads->list(threads::running);
		#my @joinable = threads->list(threads::joinable);

#		print $thread_count, " | count thread join up\n";
#		print scalar @running, " | thread running\n";

		for my $level1 ( keys %$values ) {
			my $id = $level1;
#			print(join "\t", $id, $values->{$id}->{'execute'},
#								  $values->{$id}->{'timestamp'}, $values->{$id}->{'enable'},
#								  $values->{$id}->{'interval'}, $values->{$id}->{'timestamp'},
#								  $values->{$id}->{'current_timestamp'}, "\n");

			if( $values->{$id}->{'enable'} == 1 and $first_run == 1 ) {
				$log->save(4, "start first scheduler | $id | $values->{$id}->{'current_timestamp'}");
				push @threads, threads->create(\&child, $id, $values->{$id}->{'execute'});
			}elsif( $values->{$id}->{'current_timestamp'} > $values->{$id}->{'timestamp'}+$values->{$id}->{'interval'}
					and $values->{$id}->{'enable'} == 1  and $values->{$id}->{'status'} != 0 and $first_run == 0 ) {
				$log->save(4, "start scheduler | $id | $values->{$id}->{'current_timestamp'}");
				push @threads, threads->create(\&child, $id, $values->{$id}->{'execute'});
			}
		}

		foreach (threads->list()) {
			# Обратите внимание, что $thread является не объектом, а ссылкой,
			# поэтому управление ему передано не будет.
			if ( $_->is_joinable()) { 
				#print $_->tid(), " | run thread\n";
				$_->join();
			}
		}

#		$thread_count = threads->list();
		#@running = threads->list(threads::running);
		#@joinable = threads->list(threads::joinable);
#		print $thread_count, " | count thread join down\n";
		
		$first_run = 0;

		# clear
		undef($values);

		sleep(30);
	}
}


sub child {
	$0 =~ m/.*[\/\\]/g;
	my ($id, $execute) = @_;
	
	my $log = LOG->new();
	$log->save(4, "thread -> $id");

	# mssql create object
	my $mssql = mssql->new();
	$mssql->set_con($conf->get_conf('mssql')->{host}, $conf->get_conf('mssql')->{database});

	$mssql->mssql_send($id, "$execute");
	
	# clear
	undef($mssql);
	undef($log);
	undef($mssql);

	threads->exit();
}


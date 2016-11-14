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
                filename => get_name().".log",
    };

    # хэш превращается, превращается хэш...
    bless $self, $class;
    # ... в элегантный объект!

    # эта строчка - просто для ясности кода
    # bless и так возвращает свой первый аргумент

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
Type    Level    Description
'a'     ALL      All levels including custom levels.
'd'     DEBUG    Designates fine-grained informational events that are most useful to debug an application.
'e'     ERROR    Designates error events that might still allow the application to continue running.
'f'     FATAL    Designates very severe error events that will presumably lead the application to abort.
'i'     INFO     Designates informational messages that highlight the progress of the application at coarse-grained level.
'o'     OFF      The highest possible rank and is intended to turn off logging.
't'     TRACE    Designates finer-grained informational events than the DEBUG.
'w'     WARN     Designates potentially harmful situations.
=cut

  sub save {
    my($self, $type, $log) = @_; # ссылка на объект

    my $level;
    
    if ($type =~ /a/) {
        $level = 'ALL';
    } elsif ($type =~ /d/) {
        $level = 'DEBUG';
    } elsif ($type =~ /e/) {
        $level = 'ERROR';
    } elsif ($type =~ /f/) {
        $level = 'FATAL';
    } elsif ($type =~ /i/) {
        $level = 'INFO';
    } elsif ($type =~ /o/) {
        $level = 'OFF';
    } elsif ($type =~ /t/) {
        $level = 'TRACE';
    } elsif ($type =~ /w/) {
        $level = 'WARN';
    } else {
        $level = 'INFO';
    }

    # trim both ends
    $log =~ s/^\s+|\s+$//g;

    unless($log) { $log = ''; }

    my $t = time;
    my $date = strftime "%Y-%m-%d %H:%M:%S", localtime $t;
    $date .= sprintf ".%03d", ($t-int($t))*1000;

	my $date_to_file = strftime "%Y%m%d_", localtime $t;
	my $log_file = $date_to_file.$self->{'filename'};
	
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
  use Data::Dumper;

  sub new {
    # получаем имя класса
    my($class, $log) = @_;
    # создаем хэш, содержащий свойства объекта
    my $self = {
		'log' => $log,
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

	eval{ $config = LoadFile($self->{log}->get_name().'.conf.yml') || die $!; };# обработка ошибки
	if($@) { $self->{log}->save('e', $!); exit 1; }

	for (keys %{$config}) {
		if ($_ =~ /mssql/){
			$self->{$_} = $config->{$_};
			#$self->{$_}->{host} = $config->{$_}->{host};
			#$self->{$_}->{database} = $config->{$_}->{database};
			#$self->{$name}->{username} = $config->{$name}->{username};
			#$self->{$name}->{password} = $config->{$name}->{password};
		}
	}
  }
  
  sub get_conf {
    my($self, $name) = @_; # ссылка на объект
	my ($mssql);

	if ($name =~ /mssql/){
		#$mssql->{host} = $self->{$name}->{host};
		#$mssql->{database} = $self->{$name}->{database};
		#$mssql->{username} = $self->{$name}->{username};
		#$mssql->{password} = $self->{$name}->{password};
		#return $mssql;
		return $self->{$name};
	}
  } 
}
1;


package mssql;{
  use strict;
  use warnings;
  use utf8;
  use DBI;
#  binmode(STDOUT,':utf8');
#  use open(':encoding(utf8)');
  use DBI qw(:sql_types);
  use Data::Dumper;

  sub new {
    # получаем имя класса
    my($class, $conf, $log) = @_;
    # создаем хэш, содержащий свойства объекта
    my $self = {
		'error' => 1,
		'log' => $log,
        'sql' => $conf->get_conf('mssql'),
	};

    # хэш превращается, превращается хэш...
    bless $self, $class;
    # ... в элегантный объект!

    $self->set_con();

    # эта строчка - просто для ясности кода
    # bless и так возвращает свой первый аргумент
    return $self;
  }
 
  sub set_con {
    my($self) = @_; # ссылка на объект
	$self->{dsn} = "Driver={SQL Server Native Client 11.0};Server=$self->{sql}->{host};Database=$self->{sql}->{database};Trusted_Connection=yes";
  }

  sub conn {
	my($self) = @_; # ссылка на объект
	eval{ $self->{dbh} = DBI->connect("dbi:ODBC:$self->{dsn}") || die "$DBI::errstr";
		  $self->{dbh}->{LongReadLen} = 512 * 1024 || die "$DBI::errstr"; # We are interested in the first 512 KB of data
		  $self->{dbh}->{LongTruncOk} = 1 || die "$DBI::errstr"; # We're happy to truncate any excess
#          $self->{dbh}->{RaiseError} = 0 || die "$DBI::errstr"; # при 1 eval игнорируется, для диагностики полезно
	};# обработка ошибки
	if ($@) { $self->{log}->save('e', "$@"); $self->{error} = 1; } else { $self->{error} = 0; }
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

  sub get_scheduler {
	my($self) = @_;
	my($sth, $ref, $query, %values);

	$self->conn() if ( $self->{error} == 1 or ! $self->{dbh}->ping );

	$query = "SELECT *, datediff(s, '1970', getdate()) as [current_timestamp] FROM [$self->{sql}->{database}]..$self->{sql}->{table} with(nolock)";

	eval{ $self->{dbh}->{RaiseError} = 1;
		  $sth = $self->{dbh}->prepare($query) || die "$DBI::errstr";
		  $sth->execute() || die "$DBI::errstr";
	};# обработка ошибки
	if ($@) {   $self->{error} = 1;
				$self->{log}->save('e', "$DBI::errstr");
	};

	unless($@) {
	    eval{
				while ($ref = $sth->fetchrow_hashref()) {
						$values{$ref->{'id'}}{'name'} = $ref->{'name'};
						$values{$ref->{'id'}}{'execute'} = $ref->{'execute'};
						$values{$ref->{'id'}}{'enable'} = $ref->{'enable'};
						$values{$ref->{'id'}}{'status'} = $ref->{'status'};
						$values{$ref->{'id'}}{'interval'} = $ref->{'interval'};
						$values{$ref->{'id'}}{'timestamp'} = $ref->{'timestamp'};
						$values{$ref->{'id'}}{'current_timestamp'} = $ref->{'current_timestamp'};
				}
		}
	}
	eval{ $sth->finish() || die "$DBI::errstr";	};# обработка ошибки
	if ($@) {   $self->{error} = 1;
				$self->{log}->save('e', "$DBI::errstr");
	};
	return(%values);
  }

  sub save {
	my($self, $id, $value) = @_;
	my($sth, $ref, $query, $error_message);

	local $SIG{'STOP'} = sub { 
#								$self->{log}->save('d', "start | $id");
								$self->up($id);
								#$sth->cancel;
#								$self->{log}->save('d', "stop | $id");
								threads->exit();
	};
	
	$self->status_up($id, 0);
	
	$self->conn() if ( $self->{error} == 1 or ! $self->{dbh}->ping );

	$query = "$value";
#	$self->{log}->save('d', "$query");
	my $count = 0;

	LOOP: while (1) {
        eval{ $self->{dbh}->{RaiseError} = 1;
#			  $self->{dbh}->{AutoCommit} = 0;
			  $sth = $self->{dbh}->prepare($query) || die "$DBI::errstr";
			  $sth->execute() || die "$DBI::errstr";
#			  $self->{dbh}->{AutoCommit} = 1;
		};
		if ( $@ and $count <= 10 ) {
			if("$DBI::errstr" =~ /SQL-40001/) { # deadlock
				$self->{log}->save('e', "last: ". "$DBI::errstr");
				$self->{log}->save('d', "$query");
				next LOOP;
			}
			if("$DBI::errstr" =~ /ORA-12170/) { # TNS:Connect timeout occurred
				$self->{log}->save('e', "last: ". "$DBI::errstr");
				$self->{log}->save('d', "$query");
				next LOOP;
			}
		}
		last;
	}
	if ($@) { $self->{error} = 1;
			  $self->{log}->save('e', "$DBI::errstr");
			  $error_message = "$DBI::errstr";
	}
=comm
		do {
                while(my $d = $sth->fetch)
                {
                        print "out  @$d\n";
						$self->{log}->save('e', "out: @$d");
                }
        } while($sth->{syb_more_results});
=cut

	my $query_error = $query;

	$query = "update [$self->{sql}->{database}]..$self->{sql}->{table} set ";
	if ($self->{error} == 1){
		$self->{log}->save('d', "$query_error");
		$query .= "status = -9999 ";
		$error_message =~ s/'/''/g;
		$query .= ", error = '$error_message' ";
	} else {
		$query .= "status = 1 ";
		$query .= ", error = '' ";
	}
	$query .= ", duration = datediff(s, dateadd(s, [timestamp], '1970'), getdate()) ";
	$query .= "where id = $id ";

#	$self->{log}->save('d', "$query");

	eval{ $self->{dbh}->{RaiseError} = 1;
#		  $self->{dbh}->{AutoCommit} = 0;
		  $sth = $self->{dbh}->prepare($query) || die "$DBI::errstr";
		  $sth->execute() || die "$DBI::errstr";
#		  $self->{dbh}->{AutoCommit} = 1;
		  $sth->finish() || die "$DBI::errstr";
	};
	if ($@) { $self->{error} = 1;
			  $self->{log}->save('e', "$DBI::errstr");
	}
  }


  sub up {
    my($self, $id) = @_; # ссылка на объект

    my($sth, $ref, $query);

    $self->conn() if ( $self->{error} == 1 or ! $self->{dbh}->ping );

    $query = "UPDATE [$self->{sql}->{database}]..$self->{sql}->{table} SET status = 1 , error = N'force kill thread' where id = ?";

    eval{ $self->{dbh}->{RaiseError} = 1;
#	      $self->{dbh}->{AutoCommit} = 0;
		  $sth = $self->{dbh}->prepare($query) || die "$DBI::errstr";
#          $sth->execute( @$_ ) || die "$DBI::errstr" for @array;
          $sth->execute( $id ) || die "$DBI::errstr";
#		  $self->{dbh}->{AutoCommit} = 1;
          $sth->finish || die "$DBI::errstr";
    };
    if ( $@ ) {
        $self->{log}->save('e', "$DBI::errstr");
        $self->{error} = 1;
    }
  }


  sub status_up {
    my($self, $id, $status) = @_; # ссылка на объект

    my($sth, $ref, $query);

    $self->conn() if ( $self->{error} == 1 or ! $self->{dbh}->ping );

    $query  = "UPDATE [$self->{sql}->{database}]..$self->{sql}->{table} SET status = ? ";
	$query .= ", timestamp = datediff(s, '1970', getdate()) " if defined($id);
	$query .= "where id = ? " if defined($id);
	
    eval{ $self->{dbh}->{RaiseError} = 1;
#	      $self->{dbh}->{AutoCommit} = 0;
		  $sth = $self->{dbh}->prepare($query) || die "$DBI::errstr";
		  if ( defined($id) ) {
			$sth->execute( $status, $id ) || die "$DBI::errstr";
		  } else {
			$sth->execute( $status ) || die "$DBI::errstr";
		  }
#		  $self->{dbh}->{AutoCommit} = 1;
          $sth->finish || die "$DBI::errstr";
    };
    if ( $@ ) {
        $self->{log}->save('e', "$DBI::errstr");
        $self->{error} = 1;
    }
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
  use POSIX qw(strftime);

  # если не работает -> добавить в виндовс окружение или в переменную службы
  #$ENV{'PATH'} = "$ENV{'PATH'};C:\\bin\\perl\\perl\\site\\bin\\;C:\\bin\\perl\\perl\\bin\\;C:\\bin\\perl\\c\\bin\\";

  $| = 1; #flushing output

  my $log = LOG->new();

  my $conf = CONF->new($log);

  #close(STDERR); #close error to console

  local $SIG{'INT'} = $SIG{'TERM'} = $SIG{'KILL'} = sub { $log->save('i', $log->get_name ." stop"); exit; };

  { # --| main loop
	my (%threads, $id, @kill_id);
	
	$log->save('i', $log->get_name ." start");

	# mssql create object
	my $mssql = mssql->new($conf, $log);
	$mssql->status_up(undef, 1); #first run up to 1

	while(1) {
		my %values = $mssql->get_scheduler;
		#print  Dumper(sort {$a <=> $b} keys %values);

		for my $id ( sort {$a <=> $b} keys %values ) {
=comment
			if( $values{$id}{'enable'} == 1 and $first_run == 1 ) {
				$log->save('i', "start first scheduler | $id | $values{$id}{'current_timestamp'}");
				$threads{$id} = threads->create(\&child, $id, $values{$id}{'execute'}, $conf, $log);
#				$threads{$id} = async{ $mssql_->save($id, $values{$id}{'execute'}) };
#$mssql->status_up($id, 9);
			}elsif( $values{$id}{'current_timestamp'} > $values{$id}{'timestamp'}+$values{$id}{'interval'}
					and $values{$id}{'enable'} == 1  and $values{$id}{'status'} != 0 and $first_run == 0 ) {
				$log->save('i', "start scheduler | $id | $values{$id}{'current_timestamp'}");
				$threads{$id} = threads->create(\&child, $id, $values{$id}{'execute'}, $conf, $log);
#				$threads{$id} = async{ $mssql_->save($id, $values{$id}{'execute'}) };
			}
=cut
			if( $values{$id}{'current_timestamp'} > $values{$id}{'timestamp'}+$values{$id}{'interval'}
					and $values{$id}{'enable'} == 1 and $values{$id}{'status'} != 0 ) {
#				$log->save('i', "start scheduler | $id | $values{$id}{'current_timestamp'}");
				$threads{$id} = threads->create(\&child, $id, $values{$id}{'execute'}, $conf, $log);
			}

			if ( $values{$id}{'enable'} == 0 and $values{$id}{'status'} == 0 ) { push @kill_id, $id; };
		}

#=comm
		foreach (threads->list()) {
			# Обратите внимание, что $thread является не объектом, а ссылкой,
			# поэтому управление ему передано не будет.
			if ( $_->is_joinable()) { 
				#print $_->tid(), " | run thread\n";
				$_->join();
			}
		}
#=cut
		#my $thread_count = threads->list();
		#my @running = threads->list(threads::running);
		#my @joinable = threads->list(threads::joinable);
		#print $thread_count, " | count thread join down\n";

		foreach my $kid (@kill_id){
			#print strftime "%Y-%m-%d %H:%M:%S  id | $kid\n", localtime time();
			if ( grep { $_ eq $kid } keys %threads ) {
				$log->save('i', "kill thread id $kid");
				#print strftime "%Y-%m-%d %H:%M:%S  in array $kid | $threads{$kid}\n", localtime time();
				$threads{$kid}->kill('STOP');
				if ( ! $threads{$kid}->is_running() ) {
				#	print strftime "%Y-%m-%d %H:%M:%S  delete $kid | $threads{$kid}\n", localtime time();
					delete $threads{$kid};
				}
				#@kill_id = grep { $_ != $kid } @kill_id;
				#for my $key( sort keys %threads) {
				#	print "id | $key | $threads{$key}\n";
				#}
			}
		}
		#print Dumper \@kill_id;
#=cut
		# clear
		undef(%values);
		splice(@kill_id);
		sleep(3);
	}
  } # --| main loop


sub child {
	$0 =~ m/.*[\/\\]/g;
	my ($id, $execute, $conf, $log) = @_;

	# mssql create object
	my $mssql = mssql->new($conf, $log);

#	$log->save('i', "thread id ". $id);

	threads->yield();

	$mssql->save($id, "$execute");

	threads->exit();
}

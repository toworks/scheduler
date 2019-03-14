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
    my($class, $log) = @_;
    my $self = bless {
						'log' => $log,
	}, $class;

	$self->set_conf;

    return $self;
  }

  sub set_conf {
    my($self) = @_;
	eval{ $self->{'config'} = LoadFile($self->{log}->get_name().'.conf.yml') || die $!; };# обработка ошибки
	if($@) { $self->{log}->save('e', "$@"); exit 1; }
  }

  sub get_conf {
    my($self, $name) = @_; # ссылка на объект
	return $self->{'config'}->{$name} || undef;
  } 
}
1;


package sql;{
  use strict;
  use warnings;
  use utf8;
  use DBI;
#  binmode(STDOUT,':utf8');
#  use open(':encoding(utf8)');
  use DBI qw(:sql_types);
  use Data::Dumper;

  sub new {
    my($class, $conf, $log) = @_;
    my $self = bless {	'error' => 1,
						'log' => $log,
						'sql' => $conf->get_conf('sql'),
						'DEBUG' => undef,
	}, $class;

    $self->set_con();

    return $self;
  }
 
  sub set_con {
    my($self) = @_; # ссылка на объект
	$self->{dsn} = "Driver={ODBC Driver 13 for SQL Server};Server=$self->{sql}->{host};Database=$self->{sql}->{database};Trusted_Connection=yes" if $self->{sql}->{type} eq "mssql";
  }

  sub conn {
	my($self) = @_; # ссылка на объект
	eval{ $self->{dbh} = DBI->connect("dbi:ODBC:$self->{dsn}") || die "$DBI::errstr" if $self->{sql}->{type} eq "mssql";
		  $self->{dbh}->{LongReadLen} = 512 * 1024 || die "$DBI::errstr"; # We are interested in the first 512 KB of data
		  $self->{dbh}->{LongTruncOk} = 1 || die "$DBI::errstr"; # We're happy to truncate any excess
#          $self->{dbh}->{RaiseError} = 0 || die "$DBI::errstr"; # при 1 eval игнорируется, для диагностики полезно
	};# обработка ошибки
	if ($@) { $self->{log}->save('e', "$@"); $self->{error} = 1; } else { $self->{error} = 0; }
  }

  sub get {
    my($self, $name) = @_;
    return $self->{sql}->{$name};
  }

  sub set {
    my($self, %set) = @_;
	foreach my $key ( keys %set ) {
        $self->{sql}->{$key} = $set{$key};
    }
  }

  sub debug {
    my($self, $debug) = @_;
    $self->{'DEBUG'} = $debug;
  }

  sub get_error {
	my($self) = @_; # ссылка на объект
	return $self->{error};
  }

  sub get_scheduler {
	my($self) = @_;
	my($sth, $ref, $query, %values);

	$self->conn() if ( $self->{error} == 1 or ! $self->{dbh}->ping );

	$query = "SELECT *, datediff(s, '1970', getdate()) as [current_timestamp] FROM [$self->{sql}->{database}]..$self->{sql}->{table} with(nolock) ";

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

	$self->{log}->save('d', "\n".Dumper(\%values)."\n") if $self->{'DEBUG'};
	
	return(\%values);
  }

  sub save {
	my($self, $id, $query) = @_;
	my($sth, $ref, $error_message);

	local $SIG{'STOP'} = sub { 
#								$self->{log}->save('d', "start | $id");
								$self->up($id);
								#$sth->cancel;
#								$self->{log}->save('d', "stop | $id");
								threads->exit();
	};
	
	$self->status_up(1, $id, 0);
	
	$self->conn() if ( $self->{error} == 1 or ! $self->{dbh}->ping );

	$self->{log}->save('d', "sql save query: $query") if $self->{'DEBUG'};
	my $count = 0;

	LOOP: while (1) {
        eval{ $self->{dbh}->{RaiseError} = 1;
			  # if not autocommit error if execute to linked server oracle
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
			  #$self->{log}->save('e', "$DBI::errstr");
			  $error_message = "$DBI::errstr";
			  $self->{log}->save('e', "the task execution id: $id");
			  $self->{log}->save('e', "$error_message");
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

	$query = "update [$self->{sql}->{database}]..$self->{sql}->{table} set ";
	if ($self->{error} == 1){
		$query .= "status = -9999 ";
		$error_message =~ s/'/''/g;
		$query .= ", error = '$error_message' ";
	} else {
		$query .= "status = 1 ";
		$query .= ", error = '' ";
	}
	$query .= ", duration = datediff(s, dateadd(s, [timestamp], '1970'), getdate()) ";
	$query .= "where id = $id ";

	$self->{log}->save('d', "sql save update $query: $query") if $self->{'DEBUG'};

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
    my($self, $timestamp_up, $id, $status) = @_; # ссылка на объект

    my($sth, $ref, $query);

    $self->conn() if ( $self->{error} == 1 or ! $self->{dbh}->ping );

    $query  = "UPDATE [$self->{sql}->{database}]..$self->{sql}->{table} SET status = ? ";
	if ( $timestamp_up eq 1 ) {
		$query .= ", timestamp = datediff(s, '1970', getdate()) ";
		$query .= "where id = ? ";
	}
	
    eval{ $self->{dbh}->{RaiseError} = 1;
#	      $self->{dbh}->{AutoCommit} = 0;
		  $sth = $self->{dbh}->prepare($query) || die "$DBI::errstr";
		  if ( $timestamp_up eq 1 ) {
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

  my $DEBUG = $conf->get_conf('app')->{'debug'};

  #close(STDERR); #close error to console

  local $SIG{'INT'} = $SIG{'TERM'} = $SIG{'KILL'} = sub { $log->save('i', $log->get_name ." stop"); exit; };

  { # --| main loop
	my (%threads, $id, @kill_id);
	
	$log->save('i', $log->get_name ." start");

	# mssql create object
	my $mssql = sql->new($conf, $log);
	$mssql->debug($DEBUG);

	while(1) {
		my $values = $mssql->get_scheduler;
		#print  Dumper(sort {$a <=> $b} keys %values);

		for my $id ( sort {$a <=> $b} keys %{$values} ) {
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

			$log->save('d', "execute: ".$values->{$id}->{'execute'}) if $DEBUG;

			if( $values->{$id}->{'current_timestamp'} > $values->{$id}->{'timestamp'}+$values->{$id}->{'interval'}
					and $values->{$id}->{'enable'} == 1 and $values->{$id}->{'status'} != 0 ) {
				$log->save('d', "start scheduler | $values->{$id}->{'current_timestamp'} | $id") if $DEBUG;
				threads->yield();
				$threads{$id} = threads->create(\&child, $id, $values->{$id}->{'execute'}, $conf, $log);
			}

			if ( $values->{$id}->{'enable'} == 0 and $values->{$id}->{'status'} == 0 ) { push @kill_id, $id; };
			
			#$log->save('w', "id: $id  $threads{$id}") if ( ! grep { $_ eq $id } keys %threads );
			
			# update if it hovers status 600 = 10 min
			if ( $values->{$id}->{'enable'} == 1 and $values->{$id}->{'status'} == 0
				 and ( ! grep { $_ eq $id } keys %threads ) ) {
				$mssql->status_up(0, $id, 1);
				$log->save('w', "the task $id hovered");
			};
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
		undef($values);
		splice(@kill_id);
		select undef, undef, undef, $conf->get_conf('app')->{'cycle'} || 1;
	}
  } # --| main loop


sub child {
	$0 =~ m/.*[\/\\]/g;
	my ($id, $execute, $conf, $log) = @_;

	# mssql create object
	my $mssql = sql->new($conf, $log);
	$mssql->debug($DEBUG);

	$log->save('d', "child thread id: ". $id) if $DEBUG;

	threads->yield();

	$mssql->save($id, $execute);
	
	$mssql = undef;
	
	threads->exit();
}

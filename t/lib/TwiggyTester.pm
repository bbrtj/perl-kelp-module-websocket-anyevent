package TwiggyTester;

use strict;
use warnings;
use Exporter qw(import);
use Test::More;
use Test::TCP;
use Plack::Loader;
use AnyEvent::WebSocket::Client;
use AnyEvent;
use Try::Tiny;

our @EXPORT = qw(twiggy_test);

sub twiggy_test
{
	my ($app, $messages_ref, $expected_results_ref) = @_;
	my @messages = @{$messages_ref};
	my @results;

	my $condvar = AE::cv;

	my $server = Test::TCP->new(
		code => sub {
			my ($port) = @_;

			my $server = Plack::Loader->load('Twiggy', port => $port, host => "127.0.0.1");
			$server->run($app->run_all);
		},
	);

	my $client = AnyEvent::WebSocket::Client->new;
	my $this_connection;
	$client->connect("ws://127.0.0.1:" . $server->port . "/ws")->cb(
		sub {
			my $arg = shift;
			my $err;
			try {
				$this_connection = $arg->recv
			} catch {
				my $err = $_;
				fail $err;
			};

			return if $err;

			$this_connection->on(
				each_message => sub {
					my ($connection, $message) = @_;
					push @results, $message->{body};

					if (@messages) {
						$connection->send(shift @messages)
					} else {
						$connection->close;
						note "Closing connection";
						$condvar->send;
					}
				}
			);

			my $first_message = shift @messages;
			$this_connection->send($first_message)
				if defined $first_message;
		}
	);

	my $w = AE::timer 5, 0, sub {
		fail "event loop was not stopped";
		$condvar->send;
	};

	$condvar->recv;
	undef $w;

	is scalar @messages, 0, 'all messages sent ok';
	is scalar @results, scalar @{$expected_results_ref}, 'results count ok';
	for my $data (@{$expected_results_ref}) {
		my $result = shift @results;
		if (ref $data eq 'Regexp') {
			like $result, $data, 'message like ok';
		}
		else {
			is $result, $data, 'message is ok';
		}
	}

	return $server;
}

1;

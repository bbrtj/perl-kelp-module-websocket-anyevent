package WebSocketTest;

use strict;
use warnings;
use parent 'Kelp';

sub build {
	my $self = shift;
	my $closed;

	my $r = $self->routes;
	my $ws = $self->websocket;

	$r->add("/kelp" => sub {
		"kelp still there";
	});

	$r->add("/closed" => sub {
		$closed ? "yes" : "no";
	});

	$ws->add(open => sub { shift->send("opened") })
		unless $self->mode eq 'serializer_json';

	$ws->add(
		message => sub {
			my ($conn, $message) = @_;
			if (ref $message eq ref {}) {
				$conn->send({got => $message});
			}
			else {
				$message = $self->json->encode($message);
				$conn->send("got message: $message");
			}
		}
	);

	$ws->add(
		malformed_message => sub {
			my ($conn, $message, $err) = @_;
			$conn->send({error => $err, message => $message});
		}
	);

	$ws->add(
		close => sub {
			$closed = 1;
		}
	);

	$self->symbiosis->mount("/ws", $ws);
}

1;

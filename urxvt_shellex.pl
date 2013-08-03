#line 3
use Data::Dumper;
use X11::Protocol;

sub get_outputs {
    my @outputs = ();
    for my $line (qx(xrandr -q)) {
        next unless $line =~ /\sconnected/;
        my ($w, $h, $x, $y) = ($line =~ /(\d+)x(\d+)\+(\d+)\+(\d+)/);
        push @outputs, { w => $w, h => $h, x => $x, y => $y };
    }
    return @outputs;
}

sub geometry_from_ptr {
    my ($self) = @_;

    my @outputs = get_outputs();

    my $X = X11::Protocol->new($self->display_id);
    my $ptr = { $X->QueryPointer($self->DefaultRootWindow) };

    for my $output (@outputs) {
        if ($output->{x} <= $ptr->{root_x} && $ptr->{root_x} < $output->{x} + $output->{w}) {
            $self->{x} = $output->{x};
            $self->{y} = $output->{y};
            $self->{w} = $output->{w};
            $self->{h} = $output->{h};
        }
    }
}

sub geometry_from_focus {
    my ($self) = @_;

    my @outputs = get_outputs();

    my $X = X11::Protocol->new($self->display_id);
    my ($focus, $revert) = $X->GetInputFocus();

    my $geom = { $X->GetGeometry($focus) };
    my ($fw, $fh) = ($geom->{width}, $geom->{height});
    my (undef, undef, $fx, $fy) = $X->TranslateCoordinates($focus, $self->DefaultRootWindow, 0, 0);

    my $intersection = sub {
        my ($x, $y, $w, $h) = @_;
        my $dx = $x + $w - $fx;
        $dx = $dx > 0 ? $dx : 0;
        $dx = $dx > $fw ? $fw : $dx;

        my $dy = $y + $h - $fy;
        $dy = $dy > 0 ? $dy : 0;
        $dy = $dy > $fh ? $fh : $dy;

        return $dx * $dy;
    };

    my $max_area = 0;
    for my $output (@outputs) {
        my $area = $intersection->($output->{x}, $output->{y}, $output->{w}, $output->{h});
        if ($area >= $max_area) {
            $max_area = $area;
            $self->{x} = $output->{x};
            $self->{y} = $output->{y};
            $self->{w} = $output->{w};
            $self->{h} = $output->{h};
        }
    }
}

sub on_init {
    my ($self) = @_;

    $self->{x} = 0;
    $self->{y} = 0;
    $self->{w} = 1024;
    $self->{h} = 768;

    ();
}

sub on_start {
    my ($self) = @_;

    if ($self->x_resource("%.pos") eq 'pointer') {
        print "Getting shellex-position from pointer\n";
        $self->geometry_from_ptr();
    } else {
        print "Getting shellex-position from focused window\n";
        $self->geometry_from_focus();
    }
    $ENV{SHELLEX_MAX_HEIGHT} = int($self->{h} / $self->fheight);

    $self->XMoveResizeWindow($self->parent, $self->{x}, $self->{y}, $self->{w}, 2+$self->fheight);
    ();
}

sub on_line_update {
    my ($self, $row) = @_;
    print "line_update(row = $row)\n";

    ();
}

my $grow = 1;
sub on_add_lines {
    my ($self, $string) = @_;
    my $str = $string;
    $str =~ s/\n/\\n/g;
    $str =~ s/\r/\\r/g;
    print "add_lines(string = \"$str\")\n";

    my $nl = ($string =~ tr/\n//);
    if ($nl > 0 && $grow) {
        $grow = 0;
        my $nrow = $self->nrow + $nl;
        $self->cmd_parse("\e[8;${nrow};t");
    }
    ();
}

sub on_size_change {
    my ($self, $nw, $nh) = @_;
    print "size_change($nw, $nh)\n";
    ();
}

sub on_view_change {
    my ($self, $offset) = @_;
    print "view_change(offset = $offset)\n";
    ();
}

sub on_scroll_back {
    my ($term, $lines, $saved) = @_;
    print "scroll_back(lines = $lines, saved = $saved)\n";
    ();
}

sub on_map_notify {
    my ($self, $ev) = @_;
    $self->grab($self->{data}{event}{time}, 1);
    $self->allow_events_async;
    $self->focus_in;
    ();
}

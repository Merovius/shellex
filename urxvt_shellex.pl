#line 3
use X11::Protocol;

# The existing Randr-modules on CPAN seem to work only barely, so instead we
# just parse the output of xrandr -q. This is an uglyness, that should go away
# some time in the feature.
sub get_outputs {
    my @outputs = ();
    for my $line (qx(xrandr -q)) {
        next unless $line =~ /\sconnected/;
        my ($w, $h, $x, $y) = ($line =~ /(\d+)x(\d+)\+(\d+)\+(\d+)/);
        push @outputs, { w => $w, h => $h, x => $x, y => $y };
    }
    return @outputs;
}

# This takes a list of outputs and looks up the one, the mouse pointer
# currently is on.
sub geometry_from_ptr {
    my ($self) = @_;

    my @outputs = get_outputs();

    my $ptr = { $self->{X}->QueryPointer($self->DefaultRootWindow) };

    for my $output (@outputs) {
        if ($output->{x} <= $ptr->{root_x} && $ptr->{root_x} < $output->{x} + $output->{w}) {
            $self->{x} = $output->{x};
            if ($self->{bottom}) {
                # The real y-coordinate will change during execution, when the window grows
                $self->{y} = $output->{y} + $output->{h};
            } else {
                $self->{y} = $output->{y};
            }
            $self->{y} = $output->{y};
            $self->{w} = $output->{w};
            $self->{h} = $output->{h};
        }
    }
}

# This takes a list of outputs and looks up the one, that contains most of the
# window having the input focus currently
sub geometry_from_focus {
    my ($self) = @_;

    my @outputs = get_outputs();

    # Look up the window that currently has the input focus
    my ($focus, $revert) = $self->{X}->GetInputFocus();
    my $geom = { $self->{X}->GetGeometry($focus) };
    my ($fw, $fh) = ($geom->{width}, $geom->{height});
    # The (x,y) coordinates we get are relative to the parent not the
    # root-window. So we just translate the coordinates of the upper-left
    # corner into the coordinate-system of the root-window
    my (undef, undef, $fx, $fy) = $self->{X}->TranslateCoordinates($focus, $self->DefaultRootWindow, 0, 0);

    # Returns the area (in pixel²) of the intersection of two rectangles.
    # To understand how it works, best draw a picture.
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
            if ($self->{bottom}) {
                # The real y-coordinate will change during execution, when the window grows
                $self->{y} = $output->{y} + $output->{h};
            } else {
                $self->{y} = $output->{y};
            }
            $self->{w} = $output->{w};
            $self->{h} = $output->{h};
        }
    }
}

# This hook is run when the extension is first initialized, before any windows
# are created or mapped. There is not much work we can do here.
sub on_init {
    my ($self) = @_;

    $self->{X} = X11::Protocol->new($self->display_id);

    # Some reasonably sane values in case all our methods to determine a
    # geometry fails.
    $self->{x} = 0;
    $self->{y} = 0;
    $self->{w} = 1024;
    $self->{h} = 768;

    ();
}

# This hook is run after the window is created, but before it is mapped, so
# this is the place to set the geometry to what we want
sub on_start {
    my ($self) = @_;

    if ($self->x_resource("%.edge") eq 'bottom') {
        print "position should be at the bottom";
        $self->{bottom} = 1;
        $self->{y} = $self->{h};
    } else {
        print "position should be at the top";
    }

    if ($self->x_resource("%.pos") eq 'pointer') {
        print "Getting shellex-position from pointer\n";
        $self->geometry_from_ptr();
    } else {
        print "Getting shellex-position from focused window\n";
        $self->geometry_from_focus();
    }

    # This environment variable is used by the LD_PRELOAD ioctl-override to
    # determine the values to send to the shell
    $ENV{SHELLEX_MAX_HEIGHT} = int($self->{h} / $self->fheight);

    # Our initial position is different, if we have to be at the bottom
    if ($self->{bottom}) {
        $self->XMoveResizeWindow($self->parent, $self->{x}, $self->{y} - (2 + $self->fheight), $self->{w}, 2+$self->fheight);
    } else {
        $self->XMoveResizeWindow($self->parent, $self->{x}, $self->{y}, $self->{w}, 2+$self->fheight);
    }
    ();
}

# This hook is run every time a line was changed. We do some resizing here,
# because this catches most cases where we would want to shrink our window.
sub on_line_update {
    my ($self, $row) = @_;
    print "line_update(row = $row)\n";

    # Determine the last row, that is not empty.
    # TODO: Does this work as intended, if there is an empty line in the
    # middle?
    my $nrow = 0;
    for my $i ($self->top_row .. $self->nrow-1) {
        if ($self->ROW_l($i) > 0) {
            print "row $i is " . $self->ROW_l($i) . "\n";
            $nrow++;
        }
    }
    $nrow = $nrow > 0 ? $nrow : 1;
    print "resizing to $nrow\n";

    # If the window is supposed to be at the bottom, we have to move the
    # window up a little bit
    my $y = $self->{y};
    if ($self->{bottom}) {
        $y -= 2+$nrow*$self->fheight;
    }
    $self->cmd_parse("\e[8;$nrow;t\e[3;$self->{x};${y}t");
    ();
}

# This hook is run every time before there is text output. We resize here,
# immediately before new lines would be added, which would create scrolling
sub on_add_lines {
    my ($self, $string) = @_;
    my $str = $string;
    $str =~ s/\n/\\n/g;
    $str =~ s/\r/\\r/g;
    print "add_lines(string = \"$str\")\n";

    my $nl = ($string =~ tr/\n//);
    if ($nl > 0) {
        my $nrow = 0;
        for my $i ($self->top_row .. $self->nrow-1) {
            if ($self->ROW_l($i) > 0) {
                print "row $i is " . $self->ROW_l($i) . "\n";
                $nrow++;
            }
        }
        $nrow = $nrow > 0 ? $nrow : 1;
        print "resizing to $nrow + $nl\n";
        $nrow += $nl;

        # If the window is supposed to be at the bottom, we have to move the
        # window up a little bit
        my $y = $self->{y};
        if ($self->{bottom}) {
            $y -= 2+$nrow*$self->fheight;
        }
        $self->cmd_parse("\e[8;$nrow;t\e[3;$self->{x};${y}t");
    }
    ();
}

# Just for debugging
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
    my ($self, $lines, $saved) = @_;
    print "scroll_back(lines = $lines, saved = $saved)\n";
    ();
}

# This hook is run directly after the window was mapped (= displayed on
# screen). We grab the keyboard here.
sub on_map_notify {
    my ($self, $ev) = @_;
    $self->grab($self->{data}{event}{time}, 1);
    $self->allow_events_async;
    $self->focus_in;
    ();
}

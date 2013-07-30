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

sub on_init {
    my ($self) = @_;
    my @outputs = get_outputs();

    my $X = X11::Protocol->new($self->display_id);
    my $ptr = { $X->QueryPointer($self->DefaultRootWindow) };

    $self->{x} = 0;
    $self->{y} = 0;
    $self->{w} = 1024;
    for my $output (@outputs) {
        if ($output->{x} <= $ptr->{root_x} && $ptr->{root_x} < $output->{x} + $output->{w}) {
            $self->{x} = $output->{x};
            $self->{y} = $output->{y};
            $self->{w} = $output->{w};
        }
    }

    ();
}

sub on_start {
    my ($self) = @_;
    $self->XMoveResizeWindow($self->parent, $self->{x}, $self->{y}, $self->{w}, 2+$self->fheight);
    ();
}

sub on_line_update {
    my ($self, $row) = @_;
    ();
}

sub on_add_lines {
    my ($self, $string) = @_;
    if ($string =~ /\n/g) {
        $self->XMoveResizeWindow($self->parent, 0, 0, 1440, $self->height + $self->fheight);
    }
    ();
}

sub on_view_change {
    my ($self, $offset) = @_;
    ();
}

sub on_scroll_back {
    my ($term, $lines, $saved) = @_;
    ();
}

sub on_map_notify {
    my ($self, $ev) = @_;
    $self->grab($self->{data}{event}{time}, 1);
    $self->allow_events_async;
    $self->focus_in;
    ();
}

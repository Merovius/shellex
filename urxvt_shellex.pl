use Data::Dumper;

sub on_init {
    my ($self) = @_;
    ();
}

sub on_start {
    my ($self) = @_;
    $self->XMoveResizeWindow($self->parent, 0, 0, 1440, 2+$self->fheight);
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

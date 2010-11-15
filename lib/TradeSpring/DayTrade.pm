package TradeSpring::DayTrade;
use Moose::Role;
use Method::Signatures::Simple;

requires 'highest_high';

has day_high => (is => "rw");
has day_low => (is => "rw");

has dstart => (is => "rw", isa => "Int");

has dframe => (
    is => "rw",
    isa => "TradeSpring::Frame",
    lazy_build => 1
);

has current_date => (is => "rw", isa => "DateTime");

method _build_dframe {
    TradeSpring::Frame->new( calc => $self->dcalc );
}

before run => method {
    if ($self->is_dstart) {
        $self->dstart($self->i);
        $self->day_high( $self->highest_high );
        $self->day_low(  $self->lowest_low );
        if ($self->meta->find_attribute_by_name('dcalc') && $self->i > 0) {
            my ($last_day) = $self->date($self->i-1) =~ m/^([\d-]+)/;

            $self->dframe->i( $self->dcalc->prices->date($last_day) );
            my $date = $self->date;
            my ($y, $m, $d) = split(/[-\s]/, $date);
            $self->current_date(DateTime->new(year => $y, month => $m, day => $d));
        }
    }

    if (defined $self->day_high) {
        $self->day_high->test($self->i);
        $self->day_low->test($self->i);
    }
    else {
        warn "WTF?";
    }
};

1;
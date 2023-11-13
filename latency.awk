#!/usr/bin/env gawk -E

BEGIN {
    MONTH["Jan"] = "01";
    MONTH["Feb"] = "02";
    MONTH["Mar"] = "03";
    MONTH["Apr"] = "04";
    MONTH["May"] = "05";
    MONTH["Jun"] = "06";
    MONTH["Jul"] = "07";
    MONTH["Aug"] = "08";
    MONTH["Sep"] = "09";
    MONTH["Oct"] = "10";
    MONTH["Nov"] = "11";
    MONTH["Dec"] = "12";

    previous = "";
    current = "";
    reset();
    gnuplot = "gnuplot";
#    gnuplot = "cat";

    print "set term sixelgd size 1280,360" | gnuplot;
    print "set xdata time" | gnuplot;
    print "set timefmt \"%Y-%m-%dT%H:%M\"" | gnuplot;
    print "set xtics format \"%H\"" | gnuplot;
    print "set ytics (\"0\" 0,\"1\" 1,\"2\" 2,\"3\" 3,\"4\" 4,\"5\" 5,\"6\" 6,\"7\" 7,\"8\" 8,\"9\" 9,\"10\" 10,\"15\" 11,\"20\" 12,\"25\" 13,\"30\" 14,\"40\" 15,\">40\" 16, \"∞\" 17)" | gnuplot;
    print "set cbtics (\"1\" 0, \"10\" 1, \"100\" 2, \"1k\" 3, \"10k\" 4, \"100k\" 5, \"1M\" 6, \"10M\" 7, \"100M\" 8)" | gnuplot;
    print "set pm3d map" | gnuplot;
    print "splot \"-\" using 1:2:3 with image" | gnuplot;
}


{
    current = timestampbucket($0);
    if (previous != "" && previous != current) {
        dump();
        reset();
    }
    hist[latencybucket($NF)]++;
    previous = current;
}


END {
    if (current != "" && previous != current) {
        dump();
    }
    print "e" | gnuplot;
    close(gnuplot);
}


function reset(     i) {
    for (i = 0; i <= 16; i++) {
        hist[i] = 0;
    }
    current = "";
}

function dump(      i, v) {
    for (i = 0; i <= 16; i++) {
        v = hist[i];
        if (v > 0) {
            v = log(v) / log(10);
        }
        printf "%s\t%d\t%f\n", current, i, v | gnuplot;
    }
    printf "%s\t17\t0\n\n", current | gnuplot;
}



# [09/Nov/2023:20:16:59 +0000]
function timestampbucket(line,     a) {
    match(line, /\[([0-9][0-9])\/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\/([0-9][0-9][0-9][0-9]):([0-9][0-9]):([0-9][0-9]):([0-9][0-9]) \+0000\]/, a);
    return a[3] "-" MONTH[a[2]] "-" a[1] "T" a[4] ":" a[5];
}


function latencybucket(time) {

    if (time == 0) {
        return 0;
    }
    if (time <= 1000) {
        return 1;
    }
    if (time <= 2000) {
        return 2;
    }
    if (time <= 3000) {
        return 3;
    }
    if (time <= 4000) {
        return 4;
    }
    if (time <= 5000) {
        return 5;
    }
    if (time <= 6000) {
        return 6;
    }
    if (time <= 7000) {
        return 7;
    }
    if (time <= 8000) {
        return 8;
    }
    if (time <= 9000) {
        return 9;
    }
    if (time <= 10000) {
        return 10;
    }
    if (time <= 15000) {
        return 11;
    }
    if (time <= 20000) {
        return 12;
    }
    if (time <= 25000) {
        return 13;
    }
    if (time <= 30000) {
        return 14;
    }
    if (time <= 40000) {
        return 15;
    }
    return 16;
}

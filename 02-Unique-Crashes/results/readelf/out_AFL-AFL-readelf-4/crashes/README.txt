Command line used to find this crash:

/workdir/MemLock/tool/AFL-2.52b/build/bin/afl-fuzz -i /workdir/MemLock/evaluation/BUILD/readelf/SEED/ -o out_AFL-AFL-readelf-4 -m none -d -t 5000 -- /workdir/MemLock/evaluation/BUILD/readelf/SRC_AFL/build/bin/readelf -a @@

If you can't reproduce a bug outside of afl-fuzz, be sure to set the same
memory limit. The limit used for this fuzzing session was 0 B.

Need a tool to minimize test cases before investigating the crashes or sending
them to a vendor? Check out the afl-tmin that comes with the fuzzer!

Found any cool bugs in open-source tools using afl-fuzz? If yes, please drop
me a mail at <lcamtuf@coredump.cx> once the issues are fixed - I'd love to
add your finds to the gallery at:

  http://lcamtuf.coredump.cx/afl/

Thanks :-)

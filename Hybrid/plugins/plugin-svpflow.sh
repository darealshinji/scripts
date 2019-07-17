mkdir build
cd build
wget -O svpflow.zip https://www.svp-team.com/files/gpl/svpflow-4.2.0.142.zip
unzip -j svpflow.zip
mv libsvpflow1_vs64.so libsvpflow1.so
mv libsvpflow2_vs64.so libsvpflow2.so
strip_copy libsvpflow1.so
finish libsvpflow2.so

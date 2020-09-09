#!/bin/bash -x

INPUT=$1
ENTITLEMENTS=$2

# zip app
chmod -R a-st $INPUT
zip -r -q unsigned.zip $INPUT
rm -rf $INPUT

# copy zip to storage server
scp unsigned.zip genie.theia@projects-storage.eclipse.org:./unsigned.zip

# copy entitlements to storage server
scp $ENTITLEMENTS genie.theia@projects-storage.eclipse.org:./entitlements.plist

# sign over ssh
ssh -q genie.theia@projects-storage.eclipse.org curl -o signed.zip -F file=@unsigned.zip -F entitlements=@entitlements.plist http://build.eclipse.org:31338/macsign.php
ssh -q genie.theia@projects-storage.eclipse.org cat signed.zip
ssh -q genie.theia@projects-storage.eclipse.org du -h signed.zip
ssh -q genie.theia@projects-storage.eclipse.org stat signed.zip

# copy signed app back from server
scp genie.theia@projects-storage.eclipse.org:./signed.zip ./signed.zip

cat signed.zip
du -h signed.zip
stat signed.zip

# unzip app
unzip -qq signed.zip
rm -f unsigned.zip signed.zip

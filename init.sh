#!/bin/sh

version=`git branch --contains | cut -d " " -f 2`
sed -ie "s/#__version__#/$version/" /workspace/exastro-it-automation-docs.code-workspace

if [ -f /tmp/install_talisman.bash ]; then
  bash /tmp/install_talisman.bash
fi

#!/bin/sh

if [ -z "$sphinx_port" ]; then
  sp_port=8000
else
  sp_port=$sphinx_port
fi
echo ${sp_port}"port process kill."
lsof -i :$sp_port | grep -c $sp_port && kill -9 `lsof -i :$sp_port|grep $sp_port|awk '{print $2}'`

version=`git branch --contains | cut -d " " -f 2`
sed "s/#__version__#/$version/" template.code-workspace > /workspace/exastro-it-automation-docs.code-workspace

# make html-all

echo "start sphinx_autobuild."
python -msphinx_autobuild /workspace/src/dummy /workspace/docs/ --port=$sp_port &
python -msphinx_autobuild /workspace/src/en/${version} /workspace/docs/en/${version} --port=0 &
python -msphinx_autobuild /workspace/src/ja/${version} /workspace/docs/ja/${version} --port=0
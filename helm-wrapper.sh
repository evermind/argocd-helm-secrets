#!/bin/sh

# import all keys found in dir
GPG_IMPORT_DIR='/home/argocd/gpg'
GPG_MODE=false

# only for debugging, remove it later on
LOGFILE=~/helmwrapper.log 

# do not write other informations than deployment yaml
export HELM_SECRETS_QUIET=true

if [ -d ${GPG_IMPORT_DIR} ] 
then
   echo "gpg import" >> $LOGFILE
   gpg --quiet --import ${GPG_IMPORT_DIR}/*
   if [ $? -eq 0 ]; then
      GPG_MODE=true
   fi
fi

echo "GPG_MODE is $GPG_MODE" >> $LOGFILE

# GPG_KEY='/home/argocd/gpg/gpg.asc'
# if [ -f ${GPG_KEY} ]
# then     
#     gpg --quiet --import ${GPG_KEY}
# fi

# helm secrets only supports a few helm commands
if [ $GPG_MODE = true ]
then
    echo "helm command is $1" >> $LOGFILE
    if  [ $1 = "template" ] || [ $1 = "install" ] || [ $1 = "upgrade" ] || [ $1 = "lint" ] || [ $1 = "diff" ] 
    then 
        # Helm secrets add some useless outputs to every commands including template, namely
        # 'remove: <secret-path>.dec' for every decoded secrets.
        # As argocd use helm template output to compute the resources to apply, these outputs
        # will cause a parsing error from argocd, so we need to remove them.
        # We cannot use exec here as we need to pipe the output so we call helm in a subprocess and
        # handle the return code ourselves.
        echo "call helm secrets" >> $LOGFILE
        out=$(helm.bin secrets $@)
        echo "$out" >> $LOGFILE
        code=$?
        echo "exit code is $code" >> $LOGFILE
        if [ $code -eq 0 ]; then
            # printf insted of echo here because we really don't want any backslash character processing
            printf '%s\n' "$out" | sed -E "/^removed '.+\.dec'$/d"      
            exit 0
        else
            exit $code
        fi
    else
        # helm.bin is the original helm binary
        echo "unsupported helm command -> call helm.bin" >> $LOGFILE
        exec helm.bin $@
    fi
else
    echo "GPG_MODE false -> call helm.bin" >> $LOGFILE
    # helm.bin is the original helm binary
    exec helm.bin $@
fi

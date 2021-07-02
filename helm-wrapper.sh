#!/bin/sh

# import all keys found in dir
GPG_IMPORT_DIR='/home/argocd/gpg'
GPG_MODE=false

HELM_SECRETS_VERSION=v3.8.1
# define plugin dir explict otherwise argo use a kind of temp env, where plugin get lost after finish process
export HELM_PLUGINS=/home/argocd/.local/share/helm/plugins

# only for debugging, remove it later on
LOGFILE=/home/argocd/helmwrapper.log 

# do not write other informations than deployment yaml
export HELM_SECRETS_QUIET=true

echo "before gpg check ls /home/argocd\n" >> $LOGFILE
ls -al /home/argocd >> $LOGFILE

if [ -d ${GPG_IMPORT_DIR} ] 
then
   echo "gpg import" >> $LOGFILE
   gpg --quiet --import ${GPG_IMPORT_DIR}/*
   if [ $? -eq 0 ]; then
      GPG_MODE=true
   fi
fi

echo "GPG_MODE is $GPG_MODE" >> $LOGFILE

echo "after gpg check ls /home/argocd\n" >> $LOGFILE
ls -al /home/argocd >> $LOGFILE

# install plugin and ignore error on alread installed plugin
echo "plugin install env" >> $LOGFILE 2>&1
helm.bin env >> $LOGFILE 2>&1
helm.bin plugin list >> $LOGFILE 2>&1
# out=$(helm.bin plugin install https://github.com/jkroepke/helm-secrets --version $HELM_SECRETS_VERSION >> $LOGFILE 2>&1)
# code=$?
# echo "plugin install error code $code" >> $LOGFILE 2>&1


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
        echo "call helm.bin secrets $@" >> $LOGFILE 2>&1
        out=$(helm.bin secrets $@ 2>&1)
        echo "--- beginn helm output" >> $LOGFILE
        echo "$out" >> $LOGFILE
        echo "--- end helm output" >> $LOGFILE
        code=$?
        echo "exit code is $code" >> $LOGFILE
        if [ $code -eq 0 ]; then
            # printf insted of echo here because we really don't want any backslash character processing
            # printf '%s\n' "$out" | sed -E "/^removed '.+\.dec'$/d"
            # since HELM_SECRETS_QUIET=true the hack above should not be needed anymore
            printf '%s\n' "$out"
            echo "printf and exit 0" >> $LOGFILE
            exit 0
        else
            exit $code
        fi
    else
        # helm.bin is the original helm binary
        echo "unsupported helm command -> call helm.bin $@" >> $LOGFILE
        exec helm.bin $@
    fi
else
    echo "GPG_MODE false -> call helm.bin $@" >> $LOGFILE
    # helm.bin is the original helm binary
    exec helm.bin $@
fi

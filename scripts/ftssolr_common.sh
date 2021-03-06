source /usr/share/yunohost/helpers

install_ftssolr() {

    # Check domain/path availability
    sudo yunohost app checkport 8983
    if [[ ! $? -eq 0 ]]; then
        echo "The port 8983 used by the Solr server is already in use. Aborting..."
        exit 1
    fi

    # Install Solr, and the dovecot plugin
    ynh_package_update
    ynh_package_install dovecot-solr solr-jetty

    # Use the solr schema for dovecot coming with dovecot-solr
    sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.orig
    sudo ln -s /usr/share/dovecot/solr-schema.xml /etc/solr/conf/schema.xml

    # Drop the solr conf for dovecot to the dovecot conf extension folder
    sudo tee /etc/dovecot/yunohost.d/pre-ext.d > /dev/null << EOF
mail_plugins = $mail_plugins fts fts_solr
EOF
    sudo tee /etc/dovecot/yunohost.d/post-ext.d > /dev/null << EOF
plugin {
  fts = solr
  fts_solr = url=http://127.0.0.1:8983/solr/ break-imap-search
  fts_autoindex = yes
}  
EOF

    # Start jetty on startup
    sudo sed -i '/NO_START/c\NO_START=0' /etc/default/jetty8

    # Bind only to localhost:8983
    sudo sed -i '/JETTY_HOST/c\JETTY_HOST=127.0.0.1' /etc/default/jetty8
    sudo sed -i '/JETTY_PORT/c\JETTY_PORT=8983' /etc/default/jetty8

    # Install maintenance cron jobs
    sudo tee /etc/cron.d/fts-solr > /dev/null << EOF
MAILTO=root

# References :
#   http://wiki.dovecot.org/Plugins/FTS/Solr
#   http://wiki2.dovecot.org/Tools/Doveadm/FTS

# With v2.2.3+ Dovecot only does soft commits to the Solr index to improve performance.
# You must run a hard commit once in a while or Solr will keep increasing its transaction log sizes
10 *  * * * root  /usr/bin/curl http://127.0.0.1:8983/solr/update?commit=true &>/dev/null
# Solr indexes should be optimized once in a while to make searches faster and to remove space used by deleted mails.
47 03 * * * root  /usr/bin/curl http://127.0.0.1:8983/solr/update?optimize=true &>/dev/null

# If you require to force dovecot to reindex a whole mailbox you can run the command shown, 
#  this will only take action when a search is done and will apply to the whole mailbox
22 02 * * * root /usr/bin/doveadm fts rescan -A
EOF

  sudo service jetty8 start
  sudo service dovecot reload

}
